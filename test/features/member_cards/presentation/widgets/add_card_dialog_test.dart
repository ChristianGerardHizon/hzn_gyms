import 'package:kylie_gym/src/core/i18n/strings.g.dart';
import 'package:kylie_gym/src/features/check_in/domain/rfid_keyboard_wedge_simulator.dart';
import 'package:kylie_gym/src/features/member_cards/domain/member_card.dart';
import 'package:kylie_gym/src/features/member_cards/presentation/controllers/member_cards_controller.dart';
import 'package:kylie_gym/src/features/member_cards/presentation/widgets/add_card_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AddCardDialog', () {
    testWidgets('starts waiting for scan with Save disabled', (tester) async {
      await _pumpDialog(tester);

      expect(find.text('Scan card'), findsOneWidget);
      expect(find.text('Enter Card ID manually'), findsOneWidget);
      expect(find.text('Label'), findsNothing);

      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('manual path shows Card ID field and enables Save', (
      tester,
    ) async {
      await _pumpDialog(tester);

      await tester.tap(find.text('Enter Card ID manually'));
      await tester.pumpAndSettle();

      expect(find.text('Card ID / Value *'), findsOneWidget);
      expect(find.text('Label'), findsOneWidget);
      expect(find.text('Use scanner instead'), findsOneWidget);

      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('scan captures card ID and shows label/notes', (tester) async {
      await _pumpDialog(tester);

      await _pumpRfidWedgeScan(tester, 'ABCD1234');

      expect(find.text('ABCD1234'), findsOneWidget);
      expect(find.text('Scan again'), findsOneWidget);
      expect(find.text('Label'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);

      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('scan again returns to waiting state', (tester) async {
      await _pumpDialog(tester);

      await _pumpRfidWedgeScan(tester, 'ABCD1234');

      await tester.tap(find.text('Scan again'));
      await tester.pumpAndSettle();

      expect(find.text('Scan card'), findsOneWidget);
      expect(find.text('ABCD1234'), findsNothing);
      expect(find.text('Label'), findsNothing);

      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButton.onPressed, isNull);
    });
  });
}

/// Injects a wedge scan using [tester.pump] so widget-test timers advance.
Future<void> _pumpRfidWedgeScan(WidgetTester tester, String cardId) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();

  var elapsed = Duration.zero;
  for (final stroke in buildRfidWedgeKeySequence(cardId)) {
    HardwareKeyboard.instance.handleKeyEvent(
      KeyDownEvent(
        physicalKey: stroke.physicalKey,
        logicalKey: stroke.logicalKey,
        character: stroke.character,
        timeStamp: elapsed,
      ),
    );
    elapsed += kRfidWedgeInterKeyDelay;
    await tester.pump(kRfidWedgeInterKeyDelay);
  }
  // Allow post-frame didChange + rebuild after scan.
  await tester.pump();
  await tester.pump();
}

Future<void> _pumpDialog(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          memberCardsControllerProvider.overrideWith(
            _FakeMemberCardsController.new,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AddCardDialog(memberId: 'member-1'),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeMemberCardsController extends MemberCardsController {
  @override
  Future<List<MemberCard>> build(String memberId) async => const [];

  @override
  Future<bool> addCard({
    required String cardValue,
    String? label,
    String? notes,
  }) async =>
      true;
}
