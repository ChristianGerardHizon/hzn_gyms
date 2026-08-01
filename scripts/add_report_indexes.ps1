# Adds PocketBase indexes used by Day/Week report range queries.
# Auth: set PB_LOCAL_URL + PB_LOCAL_EMAIL + PB_LOCAL_PASSWORD
#   or LOCAL_API_URL + LOCAL_USER + LOCAL_PASSWORD (superuser).
#
# Usage (from repo root):
#   pwsh ./scripts/add_report_indexes.ps1

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

$authBodyPath = Join-Path $env:TEMP 'pb_report_index_auth.json'
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

function Merge-Indexes([string]$name, [string[]]$desired) {
  $colJson = curl.exe -s "$base/api/collections/$name" -H "Authorization: $token"
  $col = $colJson | ConvertFrom-Json
  $merged = New-Object System.Collections.Generic.List[string]
  foreach ($e in @($col.indexes)) {
    if ($e) { [void]$merged.Add([string]$e) }
  }
  foreach ($d in $desired) {
    $idxName = if ($d -match 'INDEX\s+`?([A-Za-z0-9_]+)`?') { $Matches[1] } else { $null }
    $already = $false
    if ($idxName) {
      foreach ($e in $merged) {
        if ($e -match [regex]::Escape($idxName)) { $already = $true; break }
      }
    }
    if (-not $already) { [void]$merged.Add($d) }
  }
  $bodyPath = Join-Path $env:TEMP "pb_patch_$name.json"
  $body = @{ indexes = @($merged.ToArray()) } | ConvertTo-Json -Depth 5 -Compress
  [System.IO.File]::WriteAllText($bodyPath, $body, (New-Object System.Text.UTF8Encoding $false))
  try {
    $updatedJson = curl.exe -s -X PATCH "$base/api/collections/$name" `
      -H "Authorization: $token" `
      -H 'Content-Type: application/json' `
      --data-binary "@$bodyPath"
  } finally {
    Remove-Item $bodyPath -Force -ErrorAction SilentlyContinue
  }
  $updated = $updatedJson | ConvertFrom-Json
  Write-Host "$name indexes ($($updated.indexes.Count)):"
  foreach ($i in $updated.indexes) { Write-Host "  $i" }
}

Merge-Indexes 'sales' @(
  'CREATE INDEX `idx_sales_created` ON `sales` (`created`)',
  'CREATE INDEX `idx_sales_branch_created` ON `sales` (`branch`, `created`)',
  'CREATE INDEX `idx_sales_status` ON `sales` (`status`)'
)
Merge-Indexes 'saleItems' @(
  'CREATE INDEX `idx_saleItems_sale` ON `saleItems` (`sale`)'
)
Merge-Indexes 'checkIns' @(
  'CREATE INDEX `idx_checkIns_checkInTime` ON `checkIns` (`checkInTime`)',
  'CREATE INDEX `idx_checkIns_branch_checkInTime` ON `checkIns` (`branch`, `checkInTime`)'
)
Merge-Indexes 'memberMemberships' @(
  'CREATE INDEX `idx_memberMemberships_created` ON `memberMemberships` (`created`)',
  'CREATE INDEX `idx_memberMemberships_branch_created` ON `memberMemberships` (`branch`, `created`)',
  'CREATE INDEX `idx_memberMemberships_status_endDate` ON `memberMemberships` (`status`, `endDate`)'
)

Write-Host 'Done.'
