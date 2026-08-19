{{flutter_js}}
{{flutter_build_config}}

// Do not pass serviceWorkerSettings. Flutter's generated worker precaches the
// entire app (main.dart.js + CanvasKit + wasm) before first frame and can leave
// the HTML splash up for minutes. Repeat visits use the browser HTTP cache.
const _swCleanupFlag = 'ebeGymSwCleanupDone';

function loadFlutterEngine() {
  _flutter.loader.load({
    config: {
      // Serve CanvasKit from our own origin instead of Google's CDN, so first
      // load doesn't depend on gstatic.com being fast/reachable for every user.
      canvasKitBaseUrl: "canvaskit/",
    },
  });
}

function versionKey(payload) {
  if (!payload || typeof payload !== 'object') return null;
  const version = payload.version;
  const build = payload.build_number;
  if (version == null && build == null) return null;
  return `${version ?? ''}+${build ?? ''}`;
}

function startVersionPoll() {
  let currentVersion = null;

  const readVersion = () =>
    fetch('version.json', { cache: 'no-store' }).then((res) => {
      if (!res.ok) return null;
      return res.json();
    });

  readVersion()
    .then((payload) => {
      currentVersion = versionKey(payload);
    })
    .catch(() => {});

  setInterval(() => {
    readVersion()
      .then((payload) => {
        const next = versionKey(payload);
        if (currentVersion && next && next !== currentVersion) {
          location.reload();
        }
      })
      .catch(() => {});
  }, 60000);
}

async function retireLegacyServiceWorker() {
  if (!('serviceWorker' in navigator)) return false;

  const hadController = !!navigator.serviceWorker.controller;
  const registrations = await navigator.serviceWorker.getRegistrations();
  if (!hadController && registrations.length === 0) return false;

  // One reload after unregister is enough. A second pass would loop.
  if (sessionStorage.getItem(_swCleanupFlag) === '1') return false;

  await Promise.all(registrations.map((reg) => reg.unregister()));
  if (window.caches) {
    const keys = await caches.keys();
    await Promise.all(keys.map((key) => caches.delete(key)));
  }

  if (hadController) {
    sessionStorage.setItem(_swCleanupFlag, '1');
    location.reload();
    return true;
  }
  return false;
}

retireLegacyServiceWorker()
  .then((reloading) => {
    if (reloading) return;
    sessionStorage.removeItem(_swCleanupFlag);
    loadFlutterEngine();
    startVersionPoll();
  })
  .catch(() => {
    loadFlutterEngine();
    startVersionPoll();
  });
