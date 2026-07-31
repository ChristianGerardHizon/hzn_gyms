import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:ebe_gym/src/features/check_in/presentation/controllers/rfid_listener_status.dart';

void main() {
  test('RFID status defaults off and toggles', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(rfidListenerStatusControllerProvider),
      RfidListenerStatus.off,
    );

    container.read(rfidListenerStatusControllerProvider.notifier).enable();
    expect(
      container.read(rfidListenerStatusControllerProvider),
      RfidListenerStatus.listening,
    );

    container.read(rfidListenerStatusControllerProvider.notifier).toggle();
    expect(
      container.read(rfidListenerStatusControllerProvider),
      RfidListenerStatus.off,
    );
  });
}
