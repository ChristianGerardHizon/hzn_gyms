/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Users Hooks
// ============================================================================

/**
 * On create: enforce org scope. Do not auto-verify — users must confirm email.
 */
onRecordCreateRequest((e) => {
    const helpers = require(`${__hooks}/lib/users_helpers.js`);
    helpers.protectSuperAdminField(e, { isCreate: true });
    helpers.enforceUserOrganizationScope(e, {
        requireOrganization: true,
    });
}, "users");

/**
 * After create: send verification email when SMTP is configured.
 */
onRecordAfterCreateSuccess((e) => {
    const email = (e.record.getString("email") || "").trim();
    if (!email || e.record.getBool("verified")) return;

    try {
        $mails.sendRecordVerification($app, e.record);
    } catch (err) {
        $app.logger().error(
            "users: failed to send verification email",
            "email",
            email,
            "error",
            err,
        );
    }
}, "users");

onRecordUpdateRequest((e) => {
    const helpers = require(`${__hooks}/lib/users_helpers.js`);
    helpers.protectSuperAdminField(e);
    helpers.enforceUserOrganizationScope(e);
}, "users");

/**
 * Google (and other OAuth) login: allow only when an existing staff user
 * matches the provider email. Block automatic account creation.
 */
onRecordAuthWithOAuth2Request((e) => {
    require(`${__hooks}/lib/users_helpers.js`).rejectOAuthAccountCreation(e);
}, "users");
