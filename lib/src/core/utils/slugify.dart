/// Converts [input] into a URL-safe slug: lowercase, alphanumeric, words
/// joined by single hyphens (e.g. "Bacolod Branch" -> "bacolod-branch").
String slugify(String input) {
  final lower = input.trim().toLowerCase();
  final dashed = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return dashed.replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
}
