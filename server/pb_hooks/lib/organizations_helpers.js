/// <reference path="../../pb_data/types.d.ts" />

// Helpers for organizations.pb.js — Porkbun DNS subdomain provisioning.
//
// Hostname pattern: `{slug}.{PORKBUN_BASE_DOMAIN}` → e.g. `kyliegym.gyms.hznsystems.com`
//
// Required env vars (server-side only, never committed to the repo):
//   PORKBUN_API_KEY, PORKBUN_API_SECRET  — Porkbun API credentials
//   PORKBUN_BASE_DOMAIN                  — defaults to "gyms.hznsystems.com" (suffix after slug)
//   PORKBUN_DNS_ZONE                     — defaults to "hznsystems.com" (Porkbun API zone root)
//   PORKBUN_DNS_TARGET                   — server IP/host the A record points at
//
// If PORKBUN_API_KEY/PORKBUN_API_SECRET are unset (local dev/CI), the actual
// Porkbun call is skipped and the record is left "pending" instead of
// failing loudly or hitting production DNS from a dev machine.

function hostSuffix() {
    return $os.getenv("PORKBUN_BASE_DOMAIN") || "gyms.hznsystems.com"
}

function porkbunZone() {
    return $os.getenv("PORKBUN_DNS_ZONE") || "hznsystems.com"
}

function porkbunCredentialsPresent() {
    return !!($os.getenv("PORKBUN_API_KEY") && $os.getenv("PORKBUN_API_SECRET"))
}

function porkbunTarget() {
    return ($os.getenv("PORKBUN_DNS_TARGET") || "").trim()
}

function expectedSubdomain(record) {
    const slug = (record.getString("slug") || "").trim()
    if (!slug) return ""
    return `${slug}.${hostSuffix()}`
}

// Porkbun `name` for `{slug}.gyms.hznsystems.com` in zone `hznsystems.com` → `kyliegym.gyms`
function porkbunRecordName(slug) {
    const zone = porkbunZone()
    const suffix = hostSuffix()
    if (suffix === zone) {
        return slug
    }
    if (suffix.endsWith("." + zone)) {
        const labels = suffix.slice(0, -(zone.length + 1))
        return labels ? `${slug}.${labels}` : slug
    }
    return `${slug}.${suffix}`
}

function porkbunApiCall(endpoint, extraBody) {
    const body = {
        apikey: $os.getenv("PORKBUN_API_KEY"),
        secretapikey: $os.getenv("PORKBUN_API_SECRET"),
    }
    if (extraBody) {
        for (const key in extraBody) {
            body[key] = extraBody[key]
        }
    }

    const res = $http.send({
        url: `https://api.porkbun.com/api/json/v3/${endpoint}`,
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
        timeout: 15,
    })

    let parsed = {}
    try {
        parsed = JSON.parse(res.raw || "{}")
    } catch (parseErr) {
        parsed = {}
    }

    return { statusCode: res.statusCode, parsed: parsed }
}

function findDnsARecord(recordName) {
    const zone = porkbunZone()
    const { parsed } = porkbunApiCall(
        `dns/retrieveByNameType/${zone}/A/${recordName}`,
    )

    if (parsed.status === "SUCCESS" && Array.isArray(parsed.records) && parsed.records.length > 0) {
        return parsed.records[0]
    }

    // Fallback: scan all zone records (retrieveByNameType can fail on some multi-label names).
    const all = porkbunApiCall(`dns/retrieve/${zone}`)
    if (all.parsed.status !== "SUCCESS" || !Array.isArray(all.parsed.records)) {
        return null
    }

    const fqdn = `${recordName}.${zone}`
    for (let i = 0; i < all.parsed.records.length; i++) {
        const rec = all.parsed.records[i]
        if (rec.type !== "A") continue
        if (rec.name === fqdn || rec.name === recordName) {
            return rec
        }
    }

    return null
}

function findOrgByExpectedSubdomain(app, subdomain, excludeId) {
    if (!subdomain) return null

    const params = { subdomain: subdomain }
    let filter = 'subdomain = {:subdomain} && isDeleted = false'
    if (excludeId) {
        filter += " && id != {:excludeId}"
        params.excludeId = excludeId
    }

    const rows = app.findRecordsByFilter("organizations", filter, "", 1, 0, params)
    return rows.length > 0 ? rows[0] : null
}

// Returns `{ ok: true }` or `{ ok: false, message: string }`.
function validateSubdomainAvailability(app, record, excludeId) {
    const slug = (record.getString("slug") || "").trim()
    if (!slug) {
        return { ok: false, message: "slug is required" }
    }

    const subdomain = expectedSubdomain(record)
    const conflict = findOrgByExpectedSubdomain(app, subdomain, excludeId)
    if (conflict) {
        return {
            ok: false,
            message: `subdomain "${subdomain}" is already assigned to another organization`,
        }
    }

    if (!porkbunCredentialsPresent()) {
        return { ok: true }
    }

    const recordName = porkbunRecordName(slug)
    const existing = findDnsARecord(recordName)
    if (!existing) {
        return { ok: true }
    }

    const target = porkbunTarget()
    const existingIp = (existing.content || "").trim()

    if (target && existingIp === target) {
        return { ok: true, alreadyProvisioned: true }
    }

    return {
        ok: false,
        message: `DNS name "${subdomain}" is already in use (points to ${existingIp || "another host"})`,
    }
}

function assertSubdomainAvailable(app, record, excludeId) {
    const result = validateSubdomainAvailability(app, record, excludeId)
    if (!result.ok) {
        throw new BadRequestError(result.message)
    }
}

// Handler: onRecordCreateRequest("organizations")
// DNS linking is no longer required — skip Porkbun availability checks.
function onCreateRequest(e) {
    e.next()
}

// Handler: onRecordUpdateRequest("organizations")
function onUpdateRequest(e) {
    e.next()
}

function getOriginalRecord(record) {
    if (!record) return null
    if (typeof record.originalCopy === "function") {
        return record.originalCopy()
    }
    return null
}

// Creates/refreshes the Porkbun DNS record for `record`'s current slug and
// persists the outcome on the record itself. Safe to call repeatedly.
function provisionSubdomain(app, record) {
    const subdomain = expectedSubdomain(record)
    if (!subdomain) return

    const slug = record.getString("slug").trim()
    const recordName = porkbunRecordName(slug)
    record.set("subdomain", subdomain)

    if (!porkbunCredentialsPresent()) {
        record.set("dnsStatus", "pending")
        record.set("dnsError", "")
        record.set("dnsLastAttempt", new Date().toISOString())
        app.save(record)
        console.log(`[organizations] Porkbun credentials not configured, leaving ${subdomain} pending`)
        return
    }

    const target = porkbunTarget()
    if (!target) {
        record.set("dnsStatus", "failed")
        record.set("dnsError", "PORKBUN_DNS_TARGET is not configured")
        record.set("dnsLastAttempt", new Date().toISOString())
        app.save(record)
        return
    }

    const availability = validateSubdomainAvailability(app, record, record.id)
    if (!availability.ok) {
        record.set("dnsStatus", "failed")
        record.set("dnsError", availability.message)
        record.set("dnsLastAttempt", new Date().toISOString())
        app.save(record)
        return
    }

    if (availability.alreadyProvisioned) {
        record.set("dnsStatus", "created")
        record.set("dnsError", "")
        record.set("dnsLastAttempt", new Date().toISOString())
        app.save(record)
        console.log(`[organizations] DNS already points at ${target} for ${subdomain}`)
        return
    }

    const zone = porkbunZone()

    try {
        const { statusCode, parsed } = porkbunApiCall(`dns/create/${zone}`, {
            name: recordName,
            type: "A",
            content: target,
            ttl: "600",
        })

        if (statusCode >= 200 && statusCode < 300 && parsed.status === "SUCCESS") {
            record.set("dnsStatus", "created")
            record.set("dnsError", "")
        } else {
            const message = parsed.message || `Porkbun returned HTTP ${statusCode}`
            const existing = findDnsARecord(recordName)
            if (existing && (existing.content || "").trim() === target) {
                record.set("dnsStatus", "created")
                record.set("dnsError", "")
            } else {
                record.set("dnsStatus", "failed")
                record.set("dnsError", message)
            }
        }
    } catch (err) {
        record.set("dnsStatus", "failed")
        record.set("dnsError", String(err))
    }

    record.set("dnsLastAttempt", new Date().toISOString())
    app.save(record)
}

// Handler: onRecordAfterCreateSuccess("organizations")
// Auto DNS provisioning disabled — organizations do not need a subdomain.
function onCreateSuccess(e) {
    e.next()
}

// Handler: onRecordAfterUpdateSuccess("organizations")
function onUpdateSuccess(e) {
    e.next()
}

function requireOrganizationsManage(e) {
    const authRecord = e.auth
    if (!authRecord) {
        throw new ForbiddenError("authentication required")
    }
    try {
        if (authRecord.collection().name === "_superusers") {
            e.next()
            return
        }
    } catch (_) {
        // fall through to superAdmin check
    }
    if (!authRecord.getBool("superAdmin")) {
        throw new ForbiddenError("superAdmin required")
    }
    e.next()
}

// Route handler: POST /api/organizations/:id/retry-dns
function retryDns(e) {
    const id = e.request.pathValue("id")
    const record = e.app.findRecordById("organizations", id)
    provisionSubdomain(e.app, record)
    return e.json(200, {
        success: record.getString("dnsStatus") === "created",
        dnsStatus: record.getString("dnsStatus"),
        dnsError: record.getString("dnsError"),
    })
}

// Scheduled job — no-op; auto DNS retry disabled with org DNS linking.
function retryFailed() {
    // intentionally empty
}

module.exports = {
    hostSuffix: hostSuffix,
    porkbunZone: porkbunZone,
    porkbunRecordName: porkbunRecordName,
    expectedSubdomain: expectedSubdomain,
    validateSubdomainAvailability: validateSubdomainAvailability,
    provisionSubdomain: provisionSubdomain,
    onCreateRequest: onCreateRequest,
    onUpdateRequest: onUpdateRequest,
    onCreateSuccess: onCreateSuccess,
    onUpdateSuccess: onUpdateSuccess,
    requireOrganizationsManage: requireOrganizationsManage,
    retryDns: retryDns,
    retryFailed: retryFailed,
}
