# Rewrites vw_todays_sales to use an indexable Manila-day UTC range instead of
# DATE(created) (which forces a full scan on large sales tables).
#
# Uses a fixed UTC+8 offset (Philippines, no DST) rather than SQLite 'localtime',
# because production PocketBase typically runs in UTC — 'localtime' then means
# the UTC calendar day and the dashboard KPI disagrees with the client list
# (which filters by device local / Manila day).
#
# Auth: set PB_LOCAL_URL + PB_LOCAL_EMAIL + PB_LOCAL_PASSWORD
#   or LOCAL_API_URL + LOCAL_USER + LOCAL_PASSWORD (superuser).
# For prod, set PROD_URL + PROD_EMAIL + PROD_PASSWORD (or pass -UseProd).
#
# Usage (from repo root):
#   pwsh ./scripts/fix_vw_todays_sales.ps1
#   pwsh ./scripts/fix_vw_todays_sales.ps1 -UseProd

param(
  [switch]$UseProd
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

$envMap = Read-DotEnv (Join-Path $PSScriptRoot '..\.env')
if ($UseProd) {
  $baseRaw = $envMap['PROD_URL']
  $email = $envMap['PROD_EMAIL']
  $pass = $envMap['PROD_PASSWORD']
} else {
  $baseRaw = if ($envMap['PB_LOCAL_URL']) { $envMap['PB_LOCAL_URL'] } else { $envMap['LOCAL_API_URL'] }
  $email = if ($envMap['PB_LOCAL_EMAIL']) { $envMap['PB_LOCAL_EMAIL'] } else { $envMap['LOCAL_USER'] }
  $pass = if ($envMap['PB_LOCAL_PASSWORD']) { $envMap['PB_LOCAL_PASSWORD'] } else { $envMap['LOCAL_PASSWORD'] }
}
$base = "$baseRaw".TrimEnd('/')

if (-not $base -or -not $email -or -not $pass) {
  throw 'Missing PocketBase URL/email/password in .env (PB_LOCAL_*/LOCAL_* or PROD_* with -UseProd).'
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

# Manila (+8, no DST): shift now to PH wall clock, take start of day, shift back to UTC.
$viewQuery = @"
SELECT
  (ROW_NUMBER() OVER()) AS id,
  s.branch,
  COUNT(*) AS transaction_count,
  COALESCE(SUM(s.totalAmount), 0) AS total_revenue
FROM sales s
WHERE s.created >= datetime('now', '+8 hours', 'start of day', '-8 hours')
  AND s.created < datetime('now', '+8 hours', 'start of day', '+1 day', '-8 hours')
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

Write-Host "Target: $base"
Write-Host 'vw_todays_sales viewQuery:'
Write-Host $updated.viewQuery
Write-Host 'Done.'
