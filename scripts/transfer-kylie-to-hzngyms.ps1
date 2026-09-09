# Transfer records from legacy kyliegym PocketBase to HZN Gyms kyliegym org.
# Default: dry-run (no writes). Pass -Apply to mutate the target.
#
# Usage:
#   .\scripts\transfer-kylie-to-hzngyms.ps1 -Since 2026-09-08 -Until 2026-09-09
#   .\scripts\transfer-kylie-to-hzngyms.ps1 -Since 2026-09-08 -Until 2026-09-09 -Apply
#   .\scripts\transfer-kylie-to-hzngyms.ps1 -Since 2026-09-08 -Until 2026-09-09 -Apply -IncludePictures
#
# Env (from .env): KYLIE_GYM_PROD_URL/EMAIL/PASSWORD, PROD_URL/EMAIL/PASSWORD

param(
    [Parameter(Mandatory = $true)][string]$Since,   # Manila date yyyy-MM-dd (inclusive)
    [Parameter(Mandatory = $true)][string]$Until,   # Manila date yyyy-MM-dd (exclusive)
    [switch]$Apply,
    [switch]$IncludePictures,
    [switch]$IncludeActivityLogs,
    [string]$OrgSlug = "kyliegym",
    [string]$EnvFile = ""
)

$ErrorActionPreference = "Stop"

function Import-DotEnv {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return }
    Get-Content $Path | ForEach-Object {
        if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
        $k, $v = $_ -split '=', 2
        $k = $k.Trim(); $v = $v.Trim().Trim('"').Trim("'")
        if ($k -and -not [Environment]::GetEnvironmentVariable($k)) {
            [Environment]::SetEnvironmentVariable($k, $v, "Process")
        }
    }
}

if (-not $EnvFile) { $EnvFile = Join-Path $PSScriptRoot "..\.env" }
Import-DotEnv $EnvFile

$SourceUrl = $env:KYLIE_GYM_PROD_URL
$SourceEmail = $env:KYLIE_GYM_PROD_EMAIL
$SourcePass = $env:KYLIE_GYM_PROD_PASSWORD
$TargetUrl = $env:PROD_URL
$TargetEmail = $env:PROD_EMAIL
$TargetPass = $env:PROD_PASSWORD

if (-not ($SourceUrl -and $SourceEmail -and $SourcePass -and $TargetUrl -and $TargetEmail -and $TargetPass)) {
    Write-Error "Missing KYLIE_GYM_PROD_* or PROD_* credentials in env/.env"
    exit 1
}

function Get-PbToken([string]$Url, [string]$Identity, [string]$Pass) {
    $body = @{ identity = $Identity; password = $Pass } | ConvertTo-Json
    return (Invoke-RestMethod -Uri "$Url/api/collections/_superusers/auth-with-password" `
        -Method POST -ContentType "application/json" -Body $body).token
}

function Invoke-Pb {
    param(
        [string]$BaseUrl,
        [string]$Token,
        [string]$Method,
        [string]$Path,
        [object]$Body = $null
    )
    $params = @{
        Uri     = "$BaseUrl$Path"
        Method  = $Method
        Headers = @{ Authorization = $Token }
    }
    if ($null -ne $Body) {
        $params.ContentType = "application/json"
        $params.Body = ($Body | ConvertTo-Json -Depth 8 -Compress)
    }
    try {
        return Invoke-RestMethod @params
    } catch {
        $resp = $_.Exception.Response
        $detail = $_.ErrorDetails.Message
        if (-not $detail -and $resp) {
            try {
                $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
                $detail = $reader.ReadToEnd()
            } catch {}
        }
        throw "$Method $Path failed: $detail"
    }
}

function Get-PbAll {
    param([string]$BaseUrl, [string]$Token, [string]$Collection, [string]$Filter = "", [string]$Fields = "")
    $page = 1
    $fetched = 0
    $total = 1
    while ($fetched -lt $total) {
        $q = "page=$page&perPage=200&sort=created"
        if ($Filter) { $q += "&filter=$([uri]::EscapeDataString($Filter))" }
        if ($Fields) { $q += "&fields=$Fields" }
        $r = Invoke-Pb $BaseUrl $Token GET "/api/collections/$Collection/records?$q"
        $total = [int]$r.totalItems
        $batch = @($r.items)
        if ($batch.Count -eq 0) { break }
        foreach ($it in $batch) {
            Write-Output $it
            $fetched++
        }
        $page++
    }
}

function Test-PbExists {
    param([string]$BaseUrl, [string]$Token, [string]$Collection, [string]$Id)
    try {
        $null = Invoke-Pb $BaseUrl $Token GET "/api/collections/$Collection/records/$Id"
        return $true
    } catch { return $false }
}

function Get-PbOne {
    param([string]$BaseUrl, [string]$Token, [string]$Collection, [string]$Id)
    try {
        return Invoke-Pb $BaseUrl $Token GET "/api/collections/$Collection/records/$Id"
    } catch { return $null }
}

function Get-ManilaUtcRange([string]$SinceDate, [string]$UntilDate) {
    $tz = $null
    foreach ($id in @("Singapore Standard Time", "Asia/Manila", "China Standard Time")) {
        try { $tz = [TimeZoneInfo]::FindSystemTimeZoneById($id); break } catch {}
    }
    if (-not $tz) { throw "Could not find +08 timezone" }
    $startLocal = [datetime]::ParseExact($SinceDate, "yyyy-MM-dd", $null)
    $endLocal = [datetime]::ParseExact($UntilDate, "yyyy-MM-dd", $null)
    return @{
        SinceUtc = ([TimeZoneInfo]::ConvertTimeToUtc($startLocal, $tz)).ToString("yyyy-MM-dd HH:mm:ss.fffZ")
        UntilUtc = ([TimeZoneInfo]::ConvertTimeToUtc($endLocal, $tz)).ToString("yyyy-MM-dd HH:mm:ss.fffZ")
    }
}

function NormName([string]$s) {
    if (-not $s) { return "" }
    return (($s.ToUpperInvariant() -replace "\s+", " ").Trim())
}

$SkipKeys = @("collectionId", "collectionName", "expand", "photo", "image", "paymentProof")

function ConvertTo-Hashtable($obj) {
    $h = @{}
    if ($null -eq $obj) { return $h }
    if ($obj -is [hashtable]) { return $obj }
    foreach ($p in $obj.PSObject.Properties) {
        if ($p.Name -in $SkipKeys) { continue }
        $h[$p.Name] = $p.Value
    }
    return $h
}

function Remap-Id([hashtable]$Map, [string]$Id) {
    if (-not $Id) { return "" }
    if ($Map.ContainsKey($Id)) { return $Map[$Id] }
    return $Id
}

$script:Stats = @{}
function Bump([string]$Key) {
    if (-not $script:Stats.ContainsKey($Key)) { $script:Stats[$Key] = 0 }
    $script:Stats[$Key] = [int]$script:Stats[$Key] + 1
}

$script:Warnings = [System.Collections.Generic.List[string]]::new()
function Warn([string]$Msg) {
    $script:Warnings.Add($Msg)
    Write-Host "  WARN: $Msg" -ForegroundColor Yellow
}

function Upsert-Record {
    param(
        [string]$Collection,
        [hashtable]$Payload,
        [string]$TargetId
    )
    $body = @{} + $Payload
    $body["id"] = $TargetId

    $existing = Get-PbOne $TargetUrl $script:TargetToken $Collection $TargetId
    $action = if ($existing) { "update" } else { "create" }
    $label = "$Collection/$TargetId"

    if (-not $Apply) {
        Write-Host "  DRY $action $label"
        Bump "${Collection}:$action"
        return
    }

    if ($existing) {
        $patch = @{} + $body
        $patch.Remove("id")
        $patch.Remove("created")
        $null = Invoke-Pb $TargetUrl $script:TargetToken PATCH "/api/collections/$Collection/records/$TargetId" $patch
        Write-Host "  UPDATED $label"
        Bump "${Collection}:update"
    } else {
        $null = Invoke-Pb $TargetUrl $script:TargetToken POST "/api/collections/$Collection/records" $body
        Write-Host "  CREATED $label"
        Bump "${Collection}:create"
    }
}

function Transfer-FileIfNeeded {
    param(
        [string]$Collection,
        [string]$SourceId,
        [string]$TargetId,
        [string]$Field,
        [string]$FileName
    )
    if (-not $IncludePictures) { return }
    if (-not $FileName) { return }

    $srcRec = Invoke-Pb $SourceUrl $script:SourceToken GET "/api/collections/$Collection/records/$SourceId"
    $srcUrl = "$SourceUrl/api/files/$($srcRec.collectionId)/$SourceId/$FileName"

    if (-not $Apply) {
        Write-Host "  DRY upload ${Collection}/${TargetId}.${Field} ($FileName)"
        Bump "${Collection}:file"
        return
    }

    Add-Type -AssemblyName System.Net.Http -ErrorAction SilentlyContinue
    $tmp = Join-Path $env:TEMP "pb-xfer-$TargetId-$Field-$FileName"
    try {
        Invoke-WebRequest -Uri $srcUrl -Headers @{ Authorization = $script:SourceToken } -OutFile $tmp
        $multipart = [System.Net.Http.MultipartFormDataContent]::new()
        $fs = [System.IO.File]::OpenRead($tmp)
        $streamContent = [System.Net.Http.StreamContent]::new($fs)
        $multipart.Add($streamContent, $Field, $FileName)
        $client = [System.Net.Http.HttpClient]::new()
        $client.DefaultRequestHeaders.Add("Authorization", $script:TargetToken)
        $resp = $client.PatchAsync("$TargetUrl/api/collections/$Collection/records/$TargetId", $multipart).Result
        $fs.Dispose(); $multipart.Dispose(); $client.Dispose()
        if (-not $resp.IsSuccessStatusCode) {
            $txt = $resp.Content.ReadAsStringAsync().Result
            Warn "file upload failed ${Collection}/${TargetId}.${Field}: $txt"
        } else {
            Write-Host "  UPLOADED ${Collection}/${TargetId}.${Field}"
            Bump "${Collection}:file"
        }
    } finally {
        if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
    }
}

# --- main ---------------------------------------------------------------------

$range = Get-ManilaUtcRange $Since $Until
$sinceUtc = $range.SinceUtc
$untilUtc = $range.UntilUtc
$windowFilter = "(created >= '$sinceUtc' && created < '$untilUtc') || (updated >= '$sinceUtc' && updated < '$untilUtc')"

Write-Host "=== kylie -> hzngyms transfer ==="
Write-Host "Mode: $(if ($Apply) { 'APPLY' } else { 'DRY-RUN' })  pictures=$(if ($IncludePictures){'on'}else{'off'})  activityLogs=$(if ($IncludeActivityLogs){'on'}else{'off'})"
Write-Host "Window Manila [$Since, $Until) -> UTC [$sinceUtc, $untilUtc)"
Write-Host "Source: $SourceUrl"
Write-Host "Target: $TargetUrl orgSlug=$OrgSlug"

$script:SourceToken = Get-PbToken $SourceUrl $SourceEmail $SourcePass
$script:TargetToken = Get-PbToken $TargetUrl $TargetEmail $TargetPass
Write-Host "Auth OK"

$orgs = Get-PbAll $TargetUrl $script:TargetToken "organizations" "slug='$OrgSlug'" "id,name,slug"
if ($orgs.Count -eq 0) { throw "Target organization slug=$OrgSlug not found" }
$org = $orgs[0]
$orgId = $org.id
Write-Host "Target org: $($org.name) ($orgId)"

$branches = Get-PbAll $TargetUrl $script:TargetToken "branches" "organization='$orgId'" "id,name,code"
if ($branches.Count -eq 0) { throw "No branches for org $orgId" }
$branchId = $branches[0].id
Write-Host "Target branch: $($branches[0].name) ($branchId) [using first]"

$memberMap = @{}
$userMap = @{}
$membershipMap = @{}
$productMap = @{}
$addOnMap = @{}
$memberMembershipMap = @{}

Write-Host ""
Write-Host "-- users (map only) --"
$srcUsers = Get-PbAll $SourceUrl $script:SourceToken "users" "" "id,email,name"
$tgtUsers = Get-PbAll $TargetUrl $script:TargetToken "users" "" "id,email,name"
$tgtByEmail = @{}
foreach ($u in $tgtUsers) { if ($u.email) { $tgtByEmail[$u.email.ToLowerInvariant()] = $u.id } }
foreach ($u in $srcUsers) {
    if (Test-PbExists $TargetUrl $script:TargetToken "users" $u.id) {
        $userMap[$u.id] = $u.id
        Write-Host "  map same-id $($u.email) -> $($u.id)"
    } elseif ($u.email -and $tgtByEmail.ContainsKey($u.email.ToLowerInvariant())) {
        $userMap[$u.id] = $tgtByEmail[$u.email.ToLowerInvariant()]
        Write-Host "  map email $($u.email) -> $($userMap[$u.id])"
    } else {
        Warn "user $($u.email) ($($u.id)) has no target match - FKs will be cleared"
        $userMap[$u.id] = ""
    }
}

function Map-User([string]$Id) {
    if (-not $Id) { return "" }
    if ($userMap.ContainsKey($Id)) { return $userMap[$Id] }
    if (Test-PbExists $TargetUrl $script:TargetToken "users" $Id) {
        $userMap[$Id] = $Id
        return $Id
    }
    Warn "unmapped user ref $Id - clearing"
    $userMap[$Id] = ""
    return ""
}

Write-Host ""
Write-Host "-- memberships --"
$srcMemberships = Get-PbAll $SourceUrl $script:SourceToken "memberships" "branch='$branchId'"
$tgtMemberships = Get-PbAll $TargetUrl $script:TargetToken "memberships" "branch='$branchId'"
$tgtMemByKey = @{}
foreach ($m in $tgtMemberships) {
    $key = "$($m.durationUnit)|$($m.durationValue)|$($m.price)"
    if (-not $tgtMemByKey.ContainsKey($key)) { $tgtMemByKey[$key] = $m.id }
    $nkey = "n:$(NormName $m.name)|$($m.price)"
    if (-not $tgtMemByKey.ContainsKey($nkey)) { $tgtMemByKey[$nkey] = $m.id }
}

$touchedMemberships = Get-PbAll $SourceUrl $script:SourceToken "memberships" $windowFilter
$windowedMM = Get-PbAll $SourceUrl $script:SourceToken "memberMemberships" $windowFilter
$neededMembershipIds = @{}
foreach ($m in $touchedMemberships) { $neededMembershipIds[$m.id] = $true }
foreach ($m in $windowedMM) { if ($m.membership) { $neededMembershipIds[$m.membership] = $true } }

$allSrcMembershipsById = @{}
foreach ($m in $srcMemberships) { $allSrcMembershipsById[$m.id] = $m }
foreach ($mid in @($neededMembershipIds.Keys)) {
    if (-not $allSrcMembershipsById.ContainsKey($mid)) {
        $rec = Get-PbOne $SourceUrl $script:SourceToken "memberships" $mid
        if ($rec) { $allSrcMembershipsById[$mid] = $rec }
    }
}

$touchedMemIdSet = @{}
foreach ($m in $touchedMemberships) { $touchedMemIdSet[$m.id] = $true }

foreach ($mid in @($neededMembershipIds.Keys)) {
    $m = $allSrcMembershipsById[$mid]
    if (-not $m) { Warn "membership $mid missing on source"; continue }

    $targetId = $null
    if (Test-PbExists $TargetUrl $script:TargetToken "memberships" $m.id) {
        $targetId = $m.id
    } else {
        $key = "$($m.durationUnit)|$($m.durationValue)|$($m.price)"
        $nkey = "n:$(NormName $m.name)|$($m.price)"
        if ($tgtMemByKey.ContainsKey($key)) { $targetId = $tgtMemByKey[$key] }
        elseif ($tgtMemByKey.ContainsKey($nkey)) { $targetId = $tgtMemByKey[$nkey] }
    }

    if ($targetId -and $targetId -ne $m.id) {
        $membershipMap[$m.id] = $targetId
        Write-Host "  map $($m.name) $($m.id) -> $targetId"
        Bump "memberships:map"
        continue
    }
    if ($targetId -eq $m.id) {
        $membershipMap[$m.id] = $m.id
        if ($touchedMemIdSet.ContainsKey($m.id)) {
            $payload = ConvertTo-Hashtable $m
            $payload["branch"] = $branchId
            Upsert-Record "memberships" $payload $m.id
        } else {
            Write-Host "  skip same-id $($m.name) ($($m.id))"
            Bump "memberships:skip"
        }
        continue
    }

    $membershipMap[$m.id] = $m.id
    $payload = ConvertTo-Hashtable $m
    $payload["branch"] = $branchId
    Upsert-Record "memberships" $payload $m.id
}

Write-Host ""
Write-Host "-- membershipAddOns --"
$srcAddOns = Get-PbAll $SourceUrl $script:SourceToken "membershipAddOns" $windowFilter
$windowedMMA = Get-PbAll $SourceUrl $script:SourceToken "memberMembershipAddOns" $windowFilter
$neededAddOnIds = @{}
foreach ($a in $srcAddOns) { $neededAddOnIds[$a.id] = $true }
foreach ($a in $windowedMMA) { if ($a.membershipAddOn) { $neededAddOnIds[$a.membershipAddOn] = $true } }

foreach ($aid in @($neededAddOnIds.Keys)) {
    $a = Get-PbOne $SourceUrl $script:SourceToken "membershipAddOns" $aid
    if (-not $a) { Warn "membershipAddOn $aid missing"; continue }
    $payload = ConvertTo-Hashtable $a
    if ($payload["membership"]) {
        $payload["membership"] = Remap-Id $membershipMap $payload["membership"]
    }
    $addOnMap[$a.id] = $a.id
    Upsert-Record "membershipAddOns" $payload $a.id
}

Write-Host ""
Write-Host "-- products --"
$srcProducts = Get-PbAll $SourceUrl $script:SourceToken "products" $windowFilter
$tgtProducts = Get-PbAll $TargetUrl $script:TargetToken "products" "branch='$branchId'"
$tgtProdByName = @{}
foreach ($p in $tgtProducts) {
    $nkey = "$(NormName $p.name)|$($p.price)"
    if (-not $tgtProdByName.ContainsKey($nkey)) { $tgtProdByName[$nkey] = $p.id }
}

foreach ($p in $srcProducts) {
    $targetId = $null
    if (Test-PbExists $TargetUrl $script:TargetToken "products" $p.id) {
        $targetId = $p.id
    } else {
        $nkey = "$(NormName $p.name)|$($p.price)"
        if ($tgtProdByName.ContainsKey($nkey)) { $targetId = $tgtProdByName[$nkey] }
    }

    if ($targetId -and $targetId -ne $p.id) {
        $productMap[$p.id] = $targetId
        Write-Host "  map $($p.name) $($p.id) -> $targetId"
        Bump "products:map"
    } else {
        $productMap[$p.id] = $p.id
        $payload = ConvertTo-Hashtable $p
        $payload["branch"] = $branchId
        if ($payload["category"] -and -not (Test-PbExists $TargetUrl $script:TargetToken "productCategories" $payload["category"])) {
            $catId = $payload["category"]
            Warn "product $($p.name): category $catId missing - clearing"
            $payload["category"] = ""
        }
        if ($payload["quantityUnit"] -and -not (Test-PbExists $TargetUrl $script:TargetToken "quantityUnits" $payload["quantityUnit"])) {
            $payload["quantityUnit"] = ""
        }
        Upsert-Record "products" $payload $p.id
        if ($IncludePictures -and $p.image) {
            Transfer-FileIfNeeded "products" $p.id $p.id "image" $p.image
        }
    }
}

Write-Host ""
Write-Host "-- members --"
$srcMembersAll = Get-PbAll $SourceUrl $script:SourceToken "members" "branch='$branchId'" "id,name,mobileNumber,photo"
$tgtMembersAll = Get-PbAll $TargetUrl $script:TargetToken "members" "branch='$branchId'" "id,name,mobileNumber,photo"
$tgtByName = @{}
foreach ($m in $tgtMembersAll) {
    $n = NormName $m.name
    if (-not $tgtByName.ContainsKey($n)) { $tgtByName[$n] = [System.Collections.Generic.List[object]]::new() }
    $tgtByName[$n].Add($m)
}

foreach ($m in $srcMembersAll) {
    $n = NormName $m.name
    if ($tgtByName.ContainsKey($n) -and $tgtByName[$n].Count -eq 1) {
        $memberMap[$m.id] = $tgtByName[$n][0].id
    } elseif ($tgtByName.ContainsKey($n) -and $tgtByName[$n].Count -gt 1) {
        Warn "ambiguous member name '$($m.name)' - using first $($tgtByName[$n][0].id)"
        $memberMap[$m.id] = $tgtByName[$n][0].id
    } else {
        $memberMap[$m.id] = $m.id
    }
}

$touchedMembers = Get-PbAll $SourceUrl $script:SourceToken "members" $windowFilter
$refMemberIds = @{}
foreach ($m in $touchedMembers) { $refMemberIds[$m.id] = $true }
foreach ($c in @(Get-PbAll $SourceUrl $script:SourceToken "checkIns" $windowFilter "id,member")) {
    if ($c.member) { $refMemberIds[$c.member] = $true }
}
foreach ($c in @(Get-PbAll $SourceUrl $script:SourceToken "memberCards" $windowFilter "id,member")) {
    if ($c.member) { $refMemberIds[$c.member] = $true }
}
foreach ($c in $windowedMM) { if ($c.member) { $refMemberIds[$c.member] = $true } }
foreach ($s in @(Get-PbAll $SourceUrl $script:SourceToken "sales" $windowFilter "id,member")) {
    if ($s.member) { $refMemberIds[$s.member] = $true }
}

foreach ($mid in @($refMemberIds.Keys)) {
    $m = Get-PbOne $SourceUrl $script:SourceToken "members" $mid
    if (-not $m) { Warn "member $mid missing on source"; continue }
    if (-not $memberMap.ContainsKey($mid)) {
        $n = NormName $m.name
        if ($tgtByName.ContainsKey($n) -and $tgtByName[$n].Count -ge 1) {
            $memberMap[$mid] = $tgtByName[$n][0].id
        } else {
            $memberMap[$mid] = $mid
        }
    }
    $targetId = $memberMap[$mid]
    $isNew = ($targetId -eq $mid) -and -not (Test-PbExists $TargetUrl $script:TargetToken "members" $mid)

    if (-not $isNew -and $targetId -ne $mid) {
        $payload = ConvertTo-Hashtable $m
        $payload.Remove("id")
        $payload["branch"] = $branchId
        $payload["addedBy"] = Map-User $payload["addedBy"]
        if (-not $Apply) {
            Write-Host "  DRY update members/$targetId (from source $mid $($m.name))"
            Bump "members:update"
        } else {
            $payload.Remove("created")
            $null = Invoke-Pb $TargetUrl $script:TargetToken PATCH "/api/collections/members/records/$targetId" $payload
            Write-Host "  UPDATED members/$targetId ($($m.name))"
            Bump "members:update"
        }
        if ($IncludePictures -and $m.photo) {
            Transfer-FileIfNeeded "members" $mid $targetId "photo" $m.photo
        }
    } else {
        $payload = ConvertTo-Hashtable $m
        $payload["branch"] = $branchId
        $payload["addedBy"] = Map-User $payload["addedBy"]
        $memberMap[$mid] = $mid
        Upsert-Record "members" $payload $mid
        if ($IncludePictures -and $m.photo) {
            Transfer-FileIfNeeded "members" $mid $mid "photo" $m.photo
        }
    }
}

Write-Host ""
Write-Host "-- memberCards --"
foreach ($c in @(Get-PbAll $SourceUrl $script:SourceToken "memberCards" $windowFilter)) {
    $payload = ConvertTo-Hashtable $c
    $payload["member"] = Remap-Id $memberMap $payload["member"]
    Upsert-Record "memberCards" $payload $c.id
}

Write-Host ""
Write-Host "-- memberMemberships --"
foreach ($m in $windowedMM) {
    $payload = ConvertTo-Hashtable $m
    $payload["member"] = Remap-Id $memberMap $payload["member"]
    $payload["membership"] = Remap-Id $membershipMap $payload["membership"]
    $payload["branch"] = $branchId
    $payload["soldBy"] = Map-User $payload["soldBy"]
    $memberMembershipMap[$m.id] = $m.id
    Upsert-Record "memberMemberships" $payload $m.id
}

Write-Host ""
Write-Host "-- memberMembershipAddOns --"
foreach ($a in $windowedMMA) {
    $payload = ConvertTo-Hashtable $a
    $payload["memberMembership"] = Remap-Id $memberMembershipMap $payload["memberMembership"]
    $payload["membershipAddOn"] = Remap-Id $addOnMap $payload["membershipAddOn"]
    Upsert-Record "memberMembershipAddOns" $payload $a.id
}

Write-Host ""
Write-Host "-- sales --"
$windowedSales = Get-PbAll $SourceUrl $script:SourceToken "sales" $windowFilter
foreach ($s in $windowedSales) {
    $payload = ConvertTo-Hashtable $s
    $payload["branch"] = $branchId
    $payload["member"] = Remap-Id $memberMap $payload["member"]
    $payload["cashier"] = Map-User $payload["cashier"]
    $payload["voidedBy"] = Map-User $payload["voidedBy"]
    Upsert-Record "sales" $payload $s.id
}

Write-Host ""
Write-Host "-- saleItems --"
$saleItemById = @{}
foreach ($it in @(Get-PbAll $SourceUrl $script:SourceToken "saleItems" $windowFilter)) {
    $saleItemById[$it.id] = $it
}
$saleIds = @{}
foreach ($s in $windowedSales) { $saleIds[$s.id] = $true }
foreach ($sid in @($saleIds.Keys)) {
    foreach ($it in @(Get-PbAll $SourceUrl $script:SourceToken "saleItems" "sale='$sid'")) {
        $saleItemById[$it.id] = $it
    }
}
foreach ($it in @($saleItemById.Values)) {
    $payload = ConvertTo-Hashtable $it
    if ($payload["product"]) { $payload["product"] = Remap-Id $productMap $payload["product"] }
    if ($payload["productLot"] -and -not (Test-PbExists $TargetUrl $script:TargetToken "productLots" $payload["productLot"])) {
        $payload["productLot"] = ""
    }
    Upsert-Record "saleItems" $payload $it.id
}

Write-Host ""
Write-Host "-- payments --"
$paymentById = @{}
foreach ($p in @(Get-PbAll $SourceUrl $script:SourceToken "payments" $windowFilter)) {
    $paymentById[$p.id] = $p
}
foreach ($sid in @($saleIds.Keys)) {
    foreach ($p in @(Get-PbAll $SourceUrl $script:SourceToken "payments" "sale='$sid'")) {
        $paymentById[$p.id] = $p
    }
}
foreach ($p in @($paymentById.Values)) {
    $payload = ConvertTo-Hashtable $p
    Upsert-Record "payments" $payload $p.id
    if ($IncludePictures -and $p.paymentProof) {
        Transfer-FileIfNeeded "payments" $p.id $p.id "paymentProof" $p.paymentProof
    }
}

Write-Host ""
Write-Host "-- checkIns --"
foreach ($c in @(Get-PbAll $SourceUrl $script:SourceToken "checkIns" $windowFilter)) {
    $payload = ConvertTo-Hashtable $c
    $payload["member"] = Remap-Id $memberMap $payload["member"]
    $payload["branch"] = $branchId
    $payload["checkedInBy"] = Map-User $payload["checkedInBy"]
    $payload["voidedBy"] = Map-User $payload["voidedBy"]
    if ($payload["memberMembership"]) {
        $payload["memberMembership"] = Remap-Id $memberMembershipMap $payload["memberMembership"]
    }
    Upsert-Record "checkIns" $payload $c.id
}

if ($IncludeActivityLogs) {
    Write-Host ""
    Write-Host "-- activityLogs --"
    foreach ($a in @(Get-PbAll $SourceUrl $script:SourceToken "activityLogs" $windowFilter)) {
        $payload = ConvertTo-Hashtable $a
        if ($payload.ContainsKey("user")) { $payload["user"] = Map-User $payload["user"] }
        if ($payload.ContainsKey("branch")) { $payload["branch"] = $branchId }
        Upsert-Record "activityLogs" $payload $a.id
    }
}

Write-Host ""
Write-Host "=== summary ==="
$script:Stats.GetEnumerator() | Sort-Object Name | ForEach-Object {
    Write-Host ("  {0,-32} {1}" -f $_.Key, $_.Value)
}
if ($script:Warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "Warnings ($($script:Warnings.Count)):" -ForegroundColor Yellow
    $script:Warnings | Select-Object -Unique | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}
if (-not $Apply) {
    Write-Host ""
    Write-Host "Dry-run only. Re-run with -Apply to write." -ForegroundColor Cyan
}
