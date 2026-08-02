import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_connectivity_provider.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/sync/outbox_service.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/search_tokens.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
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

  /// Fast capped search for pickers: local cache first, then a limited server page.
  FutureEither<List<Member>> searchQuick(
    String query, {
    List<String>? fields,
    int limit = Pagination.memberPickerSearchLimit,
  });

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

/// Provides the [MemberRepository] instance.
@Riverpod(keepAlive: true)
MemberRepository memberRepository(Ref ref) {
  return MemberRepositoryImpl(
    pb: ref.watch(pocketbaseProvider),
    localDataSource: ref.watch(memberLocalDataSourceProvider),
    outboxService: OutboxService(ref.watch(appDatabaseProvider)),
    isOnline: () => ref.read(pbConnectivityProvider).value ?? false,
    hasAuth: () => ref.read(currentAuthProvider) != null,
  );
}

/// Implementation of [MemberRepository] using PocketBase with Drift cache.
class MemberRepositoryImpl implements MemberRepository {
  MemberRepositoryImpl({
    required PocketBase pb,
    required MemberLocalDataSource localDataSource,
    required OutboxService outboxService,
    required bool Function() isOnline,
    required bool Function() hasAuth,
  }) : _pb = pb,
       _localDataSource = localDataSource,
       _outboxService = outboxService,
       _isOnline = isOnline,
       _hasAuth = hasAuth;

  final PocketBase _pb;
  final MemberLocalDataSource _localDataSource;
  final OutboxService _outboxService;
  final bool Function() _isOnline;
  final bool Function() _hasAuth;

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.members);

  Member _toEntity(RecordModel record) {
    return MemberDto.fromRecord(record).toEntity(baseUrl: _pb.baseURL);
  }

  Map<String, dynamic> _memberBody(
    Member member, {
    bool includeAddedBy = true,
  }) {
    return {
      'name': formatPersonName(member.name),
      'mobileNumber': member.mobileNumber,
      'dateOfBirth': member.dateOfBirth?.toUtcIso8601(),
      'address': member.address,
      'sex': member.sex?.name,
      'remarks': member.remarks,
      if (includeAddedBy) 'addedBy': member.addedBy,
      'rfidCardId': member.rfidCardId,
      'email': member.email,
      'emergencyContact': member.emergencyContact,
      'branch': member.branch,
    };
  }

  bool _shouldQueueOffline() {
    return !_isOnline() && canWriteOffline(_pb, hasAuth: _hasAuth());
  }

  Future<void> _upsertRecord(RecordModel record) {
    return _localDataSource.upsertFromDtos([MemberDto.fromRecord(record)]);
  }

  Future<void> _upsertRecords(List<RecordModel> records) {
    return _localDataSource.upsertFromDtos(records.map(MemberDto.fromRecord));
  }

  @override
  Future<void> invalidateCache() => _localDataSource.clearSynced();

  @override
  FutureEither<List<Member>> fetchAll({String? filter, String? sort}) async {
    return TaskEither.tryCatch(() async {
      final sortValue = sort ?? 'name';
      final records = await _collection.getFullList(
        filter: filter,
        sort: sortValue,
      );

      final dtos = records.map(MemberDto.fromRecord).toList();
      await _localDataSource.replaceAllFromDtos(dtos);

      // Read back from cache so pending offline members remain visible.
      return _localDataSource.getAll(sort: sortValue);
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
    if (id.isEmpty) {
      return left(
        const DataFailure(
          'Member ID cannot be empty',
          null,
          'invalid_member_id',
        ),
      );
    }

    final cached = await _localDataSource.getMemberById(id);
    if (cached != null && !_isOnline()) {
      return right(cached);
    }

    final result = await TaskEither.tryCatch(() async {
      final record = await _collection.getOne(id);
      await _upsertRecord(record);
      return _toEntity(record);
    }, Failure.handle).run();

    return result.fold((failure) {
      if (cached != null) return right(cached);
      return left(failure);
    }, (member) => right(member));
  }

  @override
  FutureEither<Member> create(Member member) {
    return createWithPhoto(member);
  }

  @override
  FutureEither<Member> createWithPhoto(
    Member member, {
    http.MultipartFile? photo,
  }) async {
    if (_shouldQueueOffline()) {
      return _queueMemberCreate(member, photo: photo);
    }

    final id = member.id.isEmpty ? generateClientId() : member.id;
    final body = _memberBody(member)..['id'] = id;

    final result = await TaskEither.tryCatch(() async {
      final record = await _collection.create(
        body: body,
        files: photo != null ? [photo] : [],
      );
      await _localDataSource.upsertFromDtos([
        MemberDto.fromRecord(record),
      ], syncStatus: SyncStatus.synced);
      return _toEntity(record);
    }, Failure.handle).run();

    return result.fold((failure) {
      if (isNetworkFailure(failure) &&
          canWriteOffline(_pb, hasAuth: _hasAuth())) {
        return _queueMemberCreate(member.copyWith(id: id), photo: photo);
      }
      return left(failure);
    }, (created) => right(created));
  }

  FutureEither<Member> _queueMemberCreate(
    Member member, {
    http.MultipartFile? photo,
  }) async {
    return TaskEither.tryCatch(() async {
      final id = member.id.isEmpty ? generateClientId() : member.id;
      final body = _memberBody(member);
      List<int>? photoBytes;
      String? photoFilename;
      String? localPhotoPath;

      if (photo != null) {
        photoBytes = await _readMultipartBytes(photo);
        photoFilename = photo.filename;
        localPhotoPath = await _localDataSource.saveLocalPhoto(
          memberId: id,
          bytes: photoBytes,
          filename: photoFilename ?? 'photo.jpg',
        );
      }

      final pendingMember = member.copyWith(
        id: id,
        syncStatus: SyncStatus.pending,
        photo: localPhotoPath,
      );

      await _localDataSource.upsertMembers(
        [pendingMember],
        syncStatus: SyncStatus.pending,
        localPhotoPath: localPhotoPath,
      );

      await _outboxService.enqueueMemberCreate(
        clientRecordId: id,
        payload: body,
        photoBytes: photoBytes,
        photoFilename: photoFilename,
      );

      return pendingMember;
    }, Failure.handle).run();
  }

  @override
  FutureEither<Member> update(Member member) async {
    if (_shouldQueueOffline()) {
      return _queueMemberUpdate(member);
    }

    final body = _memberBody(member, includeAddedBy: false);

    final result = await TaskEither.tryCatch(() async {
      final record = await _collection.update(member.id, body: body);
      await _localDataSource.upsertFromDtos([
        MemberDto.fromRecord(record),
      ], syncStatus: SyncStatus.synced);
      return _toEntity(record);
    }, Failure.handle).run();

    return result.fold((failure) {
      if (isNetworkFailure(failure) &&
          canWriteOffline(_pb, hasAuth: _hasAuth())) {
        return _queueMemberUpdate(member);
      }
      return left(failure);
    }, (updated) => right(updated));
  }

  FutureEither<Member> _queueMemberUpdate(Member member) async {
    return TaskEither.tryCatch(() async {
      final body = _memberBody(member, includeAddedBy: false);
      final pendingMember = member.copyWith(syncStatus: SyncStatus.pending);

      await _localDataSource.upsertMembers([
        pendingMember,
      ], syncStatus: SyncStatus.pending);

      await _outboxService.enqueueMemberUpdate(
        clientRecordId: member.id,
        payload: body,
      );

      return pendingMember;
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
  FutureEither<List<Member>> searchQuick(
    String query, {
    List<String>? fields,
    int limit = Pagination.memberPickerSearchLimit,
  }) async {
    return TaskEither.tryCatch(() async {
      final searchFields = fields ?? ['name', 'mobileNumber'];
      final cached = await _localDataSource.searchQuick(
        query,
        fields: searchFields,
        limit: limit,
      );

      if (!_isOnline()) {
        return cached;
      }

      final searchFilter = PBFilter().searchFields(query, searchFields).build();
      final result = await _collection.getList(
        page: 1,
        perPage: limit,
        filter: searchFilter,
        sort: 'name',
      );

      await _upsertRecords(result.items);

      final serverItems = result.items.map(_toEntity).toList();
      return serverItems.isNotEmpty ? serverItems : cached;
    }, Failure.handle).run();
  }

  @override
  FutureEither<Member> updatePhoto(String id, http.MultipartFile file) async {
    if (_shouldQueueOffline()) {
      return _queueMemberPhotoUpdate(id, file);
    }

    final result = await TaskEither.tryCatch(() async {
      final record = await _collection.update(id, files: [file]);
      await _localDataSource.upsertFromDtos([
        MemberDto.fromRecord(record),
      ], syncStatus: SyncStatus.synced);
      return _toEntity(record);
    }, Failure.handle).run();

    return result.fold((failure) {
      if (isNetworkFailure(failure) &&
          canWriteOffline(_pb, hasAuth: _hasAuth())) {
        return _queueMemberPhotoUpdate(id, file);
      }
      return left(failure);
    }, (updated) => right(updated));
  }

  FutureEither<Member> _queueMemberPhotoUpdate(
    String id,
    http.MultipartFile file,
  ) async {
    return TaskEither.tryCatch(() async {
      final cached = await _localDataSource.getMemberById(id);
      if (cached == null) {
        throw const DataFailure('Member not found in cache', null, 'not_found');
      }

      final photoBytes = await _readMultipartBytes(file);
      final photoFilename = file.filename ?? 'photo.jpg';
      final localPhotoPath = await _localDataSource.saveLocalPhoto(
        memberId: id,
        bytes: photoBytes,
        filename: photoFilename,
      );

      final pendingMember = cached.copyWith(
        photo: localPhotoPath,
        syncStatus: SyncStatus.pending,
      );

      await _localDataSource.upsertMembers(
        [pendingMember],
        syncStatus: SyncStatus.pending,
        localPhotoPath: localPhotoPath,
      );

      await _outboxService.enqueueMemberUpdate(
        clientRecordId: id,
        payload: _memberBody(cached, includeAddedBy: false),
        photoBytes: photoBytes,
        photoFilename: photoFilename,
      );

      return pendingMember;
    }, Failure.handle).run();
  }

  Future<List<int>> _readMultipartBytes(http.MultipartFile file) async {
    final stream = file.finalize();
    final chunks = <List<int>>[];
    await for (final chunk in stream) {
      chunks.add(chunk);
    }
    final totalLength = chunks.fold<int>(0, (sum, c) => sum + c.length);
    final bytes = List<int>.filled(totalLength, 0);
    var offset = 0;
    for (final chunk in chunks) {
      bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return bytes;
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
