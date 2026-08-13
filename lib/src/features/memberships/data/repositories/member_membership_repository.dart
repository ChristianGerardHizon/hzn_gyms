import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/idempotency.dart';
import '../../domain/member_membership.dart';
import '../dto/member_membership_dto.dart';

part 'member_membership_repository.g.dart';

/// Repository interface for member membership (subscription) operations.
abstract class MemberMembershipRepository {
  /// Fetches all memberships for a member.
  FutureEither<List<MemberMembership>> fetchByMember(String memberId);

  /// Fetches a single member membership by ID.
  FutureEither<MemberMembership> fetchOne(String id);

  /// Creates a new member membership.
  FutureEither<MemberMembership> create({
    required String memberId,
    required String membershipId,
    required DateTime startDate,
    required DateTime endDate,
    required String branchId,
    String? saleId,
    String? soldBy,
    String? notes,
    String? idempotencyKey,
    MemberMembershipStatus status = MemberMembershipStatus.active,
  });

  /// Updates an existing member membership.
  FutureEither<MemberMembership> update(
    String id, {
    MemberMembershipStatus? status,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Sets [status] on every membership linked to [saleId].
  FutureEither<void> updateStatusBySaleId(
    String saleId,
    MemberMembershipStatus status,
  );

  /// Cancels a member membership.
  FutureEither<MemberMembership> cancel(String id);

  /// Fetches active memberships for a member.
  ///
  /// When [validAtBranchId] is set, only memberships whose plan is valid at
  /// that branch are returned (empty plan `validBranches` = all branches).
  FutureEither<List<MemberMembership>> fetchActive(
    String memberId, {
    String? validAtBranchId,
  });

  /// Fetches active memberships for multiple members, grouped by member ID.
  FutureEither<Map<String, List<MemberMembership>>> fetchActiveByMemberIds(
    List<String> memberIds,
  );

  /// Invalidates the cache.
  void invalidateCache();
}

/// Provides the MemberMembershipRepository instance.
@Riverpod(keepAlive: true)
MemberMembershipRepository memberMembershipRepository(Ref ref) {
  return MemberMembershipRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [MemberMembershipRepository] using PocketBase.
class MemberMembershipRepositoryImpl implements MemberMembershipRepository {
  final PocketBase _pb;

  MemberMembershipRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.memberMemberships);

  // Cache per member
  final Map<String, List<MemberMembership>> _memberCache = {};
  final Map<String, DateTime> _memberCacheTimestamps = {};

  static const _cacheTtl = Duration(minutes: 5);

  bool _isMemberCacheValid(String memberId) {
    final timestamp = _memberCacheTimestamps[memberId];
    if (timestamp == null || !_memberCache.containsKey(memberId)) return false;
    return DateTime.now().difference(timestamp) < _cacheTtl;
  }

  @override
  void invalidateCache() {
    _memberCache.clear();
    _memberCacheTimestamps.clear();
  }

  void _invalidateMemberCache(String memberId) {
    _memberCache.remove(memberId);
    _memberCacheTimestamps.remove(memberId);
  }

  MemberMembership _toEntity(RecordModel record) {
    return MemberMembershipDto.fromRecord(record).toEntity();
  }

  PBFilter _activeMembershipsFilter() => PBFilters.activeMemberMemberships();

  static const _memberIdChunkSize = 50;

  @override
  FutureEither<List<MemberMembership>> fetchByMember(String memberId) async {
    if (_isMemberCacheValid(memberId)) {
      return Right(_memberCache[memberId]!);
    }

    return TaskEither.tryCatch(() async {
      final filter = PBFilter().relation('member', memberId);

      final records = await _collection.getFullList(
        filter: filter.build(),
        sort: '-startDate',
        expand: 'member,membership',
      );

      final memberships = records.map(_toEntity).toList();

      _memberCache[memberId] = memberships;
      _memberCacheTimestamps[memberId] = DateTime.now();

      return memberships;
    }, Failure.handle).run();
  }

  @override
  FutureEither<MemberMembership> fetchOne(String id) async {
    return TaskEither.tryCatch(() async {
      if (id.isEmpty) {
        throw const DataFailure(
          'Member membership ID cannot be empty',
          null,
          'invalid_member_membership_id',
        );
      }

      final record = await _collection.getOne(id, expand: 'member,membership');
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<MemberMembership> create({
    required String memberId,
    required String membershipId,
    required DateTime startDate,
    required DateTime endDate,
    required String branchId,
    String? saleId,
    String? soldBy,
    String? notes,
    String? idempotencyKey,
    MemberMembershipStatus status = MemberMembershipStatus.active,
  }) async {
    return TaskEither.tryCatch(() async {
      final key = idempotencyKey?.trim();
      final body = <String, dynamic>{
        'member': memberId,
        'membership': membershipId,
        'startDate': startDate.toUtcIso8601(),
        'endDate': endDate.toUtcIso8601(),
        'status': status.name,
        'branch': branchId,
        if (saleId != null) 'saleId': saleId,
        'soldBy': soldBy,
        'notes': notes,
        if (key != null && key.isNotEmpty) 'idempotencyKey': key,
      };

      try {
        final record = await _collection.create(body: body);
        _invalidateMemberCache(memberId);
        return _toEntity(record);
      } on ClientException catch (error) {
        if (key != null &&
            key.isNotEmpty &&
            isPocketBaseUniqueViolation(error)) {
          final existing = await _findByIdempotencyKey(key);
          if (existing != null) {
            _invalidateMemberCache(memberId);
            return existing;
          }
        }
        rethrow;
      }
    }, Failure.handle).run();
  }

  Future<MemberMembership?> _findByIdempotencyKey(String key) async {
    final escaped = escapeIdempotencyKeyForFilter(key);
    final result = await _collection.getList(
      page: 1,
      perPage: 1,
      filter: 'idempotencyKey = "$escaped"',
      expand: 'member,membership',
    );
    if (result.items.isEmpty) return null;
    return _toEntity(result.items.first);
  }

  @override
  FutureEither<MemberMembership> update(
    String id, {
    MemberMembershipStatus? status,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return TaskEither.tryCatch(() async {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status.name;
      if (notes != null) body['notes'] = notes;
      if (startDate != null) body['startDate'] = startDate.toUtcIso8601();
      if (endDate != null) body['endDate'] = endDate.toUtcIso8601();

      final record = await _collection.update(id, body: body);
      invalidateCache();
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<void> updateStatusBySaleId(
    String saleId,
    MemberMembershipStatus status,
  ) async {
    return TaskEither.tryCatch(() async {
      final records = await _collection.getFullList(
        filter: PBFilter().equals('saleId', saleId).build(),
      );

      await Future.wait(
        records.map((record) async {
          await _collection.update(record.id, body: {'status': status.name});
          _invalidateMemberCache(record.getStringValue('member'));
        }),
      );
    }, Failure.handle).run();
  }

  @override
  FutureEither<MemberMembership> cancel(String id) async {
    return update(id, status: MemberMembershipStatus.cancelled);
  }

  @override
  FutureEither<List<MemberMembership>> fetchActive(
    String memberId, {
    String? validAtBranchId,
  }) async {
    return TaskEither.tryCatch(() async {
      final filter = _activeMembershipsFilter().relation('member', memberId);

      final records = await _collection.getFullList(
        filter: filter.build(),
        sort: '-endDate',
        expand: 'member,membership',
      );

      var memberships = records.map(_toEntity).toList();
      if (validAtBranchId != null) {
        memberships = memberships
            .where((m) => m.isValidAtBranch(validAtBranchId))
            .toList();
      }
      return memberships;
    }, Failure.handle).run();
  }

  @override
  FutureEither<Map<String, List<MemberMembership>>> fetchActiveByMemberIds(
    List<String> memberIds,
  ) async {
    if (memberIds.isEmpty) {
      return const Right({});
    }

    return TaskEither.tryCatch(() async {
      final uniqueIds = memberIds.toSet().toList();
      final allRecords = <RecordModel>[];

      for (var i = 0; i < uniqueIds.length; i += _memberIdChunkSize) {
        final chunk = uniqueIds.skip(i).take(_memberIdChunkSize);
        final filter = _activeMembershipsFilter().relationAny('member', chunk);

        final records = await _collection.getFullList(
          filter: filter.build(),
          sort: '-endDate',
          expand: 'membership',
        );
        allRecords.addAll(records);
      }

      final grouped = <String, List<MemberMembership>>{};
      for (final record in allRecords) {
        final membership = _toEntity(record);
        grouped.putIfAbsent(membership.memberId, () => []).add(membership);
      }

      return grouped;
    }, Failure.handle).run();
  }
}
