import 'package:web/web.dart' as web;

import 'web_brand_icons.dart';

/// Captured default `href` values for icon links, keyed by link identity.
final Map<String, String> _defaultHrefs = {};

String _linkKey(web.HTMLLinkElement link) {
  final sizes = link.getAttribute('sizes') ?? '';
  return '${link.rel}|$sizes|${link.type}';
}

/// Updates `<link rel="icon">` and `<link rel="apple-touch-icon">` to the
/// active organization logo, or restores the defaults from `web/index.html`
/// when [logoUrl] is null/empty.
void updateWebBrandIcons({String? logoUrl, String? cacheBust}) {
  try {
    final resolved = resolveWebBrandIconHref(
      logoUrl: logoUrl,
      cacheBust: cacheBust,
    );
    final nodes = web.document.querySelectorAll(
      'link[rel="icon"], link[rel="apple-touch-icon"]',
    );

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes.item(i);
      if (node == null) continue;

      final link = node as web.HTMLLinkElement;
      final key = _linkKey(link);
      _defaultHrefs.putIfAbsent(key, () => link.href);

      if (resolved != null) {
        link.href = resolved;
      } else {
        final fallback = _defaultHrefs[key];
        if (fallback != null) link.href = fallback;
      }
    }
  } catch (_) {
    // Best-effort branding; ignore DOM access failures.
  }
}
