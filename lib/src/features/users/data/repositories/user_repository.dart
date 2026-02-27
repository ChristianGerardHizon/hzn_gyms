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
import '../../domain/user.dart';
import '../dto/user_dto.dart';

part 'user_repository.g.dart';

/// Repository interface for user operations.
abstract class UserRepository {
  /// Fetches all users.
  FutureEither<List<User>> fetchAll({String? filter, String? sort});

  /// Fetches users with pagination.
  FutureEitherPaginated<User> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? filter,
    String? sort,
  });

  /// Fetches a single user by ID.
  FutureEither<User> fetchOne(String id);

  /// Creates a new user with password.
  FutureEither<User> create(User user, String password);

  /// Updates an existing user.
  FutureEither<User> update(User user);

  /// Soft deletes a user (sets isDeleted = true).
  FutureEither<void> delete(String id);

  /// Searches users by the specified fields.
  FutureEither<List<User>> search(String query, {List<String>? fields});

  /// Searches users with pagination.
  FutureEitherPaginated<User> searchPaginated(
    String query, {
    List<String>? fields,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
  });

  /// Updates a user's avatar image.
  FutureEither<User> updateAvatar(String id, http.MultipartFile file);

  /// Resets a user's password (admin action).
  FutureEither<void> resetPassword(String userId, String newPassword);

  /// Invalidates the user list cache.
  void invalidateCache();
}

/// Provides the UserRepository instance.
@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return UserRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [UserRepository] using PocketBase.
class UserRepositoryImpl implements UserRepository {
  final PocketBase _pb;

  UserRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.users);
  String get _expand => 'role,branch';

  // Cache for user list
  List<User>? _cachedUsers;
  DateTime? _cacheTimestamp;
  String? _cachedFilter;
  String? _cachedSort;

  // Cache TTL (5 minutes)
  static const _cacheTtl = Duration(minutes: 5);

  /// Checks if the cache is valid.
  bool _isCacheValid(String? filter, String? sort) {
    if (_cachedUsers == null || _cacheTimestamp == null) return false;
    if (_cachedFilter != filter || _cachedSort != sort) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  /// Invalidates the cache.
  @override
  void invalidateCache() {
    _cachedUsers = null;
    _cacheTimestamp = null;
    _cachedFilter = null;
    _cachedSort = null;
  }

  User _toEntity(RecordModel record) {
    final dto = UserDto.fromRecord(record);
    return dto.toEntity(baseUrl: _pb.baseURL);
  }

  @override
  FutureEither<List<User>> fetchAll({String? filter, String? sort}) async {
    // Return cached data if valid
    if (_isCacheValid(filter, sort)) {
      return Right(_cachedUsers!);
    }

    return TaskEither.tryCatch(
      () async {
        final baseFilter = PBFilters.active.build();
        final filterString =
            filter != null ? '$baseFilter && $filter' : baseFilter;

        final records = await _collection.getFullList(
          expand: _expand,
          filter: filterString,
          sort: sort ?? '-created',
        );

        final users = records.map(_toEntity).toList();

        // Update cache
        _cachedUsers = users;
        _cacheTimestamp = DateTime.now();
        _cachedFilter = filter;
        _cachedSort = sort;

        return users;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEitherPaginated<User> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? filter,
    String? sort,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final baseFilter = PBFilters.active.build();
        final filterString =
            filter != null ? '$baseFilter && $filter' : baseFilter;

        final result = await _collection.getList(
          page: page,
          perPage: perPage,
          expand: _expand,
          filter: filterString,
          sort: sort ?? '-created',
        );

        return PaginatedResult<User>(
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
  FutureEither<User> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'User ID cannot be empty',
            null,
            'invalid_user_id',
          );
        }

        final record = await _collection.getOne(id, expand: _expand);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<User> create(User user, String password) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'username': user.username,
          'name': user.name,
          'password': password,
          'passwordConfirm': password,
          'role': user.roleId,
          'branch': user.branchId,
          'isDeleted': false,
        };

        final record = await _collection.create(body: body, expand: _expand);
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<User> update(User user) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'username': user.username,
          'name': user.name,
          'role': user.roleId,
          'branch': user.branchId,
        };

        final record =
            await _collection.update(user.id, body: body, expand: _expand);
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
        await _collection.update(id, body: {'isDeleted': true});
        invalidateCache();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<User>> search(
    String query, {
    List<String>? fields,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final searchFields = fields ?? ['name', 'username'];
        final filter = PBFilter()
            .notDeleted()
            .searchFields(query, searchFields)
            .build();

        final records = await _collection.getFullList(
          expand: _expand,
          filter: filter,
          sort: 'name',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEitherPaginated<User> searchPaginated(
    String query, {
    List<String>? fields,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final searchFields = fields ?? ['name', 'username'];
        final filter = PBFilter()
            .notDeleted()
            .searchFields(query, searchFields)
            .build();

        final result = await _collection.getList(
          page: page,
          perPage: perPage,
          expand: _expand,
          filter: filter,
          sort: 'name',
        );

        return PaginatedResult<User>(
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
  FutureEither<User> updateAvatar(String id, http.MultipartFile file) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _collection.update(
          id,
          files: [file],
          expand: _expand,
        );
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> resetPassword(String userId, String newPassword) async {
    return TaskEither.tryCatch(
      () async {
        await _collection.update(userId, body: {
          'password': newPassword,
          'passwordConfirm': newPassword,
        });
      },
      Failure.handle,
    ).run();
  }
}
