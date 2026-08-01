import 'package:pocketbase/pocketbase.dart';

import '../../../core/utils/date_utils.dart';

/// Whether a realtime check-in event should trigger today's list refresh.
///
/// Deletes (or events without a parseable time) are treated as relevant so
/// the list can reconcile. Other actions must fall on today's local date.
bool isTodaysCheckInSubscriptionEvent(RecordSubscriptionEvent event) {
  final record = event.record;
  if (record == null) return true;

  final checkInTime = parseToLocal(record.getStringValue('checkInTime'));
  if (checkInTime == null) return true;

  return calendarDaysUntil(checkInTime) == 0;
}
