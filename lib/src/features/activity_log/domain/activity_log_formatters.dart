import 'activity_log_action.dart';
import 'activity_log_change.dart';
import 'activity_log_filter.dart';

/// Returns a human-readable label for a collection name.
String activityLogCollectionLabel(String collection) {
  return activityLogCollectionOptions[collection] ?? collection;
}

/// Returns a human-readable label for a field within a collection.
String activityLogFieldLabel(String collection, String field) {
  const common = {
    'name': 'Name',
    'email': 'Email',
    'status': 'Status',
    'total': 'Total',
    'totalAmount': 'Total Amount',
    'notes': 'Notes',
    'reason': 'Reason',
    'description': 'Description',
    'isDeleted': 'Deleted',
    'branch': 'Branch',
    'member': 'Member',
    'product': 'Product',
    'quantity': 'Quantity',
    'price': 'Price',
    'amount': 'Amount',
    'type': 'Type',
    'receiptNumber': 'Receipt #',
    'descriptor': 'Description',
    'mobileNumber': 'Mobile',
    'phone': 'Phone',
    'address': 'Address',
    'permissions': 'Permissions',
    'role': 'Role',
    'cashier': 'Cashier',
    'voidedBy': 'Voided By',
    'soldBy': 'Sold By',
    'addedBy': 'Added By',
    'checkedInBy': 'Checked In By',
    'oldValue': 'Previous Value',
    'newValue': 'New Value',
    'isPaid': 'Paid',
    'isActive': 'Active',
    'expirationDate': 'Expiration Date',
    'startDate': 'Start Date',
    'endDate': 'End Date',
  };

  return common[field] ?? _titleCase(field);
}

/// Formats a stored change value for display.
String formatActivityLogValue(Object? value) {
  if (value == null) return '—';
  if (value is bool) return value ? 'Yes' : 'No';
  if (value is List) {
    if (value.isEmpty) return '—';
    return value.map(formatActivityLogValue).join(', ');
  }
  if (value is Map) return value.toString();
  final text = value.toString();
  return text.isEmpty ? '—' : text;
}

/// Icon hint for an activity log action.
String activityLogActionIconName(ActivityLogAction action) => switch (action) {
      ActivityLogAction.create => 'add_circle_outline',
      ActivityLogAction.update => 'edit_outlined',
      ActivityLogAction.delete => 'delete_outline',
    };

/// Sorts changes for stable table display.
List<ActivityLogChange> sortedActivityLogChanges(
  List<ActivityLogChange> changes,
) {
  final copy = List<ActivityLogChange>.from(changes);
  copy.sort((a, b) => a.field.compareTo(b.field));
  return copy;
}

String _titleCase(String input) {
  if (input.isEmpty) return input;
  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    if (i == 0) {
      buffer.write(char.toUpperCase());
    } else if (char.toUpperCase() == char && char != char.toLowerCase()) {
      buffer.write(' $char');
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}
