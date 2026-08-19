// Cleanup worker for browsers that still have Flutter's precache SW.
// New loads do not register a service worker (see flutter_bootstrap.js).
// Old tabs call registration.update() on this URL; this script uninstalls
// itself, drops Cache API entries, and reloads clients so they are not stuck
// on a stale precache of main.dart.js / CanvasKit.
self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(keys.map((key) => caches.delete(key)));
      await self.registration.unregister();
      const windowClients = await self.clients.matchAll({
        type: 'window',
        includeUncontrolled: true,
      });
      await Promise.all(
        windowClients.map((client) => {
          if ('navigate' in client) {
            return client.navigate(client.url);
          }
          return Promise.resolve();
        }),
      );
    })(),
  );
});
