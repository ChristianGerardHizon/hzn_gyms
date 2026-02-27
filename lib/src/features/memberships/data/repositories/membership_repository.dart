import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/membership.dart';
import '../dto/membership_dto.dart';

part 'membership_repository.g.dart';

/// Repository interface for membership plan operations.
abstract class MembershipRepository {
  /// Fetches all membership plans for a branch.
  FutureEither<List<Membership>> fetchAll({String? branchId, bool? activeOnly});

  /// Fetches a single membership plan by ID.
  FutureEither<Membership> fetchOne(String id);

  /// Creates a new membership plan.
  FutureEither<Membership> create(Membership membership);

  /// Updates an existing membership plan.
  FutureEither<Membership> update(Membership membership);

  /// Deletes a membership plan by ID.
  FutureEither<void> delete(String id);

  /// Invalidates the membership list cache.
  void invalidateCache();
}

/// Provides the MembershipRepository instance.
@Riverpod(keepAlive: true)
MembershipRepository membershipRepository(Ref ref) {
  return MembershipRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [MembershipRepository] using PocketBase.
class MembershipRepositoryImpl implements MembershipRepository {
  final PocketBase _pb;

  MembershipRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.memberships);

  // Cache for membership list
  List<Membership>? _cachedMemberships;
  DateTime? _cacheTimestamp;
  String? _cachedBranchId;
  bool? _cachedActiveOnly;

  // Cache TTL (5 minutes)
  static const _cacheTtl = Duration(minutes: 5);

  bool _isCacheValid(String? branchId, bool? activeOnly) {
    if (_cachedMemberships == null || _cacheTimestamp == null) return false;
    if (_cachedBranchId != branchId || _cachedActiveOnly != activeOnly) {
      return false;
    }
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  @override
  void invalidateCache() {
    _cachedMemberships = null;
    _cacheTimestamp = null;
    _cachedBranchId = null;
    _cachedActiveOnly = null;
  }

  Membership _toEntity(RecordModel record) {
    return MembershipDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<Membership>> fetchAll({
    String? branchId,
    bool? activeOnly,
  }) async {
    if (_isCacheValid(branchId, activeOnly)) {
      return Right(_cachedMemberships!);
    }

    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter();
        if (branchId != null) {
          filter.relation('branch', branchId);
        }
        if (activeOnly == true) {
          filter.isTrue('isActive');
        }

        final records = await _collection.getFullList(
          filter: filter.build(),
          sort: 'name',
        );

        final memberships = records.map(_toEntity).toList();

        _cachedMemberships = memberships;
        _cacheTimestamp = DateTime.now();
        _cachedBranchId = branchId;
        _cachedActiveOnly = activeOnly;

        return memberships;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Membership> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Membership ID cannot be empty',
            null,
            'invalid_membership_id',
          );
        }

        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Membership> create(Membership membership) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': membership.name,
          'description': membership.description,
          'durationDays': membership.durationDays,
          'price': membership.price,
          'branch': membership.branchId,
          'isActive': membership.isActive,
        };

        final record = await _collection.create(body: body);
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Membership> update(Membership membership) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': membership.name,
          'description': membership.description,
          'durationDays': membership.durationDays,
          'price': membership.price,
          'branch': membership.branchId,
          'isActive': membership.isActive,
        };

        final record = await _collection.update(membership.id, body: body);
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(
      () async {
        await _collection.delete(id);
        invalidateCache();
      },
      Failure.handle,
    ).run();
  }
}
