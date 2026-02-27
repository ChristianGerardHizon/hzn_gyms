import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/member.dart';
import '../dto/member_dto.dart';

part 'member_repository.g.dart';

/// Repository interface for member operations.
abstract class MemberRepository {
  /// Fetches all members.
  FutureEither<List<Member>> fetchAll({String? filter, String? sort});

  /// Fetches a single member by ID.
  FutureEither<Member> fetchOne(String id);

  /// Creates a new member.
  FutureEither<Member> create(Member member);

  /// Updates an existing member.
  FutureEither<Member> update(Member member);

  /// Deletes a member by ID.
  FutureEither<void> delete(String id);

  /// Searches members by name or mobile number.
  FutureEither<List<Member>> search(String query, {List<String>? fields});

  /// Creates a new member with an optional photo.
  FutureEither<Member> createWithPhoto(Member member,
      {http.MultipartFile? photo});

  /// Updates a member's photo image.
  FutureEither<Member> updatePhoto(String id, http.MultipartFile file);

  /// Fetches members with pagination.
  FutureEitherPaginated<Member> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? filter,
    String? sort,
  });

  /// Searches members with pagination.
  FutureEitherPaginated<Member> searchPaginated(
    String query, {
    List<String>? fields,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? sort,
    String? filter,
  });

  /// Invalidates the member list cache.
  void invalidateCache();
}

/// Provides the MemberRepository instance.
@Riverpod(keepAlive: true)
MemberRepository memberRepository(Ref ref) {
  return MemberRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [MemberRepository] using PocketBase.
class MemberRepositoryImpl implements MemberRepository {
  final PocketBase _pb;

  MemberRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.members);

  // Cache for member list
  List<Member>? _cachedMembers;
  DateTime? _cacheTimestamp;
  String? _cachedFilter;
  String? _cachedSort;

  // Cache TTL (5 minutes)
  static const _cacheTtl = Duration(minutes: 5);

  /// Checks if the cache is valid.
  bool _isCacheValid(String? filter, String? sort) {
    if (_cachedMembers == null || _cacheTimestamp == null) return false;
    if (_cachedFilter != filter || _cachedSort != sort) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  @override
  void invalidateCache() {
    _cachedMembers = null;
    _cacheTimestamp = null;
    _cachedFilter = null;
    _cachedSort = null;
  }

  Member _toEntity(RecordModel record) {
    return MemberDto.fromRecord(record).toEntity(baseUrl: _pb.baseURL);
  }

  @override
  FutureEither<List<Member>> fetchAll({String? filter, String? sort}) async {
    if (_isCacheValid(filter, sort)) {
      return Right(_cachedMembers!);
    }

    return TaskEither.tryCatch(
      () async {
        final records = await _collection.getFullList(
          filter: filter,
          sort: sort ?? 'name',
        );

        final members = records.map(_toEntity).toList();

        // Update cache
        _cachedMembers = members;
        _cacheTimestamp = DateTime.now();
        _cachedFilter = filter;
        _cachedSort = sort;

        return members;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Member> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Member ID cannot be empty',
            null,
            'invalid_member_id',
          );
        }

        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Member> create(Member member) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': member.name,
          'mobileNumber': member.mobileNumber,
          'dateOfBirth': member.dateOfBirth?.toUtcIso8601(),
          'address': member.address,
          'sex': member.sex?.name,
          'remarks': member.remarks,
          'addedBy': member.addedBy,
          'rfidCardId': member.rfidCardId,
          'email': member.email,
          'emergencyContact': member.emergencyContact,
        };

        final record = await _collection.create(body: body);
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Member> createWithPhoto(
    Member member, {
    http.MultipartFile? photo,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': member.name,
          'mobileNumber': member.mobileNumber,
          'dateOfBirth': member.dateOfBirth?.toUtcIso8601(),
          'address': member.address,
          'sex': member.sex?.name,
          'remarks': member.remarks,
          'addedBy': member.addedBy,
          'rfidCardId': member.rfidCardId,
          'email': member.email,
          'emergencyContact': member.emergencyContact,
        };

        final record = await _collection.create(
          body: body,
          files: photo != null ? [photo] : [],
        );
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Member> update(Member member) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': member.name,
          'mobileNumber': member.mobileNumber,
          'dateOfBirth': member.dateOfBirth?.toUtcIso8601(),
          'address': member.address,
          'sex': member.sex?.name,
          'remarks': member.remarks,
          'rfidCardId': member.rfidCardId,
          'email': member.email,
          'emergencyContact': member.emergencyContact,
        };

        final record = await _collection.update(member.id, body: body);
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

  @override
  FutureEither<List<Member>> search(
    String query, {
    List<String>? fields,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final searchFields = fields ?? ['name', 'mobileNumber'];
        final filter =
            PBFilter().searchFields(query, searchFields).build();

        final records = await _collection.getFullList(
          filter: filter,
          sort: 'name',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Member> updatePhoto(String id, http.MultipartFile file) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _collection.update(id, files: [file]);
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEitherPaginated<Member> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? filter,
    String? sort,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final result = await _collection.getList(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: sort ?? 'name',
        );

        return PaginatedResult<Member>(
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
  FutureEitherPaginated<Member> searchPaginated(
    String query, {
    List<String>? fields,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? sort,
    String? filter,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final searchFields = fields ?? ['name', 'mobileNumber'];
        final searchFilter =
            PBFilter().searchFields(query, searchFields).build();

        final combinedFilter =
            filter != null ? '$searchFilter && $filter' : searchFilter;

        final result = await _collection.getList(
          page: page,
          perPage: perPage,
          filter: combinedFilter,
          sort: sort ?? 'name',
        );

        return PaginatedResult<Member>(
          items: result.items.map(_toEntity).toList(),
          page: result.page,
          totalItems: result.totalItems,
          totalPages: result.totalPages,
        );
      },
      Failure.handle,
    ).run();
  }
}
