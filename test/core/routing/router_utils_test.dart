import 'package:hzn_gyms/src/core/routing/router_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('RouterUtils.currentLocation', () {
    testWidgets('returns matched location for a known route', (tester) async {
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const SizedBox(),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(RouterUtils.currentLocation(router), '/login');
    });

    testWidgets(
      'does not throw on unknown URLs where GoRouter.state would crash',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/loginMichell',
          errorBuilder: (context, state) => const Text('404'),
          routes: [
            GoRoute(
              path: '/login',
              builder: (context, state) => const SizedBox(),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('404'), findsOneWidget);

        // Reproduce EBEGYM-1: GoRouter.state uses RouteMatchList.last, which
        // throws when error match lists have empty matches.
        expect(() => router.state.matchedLocation, throwsA(isA<StateError>()));

        expect(RouterUtils.currentLocation(router), '/loginMichell');
      },
    );

    testWidgets('auth post-frame callback survives unknown initial location', (
      tester,
    ) async {
      final auth = ValueNotifier<bool>(false);
      late GoRouter router;

      router = GoRouter(
        initialLocation: '/loginMichell',
        errorBuilder: (context, state) => const Text('404'),
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const Text('LOGIN'),
          ),
          GoRoute(path: '/', builder: (context, state) => const Text('HOME')),
        ],
      );

      auth.addListener(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final location = RouterUtils.currentLocation(router);
          if (location.isEmpty) return;
          if (auth.value && (location == '/login' || location == '/splash')) {
            router.go('/');
          } else if (!auth.value &&
              !RouterUtils.ignoredRoutes.any(
                (route) => location.startsWith(route),
              )) {
            router.go('/login');
          }
        });
      });

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('404'), findsOneWidget);

      // Toggle auth while on an error match list — must not throw.
      auth.value = true;
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('404'), findsOneWidget);

      auth.dispose();
    });
  });
}
