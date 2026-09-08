import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/check_in.dart';
import '../dto/check_in_dto.dart';

part 'check_in_repository.g.dart';

/// Repository interface for check-in operations.
abstract class CheckInRepository {
  /// Records a new check-in for a member.
  FutureEither<CheckIn> checkIn({
    required String memberId,
    required String branchId,
    required CheckInMethod method,
    String? checkedInBy,
    String? memberMembershipId,
    String? notes,
  });

  /// Soft-voids a check-in (audit trail; excluded from today's active list).
  FutureEither<CheckIn> voidCheckIn({
    required String id,
    required String voidedById,
    String? reason,
  });

  /// Fetches today's non-voided check-ins for a branch, or all branches in
  /// [organizationId] when [branchId] is null.
  FutureEither<List<CheckIn>> fetchTodaysCheckIns(
    String? branchId, {
    String? organizationId,
  });

  /// Fetches check-ins for a local calendar [date], optionally scoped to
  /// [branchId]. Includes voided rows by default (for records UI).
  /// When [branchId] is null, scopes to [organizationId] if provided.
  FutureEither<List<CheckIn>> fetchByDate({
    required DateTime date,
    String? branchId,
    String? organizationId,
    bool includeVoided = true,
  });

  /// Fetches check-ins for a specific member.
  FutureEither<List<CheckIn>> fetchByMember(String memberId);

  /// Latest non-voided check-in for [memberId] at [branchId], if any.
  FutureEither<CheckIn?> fetchLatestForMember({
    required String memberId,
    required String branchId,
  });

  /// Subscribes to check-in create/update/delete events.
  ///
  /// When [branchId] is set, only that branch's records are streamed.
  /// Call the returned [UnsubscribeFunc] to tear down the listener.
  Future<UnsubscribeFunc> subscribeCheckIns({
    String? branchId,
    required void Function(RecordSubscriptionEvent event) onEvent,
  });

  /// Invalidates the cache.
  void invalidateCache();
}

/// Provides the CheckInRepository instance.
@Riverpod(keepAlive: true)
CheckInRepository checkInRepository(Ref ref) {
  return CheckInRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [CheckInRepository] using PocketBase.
class CheckInRepositoryImpl implements CheckInRepository {
  final PocketBase _pb;

  CheckInRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.checkIns);

  // Cache for today's check-ins
  List<CheckIn>? _cachedTodaysCheckIns;
  DateTime? _cacheTimestamp;
  String? _cachedBranchId;

  static const _cacheTtl = Duration(minutes: 2);

  bool _isCacheValid(String branchId) {
    if (_cachedTodaysCheckIns == null || _cacheTimestamp == null) return false;
    if (_cachedBranchId != branchId) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  @override
  void invalidateCache() {
    _cachedTodaysCheckIns = null;
    _cacheTimestamp = null;
    _cachedBranchId = null;
  }

  CheckIn _toEntity(RecordModel record) {
    return CheckInDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<CheckIn> checkIn({
    required String memberId,
    required String branchId,
    required CheckInMethod method,
    String? checkedInBy,
    String? memberMembershipId,
    String? notes,
  }) async {
    return TaskEither.tryCatch(() async {
      final body = <String, dynamic>{
        'member': memberId,
        'branch': branchId,
        'checkInTime': DateTime.now().toUtcIso8601(),
        'method': method.name,
        'checkedInBy': checkedInBy,
        'memberMembership': memberMembershipId,
        'notes': notes,
        'isVoided': false,
      };

      final record = await _collection.create(body: body);
      invalidateCache();
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<CheckIn> voidCheckIn({
    required String id,
    required String voidedById,
    String? reason,
  }) async {
    return TaskEither.tryCatch(() async {
      final body = <String, dynamic>{
        'isVoided': true,
        'voidedAt': DateTime.now().toUtcIso8601(),
        'voidedBy': voidedById,
        if (reason != null && reason.trim().isNotEmpty)
          'voidReason': reason.trim(),
      };

      final record = await _collection.update(id, body: body);
      invalidateCache();
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<List<CheckIn>> fetchTodaysCheckIns(
    String? branchId, {
    String? organizationId,
  }) async {
    final cacheKey =
        branchId ?? (organizationId != null ? 'org:$organizationId' : '__ALL__');
    if (_isCacheValid(cacheKey)) {
      return Right(_cachedTodaysCheckIns!);
    }

    final result = await fetchByDate(
      date: DateTime.now(),
      branchId: branchId,
      organizationId: organizationId,
      includeVoided: false,
    );

    return result.map((checkIns) {
      _cachedTodaysCheckIns = checkIns;
      _cacheTimestamp = DateTime.now();
      _cachedBranchId = cacheKey;
      return checkIns;
    });
  }

  @override
  FutureEither<List<CheckIn>> fetchByDate({
    required DateTime date,
    String? branchId,
    String? organizationId,
    bool includeVoided = true,
  }) async {
    return TaskEither.tryCatch(() async {
      final localDate = toLocalDateOnly(date);
      final startOfDay = DateTime(
        localDate.year,
        localDate.month,
        localDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      var filter = PBFilter()
          .after('checkInTime', startOfDay)
          .before('checkInTime', endOfDay);
      if (branchId != null && branchId.isNotEmpty) {
        filter = filter.relation('branch', branchId);
      } else if (organizationId != null && organizationId.isNotEmpty) {
        filter = filter.relation('branch.organization', organizationId);
      }
      if (!includeVoided) {
        filter = filter.isFalse('isVoided');
      }

      final records = await _collection.getFullList(
        filter: filter.build(),
        sort: '-checkInTime',
        expand: 'member',
      );

      return records.map(_toEntity).toList();
    }, Failure.handle).run();
  }

  @override
  FutureEither<List<CheckIn>> fetchByMember(String memberId) async {
    return TaskEither.tryCatch(() async {
      final filter = PBFilter().relation('member', memberId);

      final records = await _collection.getFullList(
        filter: filter.build(),
        sort: '-checkInTime',
        expand: 'member',
      );

      return records.map(_toEntity).toList();
    }, Failure.handle).run();
  }

  @override
  FutureEither<CheckIn?> fetchLatestForMember({
    required String memberId,
    required String branchId,
  }) async {
    return TaskEither.tryCatch(() async {
      final filter = PBFilter()
          .relation('member', memberId)
          .relation('branch', branchId)
          .isFalse('isVoided');

      final records = await _collection.getList(
        page: 1,
        perPage: 1,
        filter: filter.build(),
        sort: '-checkInTime',
        expand: 'member',
      );

      if (records.items.isEmpty) return null;
      return _toEntity(records.items.first);
    }, Failure.handle).run();
  }

  @override
  Future<UnsubscribeFunc> subscribeCheckIns({
    String? branchId,
    required void Function(RecordSubscriptionEvent event) onEvent,
  }) {
    final filter = branchId != null && branchId.isNotEmpty
        ? PBFilter().relation('branch', branchId).build()
        : null;

    return _collection.subscribe('*', onEvent, filter: filter);
  }
}
