/// Resolves the href to apply to web favicon / apple-touch-icon links.
///
/// Returns `null` when [logoUrl] is missing/blank — callers should restore
/// the default HZN icons in that case.
String? resolveWebBrandIconHref({
  required String? logoUrl,
  String? cacheBust,
}) {
  final trimmed = logoUrl?.trim() ?? '';
  if (trimmed.isEmpty) return null;

  final bust = cacheBust?.trim() ?? '';
  if (bust.isEmpty) return trimmed;

  final separator = trimmed.contains('?') ? '&' : '?';
  return '$trimmed${separator}v=${Uri.encodeQueryComponent(bust)}';
}
