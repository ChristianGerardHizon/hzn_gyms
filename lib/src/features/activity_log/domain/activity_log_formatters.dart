import 'package:intl/intl.dart';

import 'activity_log.dart';
import 'activity_log_action.dart';
import 'activity_log_change.dart';
import 'activity_log_filter.dart';

const _moneyFields = {'amount', 'price', 'total', 'totalAmount'};

const _entityLabels = <String, String>{
  'members': 'member',
  'memberCards': 'member card',
  'memberships': 'membership plan',
  'memberMemberships': 'member membership',
  'membershipAddOns': 'membership add-on',
  'memberMembershipAddOns': 'member add-on',
  'checkIns': 'check-in',
  'products': 'product',
  'productCategories': 'product category',
  'productStocks': 'product stock',
  'productLots': 'product lot',
  'productAdjustments': 'stock adjustment',
  'posGroups': 'cashier group',
  'posGroupItems': 'cashier group item',
  'sales': 'sale',
  'saleItems': 'sale item',
  'payments': 'payment',
  'users': 'user',
  'userRoles': 'role',
  'branches': 'branch',
  'printerConfigs': 'printer',
  'quantityUnits': 'quantity unit',
};

const _recordLabelFields = [
  'name',
  'descriptor',
  'receiptNumber',
  'email',
  'title',
  'mobileNumber',
];

final _currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
final _dateOnlyFormat = DateFormat('MMM d, yyyy');
final _dateTimeFormat = DateFormat('MMM d, yyyy h:mm a');

final _isoDatePattern = RegExp(
  r'^\d{4}-\d{2}-\d{2}([ T]\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:?\d{2})?)?$',
);

/// Returns a human-readable label for a collection name.
String activityLogCollectionLabel(String collection) {
  return activityLogCollectionOptions[collection] ?? collection;
}

/// Singular entity label used in descriptive headlines (lowercase).
String activityLogEntityLabel(String collection) {
  return _entityLabels[collection] ?? collection;
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
///
/// When [field] is a money field, numeric values are shown as Philippine pesos.
/// ISO / PocketBase date strings are shown as local dates.
String formatActivityLogValue(Object? value, {String? field}) {
  if (value == null) return '—';
  if (value is bool) return value ? 'Yes' : 'No';
  if (value is List) {
    if (value.isEmpty) return '—';
    return value
        .map((item) => formatActivityLogValue(item, field: field))
        .join(', ');
  }
  if (value is Map) return value.toString();

  if (field != null && _moneyFields.contains(field)) {
    final amount = _asNumber(value);
    if (amount != null) return _currencyFormat.format(amount);
  }

  if (value is DateTime) {
    return _formatDateTime(value, includeTime: true);
  }

  final text = value.toString();
  if (text.isEmpty) return '—';

  final parsed = _tryParseDate(text);
  if (parsed != null) {
    final includeTime = text.length > 10 && !_isMidnight(parsed);
    return _formatDateTime(parsed, includeTime: includeTime);
  }

  return text;
}

/// Descriptive one-line headline, e.g. `Chris updated member Juan Dela Cruz`.
String formatActivityLogHeadline(ActivityLog log) {
  final verb = _headlineVerb(log);
  final entity = activityLogEntityLabel(log.collection);
  final recordLabel = activityLogRecordLabel(log);
  final phrase = '$entity $recordLabel'.trim();
  final actor = log.actorName?.trim();

  if (actor != null && actor.isNotEmpty) {
    return '$actor $verb $phrase';
  }

  return '${verb[0].toUpperCase()}${verb.substring(1)} $phrase';
}

/// Compact old → new preview for updates. Null for create/delete or no changes.
String? formatActivityLogChangePreview(ActivityLog log, {int maxChanges = 3}) {
  if (log.action != ActivityLogAction.update) return null;

  final sorted = sortedActivityLogChanges(log.changes);
  if (sorted.isEmpty) return null;

  final shown = sorted.take(maxChanges);
  final parts = shown.map((change) {
    final label = activityLogFieldLabel(log.collection, change.field);
    final oldValue = formatActivityLogValue(
      change.oldValue,
      field: change.field,
    );
    final newValue = formatActivityLogValue(
      change.newValue,
      field: change.field,
    );
    return '$label: $oldValue → $newValue';
  });

  var text = parts.join(' · ');
  final remaining = sorted.length - maxChanges;
  if (remaining > 0) {
    text = '$text · +$remaining more';
  }
  return text;
}

/// Best-effort record identity from the stored summary or changed fields.
String activityLogRecordLabel(ActivityLog log) {
  final fromSummary = _recordLabelFromSummary(log.summary);
  if (fromSummary != null) return fromSummary;

  for (final field in _recordLabelFields) {
    for (final change in log.changes) {
      if (change.field != field) continue;
      final candidate = change.newValue ?? change.oldValue;
      if (candidate == null) continue;
      final text = candidate.toString().trim();
      if (text.isNotEmpty) return text;
    }
  }

  return log.recordId;
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

String _headlineVerb(ActivityLog log) {
  if (log.action == ActivityLogAction.update) {
    final status = _changeFor(log, 'status')?.newValue;
    if (status == 'voided') return 'voided';
    if (status == 'refunded') return 'refunded';
    final deleted = _changeFor(log, 'isDeleted')?.newValue;
    if (deleted == true) return 'deleted';
  }

  return switch (log.action) {
    ActivityLogAction.create => 'created',
    ActivityLogAction.update => 'updated',
    ActivityLogAction.delete => 'deleted',
  };
}

ActivityLogChange? _changeFor(ActivityLog log, String field) {
  for (final change in log.changes) {
    if (change.field == field) return change;
  }
  return null;
}

String? _recordLabelFromSummary(String summary) {
  final colon = summary.indexOf(': ');
  if (colon < 0) return null;
  final label = summary.substring(colon + 2).trim();
  return label.isEmpty ? null : label;
}

num? _asNumber(Object value) {
  if (value is num) return value;
  return num.tryParse(value.toString());
}

DateTime? _tryParseDate(String text) {
  if (!_isoDatePattern.hasMatch(text)) return null;
  final normalized = text.contains('T') ? text : text.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized)?.toLocal();
}

bool _isMidnight(DateTime date) {
  return date.hour == 0 &&
      date.minute == 0 &&
      date.second == 0 &&
      date.millisecond == 0;
}

String _formatDateTime(DateTime date, {required bool includeTime}) {
  return includeTime
      ? _dateTimeFormat.format(date)
      : _dateOnlyFormat.format(date);
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
