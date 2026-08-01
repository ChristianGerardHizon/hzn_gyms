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
