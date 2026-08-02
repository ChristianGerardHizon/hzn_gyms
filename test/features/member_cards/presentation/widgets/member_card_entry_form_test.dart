import 'package:ebe_gym/src/core/i18n/strings.g.dart';
import 'package:ebe_gym/src/features/check_in/domain/rfid_keyboard_wedge_simulator.dart';
import 'package:ebe_gym/src/features/member_cards/presentation/widgets/member_card_entry_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MemberCardEntryForm', () {
    testWidgets('starts waiting for scan', (tester) async {
      await _pumpForm(tester);

      expect(find.text('Scan card'), findsOneWidget);
      expect(find.text('Enter Card ID manually'), findsOneWidget);
      expect(find.text('Label'), findsNothing);
    });

    testWidgets('manual path shows Card ID field and label/notes', (
      tester,
    ) async {
      await _pumpForm(tester);

      await tester.tap(find.text('Enter Card ID manually'));
      await tester.pumpAndSettle();

      expect(find.text('Card ID / Value *'), findsOneWidget);
      expect(find.text('Label'), findsOneWidget);
      expect(find.text('Use scanner instead'), findsOneWidget);
    });

    testWidgets('scan captures card ID and shows label/notes', (tester) async {
      await _pumpForm(tester);

      await _pumpRfidWedgeScan(tester, 'ABCD1234');

      expect(find.text('ABCD1234'), findsOneWidget);
      expect(find.text('Scan again'), findsOneWidget);
      expect(find.text('Label'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('scan again returns to waiting state', (tester) async {
      await _pumpForm(tester);

      await _pumpRfidWedgeScan(tester, 'ABCD1234');

      await tester.tap(find.text('Scan again'));
      await tester.pumpAndSettle();

      expect(find.text('Scan card'), findsOneWidget);
      expect(find.text('ABCD1234'), findsNothing);
      expect(find.text('Label'), findsNothing);
    });

    test('memberCardEntryCanSubmit is false while waiting for scan', () {
      expect(
        memberCardEntryCanSubmit(MemberCardEntryMode.waitingForScan),
        isFalse,
      );
      expect(memberCardEntryCanSubmit(MemberCardEntryMode.scanned), isTrue);
      expect(memberCardEntryCanSubmit(MemberCardEntryMode.manual), isTrue);
    });

    test('memberCardEntryHasDraftInput reflects scan/manual state', () {
      expect(
        memberCardEntryHasDraftInput(
          MemberCardEntryMode.waitingForScan,
          null,
        ),
        isFalse,
      );
      expect(
        memberCardEntryHasDraftInput(
          MemberCardEntryMode.scanned,
          'ABCD1234',
        ),
        isTrue,
      );
      expect(
        memberCardEntryHasDraftInput(MemberCardEntryMode.manual, ''),
        isFalse,
      );
      expect(
        memberCardEntryHasDraftInput(
          MemberCardEntryMode.manual,
          'ABCD1234',
        ),
        isTrue,
      );
    });

    testWidgets('does not capture scan when scanEnabled is false', (
      tester,
    ) async {
      await _pumpForm(tester, scanEnabled: false);

      await _pumpRfidWedgeScan(tester, 'ABCD1234');

      expect(find.text('ABCD1234'), findsNothing);
      expect(find.text('Scan card'), findsOneWidget);
    });
  });
}

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
  await tester.pump();
  await tester.pump();
}

Future<void> _pumpForm(
  WidgetTester tester, {
  bool scanEnabled = true,
}) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: _MemberCardEntryFormHarness(scanEnabled: scanEnabled),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _MemberCardEntryFormHarness extends StatefulWidget {
  const _MemberCardEntryFormHarness({this.scanEnabled = true});

  final bool scanEnabled;

  @override
  State<_MemberCardEntryFormHarness> createState() =>
      _MemberCardEntryFormHarnessState();
}

class _MemberCardEntryFormHarnessState
    extends State<_MemberCardEntryFormHarness> {
  final formKey = GlobalKey<FormBuilderState>();
  final entryMode = ValueNotifier(MemberCardEntryMode.waitingForScan);

  @override
  void dispose() {
    entryMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: MemberCardEntryForm(
        formKey: formKey,
        entryMode: entryMode,
        scanEnabled: widget.scanEnabled,
      ),
    );
  }
}
