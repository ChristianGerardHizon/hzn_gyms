/// <reference path="../../pb_data/types.d.ts" />

// Organization onboarding — public branding resolve, setup completion checks.

const orgHelpers = () => require(`${__hooks}/lib/organizations_helpers.js`);

function normalizeHost(host) {
    return (host || "").trim().toLowerCase().split(":")[0];
}

function findOrgByHost(app, host) {
    const normalized = normalizeHost(host);
    if (!normalized) return null;

    const params = { host: normalized, slug: normalized };
    const filter =
        '(subdomain = {:host} || slug = {:slug}) && isDeleted = false';
    const rows = app.findRecordsByFilter("organizations", filter, "", 1, 0, params);
    return rows.length > 0 ? rows[0] : null;
}

function brandingPayload(app, record) {
    if (!record) return null;

    const collectionName = record.collection().name;
    const id = record.id;
    const baseUrl = app.settings().meta.appUrl || "";

    function fileUrl(fileName) {
        const name = (fileName || "").trim();
        if (!name) return "";
        return `${baseUrl}/api/files/${collectionName}/${id}/${name}`;
    }

    return {
        id: id,
        slug: record.getString("slug"),
        name: record.getString("name"),
        displayName: record.getString("displayName"),
        seedColor: record.getString("seedColor"),
        logoLightUrl: fileUrl(record.getString("logoLight")),
        logoTransparentUrl: fileUrl(record.getString("logoTransparent")),
        splashBackgroundColor: record.getString("splashBackgroundColor"),
        subdomain: record.getString("subdomain"),
        setupStatus: record.getString("setupStatus") || "pending_setup",
    };
}

function roleHasSystemAdmin(app, roleId) {
    if (!roleId) return false;
    try {
        const role = app.findRecordById("userRoles", roleId);
        const permissions = role.get("permissions");
        if (!Array.isArray(permissions)) return false;
        return permissions.indexOf("system.admin") !== -1;
    } catch (_) {
        return false;
    }
}

function runSetupChecks(app, orgId) {
    const checks = [];
    const errors = [];

    let org;
    try {
        org = app.findRecordById("organizations", orgId);
    } catch (_) {
        return { ready: false, checks: [], errors: ["Organization not found"] };
    }

    if (org.getBool("isDeleted")) {
        errors.push("Organization is deleted");
    }

    const dnsStatus = org.getString("dnsStatus");
    const dnsOk = dnsStatus === "created" || dnsStatus === "pending";
    checks.push({
        key: "dns",
        label: "DNS provisioning",
        passed: dnsOk,
        detail: dnsOk
            ? `dnsStatus=${dnsStatus}`
            : `dnsStatus=${dnsStatus}${org.getString("dnsError") ? ": " + org.getString("dnsError") : ""}`,
    });
    if (!dnsOk) {
        errors.push("DNS is not ready (expected created or pending)");
    }

    const branches = app.findRecordsByFilter(
        "branches",
        'organization = {:orgId} && isDeleted = false',
        "",
        1,
        0,
        { orgId: orgId },
    );
    const hasBranch = branches.length > 0;
    checks.push({
        key: "branch",
        label: "At least one branch",
        passed: hasBranch,
        detail: hasBranch ? branches[0].getString("name") : "No branch linked to organization",
    });
    if (!hasBranch) {
        errors.push("Create at least one branch for this organization");
    }

    const users = app.findRecordsByFilter(
        "users",
        'organization = {:orgId} && isDeleted = false',
        "",
        50,
        0,
        { orgId: orgId },
    );

    let adminUser = null;
    for (let i = 0; i < users.length; i++) {
        const user = users[i];
        const email = (user.getString("email") || "").trim();
        const branchId = user.getString("branch");
        const roleId = user.getString("role");
        if (!email || !branchId || !roleId) continue;
        if (!roleHasSystemAdmin(app, roleId)) continue;
        adminUser = user;
        break;
    }

    const hasAdmin = adminUser != null;
    checks.push({
        key: "adminUser",
        label: "Org admin user with email and branch",
        passed: hasAdmin,
        detail: hasAdmin
            ? adminUser.getString("email")
            : "Need a user with organization, email, branch, and Admin role (system.admin)",
    });
    if (!hasAdmin) {
        errors.push(
            "Create an org admin user with email, default branch, and Admin role",
        );
    }

    const ready = errors.length === 0;
    return { ready: ready, checks: checks, errors: errors };
}

// GET /api/public/organizations/resolve?host=
function resolvePublic(e) {
    const host = e.request.url.query().get("host") || "";
    const record = findOrgByHost(e.app, host);
    if (!record) {
        return e.json(404, { message: "Organization not found for host" });
    }
    return e.json(200, brandingPayload(e.app, record));
}

// POST /api/organizations/{id}/complete-setup
function completeSetup(e) {
    const id = e.request.pathValue("id");
    const result = runSetupChecks(e.app, id);
    if (!result.ready) {
        return e.json(400, {
            ready: false,
            checks: result.checks,
            errors: result.errors,
        });
    }

    const record = e.app.findRecordById("organizations", id);
    record.set("setupStatus", "ready");
    record.set("setupCompletedAt", new Date().toISOString());
    e.app.save(record);

    return e.json(200, {
        ready: true,
        checks: result.checks,
        errors: [],
        setupStatus: record.getString("setupStatus"),
        setupCompletedAt: record.getString("setupCompletedAt"),
    });
}

// Default setupStatus on org create when field exists.
function onOrganizationCreateRequest(e) {
    const current = (e.record.getString("setupStatus") || "").trim();
    if (!current) {
        e.record.set("setupStatus", "pending_setup");
    }
    e.next();
}

module.exports = {
    normalizeHost: normalizeHost,
    findOrgByHost: findOrgByHost,
    brandingPayload: brandingPayload,
    runSetupChecks: runSetupChecks,
    resolvePublic: resolvePublic,
    completeSetup: completeSetup,
    onOrganizationCreateRequest: onOrganizationCreateRequest,
};
