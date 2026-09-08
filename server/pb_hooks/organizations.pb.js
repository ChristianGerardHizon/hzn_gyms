/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Organizations Hooks — onboarding + optional DNS helpers
// ============================================================================
// Registration only — see pb_hooks/lib/organizations_helpers.js and
// organization_setup_helpers.js for the actual logic (required inside each
// callback, per this repo's convention for sharing code between hooks).
//
// Per-tenant DNS / subdomain provisioning is no longer required for orgs.

onRecordCreateRequest((e) => {
    require(`${__hooks}/lib/organizations_helpers.js`).onCreateRequest(e);
    require(`${__hooks}/lib/organization_setup_helpers.js`).onOrganizationCreateRequest(e);
}, "organizations");

onRecordUpdateRequest((e) => {
    require(`${__hooks}/lib/organizations_helpers.js`).onUpdateRequest(e);
}, "organizations");

onRecordAfterCreateSuccess((e) => {
    require(`${__hooks}/lib/organizations_helpers.js`).onCreateSuccess(e);
}, "organizations");

onRecordAfterUpdateSuccess((e) => {
    require(`${__hooks}/lib/organizations_helpers.js`).onUpdateSuccess(e);
}, "organizations");

// Super-admin-only (`users.superAdmin`) retry for a stuck/failed DNS
// provisioning attempt.
routerAdd(
    "POST",
    "/api/organizations/{id}/retry-dns",
    (e) => {
        return require(`${__hooks}/lib/organizations_helpers.js`).retryDns(e);
    },
    $apis.requireAuth("users"),
    (e) => {
        require(`${__hooks}/lib/organizations_helpers.js`).requireOrganizationsManage(e);
    },
);

// Scheduled retry for organizations stuck with dnsStatus = "failed".
cronAdd("organizationsDnsRetry", "*/30 * * * *", () => {
    require(`${__hooks}/lib/organizations_helpers.js`).retryFailed();
});

// Public branding resolve for pre-auth subdomain theming.
routerAdd("GET", "/api/public/organizations/resolve", (e) => {
    return require(`${__hooks}/lib/organization_setup_helpers.js`).resolvePublic(e);
});

// Mark organization setup complete after server-side checklist validation.
routerAdd(
    "POST",
    "/api/organizations/{id}/complete-setup",
    (e) => {
        return require(`${__hooks}/lib/organization_setup_helpers.js`).completeSetup(e);
    },
    $apis.requireAuth("users"),
    (e) => {
        require(`${__hooks}/lib/organizations_helpers.js`).requireOrganizationsManage(e);
    },
);
