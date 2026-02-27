import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/membership_add_on.dart';
import '../dto/membership_add_on_dto.dart';

part 'membership_add_on_repository.g.dart';

/// Repository interface for membership add-on operations.
abstract class MembershipAddOnRepository {
  /// Fetches all add-ons for a membership plan.
  FutureEither<List<MembershipAddOn>> fetchByMembership(
    String membershipId, {
    bool? activeOnly,
  });

  /// Fetches a single add-on by ID.
  FutureEither<MembershipAddOn> fetchOne(String id);

  /// Creates a new add-on.
  FutureEither<MembershipAddOn> create(MembershipAddOn addOn);

  /// Updates an existing add-on.
  FutureEither<MembershipAddOn> update(MembershipAddOn addOn);

  /// Deletes an add-on by ID.
  FutureEither<void> delete(String id);

  /// Invalidates the add-on list cache.
  void invalidateCache();
}

/// Provides the MembershipAddOnRepository instance.
@Riverpod(keepAlive: true)
MembershipAddOnRepository membershipAddOnRepository(Ref ref) {
  return MembershipAddOnRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [MembershipAddOnRepository] using PocketBase.
class MembershipAddOnRepositoryImpl implements MembershipAddOnRepository {
  final PocketBase _pb;

  MembershipAddOnRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.membershipAddOns);

  // Cache per membership
  final Map<String, List<MembershipAddOn>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const _cacheTtl = Duration(minutes: 5);

  bool _isCacheValid(String membershipId) {
    final ts = _cacheTimestamps[membershipId];
    if (ts == null || !_cache.containsKey(membershipId)) return false;
    return DateTime.now().difference(ts) < _cacheTtl;
  }

  @override
  void invalidateCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  void _invalidateMembershipCache(String membershipId) {
    _cache.remove(membershipId);
    _cacheTimestamps.remove(membershipId);
  }

  MembershipAddOn _toEntity(RecordModel record) {
    return MembershipAddOnDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<MembershipAddOn>> fetchByMembership(
    String membershipId, {
    bool? activeOnly,
  }) async {
    if (_isCacheValid(membershipId)) {
      var cached = _cache[membershipId]!;
      if (activeOnly == true) {
        cached = cached.where((a) => a.isActive).toList();
      }
      return Right(cached);
    }

    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter().relation('membership', membershipId);

        final records = await _collection.getFullList(
          filter: filter.build(),
          sort: 'name',
        );

        final addOns = records.map(_toEntity).toList();
        _cache[membershipId] = addOns;
        _cacheTimestamps[membershipId] = DateTime.now();

        if (activeOnly == true) {
          return addOns.where((a) => a.isActive).toList();
        }
        return addOns;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<MembershipAddOn> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Add-on ID cannot be empty',
            null,
            'invalid_add_on_id',
          );
        }

        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<MembershipAddOn> create(MembershipAddOn addOn) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'membership': addOn.membershipId,
          'name': addOn.name,
          'description': addOn.description,
          'price': addOn.price,
          'isActive': addOn.isActive,
        };

        final record = await _collection.create(body: body);
        _invalidateMembershipCache(addOn.membershipId);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<MembershipAddOn> update(MembershipAddOn addOn) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': addOn.name,
          'description': addOn.description,
          'price': addOn.price,
          'isActive': addOn.isActive,
        };

        final record = await _collection.update(addOn.id, body: body);
        _invalidateMembershipCache(addOn.membershipId);
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
