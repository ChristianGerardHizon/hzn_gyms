import 'activity_log_action.dart';
import 'activity_log_change.dart';

/// Domain model for a system-wide activity log entry.
class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.action,
    required this.collection,
    required this.recordId,
    required this.summary,
    this.changes = const [],
    this.actorId,
    this.actorName,
    this.branchId,
    this.branchName,
    this.metadata,
    this.created,
    this.updated,
  });

  final String id;
  final ActivityLogAction action;
  final String collection;
  final String recordId;
  final String summary;
  final List<ActivityLogChange> changes;
  final String? actorId;
  final String? actorName;
  final String? branchId;
  final String? branchName;
  final Map<String, dynamic>? metadata;
  final DateTime? created;
  final DateTime? updated;

  bool get hasChanges => changes.isNotEmpty;
}
