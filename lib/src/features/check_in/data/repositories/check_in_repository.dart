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

  /// Fetches today's check-ins for a branch.
  FutureEither<List<CheckIn>> fetchTodaysCheckIns(String branchId);

  /// Fetches check-ins for a specific member.
  FutureEither<List<CheckIn>> fetchByMember(String memberId);

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
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'member': memberId,
          'branch': branchId,
          'checkInTime': DateTime.now().toUtcIso8601(),
          'method': method.name,
          'checkedInBy': checkedInBy,
          'memberMembership': memberMembershipId,
          'notes': notes,
        };

        final record = await _collection.create(body: body);
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<CheckIn>> fetchTodaysCheckIns(String branchId) async {
    if (_isCacheValid(branchId)) {
      return Right(_cachedTodaysCheckIns!);
    }

    return TaskEither.tryCatch(
      () async {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final filter = PBFilter()
            .relation('branch', branchId)
            .after('checkInTime', startOfDay)
            .before('checkInTime', endOfDay);

        final records = await _collection.getFullList(
          filter: filter.build(),
          sort: '-checkInTime',
          expand: 'member',
        );

        final checkIns = records.map(_toEntity).toList();

        _cachedTodaysCheckIns = checkIns;
        _cacheTimestamp = DateTime.now();
        _cachedBranchId = branchId;

        return checkIns;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<CheckIn>> fetchByMember(String memberId) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter().relation('member', memberId);

        final records = await _collection.getFullList(
          filter: filter.build(),
          sort: '-checkInTime',
          expand: 'member',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }
}
