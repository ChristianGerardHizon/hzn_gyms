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

function callerIsSuperAdmin(authRecord) {
    if (!authRecord) return false;
    try {
        return !!authRecord.getBool("superAdmin");
    } catch (_) {
        return false;
    }
}

/**
 * Only PocketBase `_superusers` may set `superAdmin`. Non-superuser creates
 * force false; updates restore the existing DB value.
 *
 * @param {core.RecordRequestEvent} e
 * @param {{ isCreate?: boolean }} [options]
 */
function protectSuperAdminField(e, options) {
    const isCreate = !!(options && options.isCreate);
    if (isSuperuserAuth(e.auth)) {
        return;
    }
    if (isCreate) {
        e.record.set("superAdmin", false);
        return;
    }
    let previous = false;
    try {
        previous = e.record.originalCopy().getBool("superAdmin");
    } catch (_) {
        previous = false;
    }
    e.record.set("superAdmin", previous);
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

    if (callerIsSuperAdmin(authRecord)) {
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

/**
 * Existing-staff Google login only: reject OAuth when PocketBase would create
 * a new users record (unknown Google email). Matching emails link/login.
 *
 * @param {core.RecordAuthWithOAuth2RequestEvent} e
 */
function rejectOAuthAccountCreation(e) {
    if (e.isNewRecord || !e.record) {
        throw new ForbiddenError(
            "No staff account for this Google email. Ask an admin to create your user first.",
        );
    }
    e.next();
}

module.exports = {
    callerIsSuperAdmin: callerIsSuperAdmin,
    protectSuperAdminField: protectSuperAdminField,
    enforceUserOrganizationScope: enforceUserOrganizationScope,
    rejectOAuthAccountCreation: rejectOAuthAccountCreation,
};
