# Applies branded auth email templates from docs/email-templates/ to users and _superusers.
# Never hand-edit server/pb_migrations/ — PocketBase may auto-generate migrations from this PATCH.
#
# Usage (from repo root):
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\patch-email-templates.ps1 local
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\patch-email-templates.ps1 staging
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\patch-email-templates.ps1 prod

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

function Apply-AuthEmailTemplates {
  param(
    [string]$Base,
    [string]$Token,
    [string]$CollectionName,
    [bool]$ForceEnableOtp,
    [string]$OtpHtml,
    [string]$VerificationHtml,
    [string]$ResetHtml,
    [string]$ConfirmEmailHtml,
    [string]$AuthAlertHtml,
    [string]$PatchBodyPath
  )

  Write-Host "Fetching $CollectionName collection..."
  $colOut = curl.exe -s "$Base/api/collections/$CollectionName" -H "Authorization: $Token"
  $col = $colOut | ConvertFrom-Json
  if (-not $col.id) {
    throw "Failed to load $CollectionName collection: $colOut"
  }

  $otpDuration = 180
  if ($col.otp -and $col.otp.duration) { $otpDuration = [int]$col.otp.duration }
  $otpEnabled = $ForceEnableOtp
  if (-not $ForceEnableOtp -and $col.otp -and $null -ne $col.otp.enabled) {
    $otpEnabled = [bool]$col.otp.enabled
  }
  $otpLength = 6
  if (-not $ForceEnableOtp -and $col.otp -and $col.otp.length) {
    $otpLength = [int]$col.otp.length
  }

  $col.otp = [pscustomobject]@{
    enabled = $otpEnabled
    duration = $otpDuration
    length = $otpLength
    emailTemplate = [pscustomobject]@{
      subject = 'Your {APP_NAME} sign-in code'
      body = $OtpHtml
    }
  }

  $col.verificationTemplate = [pscustomobject]@{
    subject = 'Verify your {APP_NAME} email address'
    body = $VerificationHtml
  }
  $col.resetPasswordTemplate = [pscustomobject]@{
    subject = 'Reset your {APP_NAME} password'
    body = $ResetHtml
  }
  $col.confirmEmailChangeTemplate = [pscustomobject]@{
    subject = 'Confirm your new {APP_NAME} email address'
    body = $ConfirmEmailHtml
  }

  $alertEnabled = $true
  if ($col.authAlert -and $null -ne $col.authAlert.enabled -and -not $ForceEnableOtp) {
    $alertEnabled = [bool]$col.authAlert.enabled
  }
  if (-not $col.authAlert) {
    $col | Add-Member -NotePropertyName authAlert -NotePropertyValue ([pscustomobject]@{}) -Force
  }
  $col.authAlert.enabled = $alertEnabled
  $col.authAlert.emailTemplate = [pscustomobject]@{
    subject = 'New sign-in to your {APP_NAME} account'
    body = $AuthAlertHtml
  }

  $json = $col | ConvertTo-Json -Depth 40 -Compress
  [System.IO.File]::WriteAllText(
    $PatchBodyPath,
    $json,
    (New-Object System.Text.UTF8Encoding $false)
  )

  Write-Host "Patching $CollectionName auth email templates..."
  $patchOut = curl.exe -s -X PATCH "$Base/api/collections/$CollectionName" `
    -H "Authorization: $Token" `
    -H 'Content-Type: application/json' `
    --data-binary "@$PatchBodyPath"

  $patched = $patchOut | ConvertFrom-Json
  if (-not $patched.id) {
    throw "PATCH failed for $CollectionName : $patchOut"
  }

  Write-Host ("OK {0}: otp formal={1}, verify formal={2}, otp.enabled={3}" -f `
    $CollectionName, `
    ($patched.otp.emailTemplate.body -like '*02F268*'), `
    ($patched.verificationTemplate.body -like '*02F268*'), `
    $patched.otp.enabled)
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
$usersPatchPath = Join-Path $env:TEMP "pb_email_templates_users_$Target.json"
$superPatchPath = Join-Path $env:TEMP "pb_email_templates_super_$Target.json"

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

  Apply-AuthEmailTemplates `
    -Base $base -Token $token -CollectionName 'users' -ForceEnableOtp $true `
    -OtpHtml $otpHtml -VerificationHtml $verificationHtml -ResetHtml $resetHtml `
    -ConfirmEmailHtml $confirmEmailHtml -AuthAlertHtml $authAlertHtml `
    -PatchBodyPath $usersPatchPath

  # Superusers confirm verification in PocketBase Admin UI, not the Flutter app route.
  $superVerificationHtml = $verificationHtml.Replace(
    '{APP_URL}/confirm-verification/{TOKEN}',
    '{APP_URL}/_/#/auth/confirm-verification/{TOKEN}'
  )

  Apply-AuthEmailTemplates `
    -Base $base -Token $token -CollectionName '_superusers' -ForceEnableOtp $false `
    -OtpHtml $otpHtml -VerificationHtml $superVerificationHtml -ResetHtml $resetHtml `
    -ConfirmEmailHtml $confirmEmailHtml -AuthAlertHtml $authAlertHtml `
    -PatchBodyPath $superPatchPath
}
finally {
  Remove-Item -ErrorAction SilentlyContinue $authBodyPath, $usersPatchPath, $superPatchPath
}
