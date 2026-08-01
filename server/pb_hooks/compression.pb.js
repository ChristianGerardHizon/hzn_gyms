/// <reference path="../pb_data/types.d.ts" />

// Gzip-compresses static web asset responses (the Flutter web build served
// from pb_public/). Skips /api/* entirely so it never touches the realtime
// (SSE) endpoint used by check-in live updates or any other API response.
routerUse((e) => {
    if (e.request.url.path.startsWith("/api/")) {
        return e.next();
    }
    return $apis.gzip().func(e);
});
