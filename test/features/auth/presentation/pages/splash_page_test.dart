import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/features/auth/domain/auth_state.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/auth/presentation/pages/splash_page.dart';

class _LoadingAuthController extends AuthController {
  @override
  Future<AuthState?> build() => Completer<AuthState?>().future;
}

void main() {
  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('shows warming-up note and a loading verb', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_LoadingAuthController.new),
        ],
        child: TranslationProvider(
          child: const MaterialApp(home: SplashPage()),
        ),
      ),
    );

    await tester.pump();

    expect(find.text(t.auth.almostThereWarmingUp), findsOneWidget);
    expect(find.textContaining(splashLoadingVerbs.first), findsOneWidget);
  });
}
