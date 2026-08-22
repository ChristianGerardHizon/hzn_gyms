/// <reference path="../pb_data/types.d.ts" />

// Gzip-compresses static web asset responses (the Flutter web build served
// from pb_public/). Skips:
// - /api/*  — realtime SSE + API responses must stay untouched
// - /_/*    — admin UI is already precompressed; gzipping again breaks the browser
routerUse((e) => {
    const path = e.request.url.path;
    if (path.startsWith("/api/") || path.startsWith("/_/")) {
        return e.next();
    }
    return $apis.gzip().func(e);
});
