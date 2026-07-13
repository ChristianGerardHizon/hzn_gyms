import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_connectivity_provider.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/membership.dart';
import '../dto/membership_dto.dart';
import '../local/membership_cache_local_data_source.dart';

part 'membership_repository.g.dart';

/// Repository interface for membership plan operations.
abstract class MembershipRepository {
  /// Fetches membership plans.
  ///
  /// When [branchId] is set, returns plans valid at that branch
  /// (`validBranches` contains it, or empty = all branches).
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
  return MembershipRepositoryImpl(
    ref.watch(pocketbaseProvider),
    ref.watch(membershipCacheLocalDataSourceProvider),
    () => ref.read(pbConnectivityProvider).value ?? false,
  );
}

/// Implementation of [MembershipRepository] using PocketBase.
class MembershipRepositoryImpl implements MembershipRepository {
  MembershipRepositoryImpl(this._pb, this._localCache, this._isOnline);

  final PocketBase _pb;
  final MembershipCacheLocalDataSource _localCache;
  final bool Function() _isOnline;

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

    final result = await TaskEither.tryCatch(() async {
      final filter = PBFilter();
      if (branchId != null) {
        // validBranches contains branch OR empty (all branches)
        filter.raw(
          '(validBranches.id ?= "$branchId" || validBranches.id = "")',
        );
      }
      if (activeOnly == true) {
        filter.isTrue('isActive');
      }

      final records = await _collection.getFullList(
        filter: filter.build(),
        sort: 'name',
      );

      var memberships = records.map(_toEntity).toList();

      // Client-side fallback if PB empty multi-relation filter is unreliable
      if (branchId != null) {
        memberships = memberships
            .where((m) => m.isValidAtBranch(branchId))
            .toList();
      }

      await _localCache.replacePlans(memberships);

      _cachedMemberships = memberships;
      _cacheTimestamp = DateTime.now();
      _cachedBranchId = branchId;
      _cachedActiveOnly = activeOnly;

      return memberships;
    }, Failure.handle).run();

    return result.fold((failure) async {
      final cached = await _localCache.getPlans(branchId: branchId);
      if (cached.isNotEmpty) {
        var plans = cached;
        if (activeOnly == true) {
          plans = plans.where((p) => p.isActive).toList();
        }
        return Right(plans);
      }
      if (!_isOnline()) {
        return left(failure);
      }
      return left(failure);
    }, (memberships) => right(memberships));
  }

  @override
  FutureEither<Membership> fetchOne(String id) async {
    return TaskEither.tryCatch(() async {
      if (id.isEmpty) {
        throw const DataFailure(
          'Membership ID cannot be empty',
          null,
          'invalid_membership_id',
        );
      }

      final record = await _collection.getOne(id);
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<Membership> create(Membership membership) async {
    return TaskEither.tryCatch(() async {
      final body = <String, dynamic>{
        'name': membership.name,
        'description': membership.description,
        'durationDays': membership.durationDays,
        'price': membership.price,
        'branch': membership.branchId,
        'validBranches': membership.validBranches,
        'isActive': membership.isActive,
        'isFavorite': membership.isFavorite,
      };

      final record = await _collection.create(body: body);
      invalidateCache();
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<Membership> update(Membership membership) async {
    return TaskEither.tryCatch(() async {
      final body = <String, dynamic>{
        'name': membership.name,
        'description': membership.description,
        'durationDays': membership.durationDays,
        'price': membership.price,
        'branch': membership.branchId,
        'validBranches': membership.validBranches,
        'isActive': membership.isActive,
        'isFavorite': membership.isFavorite,
      };

      final record = await _collection.update(membership.id, body: body);
      invalidateCache();
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(() async {
      await _collection.delete(id);
      invalidateCache();
    }, Failure.handle).run();
  }
}
