# Rewrites vw_todays_sales to use an indexable local-day UTC range instead of
# DATE(created) (which forces a full scan on large sales tables).
# Auth: set PB_LOCAL_URL + PB_LOCAL_EMAIL + PB_LOCAL_PASSWORD
#   or LOCAL_API_URL + LOCAL_USER + LOCAL_PASSWORD (superuser).
#
# Usage (from repo root):
#   pwsh ./scripts/fix_vw_todays_sales.ps1

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

$envMap = Read-DotEnv (Join-Path $PSScriptRoot '..\.env')
$baseRaw = if ($envMap['PB_LOCAL_URL']) { $envMap['PB_LOCAL_URL'] } else { $envMap['LOCAL_API_URL'] }
$email = if ($envMap['PB_LOCAL_EMAIL']) { $envMap['PB_LOCAL_EMAIL'] } else { $envMap['LOCAL_USER'] }
$pass = if ($envMap['PB_LOCAL_PASSWORD']) { $envMap['PB_LOCAL_PASSWORD'] } else { $envMap['LOCAL_PASSWORD'] }
$base = "$baseRaw".TrimEnd('/')

if (-not $base -or -not $email -or -not $pass) {
  throw 'Missing PocketBase URL/email/password in .env (PB_LOCAL_* or LOCAL_*).'
}

$authBodyPath = Join-Path $env:TEMP 'pb_vw_todays_auth.json'
$authJson = (@{ identity = $email; password = $pass } | ConvertTo-Json -Compress)
[System.IO.File]::WriteAllText(
  $authBodyPath,
  $authJson,
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
if (-not $auth.token) {
  throw "Superuser auth failed: $authOut"
}
$token = $auth.token

$viewQuery = @"
SELECT
  (ROW_NUMBER() OVER()) AS id,
  s.branch,
  COUNT(*) AS transaction_count,
  COALESCE(SUM(s.totalAmount), 0) AS total_revenue
FROM sales s
WHERE s.created >= datetime('now', 'localtime', 'start of day', 'utc')
  AND s.created < datetime('now', 'localtime', 'start of day', '+1 day', 'utc')
  AND s.status IN ('completed', 'paid')
  AND (s.isDeleted = false OR s.isDeleted IS NULL)
GROUP BY s.branch
"@

$bodyPath = Join-Path $env:TEMP 'pb_patch_vw_todays_sales.json'
$body = @{ viewQuery = $viewQuery } | ConvertTo-Json -Compress
[System.IO.File]::WriteAllText($bodyPath, $body, (New-Object System.Text.UTF8Encoding $false))
try {
  $updatedJson = curl.exe -s -X PATCH "$base/api/collections/vw_todays_sales" `
    -H "Authorization: $token" `
    -H 'Content-Type: application/json' `
    --data-binary "@$bodyPath"
} finally {
  Remove-Item $bodyPath -Force -ErrorAction SilentlyContinue
}

$updated = $updatedJson | ConvertFrom-Json
if (-not $updated.viewQuery) {
  throw "Failed to patch vw_todays_sales: $updatedJson"
}

Write-Host 'vw_todays_sales viewQuery:'
Write-Host $updated.viewQuery
Write-Host 'Done.'
