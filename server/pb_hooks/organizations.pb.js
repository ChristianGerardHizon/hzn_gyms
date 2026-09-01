/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Organizations Hooks — Porkbun DNS subdomain provisioning
// ============================================================================
// Registration only — see pb_hooks/lib/organizations_helpers.js for the
// actual logic (required inside each callback, per this repo's convention
// for sharing code between hook callbacks).

onRecordCreateRequest((e) => {
    require(`${__hooks}/lib/organizations_helpers.js`).onCreateRequest(e);
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

// Super-admin-only (`organizations.manage` permission) retry for a
// stuck/failed DNS provisioning attempt.
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
