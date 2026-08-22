import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kylie_gym/src/core/utils/date_utils.dart';
import 'package:kylie_gym/src/features/check_in/presentation/controllers/check_in_records_date_controller.dart';

void main() {
  test('defaults to today as a local date-only value', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final date = container.read(checkInRecordsDateControllerProvider);
    expect(date, toLocalDateOnly(DateTime.now()));
    expect(date.hour, 0);
    expect(date.minute, 0);
  });

  test('setDate normalizes to local date-only', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      checkInRecordsDateControllerProvider.notifier,
    );
    notifier.setDate(DateTime(2024, 6, 15, 14, 30));

    expect(
      container.read(checkInRecordsDateControllerProvider),
      DateTime(2024, 6, 15),
    );
  });

  test('previousDay and nextDay move by one calendar day', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      checkInRecordsDateControllerProvider.notifier,
    );
    notifier.setDate(DateTime(2024, 6, 15));

    notifier.previousDay();
    expect(
      container.read(checkInRecordsDateControllerProvider),
      DateTime(2024, 6, 14),
    );

    notifier.nextDay();
    expect(
      container.read(checkInRecordsDateControllerProvider),
      DateTime(2024, 6, 15),
    );
  });

  test('goToToday resets to today', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      checkInRecordsDateControllerProvider.notifier,
    );
    notifier.setDate(DateTime(2020, 1, 1));
    notifier.goToToday();

    expect(
      container.read(checkInRecordsDateControllerProvider),
      toLocalDateOnly(DateTime.now()),
    );
  });
}
