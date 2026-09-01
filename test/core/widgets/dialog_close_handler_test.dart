import 'package:hzn_gyms/src/core/widgets/dialog_close_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpDialog(
    WidgetTester tester, {
    required Widget dialogChild,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Dialog(
                    child: DialogCloseHandler(child: dialogChild),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('Escape closes dialog', (tester) async {
    await pumpDialog(
      tester,
      dialogChild: const SizedBox(
        width: 200,
        height: 100,
        child: Center(child: Text('Renew Membership')),
      ),
    );

    expect(find.text('Renew Membership'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Renew Membership'), findsNothing);
  });

  testWidgets('Escape closes dialog while TextField has focus', (tester) async {
    await pumpDialog(
      tester,
      dialogChild: const SizedBox(
        width: 300,
        height: 120,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Search member'),
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('onClose false prevents Escape from closing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Dialog(
                    child: DialogCloseHandler(
                      onClose: (_) async => false,
                      child: const SizedBox(
                        width: 200,
                        height: 100,
                        child: Center(child: Text('Blocked')),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Blocked'), findsOneWidget);
  });
}
