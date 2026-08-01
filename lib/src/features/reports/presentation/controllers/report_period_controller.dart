import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/report_period.dart';

part 'report_period_controller.g.dart';

/// Manages the selected report period grain and start/end range.
@Riverpod(keepAlive: true)
class ReportPeriodController extends _$ReportPeriodController {
  @override
  ReportPeriodSelection build() =>
      ReportPeriodSelection.current(ReportPeriod.day);

  void setPeriod(ReportPeriod period) {
    state = state.withPeriod(period);
  }

  void setRangeStart(DateTime value) {
    state = state.withRangeStart(value);
  }

  void setRangeEnd(DateTime value) {
    state = state.withRangeEnd(value);
  }

  void setDay(DateTime value) {
    state = state.withDay(value);
  }
}
