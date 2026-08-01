/// Type of mutation captured in an activity log entry.
enum ActivityLogAction {
  create('create'),
  update('update'),
  delete('delete');

  const ActivityLogAction(this.value);

  final String value;

  static ActivityLogAction? fromValue(String? value) {
    if (value == null) return null;
    for (final action in ActivityLogAction.values) {
      if (action.value == value) return action;
    }
    return null;
  }

  String get label => switch (this) {
        ActivityLogAction.create => 'Created',
        ActivityLogAction.update => 'Updated',
        ActivityLogAction.delete => 'Deleted',
      };
}
