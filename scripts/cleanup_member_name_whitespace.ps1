# Formats members.name for consistent storage via the PocketBase Admin API.
# - Trims / collapses irregular whitespace ("CHLOE  SY" → "Chloe Sy")
# - Title-cases each word; capitalizes segments after . or -
# - Keeps Jr / Sr / II / III / IV / V suffixes
#
# Do NOT put this in server/pb_migrations — data cleanup is done via Admin API.
#
# Auth: PB_LOCAL_* or LOCAL_* from .env (superuser).
#
# Usage (from repo root):
#   powershell -File ./scripts/cleanup_member_name_whitespace.ps1           # apply
#   powershell -File ./scripts/cleanup_member_name_whitespace.ps1 -DryRun   # preview only

param(
  [switch]$DryRun
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

function Normalize-Whitespace([string]$value) {
  if ($null -eq $value) { return '' }
  return [regex]::Replace($value.Trim(), '\s+', ' ')
}

function Format-PersonNameWord([string]$word) {
  $upper = $word.ToUpperInvariant()
  switch ($upper) {
    'JR' { return 'Jr' }
    'JR.' { return 'Jr.' }
    'SR' { return 'Sr' }
    'SR.' { return 'Sr.' }
    'II' { return 'II' }
    'III' { return 'III' }
    'IV' { return 'IV' }
    'V' { return 'V' }
  }

  $parts = [regex]::Split($word, '([.\-])')
  $builder = New-Object System.Text.StringBuilder
  foreach ($part in $parts) {
    if ([string]::IsNullOrEmpty($part)) { continue }
    if ($part -eq '.' -or $part -eq '-') {
      [void]$builder.Append($part)
      continue
    }
    $capped = $part.Substring(0, 1).ToUpperInvariant() + $part.Substring(1).ToLowerInvariant()
    [void]$builder.Append($capped)
  }
  return $builder.ToString()
}

function Format-PersonName([string]$value) {
  $normalized = Normalize-Whitespace $value
  if ([string]::IsNullOrEmpty($normalized)) { return $normalized }
  $words = $normalized -split ' '
  return ($words | ForEach-Object { Format-PersonNameWord $_ }) -join ' '
}

$envMap = Read-DotEnv (Join-Path $PSScriptRoot '..\.env')
$baseRaw = if ($envMap['PB_LOCAL_URL']) { $envMap['PB_LOCAL_URL'] } else { $envMap['LOCAL_API_URL'] }
$email = if ($envMap['PB_LOCAL_EMAIL']) { $envMap['PB_LOCAL_EMAIL'] } else { $envMap['LOCAL_USER'] }
$pass = if ($envMap['PB_LOCAL_PASSWORD']) { $envMap['PB_LOCAL_PASSWORD'] } else { $envMap['LOCAL_PASSWORD'] }
$base = "$baseRaw".TrimEnd('/')

if (-not $base -or -not $email -or -not $pass) {
  throw 'Missing PocketBase URL/email/password in .env (PB_LOCAL_* or LOCAL_*).'
}

$authBodyPath = Join-Path $env:TEMP 'pb_cleanup_names_auth.json'
[System.IO.File]::WriteAllText(
  $authBodyPath,
  (@{ identity = $email; password = $pass } | ConvertTo-Json -Compress),
  (New-Object System.Text.UTF8Encoding $false)
)

try {
  $authOut = curl.exe -s -X POST "$base/api/collections/_superusers/auth-with-password" `
    -H 'Content-Type: application/json' `
    --data-binary "@$authBodyPath"
} finally {
  Remove-Item $authBodyPath -Force -ErrorAction SilentlyContinue
}

$auth = $authOut | ConvertFrom-Json
if (-not $auth.token) { throw "Superuser auth failed: $authOut" }
$token = $auth.token

$page = 1
$perPage = 200
$totalScanned = 0
$totalChanged = 0
$totalFailed = 0

Write-Host ("Mode: {0}" -f ($(if ($DryRun) { 'DRY RUN' } else { 'APPLY' })))
Write-Host "Scanning members for name formatting (whitespace + Title Case)..."

while ($true) {
  $listOut = curl.exe -s "$base/api/collections/members/records?page=$page&perPage=$perPage&fields=id,name" `
    -H "Authorization: $token"
  $list = $listOut | ConvertFrom-Json
  if (-not $list.items) {
    if ($list.message) { throw "List failed: $listOut" }
    break
  }

  foreach ($item in $list.items) {
    $totalScanned++
    $original = [string]$item.name
    $formatted = Format-PersonName $original
    if ([string]::Equals($formatted, $original, [System.StringComparison]::Ordinal)) {
      continue
    }

    $totalChanged++
    Write-Host ("  [{0}] '{1}' -> '{2}'" -f $item.id, $original, $formatted)

    if ($DryRun) { continue }

    $patchPath = Join-Path $env:TEMP ("pb_cleanup_name_{0}.json" -f $item.id)
    [System.IO.File]::WriteAllText(
      $patchPath,
      (@{ name = $formatted } | ConvertTo-Json -Compress),
      (New-Object System.Text.UTF8Encoding $false)
    )
    try {
      $patchOut = curl.exe -s -X PATCH "$base/api/collections/members/records/$($item.id)" `
        -H "Authorization: $token" `
        -H 'Content-Type: application/json' `
        --data-binary "@$patchPath"
      $patched = $patchOut | ConvertFrom-Json
      if (-not $patched.id) {
        $totalFailed++
        Write-Warning "Failed to patch $($item.id): $patchOut"
      }
    } finally {
      Remove-Item $patchPath -Force -ErrorAction SilentlyContinue
    }
  }

  if ($page -ge [int]$list.totalPages) { break }
  $page++
}

Write-Host ""
Write-Host ("Scanned: {0}" -f $totalScanned)
Write-Host ("{0}: {1}" -f ($(if ($DryRun) { 'Would update' } else { 'Updated' }), $totalChanged))
if (-not $DryRun) {
  Write-Host ("Failed: {0}" -f $totalFailed)
  if ($totalFailed -gt 0) { exit 1 }
}
