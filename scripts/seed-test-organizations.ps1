# Seed multiple test organizations in local PocketBase for multi-tenant testing.
# Uses the org switcher in the app — no custom subdomains required.
# See docs/backfill-organizations.md for the API pattern.

param(
    [string]$ApiUrl = $env:LOCAL_API_URL,
    [string]$Email = $env:LOCAL_EMAIL,
    [string]$Password = $env:LOCAL_PASSWORD,
    [string]$AdminRoleId = "ca4gbxa1c9u0vu9",
    [string]$TestPassword = "TestPass123!"
)

if (-not $ApiUrl) { $ApiUrl = "http://localhost:8090" }
if (-not $Email -or -not $Password) {
    Write-Error "Set LOCAL_API_URL, LOCAL_EMAIL, LOCAL_PASSWORD in .env or pass -ApiUrl/-Email/-Password"
    exit 1
}

function Get-PbToken {
    param([string]$Url, [string]$Identity, [string]$Pass)
    $body = @{ identity = $Identity; password = $Pass } | ConvertTo-Json
    $resp = Invoke-RestMethod -Uri "$Url/api/collections/_superusers/auth-with-password" `
        -Method POST -ContentType "application/json" -Body $body
    return $resp.token
}

function Invoke-Pb {
    param(
        [string]$Method,
        [string]$Path,
        [hashtable]$Headers,
        [object]$Body = $null
    )
    $params = @{
        Uri     = "$ApiUrl$Path"
        Method  = $Method
        Headers = $Headers
    }
    if ($null -ne $Body) {
        $params.ContentType = "application/json"
        $params.Body = ($Body | ConvertTo-Json -Depth 5 -Compress)
    }
    return Invoke-RestMethod @params
}

function Get-OrgBySlug {
    param([string]$Slug, [hashtable]$Headers)
    $filter = [uri]::EscapeDataString("slug='$Slug'")
    $resp = Invoke-Pb -Method GET -Path "/api/collections/organizations/records?filter=$filter&perPage=1" -Headers $Headers
    if ($resp.items.Count -gt 0) { return $resp.items[0] }
    return $null
}

function Ensure-Organization {
    param(
        [hashtable]$Org,
        [hashtable]$Headers
    )
    $existing = Get-OrgBySlug -Slug $Org.slug -Headers $Headers
    if ($existing) {
        Write-Host "  [skip] org exists: $($Org.name) ($($existing.id))"
        return $existing
    }

    $body = @{
        name                  = $Org.name
        slug                  = $Org.slug
        displayName           = $Org.displayName
        seedColor             = $Org.seedColor
        splashBackgroundColor = $Org.splashBackgroundColor
        isDeleted             = $false
    }
    $created = Invoke-Pb -Method POST -Path "/api/collections/organizations/records" -Headers $Headers -Body $body
    Write-Host "  [created] org: $($Org.name) ($($created.id)) subdomain=$($created.subdomain)"
    return $created
}

function Ensure-Branch {
    param(
        [string]$OrgId,
        [string]$Name,
        [string]$Code,
        [hashtable]$Headers
    )
    $filter = [uri]::EscapeDataString("organization='$OrgId' && code='$Code'")
    $resp = Invoke-Pb -Method GET -Path "/api/collections/branches/records?filter=$filter&perPage=1" -Headers $Headers
    if ($resp.items.Count -gt 0) {
        Write-Host "    [skip] branch exists: $Name ($($resp.items[0].id))"
        return $resp.items[0]
    }

    $body = @{
        name         = $Name
        code         = $Code
        organization = $OrgId
        isDeleted    = $false
    }
    $created = Invoke-Pb -Method POST -Path "/api/collections/branches/records" -Headers $Headers -Body $body
    Write-Host "    [created] branch: $Name ($($created.id))"
    return $created
}

function Ensure-AdminUser {
    param(
        [string]$OrgId,
        [string]$BranchId,
        [string]$Name,
        [string]$Username,
        [string]$Email,
        [hashtable]$Headers
    )
    $filter = [uri]::EscapeDataString("email='$Email'")
    $resp = Invoke-Pb -Method GET -Path "/api/collections/users/records?filter=$filter&perPage=1" -Headers $Headers
    if ($resp.items.Count -gt 0) {
        Write-Host "    [skip] user exists: $Email ($($resp.items[0].id))"
        return $resp.items[0]
    }

    $body = @{
        name           = $Name
        username       = $Username
        email          = $Email
        password       = $TestPassword
        passwordConfirm = $TestPassword
        organization   = $OrgId
        branch         = $BranchId
        role           = $AdminRoleId
        allowedBranches = @($BranchId)
        isDeleted      = $false
    }
    $created = Invoke-Pb -Method POST -Path "/api/collections/users/records" -Headers $Headers -Body $body
    Write-Host "    [created] admin user: $Email ($($created.id))"
    return $created
}

function Set-SetupReady {
    param([string]$OrgId, [hashtable]$Headers)
    # complete-setup requires a user token (organizations.manage), not superuser.
    # PATCH setupStatus directly when the field exists on the collection.
    try {
        $body = @{
            setupStatus      = "ready"
            setupCompletedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        }
        Invoke-Pb -Method PATCH -Path "/api/collections/organizations/records/$OrgId" `
            -Headers $Headers -Body $body | Out-Null
        Write-Host "    [ready] setupStatus patched"
        return $true
    }
    catch {
        Write-Host "    [pending] setupStatus field may not exist locally — org still usable"
        return $false
    }
}

# --- Test tenants ---
$tenants = @(
    @{
        name                  = "Iron Forge Fitness"
        slug                  = "ironforge"
        displayName           = "Iron Forge"
        seedColor             = "#C62828"
        splashBackgroundColor = "#1A0A0A"
        branchName            = "Main Branch"
        branchCode            = "IRON"
        adminName             = "Iron Forge Admin"
        adminUsername         = "ironforge.admin"
        adminEmail            = "admin@ironforge.local"
        markReady             = $true
    },
    @{
        name                  = "Zenith Wellness Club"
        slug                  = "zenith"
        displayName           = "Zenith Wellness"
        seedColor             = "#6A1B9A"
        splashBackgroundColor = "#1A0F24"
        branchName            = $null
        branchCode            = $null
        adminName             = $null
        adminUsername         = $null
        adminEmail            = $null
        markReady             = $false
    },
    @{
        name                  = "Peak Performance Gym"
        slug                  = "peakperf"
        displayName           = "Peak Performance"
        seedColor             = "#1565C0"
        splashBackgroundColor = "#0A1628"
        branchName            = "Downtown"
        branchCode            = "PEAK"
        adminName             = "Peak Admin"
        adminUsername         = "peak.admin"
        adminEmail            = "admin@peakperf.local"
        markReady             = $true
    },
    @{
        name                  = "Sunrise Fitness Studio"
        slug                  = "sunrise"
        displayName           = "Sunrise Studio"
        seedColor             = "#EF6C00"
        splashBackgroundColor = "#2A1808"
        branchName            = "Studio A"
        branchCode            = "RISE"
        adminName             = $null
        adminUsername         = $null
        adminEmail            = $null
        markReady             = $false
    },
    @{
        name                  = "Harbor City Athletics"
        slug                  = "harbor"
        displayName           = "Harbor City"
        seedColor             = "#00897B"
        splashBackgroundColor = "#0A1F1C"
        branchName            = "Waterfront"
        branchCode            = "HARB"
        adminName             = "Harbor Admin"
        adminUsername         = "harbor.admin"
        adminEmail            = "admin@harbor.local"
        markReady             = $true
    }
)

Write-Host "==> Authenticating at $ApiUrl"
$token = Get-PbToken -Url $ApiUrl -Identity $Email -Pass $Password
$headers = @{ Authorization = $token }

Write-Host "==> Seeding $($tenants.Count) test organizations"
$summary = @()

foreach ($tenant in $tenants) {
    Write-Host ""
    Write-Host "--- $($tenant.name) ---"
    $org = Ensure-Organization -Org $tenant -Headers $headers
    $branchId = $null

    if ($tenant.branchName) {
        $branch = Ensure-Branch -OrgId $org.id -Name $tenant.branchName `
            -Code $tenant.branchCode -Headers $headers
        $branchId = $branch.id
    }

    if ($tenant.adminEmail -and $branchId) {
        Ensure-AdminUser -OrgId $org.id -BranchId $branchId `
            -Name $tenant.adminName -Username $tenant.adminUsername `
            -Email $tenant.adminEmail -Headers $headers | Out-Null
    }

    $setupStatus = "pending_setup"
    if ($tenant.markReady) {
        if (Set-SetupReady -OrgId $org.id -Headers $headers) {
            $setupStatus = "ready"
        }
    }

    $summary += [PSCustomObject]@{
        Name        = $tenant.displayName
        Slug        = $tenant.slug
        Id          = $org.id
        SeedColor   = $tenant.seedColor
        SetupStatus = $setupStatus
        AdminEmail  = $tenant.adminEmail
    }
}

Write-Host ""
Write-Host "==> Summary"
$summary | Format-Table -AutoSize
Write-Host "Test admin password (new users): $TestPassword"
Write-Host "Switch orgs in-app via the organization dropdown (requires organizations.manage)."
