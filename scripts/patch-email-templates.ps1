# Applies branded auth email templates from docs/email-templates/ to the users collection.
# Never hand-edit server/pb_migrations/ — PocketBase may auto-generate migrations from this PATCH.
#
# Usage (from repo root):
#   pwsh ./scripts/patch-email-templates.ps1 local
#   pwsh ./scripts/patch-email-templates.ps1 staging
#   pwsh ./scripts/patch-email-templates.ps1 prod

param(
  [Parameter(Mandatory = $true, Position = 0)]
  [ValidateSet('local', 'staging', 'prod')]
  [string]$Target
)

$ErrorActionPreference = 'Stop'

function Read-DotEnv([string]$path) {
  $map = @{}
  if (-not (Test-Path $path)) { return $map }
  Get-Content $path | ForEach-Object {
    if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
    $k, $v = $_ -split '=', 2
    $map[$k.Trim()] = $v.Trim().Trim('"').Trim("'")
  }
  return $map
}

function Read-TemplateHtml([string]$filePath) {
  if (-not (Test-Path $filePath)) {
    throw "Missing template file: $filePath"
  }
  return [System.IO.File]::ReadAllText($filePath).Trim()
}

$envMap = Read-DotEnv (Join-Path $PSScriptRoot '..\.env')
$templatesDir = Join-Path $PSScriptRoot '..\docs\email-templates'

switch ($Target) {
  'local' {
    $baseRaw = if ($envMap['PB_LOCAL_URL']) { $envMap['PB_LOCAL_URL'] } else { $envMap['LOCAL_API_URL'] }
    $email = if ($envMap['PB_LOCAL_EMAIL']) { $envMap['PB_LOCAL_EMAIL'] } else { $envMap['LOCAL_EMAIL'] }
    $pass = if ($envMap['PB_LOCAL_PASSWORD']) { $envMap['PB_LOCAL_PASSWORD'] } else { $envMap['LOCAL_PASSWORD'] }
  }
  'staging' {
    $baseRaw = if ($envMap['PB_STAGING_URL']) { $envMap['PB_STAGING_URL'] } else { $envMap['STAGING_URL'] }
    $email = if ($envMap['PB_STAGING_EMAIL']) { $envMap['PB_STAGING_EMAIL'] } else { $envMap['STAGING_EMAIL'] }
    $pass = if ($envMap['PB_STAGING_PASSWORD']) { $envMap['PB_STAGING_PASSWORD'] } else { $envMap['STAGING_PASSWORD'] }
  }
  'prod' {
    $baseRaw = if ($envMap['PB_PROD_URL']) { $envMap['PB_PROD_URL'] } else { $envMap['PROD_URL'] }
    $email = if ($envMap['PB_PROD_EMAIL']) { $envMap['PB_PROD_EMAIL'] } else { $envMap['PROD_EMAIL'] }
    $pass = if ($envMap['PB_PROD_PASSWORD']) { $envMap['PB_PROD_PASSWORD'] } else { $envMap['PROD_PASSWORD'] }
  }
}

$base = "$baseRaw".TrimEnd('/')
if (-not $base -or -not $email -or -not $pass) {
  throw "Missing PocketBase URL/email/password in .env for target '$Target'."
}

$otpHtml = Read-TemplateHtml (Join-Path $templatesDir 'otp.html')
$verificationHtml = Read-TemplateHtml (Join-Path $templatesDir 'verification.html')
$resetHtml = Read-TemplateHtml (Join-Path $templatesDir 'reset-password.html')
$confirmEmailHtml = Read-TemplateHtml (Join-Path $templatesDir 'confirm-email-change.html')
$authAlertHtml = Read-TemplateHtml (Join-Path $templatesDir 'auth-alert.html')

$authBodyPath = Join-Path $env:TEMP "pb_email_templates_auth_$Target.json"
$patchBodyPath = Join-Path $env:TEMP "pb_email_templates_patch_$Target.json"

[System.IO.File]::WriteAllText(
  $authBodyPath,
  (@{ identity = $email; password = $pass } | ConvertTo-Json -Compress),
  (New-Object System.Text.UTF8Encoding $false)
)

try {
  Write-Host "Authenticating against $base ($Target)..."
  $authOut = curl.exe -s -X POST "$base/api/collections/_superusers/auth-with-password" `
    -H 'Content-Type: application/json' `
    --data-binary "@$authBodyPath"
  $auth = $authOut | ConvertFrom-Json
  if (-not $auth.token) {
    throw "Auth failed for $Target : $authOut"
  }
  $token = $auth.token

  Write-Host 'Fetching users collection...'
  $usersOut = curl.exe -s "$base/api/collections/users" -H "Authorization: $token"
  $users = $usersOut | ConvertFrom-Json
  if (-not $users.id) {
    throw "Failed to load users collection: $usersOut"
  }

  # Merge OTP settings; keep duration if already set.
  $otpDuration = 180
  if ($users.otp -and $users.otp.duration) { $otpDuration = [int]$users.otp.duration }

  $users.otp = [pscustomobject]@{
    enabled = $true
    duration = $otpDuration
    length = 6
    emailTemplate = [pscustomobject]@{
      subject = 'Your {APP_NAME} login code'
      body = $otpHtml
    }
  }

  $users.verificationTemplate = [pscustomobject]@{
    subject = 'Verify your {APP_NAME} email'
    body = $verificationHtml
  }
  $users.resetPasswordTemplate = [pscustomobject]@{
    subject = 'Reset your {APP_NAME} password'
    body = $resetHtml
  }
  $users.confirmEmailChangeTemplate = [pscustomobject]@{
    subject = 'Confirm your new {APP_NAME} email'
    body = $confirmEmailHtml
  }

  if (-not $users.authAlert) {
    $users | Add-Member -NotePropertyName authAlert -NotePropertyValue ([pscustomobject]@{}) -Force
  }
  $users.authAlert.enabled = $true
  $users.authAlert.emailTemplate = [pscustomobject]@{
    subject = 'New login to your {APP_NAME} account'
    body = $authAlertHtml
  }

  $json = $users | ConvertTo-Json -Depth 40 -Compress
  [System.IO.File]::WriteAllText(
    $patchBodyPath,
    $json,
    (New-Object System.Text.UTF8Encoding $false)
  )

  Write-Host 'Patching users auth email templates...'
  $patchOut = curl.exe -s -X PATCH "$base/api/collections/users" `
    -H "Authorization: $token" `
    -H 'Content-Type: application/json' `
    --data-binary "@$patchBodyPath"

  $patched = $patchOut | ConvertFrom-Json
  if (-not $patched.id) {
    throw "PATCH failed for $Target : $patchOut"
  }

  $otpSubject = $patched.otp.emailTemplate.subject
  $verifySubject = $patched.verificationTemplate.subject
  Write-Host "OK ($Target): otp='$otpSubject', verification='$verifySubject', otp.length=$($patched.otp.length), otp.enabled=$($patched.otp.enabled)"
}
finally {
  Remove-Item -ErrorAction SilentlyContinue $authBodyPath, $patchBodyPath
}
