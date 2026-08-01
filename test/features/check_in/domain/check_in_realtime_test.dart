import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:ebe_gym/src/features/check_in/domain/check_in_realtime.dart';

void main() {
  RecordSubscriptionEvent eventWithTime(DateTime time) {
    return RecordSubscriptionEvent(
      action: 'create',
      record: RecordModel({
        'id': 'checkin-1',
        'checkInTime': time.toUtc().toIso8601String(),
      }),
    );
  }

  test('treats null record as relevant', () {
    expect(
      isTodaysCheckInSubscriptionEvent(RecordSubscriptionEvent(action: 'delete')),
      isTrue,
    );
  });

  test('accepts check-ins from today local date', () {
    final now = DateTime.now();
    expect(isTodaysCheckInSubscriptionEvent(eventWithTime(now)), isTrue);
  });

  test('rejects check-ins from another local date', () {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    expect(isTodaysCheckInSubscriptionEvent(eventWithTime(yesterday)), isFalse);
  });
}
