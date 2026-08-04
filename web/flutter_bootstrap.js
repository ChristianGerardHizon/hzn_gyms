{{flutter_js}}
{{flutter_build_config}}
_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  },
  config: {
    // Serve CanvasKit from our own origin instead of Google's CDN, so first
    // load doesn't depend on gstatic.com being fast/reachable for every user.
    canvasKitBaseUrl: "canvaskit/",
  },
});

// Poll for a new deployed service worker so long-lived tabs pick up new
// versions without the user needing to manually hard-refresh; the generated
// service worker force-reloads all open tabs once it activates.
if ('serviceWorker' in navigator) {
  setInterval(() => {
    navigator.serviceWorker.getRegistration().then((reg) => reg?.update());
  }, 60000);
}
