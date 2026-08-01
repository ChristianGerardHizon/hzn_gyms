# Creates the admin-only activityLogs collection, indexes, and API rules.
# Auth: PB_LOCAL_* or LOCAL_* from .env (superuser).
#
# Usage (from repo root):
#   pwsh ./scripts/setup_activity_logs.ps1

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

$authBodyPath = Join-Path $env:TEMP 'pb_activity_log_auth.json'
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

$usersCol = (curl.exe -s "$base/api/collections/users" -H "Authorization: $token" | ConvertFrom-Json).id
$branchesCol = (curl.exe -s "$base/api/collections/branches" -H "Authorization: $token" | ConvertFrom-Json).id

$listRule = '@request.auth.id != "" && @request.auth.role.permissions ?~ "system.admin"'

$existing = curl.exe -s "$base/api/collections/activityLogs" -H "Authorization: $token"
if ($existing -match '"status":404') {
  $createBody = @{
    name = 'activityLogs'
    type = 'base'
    listRule = $listRule
    viewRule = $listRule
    createRule = $null
    updateRule = $null
    deleteRule = $null
    fields = @(
      @{ name = 'action'; type = 'select'; required = $true; values = @('create', 'update', 'delete') },
      @{ name = 'collection'; type = 'text'; required = $true; min = 1; max = 100 },
      @{ name = 'recordId'; type = 'text'; required = $true; min = 1; max = 50 },
      @{ name = 'summary'; type = 'text'; required = $true; min = 1; max = 500 },
      @{ name = 'changes'; type = 'json'; required = $false },
      @{ name = 'actor'; type = 'relation'; required = $false; collectionId = $usersCol; maxSelect = 1; minSelect = 0; cascadeDelete = $false },
      @{ name = 'branch'; type = 'relation'; required = $false; collectionId = $branchesCol; maxSelect = 1; minSelect = 0; cascadeDelete = $false },
      @{ name = 'metadata'; type = 'json'; required = $false },
      @{ name = 'created'; type = 'autodate'; onCreate = $true; onUpdate = $false; required = $false },
      @{ name = 'updated'; type = 'autodate'; onCreate = $true; onUpdate = $true; required = $false }
    )
    indexes = @(
      'CREATE INDEX idx_activity_logs_collection_record ON activityLogs (`collection`, recordId)',
      'CREATE INDEX idx_activity_logs_actor ON activityLogs (actor)',
      'CREATE INDEX idx_activity_logs_branch ON activityLogs (branch)'
    )
  }

  $bodyPath = Join-Path $env:TEMP 'pb_create_activity_logs.json'
  [System.IO.File]::WriteAllText(
    $bodyPath,
    ($createBody | ConvertTo-Json -Depth 10 -Compress),
    (New-Object System.Text.UTF8Encoding $false)
  )
  try {
    $created = curl.exe -s -X POST "$base/api/collections" `
      -H "Authorization: $token" `
      -H 'Content-Type: application/json' `
      --data-binary "@$bodyPath"
    Write-Host "Created activityLogs collection: $created"
  } finally {
    Remove-Item $bodyPath -Force -ErrorAction SilentlyContinue
  }
} else {
  Write-Host 'activityLogs collection already exists — skipping create.'
}

# Keep existing collections aligned with the admin-only read policy.
$rulesBodyPath = Join-Path $env:TEMP 'pb_patch_activity_logs_rules.json'
[System.IO.File]::WriteAllText(
  $rulesBodyPath,
  (@{ listRule = $listRule; viewRule = $listRule } | ConvertTo-Json -Compress),
  (New-Object System.Text.UTF8Encoding $false)
)
try {
  $patchedRules = curl.exe -s -X PATCH "$base/api/collections/activityLogs" `
    -H "Authorization: $token" `
    -H 'Content-Type: application/json' `
    --data-binary "@$rulesBodyPath"
  $patchedRulesJson = $patchedRules | ConvertFrom-Json
  if ($patchedRulesJson.status -ge 400) {
    throw "Failed to update activityLogs API rules: $patchedRules"
  }
  Write-Host 'Updated activityLogs API rules to admin-only.'
} finally {
  Remove-Item $rulesBodyPath -Force -ErrorAction SilentlyContinue
}

# Ensure created/updated autodate fields exist (required for sort/filter by created).
$colJson = curl.exe -s "$base/api/collections/activityLogs" -H "Authorization: $token"
if ($colJson -notmatch '"status":404') {
  $col = $colJson | ConvertFrom-Json
  $hasCreated = @($col.fields | Where-Object { $_.name -eq 'created' }).Count -gt 0
  if (-not $hasCreated) {
    Write-Host 'Adding missing created/updated autodate fields to activityLogs...'
    $fields = [System.Collections.Generic.List[object]]@($col.fields)
    [void]$fields.Add(@{
      name = 'created'; type = 'autodate'; onCreate = $true; onUpdate = $false; required = $false
    })
    [void]$fields.Add(@{
      name = 'updated'; type = 'autodate'; onCreate = $true; onUpdate = $true; required = $false
    })
    $indexes = [System.Collections.Generic.List[string]]@($col.indexes)
    $createdIdx = 'CREATE INDEX idx_activity_logs_created ON activityLogs (created DESC)'
    if ($indexes -notcontains $createdIdx) { [void]$indexes.Add($createdIdx) }
    $patchColPath = Join-Path $env:TEMP 'pb_patch_activity_logs_fields.json'
    [System.IO.File]::WriteAllText(
      $patchColPath,
      (@{ fields = @($fields.ToArray()); indexes = @($indexes.ToArray()) } | ConvertTo-Json -Depth 12 -Compress),
      (New-Object System.Text.UTF8Encoding $false)
    )
    try {
      $patchedCol = curl.exe -s -X PATCH "$base/api/collections/activityLogs" `
        -H "Authorization: $token" `
        -H 'Content-Type: application/json' `
        --data-binary "@$patchColPath"
      Write-Host "Patched activityLogs fields: $patchedCol"
    } finally {
      Remove-Item $patchColPath -Force -ErrorAction SilentlyContinue
    }
  } else {
    Write-Host 'activityLogs already has created/updated fields.'
  }
}

Write-Host 'Done.'
