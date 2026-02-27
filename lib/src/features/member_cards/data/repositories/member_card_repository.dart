import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/member_card.dart';
import '../dto/member_card_dto.dart';

part 'member_card_repository.g.dart';

/// Repository interface for member card operations.
abstract class MemberCardRepository {
  /// Fetches all cards for a member.
  FutureEither<List<MemberCard>> fetchByMember(String memberId);

  /// Fetches a single member card by ID.
  FutureEither<MemberCard> fetchOne(String id);

  /// Finds an active card by its card value (for check-in lookup).
  FutureEither<MemberCard?> findByCardValue(String cardValue);

  /// Creates a new member card.
  FutureEither<MemberCard> create({
    required String memberId,
    required String cardValue,
    String? label,
    String? notes,
  });

  /// Updates a card's status.
  FutureEither<MemberCard> updateStatus(String id, MemberCardStatus status);

  /// Deletes a member card.
  FutureEither<void> delete(String id);

  /// Invalidates the cache.
  void invalidateCache();
}

/// Provides the MemberCardRepository instance.
@Riverpod(keepAlive: true)
MemberCardRepository memberCardRepository(Ref ref) {
  return MemberCardRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [MemberCardRepository] using PocketBase.
class MemberCardRepositoryImpl implements MemberCardRepository {
  final PocketBase _pb;

  MemberCardRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.memberCards);

  // Cache per member
  final Map<String, List<MemberCard>> _memberCache = {};
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

  MemberCard _toEntity(RecordModel record) {
    return MemberCardDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<MemberCard>> fetchByMember(String memberId) async {
    if (_isMemberCacheValid(memberId)) {
      return Right(_memberCache[memberId]!);
    }

    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter().relation('member', memberId);

        final records = await _collection.getFullList(
          filter: filter.build(),
          sort: '-created',
          expand: 'member',
        );

        final cards = records.map(_toEntity).toList();

        _memberCache[memberId] = cards;
        _memberCacheTimestamps[memberId] = DateTime.now();

        return cards;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<MemberCard> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _collection.getOne(
          id,
          expand: 'member',
        );
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<MemberCard?> findByCardValue(String cardValue) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter()
            .equals('cardValue', cardValue)
            .equals('status', 'active');

        final records = await _collection.getFullList(
          filter: filter.build(),
          expand: 'member',
        );

        if (records.isEmpty) return null;
        return _toEntity(records.first);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<MemberCard> create({
    required String memberId,
    required String cardValue,
    String? label,
    String? notes,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'member': memberId,
          'cardValue': cardValue,
          'status': 'active',
          if (label != null && label.isNotEmpty) 'label': label,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        };

        final record = await _collection.create(body: body);
        _invalidateMemberCache(memberId);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<MemberCard> updateStatus(
      String id, MemberCardStatus status) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'status': status.name,
        };

        // Set deactivatedAt when deactivating or reporting lost
        if (status == MemberCardStatus.deactivated ||
            status == MemberCardStatus.lost) {
          body['deactivatedAt'] = DateTime.now().toUtcIso8601();
        }

        final record = await _collection.update(id, body: body);
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
