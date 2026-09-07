/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Privacy policy path aliases
// ============================================================================
// PocketBase SPA fallback serves pb_public/index.html for unknown paths.
// GET /privacy-policy (no .html) would otherwise boot the Flutter app.
// Redirect to the static file before that fallback.
//
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

/**
 * GET /privacy-policy
 *
 * 302 to /privacy-policy.html so Play Console and browsers never hit the SPA.
 */
routerAdd("GET", "/privacy-policy", function(e) {
  return e.redirect(302, "/privacy-policy.html");
});

/**
 * GET /privacy-policy/
 *
 * Same alias with a trailing slash (directory-style URL).
 */
routerAdd("GET", "/privacy-policy/", function(e) {
  return e.redirect(302, "/privacy-policy.html");
});
