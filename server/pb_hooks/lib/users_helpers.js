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

function callerIsSuperAdmin(app, authRecord) {
    if (!authRecord) return false;
    // Prefer a fresh DB read — request auth can omit/stale custom bools
    // after mid-session field changes (e.g. org switch).
    try {
        const id = authRecord.getString("id") || ("" + authRecord.id);
        if (app && id) {
            const fresh = app.findRecordById("users", id);
            if (fresh && fresh.getBool("superAdmin")) return true;
        }
    } catch (_) {
        // fall through to auth-record fields
    }
    try {
        if (authRecord.getBool("superAdmin")) return true;
    } catch (_) {
        // fall through
    }
    try {
        const raw = authRecord.get("superAdmin");
        return raw === true || raw === 1 || raw === "true";
    } catch (_) {
        return false;
    }
}

/**
 * PocketBase `_superusers` and app platform operators (`users.superAdmin`)
 * may set `superAdmin`. Everyone else: creates force false; updates restore
 * the existing DB value.
 *
 * @param {core.RecordRequestEvent} e
 * @param {{ isCreate?: boolean }} [options]
 */
function protectSuperAdminField(e, options) {
    const isCreate = !!(options && options.isCreate);
    if (isSuperuserAuth(e.auth)) {
        return;
    }
    // Platform operators may grant/revoke via the /platform/users UI.
    if (callerIsSuperAdmin(e.app, e.auth)) {
        return;
    }
    if (isCreate) {
        e.record.set("superAdmin", false);
        return;
    }
    // Always re-read from DB. originalCopy()/request merge can zero bools on
    // partial PATCHes, which would strip platform operators on org switch.
    let previous = false;
    try {
        const id = e.record.getString("id") || ("" + e.record.id);
        const existing = e.app.findRecordById("users", id);
        previous = existing.getBool("superAdmin");
    } catch (_) {
        try {
            previous = e.record.originalCopy().getBool("superAdmin");
        } catch (_) {
            previous = false;
        }
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

    if (callerIsSuperAdmin(e.app, authRecord)) {
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
