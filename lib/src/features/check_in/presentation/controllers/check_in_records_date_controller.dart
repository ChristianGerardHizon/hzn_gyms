import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/date_utils.dart';

part 'check_in_records_date_controller.g.dart';

/// Selected calendar day for the Check-In Records page.
@Riverpod(keepAlive: true)
class CheckInRecordsDateController extends _$CheckInRecordsDateController {
  @override
  DateTime build() => toLocalDateOnly(DateTime.now());

  void setDate(DateTime date) {
    state = toLocalDateOnly(date);
  }

  void previousDay() {
    state = state.subtract(const Duration(days: 1));
  }

  void nextDay() {
    state = state.add(const Duration(days: 1));
  }

  void goToToday() {
    state = toLocalDateOnly(DateTime.now());
  }
}
