/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Organization Invites — invite/accept/revoke routes for org team membership
// ============================================================================
// Registration only — see pb_hooks/lib/organization_invites_helpers.js for
// the actual logic (required inside each callback, per this repo's
// convention for sharing code between hook callbacks).
//
// `organizationMemberships` and `organizationInvites` both have
// create/update/delete rules set to `null` — direct REST writes are
// blocked, so creation/mutation only happens through these routes. Hook
// code calling `app.save()` is not subject to collection API rules, so
// that's intentional, not a bug.

routerAdd(
    "POST",
    "/api/organization-invites",
    (e) => {
        return require(`${__hooks}/lib/organization_invites_helpers.js`).createInvite(e);
    },
    $apis.requireAuth("users"),
);

routerAdd(
    "POST",
    "/api/organization-invites/{id}/accept",
    (e) => {
        return require(`${__hooks}/lib/organization_invites_helpers.js`).acceptInvite(e);
    },
    $apis.requireAuth("users"),
);

routerAdd(
    "POST",
    "/api/organization-invites/{id}/revoke",
    (e) => {
        return require(`${__hooks}/lib/organization_invites_helpers.js`).revokeInvite(e);
    },
    $apis.requireAuth("users"),
);
