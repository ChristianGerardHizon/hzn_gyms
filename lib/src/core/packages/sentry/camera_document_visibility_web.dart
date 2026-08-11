import 'package:web/web.dart' as web;

/// Reads `document.visibilityState` on web (`visible` / `hidden` / …).
String? readCameraDocumentVisibility() {
  try {
    return web.document.visibilityState;
  } catch (_) {
    return null;
  }
}
