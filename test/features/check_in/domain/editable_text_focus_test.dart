import 'package:kylie_gym/src/features/check_in/domain/editable_text_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isEditableTextFocusContext', () {
    test('returns false when context is null', () {
      expect(isEditableTextFocusContext(null), isFalse);
    });

    testWidgets('returns false for an unmounted context', (tester) async {
      BuildContext? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              saved = context;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(saved, isNotNull);
      expect(saved!.mounted, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());

      expect(saved!.mounted, isFalse);
      expect(isEditableTextFocusContext(saved), isFalse);
    });

    testWidgets('returns true when focus is on a TextField', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(focusNode: focusNode),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      expect(
        isEditableTextFocusContext(FocusManager.instance.primaryFocus?.context),
        isTrue,
      );
    });

    testWidgets('returns false when focus is not an EditableText', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Focus(
              focusNode: focusNode,
              child: const SizedBox(width: 10, height: 10),
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      expect(
        isEditableTextFocusContext(FocusManager.instance.primaryFocus?.context),
        isFalse,
      );
    });
  });
}
