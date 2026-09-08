/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Privacy policy — serve HTML directly (never SPA fallback)
// ============================================================================
// PocketBase serves pb_public/index.html for unknown paths, so a 302 to
// /privacy-policy.html still boots Flutter if that file is missing from
// pb_public. These routes return the policy HTML body instead.
//
// Prefers pb_public/privacy-policy.html (web deploy), falls back to the
// copy shipped with pb_hooks so hooks-only deploys still work.
//
// Logic lives in lib/privacy_policy_helpers.js and is required inside each
// callback — PB JSVM does not share top-level functions into handlers.
// ============================================================================

/**
 * GET /privacy-policy
 */
routerAdd("GET", "/privacy-policy", function (e) {
  return require(`${__hooks}/lib/privacy_policy_helpers.js`).serve(e);
});

/**
 * GET /privacy-policy/
 */
routerAdd("GET", "/privacy-policy/", function (e) {
  return require(`${__hooks}/lib/privacy_policy_helpers.js`).serve(e);
});

/**
 * GET /privacy-policy.html
 *
 * Explicit route so SPA fallback cannot replace a missing static file.
 */
routerAdd("GET", "/privacy-policy.html", function (e) {
  return require(`${__hooks}/lib/privacy_policy_helpers.js`).serve(e);
});
