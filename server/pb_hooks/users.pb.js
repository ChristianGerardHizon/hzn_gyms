/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Users Hooks
// ============================================================================

/**
 * Hook: Automatically set new users as verified on creation.
 *
 * PocketBase auth collections require email verification by default.
 * Since users are created by admins in this system (not self-registered),
 * we skip the verification step by marking them verified immediately.
 */
onRecordCreateRequest((e) => {
    e.record.set("verified", true);
    require(`${__hooks}/lib/users_helpers.js`).enforceUserOrganizationScope(e);
}, "users");

onRecordUpdateRequest((e) => {
    require(`${__hooks}/lib/users_helpers.js`).enforceUserOrganizationScope(e);
}, "users");
