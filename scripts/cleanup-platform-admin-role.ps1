# Remove the obsolete "Platform Admin" userRoles record.
# Platform access is users.superAdmin; org full access is the Admin role (system.admin).
#
# Usage:
#   .\scripts\cleanup-platform-admin-role.ps1 -Target local
#   .\scripts\cleanup-platform-admin-role.ps1 -Target staging -Apply
#   .\scripts\cleanup-platform-admin-role.ps1 -Target prod -Apply
#
# Default is dry-run. Pass -Apply to write.

param(
    [ValidateSet('local', 'staging', 'prod')]
    [string]$Target = 'local',
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EnvFile = Join-Path $Root '.env'

if (-not (Test-Path $EnvFile)) {
    Write-Error "Missing .env at $EnvFile"
    exit 1
}

$envMap = @{}
Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^\s*#' -or $_ -match '^\s*$') { return }
    $i = $_.IndexOf('=')
    if ($i -gt 0) {
        $envMap[$_.Substring(0, $i).Trim()] = $_.Substring($i + 1).Trim()
    }
}

switch ($Target) {
    'staging' {
        $ApiUrl = if ($envMap['PB_STAGING_URL']) { $envMap['PB_STAGING_URL'] } else { $envMap['STAGING_URL'] }
        $Email = if ($envMap['PB_STAGING_EMAIL']) { $envMap['PB_STAGING_EMAIL'] } else { $envMap['STAGING_EMAIL'] }
        $Password = if ($envMap['PB_STAGING_PASSWORD']) { $envMap['PB_STAGING_PASSWORD'] } else { $envMap['STAGING_PASSWORD'] }
    }
    'prod' {
        $ApiUrl = if ($envMap['PB_PROD_URL']) { $envMap['PB_PROD_URL'] } else { $envMap['PROD_URL'] }
        $Email = if ($envMap['PB_PROD_EMAIL']) { $envMap['PB_PROD_EMAIL'] } else { $envMap['PROD_EMAIL'] }
        $Password = if ($envMap['PB_PROD_PASSWORD']) { $envMap['PB_PROD_PASSWORD'] } else { $envMap['PROD_PASSWORD'] }
    }
    default {
        $ApiUrl = if ($envMap['PB_LOCAL_URL']) { $envMap['PB_LOCAL_URL'] } else { $envMap['LOCAL_API_URL'] }
        $Email = if ($envMap['PB_LOCAL_EMAIL']) { $envMap['PB_LOCAL_EMAIL'] } else { $envMap['LOCAL_EMAIL'] }
        $Password = if ($envMap['PB_LOCAL_PASSWORD']) { $envMap['PB_LOCAL_PASSWORD'] } else { $envMap['LOCAL_PASSWORD'] }
    }
}

if (-not $ApiUrl -or -not $Email -or -not $Password) {
    Write-Error "Missing API URL / email / password for target '$Target' in .env"
    exit 1
}

$ApiUrl = $ApiUrl.TrimEnd('/')
$mode = if ($Apply) { 'APPLY' } else { 'DRY-RUN' }
Write-Host "Target=$Target mode=$mode url=$ApiUrl"

$auth = Invoke-RestMethod -Uri "$ApiUrl/api/collections/_superusers/auth-with-password" `
    -Method POST -ContentType 'application/json' `
    -Body (@{ identity = $Email; password = $Password } | ConvertTo-Json)
$headers = @{ Authorization = $auth.token }

function Get-RoleByName([string]$Name) {
    $filter = [uri]::EscapeDataString(('name="{0}"' -f $Name))
    $uri = '{0}/api/collections/userRoles/records?filter={1}&perPage=5' -f $ApiUrl, $filter
    $resp = Invoke-RestMethod -Uri $uri -Headers $headers
    if ($resp.totalItems -lt 1) { return $null }
    return $resp.items[0]
}

function Get-Permissions($Role) {
    $p = $Role.permissions
    if ($null -eq $p) { return @() }
    if ($p -is [string]) {
        try { return @(ConvertFrom-Json $p) } catch { return @() }
    }
    return @($p)
}

$admin = Get-RoleByName 'Admin'
$platform = Get-RoleByName 'Platform Admin'

if (-not $admin) {
    Write-Error "Admin role not found"
    exit 1
}

if (-not $platform) {
    Write-Host 'Platform Admin role already gone - nothing to do.'
    exit 0
}

Write-Host ("Admin id={0} Platform Admin id={1}" -f $admin.id, $platform.id)

$requiredKeys = @('organizations.view', 'members.manage')
$adminPerms = Get-Permissions $admin
$missing = @($requiredKeys | Where-Object { $adminPerms -notcontains $_ })
if ($missing.Count -gt 0) {
    $newPerms = @($adminPerms) + $missing
    Write-Host ("Admin missing keys: {0}" -f ($missing -join ', '))
    if ($Apply) {
        $updated = Invoke-RestMethod -Uri "$ApiUrl/api/collections/userRoles/records/$($admin.id)" `
            -Method PATCH -Headers $headers -ContentType 'application/json' `
            -Body (@{ permissions = $newPerms } | ConvertTo-Json -Compress)
        $admin = $updated
        Write-Host ("  patched Admin permissions (now {0} keys)" -f $newPerms.Count)
    } else {
        Write-Host ("  would patch Admin permissions (+{0})" -f $missing.Count)
    }
} else {
    Write-Host 'Admin already has organizations.view + members.manage'
}

# Reassign users
$userFilter = [uri]::EscapeDataString(('role="{0}"' -f $platform.id))
$usersUri = '{0}/api/collections/users/records?filter={1}&perPage=100&fields=id,email,superAdmin,organization,role' -f $ApiUrl, $userFilter
$users = Invoke-RestMethod -Uri $usersUri -Headers $headers
Write-Host ("Users on Platform Admin: {0}" -f $users.totalItems)

$reassigned = 0
$flagged = 0
foreach ($u in $users.items) {
    $org = [string]$u.organization
    $needsFlag = [string]::IsNullOrWhiteSpace($org) -and -not [bool]$u.superAdmin
    Write-Host ("  {0} org=[{1}] superAdmin={2} needsFlag={3}" -f $u.email, $org, $u.superAdmin, $needsFlag)

    if ($Apply) {
        $body = @{ role = $admin.id }
        if ($needsFlag) { $body.superAdmin = $true }
        Invoke-RestMethod -Uri "$ApiUrl/api/collections/users/records/$($u.id)" `
            -Method PATCH -Headers $headers -ContentType 'application/json' `
            -Body ($body | ConvertTo-Json -Compress) | Out-Null
        $reassigned++
        if ($needsFlag) { $flagged++ }
    } else {
        $reassigned++
        if ($needsFlag) { $flagged++ }
    }
}

# Reassign organizationMemberships
$memFilter = [uri]::EscapeDataString(('role="{0}"' -f $platform.id))
$memsUri = '{0}/api/collections/organizationMemberships/records?filter={1}&perPage=100&fields=id,user,organization,role' -f $ApiUrl, $memFilter
$mems = Invoke-RestMethod -Uri $memsUri -Headers $headers
Write-Host ("organizationMemberships on Platform Admin: {0}" -f $mems.totalItems)
$memReassigned = 0
foreach ($m in $mems.items) {
    Write-Host ("  membership {0} user={1} org={2}" -f $m.id, $m.user, $m.organization)
    if ($Apply) {
        Invoke-RestMethod -Uri "$ApiUrl/api/collections/organizationMemberships/records/$($m.id)" `
            -Method PATCH -Headers $headers -ContentType 'application/json' `
            -Body (@{ role = $admin.id } | ConvertTo-Json -Compress) | Out-Null
    }
    $memReassigned++
}

# Soft-delete Platform Admin
Write-Host ("Soft-delete Platform Admin isDeleted={0}" -f $platform.isDeleted)
if (-not [bool]$platform.isDeleted) {
    if ($Apply) {
        Invoke-RestMethod -Uri "$ApiUrl/api/collections/userRoles/records/$($platform.id)" `
            -Method PATCH -Headers $headers -ContentType 'application/json' `
            -Body (@{ isDeleted = $true } | ConvertTo-Json -Compress) | Out-Null
        Write-Host '  soft-deleted Platform Admin'
    } else {
        Write-Host '  would soft-delete Platform Admin'
    }
} else {
    Write-Host '  already soft-deleted'
}

Write-Host ''
Write-Host ("Summary ({0}):" -f $mode)
Write-Host ("  Admin keys added:     {0}" -f $(if ($missing.Count) { $missing -join ', ' } else { '(none)' }))
Write-Host ("  Users reassigned:     {0}" -f $reassigned)
Write-Host ("  superAdmin flagged:   {0}" -f $flagged)
Write-Host ("  Memberships moved:    {0}" -f $memReassigned)
$goneLabel = if ($Apply -or [bool]$platform.isDeleted) { 'yes/queued' } else { 'would soft-delete' }
Write-Host ("  Platform Admin gone:  {0}" -f $goneLabel)
if (-not $Apply) {
    Write-Host 'Re-run with -Apply to write changes.'
}
