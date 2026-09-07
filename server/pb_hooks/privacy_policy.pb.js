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
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

/**
 * Load privacy policy HTML from pb_public, then hooks fallback.
 */
function loadPrivacyPolicyHtml() {
  try {
    return toString($os.readFile(__hooks + "/../pb_public/privacy-policy.html"));
  } catch (errPublic) {
    try {
      return toString($os.readFile(__hooks + "/privacy-policy.html"));
    } catch (errHooks) {
      return null;
    }
  }
}

/**
 * Respond with the privacy policy HTML (200) or a small 404 page.
 */
function servePrivacyPolicy(e) {
  var html = loadPrivacyPolicyHtml();
  if (!html) {
    return e.html(
      404,
      "<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title>Not Found</title></head>" +
        "<body><h1>Privacy Policy Not Found</h1>" +
        "<p>The privacy policy file is missing on this server.</p></body></html>"
    );
  }

  e.response.header().set("X-Robots-Tag", "noindex, nofollow");
  e.response.header().set("Cache-Control", "public, max-age=300");
  return e.html(200, html);
}

/**
 * GET /privacy-policy
 */
routerAdd("GET", "/privacy-policy", function(e) {
  return servePrivacyPolicy(e);
});

/**
 * GET /privacy-policy/
 */
routerAdd("GET", "/privacy-policy/", function(e) {
  return servePrivacyPolicy(e);
});

/**
 * GET /privacy-policy.html
 *
 * Explicit route so SPA fallback cannot replace a missing static file.
 */
routerAdd("GET", "/privacy-policy.html", function(e) {
  return servePrivacyPolicy(e);
});
