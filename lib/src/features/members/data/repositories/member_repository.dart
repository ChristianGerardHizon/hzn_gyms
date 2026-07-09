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
import '../local/member_local_data_source.dart';

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
  FutureEither<Member> createWithPhoto(
    Member member, {
    http.MultipartFile? photo,
  });

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

  /// Syncs all members from PocketBase into the local cache.
  FutureEither<void> syncAllMembers({String? filter, String? sort});

  /// Invalidates the member list cache.
  Future<void> invalidateCache();
}

/// Provides the MemberRepository instance.
@Riverpod(keepAlive: true)
MemberRepository memberRepository(Ref ref) {
  return MemberRepositoryImpl(
    ref.watch(pocketbaseProvider),
    ref.watch(memberLocalDataSourceProvider),
  );
}

/// Implementation of [MemberRepository] using PocketBase with Drift cache.
class MemberRepositoryImpl implements MemberRepository {
  MemberRepositoryImpl(this._pb, this._localDataSource);

  final PocketBase _pb;
  final MemberLocalDataSource _localDataSource;

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.members);

  Member _toEntity(RecordModel record) {
    return MemberDto.fromRecord(record).toEntity(baseUrl: _pb.baseURL);
  }

  Future<void> _upsertRecord(RecordModel record) {
    return _localDataSource.upsertFromDtos([MemberDto.fromRecord(record)]);
  }

  Future<void> _upsertRecords(List<RecordModel> records) {
    return _localDataSource.upsertFromDtos(records.map(MemberDto.fromRecord));
  }

  @override
  Future<void> invalidateCache() => _localDataSource.clearAll();

  @override
  FutureEither<List<Member>> fetchAll({String? filter, String? sort}) async {
    return TaskEither.tryCatch(() async {
      final records = await _collection.getFullList(
        filter: filter,
        sort: sort ?? 'name',
      );

      final dtos = records.map(MemberDto.fromRecord).toList();
      await _localDataSource.replaceAllFromDtos(dtos);

      return dtos.map((dto) => dto.toEntity(baseUrl: _pb.baseURL)).toList();
    }, Failure.handle).run();
  }

  @override
  FutureEither<void> syncAllMembers({String? filter, String? sort}) async {
    return TaskEither.tryCatch(() async {
      final records = await _collection.getFullList(
        filter: filter,
        sort: sort ?? 'name',
      );
      await _localDataSource.replaceAllFromDtos(
        records.map(MemberDto.fromRecord),
      );
    }, Failure.handle).run();
  }

  @override
  FutureEither<Member> fetchOne(String id) async {
    return TaskEither.tryCatch(() async {
      if (id.isEmpty) {
        throw const DataFailure(
          'Member ID cannot be empty',
          null,
          'invalid_member_id',
        );
      }

      final record = await _collection.getOne(id);
      await _upsertRecord(record);
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<Member> create(Member member) async {
    return TaskEither.tryCatch(() async {
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
      await _upsertRecord(record);
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<Member> createWithPhoto(
    Member member, {
    http.MultipartFile? photo,
  }) async {
    return TaskEither.tryCatch(() async {
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
      await _upsertRecord(record);
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<Member> update(Member member) async {
    return TaskEither.tryCatch(() async {
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
      await _upsertRecord(record);
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(() async {
      await _collection.delete(id);
      await _localDataSource.deleteMember(id);
    }, Failure.handle).run();
  }

  @override
  FutureEither<List<Member>> search(
    String query, {
    List<String>? fields,
  }) async {
    return TaskEither.tryCatch(() async {
      final searchFields = fields ?? ['name', 'mobileNumber'];
      final filter = PBFilter().searchFields(query, searchFields).build();

      final records = await _collection.getFullList(
        filter: filter,
        sort: 'name',
      );

      await _upsertRecords(records);
      return records.map(_toEntity).toList();
    }, Failure.handle).run();
  }

  @override
  FutureEither<Member> updatePhoto(String id, http.MultipartFile file) async {
    return TaskEither.tryCatch(() async {
      final record = await _collection.update(id, files: [file]);
      await _upsertRecord(record);
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEitherPaginated<Member> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? filter,
    String? sort,
  }) async {
    return TaskEither.tryCatch(() async {
      final result = await _collection.getList(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort ?? 'name',
      );

      await _upsertRecords(result.items);

      return PaginatedResult<Member>(
        items: result.items.map(_toEntity).toList(),
        page: result.page,
        totalItems: result.totalItems,
        totalPages: result.totalPages,
      );
    }, Failure.handle).run();
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
    return TaskEither.tryCatch(() async {
      final searchFields = fields ?? ['name', 'mobileNumber'];
      final searchFilter = PBFilter().searchFields(query, searchFields).build();

      final combinedFilter = filter != null
          ? '$searchFilter && $filter'
          : searchFilter;

      final result = await _collection.getList(
        page: page,
        perPage: perPage,
        filter: combinedFilter,
        sort: sort ?? 'name',
      );

      await _upsertRecords(result.items);

      return PaginatedResult<Member>(
        items: result.items.map(_toEntity).toList(),
        page: result.page,
        totalItems: result.totalItems,
        totalPages: result.totalPages,
      );
    }, Failure.handle).run();
  }
}
