/// <reference path="../../pb_data/types.d.ts" />

// Users hooks — org-scoping for tenant isolation.

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
    const roleId = authRecord.getString("role");
    if (!roleId) return false;
    try {
        const role = app.findRecordById("userRoles", roleId);
        const permissions = role.get("permissions") || [];
        if (!Array.isArray(permissions)) return false;
        return permissions.indexOf("organizations.manage") !== -1;
    } catch (_) {
        return false;
    }
}

function enforceUserOrganizationScope(e) {
    const authRecord = e.auth;
    if (!authRecord) {
        e.next();
        return;
    }

    // PocketBase superusers may create/update users across tenants
    // (including platform admins with no organization).
    if (isSuperuserAuth(authRecord)) {
        e.next();
        return;
    }

    if (callerHasOrganizationsManage(e.app, authRecord)) {
        e.next();
        return;
    }

    const authOrg = authRecord.getString("organization");
    if (!authOrg) {
        throw new ForbiddenError("Your account is not linked to an organization");
    }

    const requestedOrg = e.record.getString("organization");
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
