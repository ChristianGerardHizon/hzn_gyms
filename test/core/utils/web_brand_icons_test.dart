import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/utils/web_brand_icons.dart';

void main() {
  group('resolveWebBrandIconHref', () {
    test('returns null for null or blank logo URLs', () {
      expect(resolveWebBrandIconHref(logoUrl: null), isNull);
      expect(resolveWebBrandIconHref(logoUrl: ''), isNull);
      expect(resolveWebBrandIconHref(logoUrl: '   '), isNull);
    });

    test('returns the trimmed logo URL without cache bust', () {
      expect(
        resolveWebBrandIconHref(logoUrl: '  https://cdn.example/logo.png  '),
        'https://cdn.example/logo.png',
      );
    });

    test('appends ?v= when the URL has no query', () {
      expect(
        resolveWebBrandIconHref(
          logoUrl: 'https://cdn.example/logo.png',
          cacheBust: 'org-1',
        ),
        'https://cdn.example/logo.png?v=org-1',
      );
    });

    test('appends &v= when the URL already has a query', () {
      expect(
        resolveWebBrandIconHref(
          logoUrl: 'https://cdn.example/logo.png?token=abc',
          cacheBust: 'org-2',
        ),
        'https://cdn.example/logo.png?token=abc&v=org-2',
      );
    });

    test('ignores blank cache bust values', () {
      expect(
        resolveWebBrandIconHref(
          logoUrl: 'https://cdn.example/logo.png',
          cacheBust: '  ',
        ),
        'https://cdn.example/logo.png',
      );
    });

    test('encodes cache bust query values', () {
      expect(
        resolveWebBrandIconHref(
          logoUrl: 'https://cdn.example/logo.png',
          cacheBust: 'a b',
        ),
        'https://cdn.example/logo.png?v=a+b',
      );
    });
  });
}
