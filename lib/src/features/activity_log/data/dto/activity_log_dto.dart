import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/activity_log.dart';
import '../../domain/activity_log_action.dart';
import '../../domain/activity_log_change.dart';

/// DTO for ActivityLog records from PocketBase.
class ActivityLogDto {
  const ActivityLogDto({
    required this.id,
    required this.action,
    required this.collection,
    required this.recordId,
    required this.summary,
    this.changesRaw,
    this.actorId,
    this.actorName,
    this.branchId,
    this.branchName,
    this.metadata,
    this.created,
    this.updated,
  });

  final String id;
  final String action;
  final String collection;
  final String recordId;
  final String summary;
  final Map<String, dynamic>? changesRaw;
  final String? actorId;
  final String? actorName;
  final String? branchId;
  final String? branchName;
  final Map<String, dynamic>? metadata;
  final String? created;
  final String? updated;

  factory ActivityLogDto.fromRecord(RecordModel record) {
    final actorRecord = record.get<RecordModel?>('expand.actor');
    final branchRecord = record.get<RecordModel?>('expand.branch');

    return ActivityLogDto(
      id: record.id,
      action: record.getStringValue('action'),
      collection: record.getStringValue('collection'),
      recordId: record.getStringValue('recordId'),
      summary: record.getStringValue('summary'),
      changesRaw: _parseChanges(record.get('changes')),
      actorId: record.getStringValue('actor'),
      actorName: actorRecord?.getStringValue('name'),
      branchId: record.getStringValue('branch'),
      branchName: branchRecord?.getStringValue('name'),
      metadata: _parseMap(record.get('metadata')),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  ActivityLog toEntity() {
    final parsedAction =
        ActivityLogAction.fromValue(action) ?? ActivityLogAction.update;
    final changes = <ActivityLogChange>[];

    changesRaw?.forEach((field, value) {
      if (value is Map) {
        changes.add(ActivityLogChange.fromJson(field, Map<String, dynamic>.from(value)));
      }
    });

    return ActivityLog(
      id: id,
      action: parsedAction,
      collection: collection,
      recordId: recordId,
      summary: summary,
      changes: changes,
      actorId: actorId?.isNotEmpty == true ? actorId : null,
      actorName: actorName?.isNotEmpty == true ? actorName : null,
      branchId: branchId?.isNotEmpty == true ? branchId : null,
      branchName: branchName?.isNotEmpty == true ? branchName : null,
      metadata: metadata,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  static Map<String, dynamic>? _parseChanges(Object? raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  static Map<String, dynamic>? _parseMap(Object? raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }
}
