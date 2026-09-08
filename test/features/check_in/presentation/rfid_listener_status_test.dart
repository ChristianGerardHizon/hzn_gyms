import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:hzn_gyms/src/features/check_in/presentation/controllers/rfid_listener_status.dart';

void main() {
  test('RFID status defaults off and supports enable/pause/disable', () {
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

    container.read(rfidListenerStatusControllerProvider.notifier).pause();
    expect(
      container.read(rfidListenerStatusControllerProvider),
      RfidListenerStatus.paused,
    );

    container.read(rfidListenerStatusControllerProvider.notifier).disable();
    expect(
      container.read(rfidListenerStatusControllerProvider),
      RfidListenerStatus.off,
    );
  });

  test('check-in hold refcount acquire/release', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier =
        container.read(rfidListenerStatusControllerProvider.notifier);

    expect(notifier.isCheckInHeld, isFalse);

    notifier.acquireCheckInHold();
    expect(notifier.isCheckInHeld, isTrue);

    notifier.acquireCheckInHold();
    expect(notifier.isCheckInHeld, isTrue);

    notifier.releaseCheckInHold();
    expect(notifier.isCheckInHeld, isTrue);

    notifier.releaseCheckInHold();
    expect(notifier.isCheckInHeld, isFalse);

    // Extra release is a no-op.
    notifier.releaseCheckInHold();
    expect(notifier.isCheckInHeld, isFalse);
  });
}
