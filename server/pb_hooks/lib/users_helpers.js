/// <reference path="../../pb_data/types.d.ts" />

// Users hooks — org-scoping for tenant isolation.

const { roleHasPermission } = require(`${__hooks}/lib/permissions_helpers.js`);

function isSuperuserAuth(authRecord) {
    if (!authRecord) return false;
    try {
        return authRecord.collection().name === "_superusers";
    } catch (_) {
        return false;
    }
}

function callerHasOrganizationsManage(app, authRecord) {
    if (!authRecord) return false;
    // Resolve via users.role → userRoles.permissions (not userRoles.user).
    return roleHasPermission(
        app,
        authRecord.getString("role"),
        "organizations.manage",
    );
}

/**
 * @param {core.RecordRequestEvent} e
 * @param {{ requireOrganization?: boolean }} [options]
 *   When true (create requests), platform admins / superusers must supply
 *   an organization so new users are never created unlinked.
 */
function enforceUserOrganizationScope(e, options) {
    const requireOrganization = !!(options && options.requireOrganization);
    const authRecord = e.auth;
    if (!authRecord) {
        e.next();
        return;
    }

    const requestedOrg = (e.record.getString("organization") || "").trim();

    // PocketBase superusers may create/update users across tenants
    // (including platform admins with no organization).
    if (isSuperuserAuth(authRecord)) {
        if (requireOrganization && !requestedOrg) {
            throw new BadRequestError("organization is required");
        }
        e.next();
        return;
    }

    if (callerHasOrganizationsManage(e.app, authRecord)) {
        if (requireOrganization && !requestedOrg) {
            throw new BadRequestError("organization is required");
        }
        e.next();
        return;
    }

    const authOrg = authRecord.getString("organization");
    if (!authOrg) {
        throw new ForbiddenError("Your account is not linked to an organization");
    }

    if (requestedOrg && requestedOrg !== authOrg) {
        throw new ForbiddenError("Cannot assign users to another organization");
    }

    e.record.set("organization", authOrg);
    e.next();
}

module.exports = {
    callerHasOrganizationsManage: callerHasOrganizationsManage,
    enforceUserOrganizationScope: enforceUserOrganizationScope,
};
