import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/widgets/organization_seed_color_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrganizationSeedColorField', () {
    Future<void> pumpField(
      WidgetTester tester, {
      String? initialValue,
      GlobalKey<FormBuilderState>? formKey,
    }) async {
      final key = formKey ?? GlobalKey<FormBuilderState>();

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: FormBuilder(
                key: key,
                child: OrganizationSeedColorField(
                  name: 'seedColor',
                  initialValue: initialValue,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('typing hex stores normalized value and shows preview', (
      tester,
    ) async {
      final formKey = GlobalKey<FormBuilderState>();
      await pumpField(tester, formKey: formKey);

      await tester.enterText(find.byType(TextFormField), '#1E88E5');
      await tester.pump();

      expect(formKey.currentState?.fields['seedColor']?.value, '#1E88E5');
      expect(find.textContaining('Preview: #1E88E5'), findsOneWidget);
    });

    testWidgets('color picker dialog updates field value', (tester) async {
      final formKey = GlobalKey<FormBuilderState>();
      await pumpField(tester, formKey: formKey);

      await tester.tap(find.byTooltip('Pick color'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final value = formKey.currentState?.fields['seedColor']?.value as String?;
      expect(value, isNotNull);
      expect(value, startsWith('#'));
    });

    testWidgets('clear button removes selected color', (tester) async {
      final formKey = GlobalKey<FormBuilderState>();
      await pumpField(
        tester,
        formKey: formKey,
        initialValue: '#ABCDEF',
      );

      await tester.tap(find.byTooltip('Clear color'));
      await tester.pump();

      expect(formKey.currentState?.fields['seedColor']?.value, isNull);
      expect(find.textContaining('Preview:'), findsNothing);
    });

    testWidgets('loads initial hex value', (tester) async {
      final formKey = GlobalKey<FormBuilderState>();
      await pumpField(
        tester,
        formKey: formKey,
        initialValue: '#ABCDEF',
      );

      expect(formKey.currentState?.fields['seedColor']?.value, '#ABCDEF');
      expect(find.textContaining('Preview: #ABCDEF'), findsOneWidget);
    });

    testWidgets('preview swatch shows literal seed color for black', (
      tester,
    ) async {
      await pumpField(tester, initialValue: '#000000');

      final swatch = tester.widget<Container>(
        find.byKey(const Key('seed_color_preview_swatch')),
      );
      final decoration = swatch.decoration! as BoxDecoration;

      expect(decoration.color, const Color(0xFF000000));
    });
  });
}
