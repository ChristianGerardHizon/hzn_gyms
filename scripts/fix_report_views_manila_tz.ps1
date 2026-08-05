# Rewrites PocketBase report/aggregate views that bucket with SQLite 'localtime'
# to use a fixed UTC+8 offset (Philippines, no DST).
#
# Prod PocketBase runs in UTC, so 'localtime' means UTC calendar days and
# midnight–8AM Manila activity lands on the previous UTC day.
#
# Usage (from repo root):
#   pwsh ./scripts/fix_report_views_manila_tz.ps1            # local
#   pwsh ./scripts/fix_report_views_manila_tz.ps1 -UseProd   # production

param(
  [switch]$UseProd,
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

function Convert-ToManilaQuery([string]$query) {
  # Only replace the SQLite timezone modifier, not unrelated text.
  return $query.Replace("'localtime'", "'+8 hours'")
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
  throw 'Missing PocketBase URL/email/password in .env.'
}

Write-Host "Target: $base"

$authBodyPath = Join-Path $env:TEMP 'pb_manila_tz_auth.json'
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
if (-not $auth.token) {
  throw "Superuser auth failed: $authOut"
}
$token = $auth.token

$colsOut = curl.exe -s "$base/api/collections?perPage=500" -H "Authorization: $token"
$cols = $colsOut | ConvertFrom-Json
# vw_todays_sales uses datetime('now', …) range math — use fix_vw_todays_sales.ps1
# instead of a naive 'localtime' → '+8 hours' swap (that leaves a wrong 'utc' suffix).
$views = @($cols.items | Where-Object {
  $_.type -eq 'view' -and
  $_.name -ne 'vw_todays_sales' -and
  $_.viewQuery -and
  ($_.viewQuery -match "'localtime'")
})

if ($views.Count -eq 0) {
  Write-Host "No views still using 'localtime'. Nothing to patch."
  exit 0
}

Write-Host "Found $($views.Count) view(s) with 'localtime':"
$views | ForEach-Object { Write-Host "  - $($_.name)" }

$patched = 0
$failed = 0
foreach ($view in $views) {
  $newQuery = Convert-ToManilaQuery $view.viewQuery
  if ($newQuery -eq $view.viewQuery) {
    Write-Host "SKIP $($view.name) (no change)"
    continue
  }
  if ($newQuery -match "'localtime'") {
    Write-Host "ERROR $($view.name): replacement left residual 'localtime'"
    $failed++
    continue
  }

  if ($DryRun) {
    Write-Host "DRY-RUN would patch $($view.name)"
    $patched++
    continue
  }

  $bodyPath = Join-Path $env:TEMP "pb_patch_$($view.name).json"
  [System.IO.File]::WriteAllText(
    $bodyPath,
    (@{ viewQuery = $newQuery } | ConvertTo-Json -Compress),
    (New-Object System.Text.UTF8Encoding $false)
  )
  try {
    $updatedJson = curl.exe -s -X PATCH "$base/api/collections/$($view.name)" `
      -H "Authorization: $token" `
      -H 'Content-Type: application/json' `
      --data-binary "@$bodyPath"
  } finally {
    Remove-Item $bodyPath -Force -ErrorAction SilentlyContinue
  }

  $updated = $updatedJson | ConvertFrom-Json
  if (-not $updated.viewQuery -or ($updated.viewQuery -match "'localtime'")) {
    Write-Host "FAIL $($view.name): $updatedJson"
    $failed++
    continue
  }
  Write-Host "OK   $($view.name)"
  $patched++
}

Write-Host ""
Write-Host "Patched: $patched  Failed: $failed"
if ($failed -gt 0) { exit 1 }
Write-Host 'Done.'
