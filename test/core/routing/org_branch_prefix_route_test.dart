import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('org/branch prefix GoRoute', () {
    test('throws without builder, pageBuilder, or redirect', () {
      expect(
        () => GoRoute(
          path: '/:orgSlug/:branchSlug',
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const SizedBox(),
            ),
          ],
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('bare /org/branch redirects to /dashboard child', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/acme/main',
        routes: [
          GoRoute(
            path: '/:orgSlug/:branchSlug',
            redirect: (context, state) {
              final org = state.pathParameters['orgSlug']!;
              final branch = state.pathParameters['branchSlug']!;
              if (state.uri.path == '/$org/$branch') {
                return '/$org/$branch/dashboard';
              }
              return null;
            },
            routes: [
              ShellRoute(
                builder: (context, state, child) => Scaffold(body: child),
                routes: [
                  GoRoute(
                    path: '/dashboard',
                    builder: (context, state) => Text(
                      '${state.pathParameters['orgSlug']}/'
                      '${state.pathParameters['branchSlug']}',
                    ),
                  ),
                  GoRoute(
                    path: '/members',
                    builder: (context, state) => const Text('members'),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('acme/main'), findsOneWidget);
      expect(router.state.uri.path, '/acme/main/dashboard');
    });

    testWidgets('nested /members does not keep redirect-only as leaf', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/acme/main/members',
        routes: [
          GoRoute(
            path: '/:orgSlug/:branchSlug',
            redirect: (context, state) {
              final org = state.pathParameters['orgSlug']!;
              final branch = state.pathParameters['branchSlug']!;
              if (state.uri.path == '/$org/$branch') {
                return '/$org/$branch/dashboard';
              }
              return null;
            },
            routes: [
              ShellRoute(
                builder: (context, state, child) => Scaffold(body: child),
                routes: [
                  GoRoute(
                    path: '/dashboard',
                    builder: (context, state) => const Text('dashboard'),
                  ),
                  GoRoute(
                    path: '/members',
                    builder: (context, state) => const Text('members'),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('members'), findsOneWidget);
      expect(router.state.uri.path, '/acme/main/members');
    });
  });
}
