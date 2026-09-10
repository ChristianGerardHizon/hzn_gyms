import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/pages/page_not_found_page.dart';

Widget _wrap(Widget child, {required Size size}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('PageNotFoundPage shows branding and home action', (
    tester,
  ) async {
    var wentHome = false;

    await tester.pumpWidget(
      _wrap(
        PageNotFoundPage(
          attemptedPath: '/missing-route',
          onGoHome: () => wentHome = true,
        ),
        size: const Size(800, 600),
      ),
    );

    expect(find.text('404'), findsOneWidget);
    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('/missing-route'), findsOneWidget);
    expect(find.text('Go Home'), findsOneWidget);

    await tester.tap(find.text('Go Home'));
    await tester.pump();

    expect(wentHome, isTrue);
  });

  testWidgets('PageNotFoundPage scales content for desktop width', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PageNotFoundPage(onGoHome: () {}),
        size: const Size(1280, 800),
      ),
    );

    final code = tester.widget<Text>(find.text('404'));
    expect(code.style?.fontSize, 112);
  });

  testWidgets('PageNotFoundPage scales content for mobile width', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PageNotFoundPage(onGoHome: () {}),
        size: const Size(390, 844),
      ),
    );

    final code = tester.widget<Text>(find.text('404'));
    expect(code.style?.fontSize, 64);
  });
}
