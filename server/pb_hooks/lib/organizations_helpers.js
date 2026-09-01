/// <reference path="../../pb_data/types.d.ts" />

// Helpers for organizations.pb.js — Porkbun DNS subdomain provisioning.
//
// Required env vars (server-side only, never committed to the repo):
//   PORKBUN_API_KEY, PORKBUN_API_SECRET  — Porkbun API credentials
//   PORKBUN_BASE_DOMAIN                  — defaults to "hzngyms.com"
//   PORKBUN_DNS_TARGET                   — server IP/host the A record points at
//
// If PORKBUN_API_KEY/PORKBUN_API_SECRET are unset (local dev/CI), the actual
// Porkbun call is skipped and the record is left "pending" instead of
// failing loudly or hitting production DNS from a dev machine.

function baseDomain() {
    return $os.getenv("PORKBUN_BASE_DOMAIN") || "hzngyms.com"
}

function porkbunCredentialsPresent() {
    return !!($os.getenv("PORKBUN_API_KEY") && $os.getenv("PORKBUN_API_SECRET"))
}

function expectedSubdomain(record) {
    const slug = (record.getString("slug") || "").trim()
    if (!slug) return ""
    return `${slug}.${baseDomain()}`
}

// Creates/refreshes the Porkbun DNS record for `record`'s current slug and
// persists the outcome on the record itself. Safe to call repeatedly.
function provisionSubdomain(app, record) {
    const subdomain = expectedSubdomain(record)
    if (!subdomain) return

    const slug = record.getString("slug").trim()
    record.set("subdomain", subdomain)

    if (!porkbunCredentialsPresent()) {
        record.set("dnsStatus", "pending")
        record.set("dnsError", "")
        record.set("dnsLastAttempt", new Date().toISOString())
        app.save(record)
        console.log(`[organizations] Porkbun credentials not configured, leaving ${subdomain} pending`)
        return
    }

    const domain = baseDomain()
    const target = $os.getenv("PORKBUN_DNS_TARGET") || ""

    try {
        const res = $http.send({
            url: `https://api.porkbun.com/api/json/v3/dns/create/${domain}`,
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                apikey: $os.getenv("PORKBUN_API_KEY"),
                secretapikey: $os.getenv("PORKBUN_API_SECRET"),
                name: slug,
                type: "A",
                content: target,
                ttl: "600",
            }),
            timeout: 15,
        })

        let parsed = {}
        try {
            parsed = JSON.parse(res.raw || "{}")
        } catch (parseErr) {
            parsed = {}
        }

        if (res.statusCode >= 200 && res.statusCode < 300 && parsed.status === "SUCCESS") {
            record.set("dnsStatus", "created")
            record.set("dnsError", "")
        } else {
            record.set("dnsStatus", "failed")
            record.set("dnsError", parsed.message || `Porkbun returned HTTP ${res.statusCode}`)
        }
    } catch (err) {
        record.set("dnsStatus", "failed")
        record.set("dnsError", String(err))
    }

    record.set("dnsLastAttempt", new Date().toISOString())
    app.save(record)
}

// Handler: onRecordAfterCreateSuccess("organizations")
function onCreateSuccess(e) {
    e.next()
    try {
        provisionSubdomain(e.app, e.record)
    } catch (err) {
        console.log(`[organizations] create-provisioning error: ${err}`)
    }
}

// Handler: onRecordAfterUpdateSuccess("organizations")
//
// Only reprovisions when `slug` actually changed — provisionSubdomain always
// writes the up-to-date `subdomain` value, so comparing against the expected
// value (instead of diffing against a "previous record") is enough to detect
// drift. The old subdomain is intentionally left in place (not deprovisioned)
// so in-flight links/bookmarks to it don't break.
function onUpdateSuccess(e) {
    e.next()
    try {
        if (e.record.getString("subdomain") !== expectedSubdomain(e.record)) {
            provisionSubdomain(e.app, e.record)
        }
    } catch (err) {
        console.log(`[organizations] update-provisioning error: ${err}`)
    }
}

function requireOrganizationsManage(e) {
    const authRecord = e.auth
    if (!authRecord) {
        throw new ForbiddenError("authentication required")
    }
    const roles = e.app.findRecordsByFilter(
        "userRoles",
        "user = {:userId}",
        "",
        1,
        0,
        { userId: authRecord.id },
    )
    const role = roles.length > 0 ? roles[0] : null
    const permissions = role ? role.get("permissions") : []
    if (!Array.isArray(permissions) || permissions.indexOf("organizations.manage") === -1) {
        throw new ForbiddenError("organizations.manage permission required")
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

// Scheduled job: retries records stuck in "failed".
function retryFailed() {
    try {
        const failed = $app.findRecordsByFilter(
            "organizations",
            'dnsStatus = "failed" && isDeleted = false',
            "",
            50,
            0,
        )
        for (const record of failed) {
            provisionSubdomain($app, record)
        }
        if (failed.length > 0) {
            console.log(`[organizations] retried DNS provisioning for ${failed.length} org(s)`)
        }
    } catch (err) {
        console.log(`[organizations] scheduled retry error: ${err}`)
    }
}

module.exports = {
    provisionSubdomain: provisionSubdomain,
    onCreateSuccess: onCreateSuccess,
    onUpdateSuccess: onUpdateSuccess,
    requireOrganizationsManage: requireOrganizationsManage,
    retryDns: retryDns,
    retryFailed: retryFailed,
}
