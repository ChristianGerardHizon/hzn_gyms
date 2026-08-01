import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/activity_log.dart';
import '../../domain/activity_log_filter.dart';
import '../dto/activity_log_dto.dart';

part 'activity_log_repository.g.dart';

/// Read-only repository for activity log entries.
abstract class ActivityLogRepository {
  FutureEitherPaginated<ActivityLog> fetchPaginated({
    required ActivityLogQuery query,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
  });

  FutureEither<ActivityLog> fetchOne(String id);
}

@Riverpod(keepAlive: true)
ActivityLogRepository activityLogRepository(Ref ref) {
  return ActivityLogRepositoryImpl(ref.watch(pocketbaseProvider));
}

class ActivityLogRepositoryImpl implements ActivityLogRepository {
  ActivityLogRepositoryImpl(this._pb);

  final PocketBase _pb;

  static const _expand = 'actor,branch';
  static const _fields =
      'id,action,collection,recordId,summary,changes,actor,branch,metadata,created,updated';

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.activityLogs);

  ActivityLog _toEntity(RecordModel record) {
    return ActivityLogDto.fromRecord(record).toEntity();
  }

  @override
  FutureEitherPaginated<ActivityLog> fetchPaginated({
    required ActivityLogQuery query,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final filter = buildActivityLogFilter(query);
        final result = await _collection.getList(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: '-created',
          expand: _expand,
          fields: _fields,
        );

        return PaginatedResult<ActivityLog>(
          items: result.items.map(_toEntity).toList(),
          page: result.page,
          totalItems: result.totalItems,
          totalPages: result.totalPages,
        );
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<ActivityLog> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _collection.getOne(
          id,
          expand: _expand,
          fields: _fields,
        );
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }
}
