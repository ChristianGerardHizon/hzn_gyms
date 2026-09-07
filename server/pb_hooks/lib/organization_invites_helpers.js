/// <reference path="../../pb_data/types.d.ts" />

// Helpers for organization_invites.pb.js — org team invite lifecycle.
//
// Direct REST create/update/delete on `organizationMemberships` and
// `organizationInvites` is blocked (rules are `null` on both collections);
// all writes go through these hook-backed routes instead. Hook code calling
// `app.save()` is NOT subject to collection API rules, so that's expected.

const INVITE_TTL_DAYS = 7;

function isSuperuser(authRecord) {
    try {
        return authRecord.collection().name === "_superusers";
    } catch (_) {
        return false;
    }
}

const { roleHasPermission } = require(`${__hooks}/lib/permissions_helpers.js`);

function hasPermission(app, roleId, permissionKey) {
    return roleHasPermission(app, roleId, permissionKey);
}

// Caller may manage org invites/members if they're a platform superuser
// (organizations.manage), OR they hold an active organizationMemberships
// row for this specific org whose role has members.manage. Looked up as a
// single authoritative row — not a filter-rule chain across relations — to
// avoid ANDing conditions across different back-relation rows.
function canManageOrgMembers(e, orgId) {
    const authRecord = e.auth;
    if (!authRecord) return false;

    if (isSuperuser(authRecord)) return true;

    if (hasPermission(e.app, authRecord.getString("role"), "organizations.manage")) {
        return true;
    }

    let membership;
    try {
        membership = e.app.findFirstRecordByFilter(
            "organizationMemberships",
            "organization = {:org} && user = {:user} && status = 'active'",
            { org: orgId, user: authRecord.id },
        );
    } catch (_) {
        return false;
    }
    if (!membership) return false;

    return hasPermission(e.app, membership.getString("role"), "members.manage");
}

function requireManageOrgMembers(e, orgId) {
    if (!e.auth) {
        throw new ForbiddenError("authentication required");
    }
    if (!canManageOrgMembers(e, orgId)) {
        throw new ForbiddenError("members.manage permission required for this organization");
    }
}

// POST /api/organization-invites
function createInvite(e) {
    if (!e.auth) {
        throw new ForbiddenError("authentication required");
    }

    const body = e.requestInfo().body || {};
    const organization = (body.organization || "").trim();
    const role = (body.role || "").trim();
    const email = (body.email || "").trim().toLowerCase();

    if (!organization || !role || !email) {
        throw new BadRequestError("organization, role, and email are required");
    }

    requireManageOrgMembers(e, organization);

    const collection = e.app.findCollectionByNameOrId("organizationInvites");
    const record = new Record(collection);
    record.set("email", email);
    record.set("organization", organization);
    record.set("role", role);
    record.set("invitedBy", e.auth.id);
    record.set("status", "pending");
    const expiresAt = new Date(Date.now() + INVITE_TTL_DAYS * 24 * 60 * 60 * 1000);
    record.set("expiresAt", expiresAt.toISOString());
    // token auto-generates from the field's autogeneratePattern — don't set it.

    e.app.save(record);

    return e.json(200, record);
}

// POST /api/organization-invites/{id}/accept
function acceptInvite(e) {
    if (!e.auth) {
        throw new ForbiddenError("authentication required");
    }

    const id = e.request.pathValue("id");
    let invite;
    try {
        invite = e.app.findRecordById("organizationInvites", id);
    } catch (_) {
        throw new NotFoundError("invite not found");
    }
    if (!invite) {
        throw new NotFoundError("invite not found");
    }

    if (invite.getString("status") !== "pending") {
        throw new BadRequestError("invite is no longer valid");
    }

    const expiresAt = new Date(invite.getString("expiresAt"));
    if (Date.now() > expiresAt.getTime()) {
        invite.set("status", "expired");
        e.app.save(invite);
        throw new BadRequestError("invite has expired");
    }

    const authEmail = (e.auth.getString("email") || "").trim().toLowerCase();
    const inviteEmail = (invite.getString("email") || "").trim().toLowerCase();
    if (authEmail !== inviteEmail) {
        throw new ForbiddenError("this invite is for a different account");
    }

    const organizationId = invite.getString("organization");

    let existing;
    try {
        existing = e.app.findFirstRecordByFilter(
            "organizationMemberships",
            "user = {:user} && organization = {:org}",
            { user: e.auth.id, org: organizationId },
        );
    } catch (_) {
        existing = null;
    }

    let membership;
    if (existing) {
        // Idempotent: already a member, just settle the invite.
        membership = existing;
    } else {
        const collection = e.app.findCollectionByNameOrId("organizationMemberships");
        membership = new Record(collection);
        membership.set("user", e.auth.id);
        membership.set("organization", organizationId);
        membership.set("role", invite.getString("role"));
        membership.set("status", "active");
        membership.set("invitedBy", invite.getString("invitedBy"));
        membership.set("joinedAt", new Date().toISOString());
        e.app.save(membership);
    }

    invite.set("status", "accepted");
    invite.set("acceptedBy", e.auth.id);
    e.app.save(invite);

    return e.json(200, membership);
}

// POST /api/organization-invites/{id}/revoke
function revokeInvite(e) {
    if (!e.auth) {
        throw new ForbiddenError("authentication required");
    }

    const id = e.request.pathValue("id");
    let invite;
    try {
        invite = e.app.findRecordById("organizationInvites", id);
    } catch (_) {
        throw new NotFoundError("invite not found");
    }
    if (!invite) {
        throw new NotFoundError("invite not found");
    }

    requireManageOrgMembers(e, invite.getString("organization"));

    if (invite.getString("status") !== "pending") {
        throw new BadRequestError("invite is no longer pending");
    }

    invite.set("status", "revoked");
    e.app.save(invite);

    return e.json(200, invite);
}

module.exports = {
    canManageOrgMembers: canManageOrgMembers,
    requireManageOrgMembers: requireManageOrgMembers,
    createInvite: createInvite,
    acceptInvite: acceptInvite,
    revokeInvite: revokeInvite,
};
