import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/user_role.dart';
import '../dto/user_role_dto.dart';

part 'user_role_repository.g.dart';

/// Repository interface for user role operations.
abstract class UserRoleRepository {
  /// Fetches all user roles.
  FutureEither<List<UserRole>> fetchAll({String? filter, String? sort});

  /// Fetches a single user role by ID.
  FutureEither<UserRole> fetchOne(String id);

  /// Creates a new user role.
  FutureEither<UserRole> create(UserRole role);

  /// Updates an existing user role.
  FutureEither<UserRole> update(UserRole role);

  /// Soft deletes a user role (sets isDeleted = true).
  FutureEither<void> delete(String id);

  /// Searches user roles by name.
  FutureEither<List<UserRole>> search(String query);

  /// Invalidates the role list cache.
  void invalidateCache();
}

/// Provides the UserRoleRepository instance.
@Riverpod(keepAlive: true)
UserRoleRepository userRoleRepository(Ref ref) {
  return UserRoleRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [UserRoleRepository] using PocketBase.
class UserRoleRepositoryImpl implements UserRoleRepository {
  final PocketBase _pb;

  UserRoleRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.userRoles);

  // Cache for role list
  List<UserRole>? _cachedRoles;
  DateTime? _cacheTimestamp;

  // Cache TTL (10 minutes - roles change less frequently)
  static const _cacheTtl = Duration(minutes: 10);

  /// Checks if the cache is valid.
  bool _isCacheValid() {
    if (_cachedRoles == null || _cacheTimestamp == null) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  /// Invalidates the cache.
  @override
  void invalidateCache() {
    _cachedRoles = null;
    _cacheTimestamp = null;
  }

  UserRole _toEntity(RecordModel record) {
    final dto = UserRoleDto.fromRecord(record);
    return dto.toEntity();
  }

  @override
  FutureEither<List<UserRole>> fetchAll({String? filter, String? sort}) async {
    // Return cached data if valid and no custom filter/sort
    if (_isCacheValid() && filter == null && sort == null) {
      return Right(_cachedRoles!);
    }

    return TaskEither.tryCatch(() async {
      final baseFilter = PBFilters.active.build();
      final filterString = filter != null
          ? '$baseFilter && $filter'
          : baseFilter;

      final records = await _collection.getFullList(
        filter: filterString,
        sort: sort ?? 'name',
      );

      final roles = records.map(_toEntity).toList();

      // Update cache only if using default filter/sort
      if (filter == null && sort == null) {
        _cachedRoles = roles;
        _cacheTimestamp = DateTime.now();
      }

      return roles;
    }, Failure.handle).run();
  }

  @override
  FutureEither<UserRole> fetchOne(String id) async {
    return TaskEither.tryCatch(() async {
      if (id.isEmpty) {
        throw const DataFailure(
          'Role ID cannot be empty',
          null,
          'invalid_role_id',
        );
      }

      final record = await _collection.getOne(id);
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<UserRole> create(UserRole role) async {
    return TaskEither.tryCatch(() async {
      final body = <String, dynamic>{
        'name': role.name,
        'description': role.description,
        'permissions': role.permissions,
        'isSystem': false, // User-created roles are never system roles
        'isDeleted': false,
      };

      final record = await _collection.create(body: body);
      invalidateCache();
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<UserRole> update(UserRole role) async {
    return TaskEither.tryCatch(() async {
      // Prevent updating system roles
      if (role.isSystem) {
        throw const DataFailure(
          'System roles cannot be modified',
          null,
          'system_role_protected',
        );
      }

      final body = <String, dynamic>{
        'name': role.name,
        'description': role.description,
        'permissions': role.permissions,
      };

      final record = await _collection.update(role.id, body: body);
      invalidateCache();
      return _toEntity(record);
    }, Failure.handle).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(() async {
      // Fetch the role first to check if it's a system role
      final record = await _collection.getOne(id);
      final role = _toEntity(record);

      if (role.isSystem) {
        throw const DataFailure(
          'System roles cannot be deleted',
          null,
          'system_role_protected',
        );
      }

      await _collection.update(id, body: {'isDeleted': true});
      invalidateCache();
    }, Failure.handle).run();
  }

  @override
  FutureEither<List<UserRole>> search(String query) async {
    return TaskEither.tryCatch(() async {
      final filter = PBFilter().notDeleted().searchFields(query, [
        'name',
        'description',
      ]).build();

      final records = await _collection.getFullList(
        filter: filter,
        sort: 'name',
      );

      return records.map(_toEntity).toList();
    }, Failure.handle).run();
  }
}
