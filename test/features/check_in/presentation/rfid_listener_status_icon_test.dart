import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kylie_gym/src/features/check_in/presentation/controllers/rfid_listener_status.dart';
import 'package:kylie_gym/src/features/check_in/presentation/widgets/rfid_listener_status_icon.dart';

void main() {
  testWidgets('RFID icon is green when listening and red otherwise', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: RfidListenerStatusIcon())),
      ),
    );

    Icon iconOf() => tester.widget<Icon>(find.byIcon(Icons.nfc));

    expect(iconOf().color, Colors.red);

    container.read(rfidListenerStatusControllerProvider.notifier).enable();
    await tester.pump();
    expect(iconOf().color, Colors.green);

    container.read(rfidListenerStatusControllerProvider.notifier).pause();
    await tester.pump();
    expect(iconOf().color, Colors.red);

    container.read(rfidListenerStatusControllerProvider.notifier).disable();
    await tester.pump();
    expect(iconOf().color, Colors.red);
  });
}
