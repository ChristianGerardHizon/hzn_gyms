import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';
import 'package:hzn_gyms/src/features/users/presentation/widgets/user_role_list_panel.dart';

void main() {
  const longSystemRole = UserRole(
    id: 'role-1',
    name: 'Platform Admin With A Very Long Name',
    description: 'Cross-org platform management',
    permissions: ['system.admin'],
    isSystem: true,
  );

  testWidgets(
    'does not overflow title when system role name is long in 320px pane',
    (tester) async {
      final overflowErrors = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          overflowErrors.add(details);
        }
        previousOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = previousOnError);

      await tester.pumpWidget(
        TranslationProvider(
          child: ProviderScope(
            child: MaterialApp(
              home: SizedBox(
                width: 320,
                height: 600,
                child: UserRoleListPanel(
                  roles: const [longSystemRole],
                  onRefresh: () async {},
                  onEdit: (_) {},
                  onDelete: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Platform Admin'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(overflowErrors, isEmpty);
    },
  );
}
