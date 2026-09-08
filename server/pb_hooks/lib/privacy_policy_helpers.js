/// <reference path="../../pb_data/types.d.ts" />

// Shared by privacy_policy.pb.js — required inside each routerAdd callback
// (PB JSVM does not share top-level functions from .pb.js into handlers).

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
function serve(e) {
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

module.exports = {
  serve: serve,
};
