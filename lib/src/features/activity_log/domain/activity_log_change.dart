/// A single field change stored in an activity log entry.
class ActivityLogChange {
  const ActivityLogChange({
    required this.field,
    this.oldValue,
    this.newValue,
  });

  final String field;
  final Object? oldValue;
  final Object? newValue;

  factory ActivityLogChange.fromJson(String field, Map<String, dynamic> json) {
    return ActivityLogChange(
      field: field,
      oldValue: json['old'],
      newValue: json['new'],
    );
  }
}
