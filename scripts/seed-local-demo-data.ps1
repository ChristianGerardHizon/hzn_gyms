# Seed local PocketBase with demo memberships, products, members, and ~50 sales
# per organization over the last 3 weeks. Skips Kylie's Gym.
# Idempotent: skips an org if it already has sales with notes "[local-seed]".

param(
    [string]$ApiUrl = $env:LOCAL_API_URL,
    [string]$Email = $env:LOCAL_EMAIL,
    [string]$Password = $env:LOCAL_PASSWORD,
    [string]$AdminRoleId = "ca4gbxa1c9u0vu9",
    [string]$DbPath = "",
    [int]$SalesPerOrg = 50,
    [int]$DaysBack = 21,
    [string]$ExcludeSlug = "kyliegym",
    [string]$TestPassword = "TestPass123!",
    [string]$SeedMarker = "[local-seed]"
)

if (-not $ApiUrl) { $ApiUrl = "http://localhost:8090" }
if (-not $Email -or -not $Password) {
    Write-Error "Set LOCAL_API_URL, LOCAL_EMAIL, LOCAL_PASSWORD in .env or pass -ApiUrl/-Email/-Password"
    exit 1
}
if (-not $DbPath) {
    $DbPath = Join-Path $PSScriptRoot "..\server\pb_data\data.db"
}

$ErrorActionPreference = "Stop"
$rng = [System.Random]::new(42)

$firstNames = @(
    "Juan", "Maria", "Jose", "Ana", "Pedro", "Rosa", "Carlos", "Elena",
    "Miguel", "Sofia", "Luis", "Carmen", "Andres", "Isabel", "Rafael",
    "Lucia", "Diego", "Patricia", "Marco", "Diana", "Paolo", "Grace",
    "Rico", "Nina", "Ben", "Lara", "Leo", "Mia", "Sam", "Kate"
)
$lastNames = @(
    "Santos", "Reyes", "Cruz", "Bautista", "Garcia", "Mendoza", "Torres",
    "Flores", "Ramos", "Gonzales", "Aquino", "Dela Cruz", "Navarro",
    "Castro", "Jimenez", "Morales", "Vargas", "Silva", "Lopez", "Perez"
)
$productNames = @(
    "Bottled Water", "Sports Drink", "Protein Bar", "Gym Towel", "Shaker Bottle",
    "Resistance Band", "Wrist Wraps", "Hand Gripper", "Energy Gel", "Creatine 300g",
    "Whey Sample Pack", "Vitamin C Pack", "Skip Rope", "Knee Sleeves", "Lifting Chalk"
)
$membershipTemplates = @(
    @{ name = "Day Pass"; durationValue = 1; durationUnit = "days"; price = 150; memberNotRequired = $true },
    @{ name = "Weekly"; durationValue = 1; durationUnit = "weeks"; price = 500; memberNotRequired = $false },
    @{ name = "Monthly"; durationValue = 1; durationUnit = "months"; price = 1200; memberNotRequired = $false },
    @{ name = "Quarterly"; durationValue = 3; durationUnit = "months"; price = 3200; memberNotRequired = $false },
    @{ name = "Semi-Annual"; durationValue = 6; durationUnit = "months"; price = 5800; memberNotRequired = $false },
    @{ name = "Annual"; durationValue = 1; durationUnit = "years"; price = 10000; memberNotRequired = $false },
    @{ name = "Student Monthly"; durationValue = 1; durationUnit = "months"; price = 900; memberNotRequired = $false },
    @{ name = "Couple Monthly"; durationValue = 1; durationUnit = "months"; price = 2000; memberNotRequired = $false }
)
$paymentMethods = @("cash", "card", "bankTransfer", "cash", "cash", "card")

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
        $params.Body = ($Body | ConvertTo-Json -Depth 6 -Compress)
    }
    return Invoke-RestMethod @params
}

function Get-RandomName {
    $f = $firstNames[$rng.Next($firstNames.Count)]
    $l = $lastNames[$rng.Next($lastNames.Count)]
    return "$f $l"
}

function Get-RandomPhone {
    return ("09{0:d9}" -f $rng.Next(0, 1000000000))
}

function Get-ReceiptNumber {
    param([datetime]$At)
    $suffixChars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    $suffix = -join (1..4 | ForEach-Object { $suffixChars[$rng.Next($suffixChars.Length)] })
    return ("S-{0:yyMMdd}-{1}" -f $At, $suffix)
}

function Add-Duration {
    param([datetime]$Start, [int]$Value, [string]$Unit)
    switch ($Unit) {
        "days" { return $Start.AddDays($Value) }
        "weeks" { return $Start.AddDays(7 * $Value) }
        "months" { return $Start.AddMonths($Value) }
        "years" { return $Start.AddYears($Value) }
        default { return $Start.AddDays($Value) }
    }
}

function Format-PbDate([datetime]$dt) {
    return $dt.ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss.fffZ")
}

function Ensure-Branch {
    param([string]$OrgId, [string]$Name, [string]$Code, [hashtable]$Headers)
    $filter = [uri]::EscapeDataString("organization='$OrgId'")
    $resp = Invoke-Pb -Method GET -Path "/api/collections/branches/records?filter=$filter&perPage=1" -Headers $Headers
    if ($resp.items.Count -gt 0) { return $resp.items[0] }

    $body = @{
        name         = $Name
        code         = $Code
        organization = $OrgId
        isDeleted    = $false
        color        = "teal"
    }
    $created = Invoke-Pb -Method POST -Path "/api/collections/branches/records" -Headers $Headers -Body $body
    Write-Host "    [created] branch: $Name ($($created.id))"
    return $created
}

function Ensure-Cashier {
    param(
        [string]$OrgId,
        [string]$BranchId,
        [string]$Slug,
        [hashtable]$Headers
    )
    $filter = [uri]::EscapeDataString("organization='$OrgId' && branch='$BranchId'")
    $resp = Invoke-Pb -Method GET -Path "/api/collections/users/records?filter=$filter&perPage=1" -Headers $Headers
    if ($resp.items.Count -gt 0) { return $resp.items[0] }

    $email = "seed.$Slug@local.dev"
    $body = @{
        name            = "$Slug Seed Admin"
        username        = "seed.$Slug"
        email           = $email
        password        = $TestPassword
        passwordConfirm = $TestPassword
        organization    = $OrgId
        branch          = $BranchId
        role            = $AdminRoleId
        allowedBranches = @($BranchId)
        isDeleted       = $false
    }
    $created = Invoke-Pb -Method POST -Path "/api/collections/users/records" -Headers $Headers -Body $body
    Write-Host "    [created] cashier: $email ($($created.id))"
    return $created
}

function Test-AlreadySeeded {
    param([string]$BranchId, [hashtable]$Headers)
    $filter = [uri]::EscapeDataString("branch='$BranchId' && notes~'$SeedMarker'")
    $resp = Invoke-Pb -Method GET -Path "/api/collections/sales/records?filter=$filter&perPage=1" -Headers $Headers
    return ($resp.totalItems -gt 0)
}

function New-Memberships {
    param([string]$BranchId, [hashtable]$Headers)
    $plans = @()
    foreach ($t in $membershipTemplates) {
        $body = @{
            name              = $t.name
            description       = "$SeedMarker $($t.name) plan"
            durationValue     = $t.durationValue
            durationUnit      = $t.durationUnit
            price             = $t.price
            branch            = $BranchId
            validBranches     = @($BranchId)
            isActive          = $true
            isDeleted         = $false
            isFavorite        = ($t.name -eq "Monthly")
            memberNotRequired = [bool]$t.memberNotRequired
        }
        $plans += Invoke-Pb -Method POST -Path "/api/collections/memberships/records" -Headers $Headers -Body $body
    }
    return $plans
}

function New-Products {
    param([string]$BranchId, [hashtable]$Headers)
    $items = @()
    foreach ($name in $productNames) {
        $price = [math]::Round(20 + $rng.NextDouble() * 480, 0)
        $body = @{
            name           = $name
            description    = "$SeedMarker"
            price          = $price
            branch         = $BranchId
            forSale        = $true
            isDeleted      = $false
            trackByLot     = $false
            trackStock     = $false
            requireStock   = $false
            quantity       = $rng.Next(20, 200)
            stockThreshold = 5
        }
        $items += Invoke-Pb -Method POST -Path "/api/collections/products/records" -Headers $Headers -Body $body
    }
    return $items
}

function New-Members {
    param([string]$BranchId, [string]$CashierId, [hashtable]$Headers, [int]$Count = 25)
    $list = @()
    for ($i = 0; $i -lt $Count; $i++) {
        $body = @{
            name         = Get-RandomName
            mobileNumber = Get-RandomPhone
            branch       = $BranchId
            addedBy      = $CashierId
            sex          = @("male", "female", "other")[$rng.Next(3)]
            remarks      = $SeedMarker
            isDeleted    = $false
        }
        $list += Invoke-Pb -Method POST -Path "/api/collections/members/records" -Headers $Headers -Body $body
    }
    return $list
}

# --- main ---
Write-Host "==> Authenticating at $ApiUrl"
$token = Get-PbToken -Url $ApiUrl -Identity $Email -Pass $Password
$headers = @{ Authorization = $token }

$orgsResp = Invoke-Pb -Method GET -Path "/api/collections/organizations/records?perPage=100" -Headers $headers
$orgs = @($orgsResp.items | Where-Object { $_.slug -ne $ExcludeSlug })
Write-Host "==> Seeding $($orgs.Count) orgs (exclude slug=$ExcludeSlug), $SalesPerOrg sales / $DaysBack days each"

$backdates = New-Object System.Collections.Generic.List[object]
$now = Get-Date

foreach ($org in $orgs) {
    Write-Host ""
    Write-Host "--- $($org.name) ($($org.slug)) ---"

    $codeBase = ($org.slug.ToUpper() -replace '[^A-Z0-9]', '')
    if ($codeBase.Length -lt 2) { $codeBase = "ORG" }
    $code = $codeBase.Substring(0, [Math]::Min(5, $codeBase.Length))
    $branch = Ensure-Branch -OrgId $org.id -Name "Main Branch" -Code $code -Headers $headers
    $cashier = Ensure-Cashier -OrgId $org.id -BranchId $branch.id -Slug $org.slug -Headers $headers

    if (Test-AlreadySeeded -BranchId $branch.id -Headers $headers) {
        Write-Host "  [skip] already seeded (notes contain $SeedMarker)"
        continue
    }

    Write-Host "  creating memberships..."
    $plans = New-Memberships -BranchId $branch.id -Headers $headers
    Write-Host "  creating products..."
    $products = New-Products -BranchId $branch.id -Headers $headers
    Write-Host "  creating members..."
    $members = New-Members -BranchId $branch.id -CashierId $cashier.id -Headers $headers -Count 25

    Write-Host "  creating $SalesPerOrg sales over $DaysBack days..."
    for ($i = 0; $i -lt $SalesPerOrg; $i++) {
        $dayOffset = $rng.Next(0, $DaysBack)
        $hour = $rng.Next(6, 22)
        $minute = $rng.Next(0, 60)
        $saleAt = $now.AddDays(-$dayOffset).Date.AddHours($hour).AddMinutes($minute)
        $isMembershipSale = ($rng.NextDouble() -lt 0.45)
        $member = $members[$rng.Next($members.Count)]
        $method = $paymentMethods[$rng.Next($paymentMethods.Count)]
        $payType = if ($method -eq "cash") { "payment" } else { "deposit" }
        $receipt = Get-ReceiptNumber -At $saleAt

        if ($isMembershipSale) {
            $plan = $plans[$rng.Next($plans.Count)]
            $walkIn = [bool]$plan.memberNotRequired -and ($rng.NextDouble() -lt 0.3)
            $customerName = if ($walkIn) { "Walk-in" } else { $member.name }
            $memberId = if ($walkIn) { "" } else { $member.id }
            $itemType = if ($walkIn) { "walkIn" } else { "membership" }
            $total = [double]$plan.price
            $descriptor = if ($walkIn) { "Walk-in · $($plan.name)" } else { "$($member.name) · $($plan.name)" }

            $saleBody = @{
                receiptNumber = $receipt
                branch        = $branch.id
                cashier       = $cashier.id
                totalAmount   = $total
                status        = "paid"
                isPaid        = $true
                customerName  = $customerName
                member        = $memberId
                descriptor    = $descriptor
                notes         = $SeedMarker
                isDeleted     = $false
            }
            $sale = Invoke-Pb -Method POST -Path "/api/collections/sales/records" -Headers $headers -Body $saleBody

            Invoke-Pb -Method POST -Path "/api/collections/saleItems/records" -Headers $headers -Body @{
                sale        = $sale.id
                product     = ""
                productName = $plan.name
                quantity    = 1
                unitPrice   = $total
                subtotal    = $total
                itemType    = $itemType
            } | Out-Null

            Invoke-Pb -Method POST -Path "/api/collections/payments/records" -Headers $headers -Body @{
                sale          = $sale.id
                amount        = $total
                paymentMethod = $method
                type          = $payType
                notes         = $SeedMarker
            } | Out-Null

            if (-not $walkIn) {
                $end = Add-Duration -Start $saleAt -Value ([int]$plan.durationValue) -Unit $plan.durationUnit
                $status = if ($end -lt $now) { "expired" } else { "active" }
                $mm = Invoke-Pb -Method POST -Path "/api/collections/memberMemberships/records" -Headers $headers -Body @{
                    member     = $member.id
                    membership = $plan.id
                    startDate  = Format-PbDate $saleAt
                    endDate    = Format-PbDate $end
                    status     = $status
                    branch     = $branch.id
                    saleId     = $sale.id
                    soldBy     = $cashier.id
                    notes      = $SeedMarker
                }
                $backdates.Add([pscustomobject]@{ Table = "memberMemberships"; Id = $mm.id; Created = Format-PbDate $saleAt })
            }

            $backdates.Add([pscustomobject]@{ Table = "sales"; Id = $sale.id; Created = Format-PbDate $saleAt })
        }
        else {
            $lineCount = $rng.Next(1, 4)
            $picked = [System.Collections.Generic.List[object]]::new()
            $pickedIds = @{}
            while ($picked.Count -lt $lineCount) {
                $p = $products[$rng.Next($products.Count)]
                if (-not $pickedIds.ContainsKey($p.id)) {
                    $pickedIds[$p.id] = $true
                    $picked.Add($p)
                }
            }
            $lines = @()
            $total = 0.0
            foreach ($p in $picked) {
                $qty = $rng.Next(1, 4)
                $sub = [double]$p.price * $qty
                $total += $sub
                $lines += @{ product = $p; qty = $qty; sub = $sub }
            }
            $names = ($lines | ForEach-Object { $_.product.name })
            $descriptor = if ($names.Count -eq 1) { $names[0] } else { "$($names[0]) +$($names.Count - 1) more" }

            $saleBody = @{
                receiptNumber = $receipt
                branch        = $branch.id
                cashier       = $cashier.id
                totalAmount   = $total
                status        = "paid"
                isPaid        = $true
                customerName  = $member.name
                member        = $member.id
                descriptor    = $descriptor
                notes         = $SeedMarker
                isDeleted     = $false
            }
            $sale = Invoke-Pb -Method POST -Path "/api/collections/sales/records" -Headers $headers -Body $saleBody

            foreach ($line in $lines) {
                Invoke-Pb -Method POST -Path "/api/collections/saleItems/records" -Headers $headers -Body @{
                    sale        = $sale.id
                    product     = $line.product.id
                    productName = $line.product.name
                    quantity    = $line.qty
                    unitPrice   = $line.product.price
                    subtotal    = $line.sub
                    itemType    = "product"
                } | Out-Null
            }

            Invoke-Pb -Method POST -Path "/api/collections/payments/records" -Headers $headers -Body @{
                sale          = $sale.id
                amount        = $total
                paymentMethod = $method
                type          = $payType
                notes         = $SeedMarker
            } | Out-Null

            $backdates.Add([pscustomobject]@{ Table = "sales"; Id = $sale.id; Created = Format-PbDate $saleAt })
        }

        if ((($i + 1) % 10) -eq 0) {
            Write-Host "    ... $($i + 1)/$SalesPerOrg"
        }
    }
}

Write-Host ""
Write-Host "==> Backdating $($backdates.Count) records in SQLite ($DbPath)"
if (-not (Test-Path $DbPath)) {
    Write-Warning "DB not found; sales stay at create-time. Reports may not show 3-week spread."
}
else {
    $sqlFile = Join-Path $env:TEMP "hzn_seed_backdate.sql"
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("BEGIN;")
    foreach ($row in $backdates) {
        $id = $row.Id.Replace("'", "''")
        $created = $row.Created.Replace("'", "''")
        [void]$sb.AppendLine("UPDATE $($row.Table) SET created='$created', updated='$created' WHERE id='$id';")
        if ($row.Table -eq "sales") {
            [void]$sb.AppendLine("UPDATE saleItems SET created='$created', updated='$created' WHERE sale='$id';")
            [void]$sb.AppendLine("UPDATE payments SET created='$created', updated='$created' WHERE sale='$id';")
        }
    }
    [void]$sb.AppendLine("COMMIT;")
    Set-Content -Path $sqlFile -Value $sb.ToString() -Encoding UTF8
    sqlite3 $DbPath ".read $sqlFile"
    Remove-Item $sqlFile -ErrorAction SilentlyContinue
    Write-Host "  done"
}

Write-Host ""
Write-Host "==> Seed complete. Marker notes: $SeedMarker"
Write-Host "Re-run is safe: orgs with existing seeded sales are skipped."
