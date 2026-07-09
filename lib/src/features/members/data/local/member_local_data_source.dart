import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/members_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/member.dart';
import '../dto/member_dto.dart';

part 'member_local_data_source.g.dart';

/// Local persistence layer for cached members using Drift.
class MemberLocalDataSource {
  MemberLocalDataSource(this._db, this._baseUrl);

  final AppDatabase _db;
  final String _baseUrl;

  MembersDao get _dao => _db.membersDao;

  /// Returns a cached member by ID, if available.
  Future<Member?> getMemberById(String id) async {
    final row = await _dao.getMemberById(id);
    return row == null ? null : _mapRowToEntity(row);
  }

  /// Returns all cached members.
  Future<List<Member>> getAll({String? sort}) async {
    final rows = await _dao.getAll(sort: sort ?? 'name');
    return rows.map(_mapRowToEntity).toList();
  }

  /// Returns a paginated slice from the local cache.
  Future<PaginatedResult<Member>> getPaginated({
    int page = 1,
    int perPage = 20,
    String? sort,
  }) async {
    final sortValue = sort ?? 'name';
    final rows = await _dao.getPaginated(
      page: page,
      perPage: perPage,
      sort: sortValue,
    );
    final totalItems = await _dao.countAll();
    final totalPages = totalItems == 0 ? 0 : (totalItems / perPage).ceil();

    return PaginatedResult(
      items: rows.map(_mapRowToEntity).toList(),
      page: page,
      totalItems: totalItems,
      totalPages: totalPages,
    );
  }

  /// Searches cached members with pagination.
  Future<PaginatedResult<Member>> searchPaginated(
    String query, {
    List<String>? fields,
    int page = 1,
    int perPage = 20,
    String? sort,
  }) async {
    final searchFields = fields ?? ['name', 'mobileNumber'];
    final sortValue = sort ?? 'name';
    final rows = await _dao.searchPaginated(
      query: query,
      fields: searchFields,
      page: page,
      perPage: perPage,
      sort: sortValue,
    );
    final totalItems = await _dao.countSearch(query, fields: searchFields);
    final totalPages = totalItems == 0 ? 0 : (totalItems / perPage).ceil();

    return PaginatedResult(
      items: rows.map(_mapRowToEntity).toList(),
      page: page,
      totalItems: totalItems,
      totalPages: totalPages,
    );
  }

  /// Upserts members from DTOs (preserves raw photo filenames).
  Future<void> upsertFromDtos(Iterable<MemberDto> dtos) async {
    final now = DateTime.now();
    final companions = dtos.map((dto) => _mapDtoToCompanion(dto, now)).toList();
    await _dao.upsertMembers(companions);
  }

  /// Upserts members from domain entities.
  Future<void> upsertMembers(Iterable<Member> members) async {
    final now = DateTime.now();
    final companions = members
        .map((member) => _mapMemberToCompanion(member, now))
        .toList();
    await _dao.upsertMembers(companions);
  }

  /// Replaces the entire cache with the provided DTOs.
  Future<void> replaceAllFromDtos(Iterable<MemberDto> dtos) async {
    await _dao.clearAll();
    await upsertFromDtos(dtos);
  }

  /// Deletes a member from the cache.
  Future<void> deleteMember(String id) => _dao.deleteMember(id);

  /// Clears all cached members.
  Future<void> clearAll() => _dao.clearAll();

  /// Returns whether the cache has any members.
  Future<bool> hasCachedMembers() async {
    return (await _dao.countAll()) > 0;
  }

  Member _mapRowToEntity(MemberRow row) {
    return Member(
      id: row.id,
      name: row.name,
      photo: _buildPhotoUrl(
        photoFile: row.photoFile,
        id: row.id,
        updated: row.updated,
      ),
      mobileNumber: row.mobileNumber,
      dateOfBirth: row.dateOfBirth,
      address: row.address,
      sex: _parseSex(row.sex),
      remarks: row.remarks,
      addedBy: row.addedBy,
      rfidCardId: row.rfidCardId,
      email: row.email,
      emergencyContact: row.emergencyContact,
      created: row.created,
      updated: row.updated,
    );
  }

  MembersCompanion _mapDtoToCompanion(MemberDto dto, DateTime syncedAt) {
    return MembersCompanion(
      id: Value(dto.id),
      name: Value(dto.name),
      photoFile: Value(dto.photo),
      mobileNumber: Value(_emptyToNull(dto.mobileNumber)),
      dateOfBirth: Value(_parseDate(dto.dateOfBirth)),
      address: Value(_emptyToNull(dto.address)),
      sex: Value(_emptyToNull(dto.sex)),
      remarks: Value(_emptyToNull(dto.remarks)),
      addedBy: Value(_emptyToNull(dto.addedBy)),
      rfidCardId: Value(_emptyToNull(dto.rfidCardId)),
      email: Value(_emptyToNull(dto.email)),
      emergencyContact: Value(_emptyToNull(dto.emergencyContact)),
      created: Value(_parseDate(dto.created)),
      updated: Value(_parseDate(dto.updated)),
      syncedAt: Value(syncedAt),
    );
  }

  MembersCompanion _mapMemberToCompanion(Member member, DateTime syncedAt) {
    return MembersCompanion(
      id: Value(member.id),
      name: Value(member.name),
      photoFile: const Value.absent(),
      mobileNumber: Value(member.mobileNumber),
      dateOfBirth: Value(member.dateOfBirth),
      address: Value(member.address),
      sex: Value(member.sex?.name),
      remarks: Value(member.remarks),
      addedBy: Value(member.addedBy),
      rfidCardId: Value(member.rfidCardId),
      email: Value(member.email),
      emergencyContact: Value(member.emergencyContact),
      created: Value(member.created),
      updated: Value(member.updated),
      syncedAt: Value(syncedAt),
    );
  }

  String? _buildPhotoUrl({
    required String? photoFile,
    required String id,
    required DateTime? updated,
  }) {
    if (photoFile == null || photoFile.isEmpty) return null;
    final url =
        '$_baseUrl/api/files/${PocketBaseCollections.members}/$id/$photoFile';
    if (updated != null) {
      return '$url?t=${updated.toUtc().toIso8601String()}';
    }
    return url;
  }

  static MemberSex? _parseSex(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.toLowerCase()) {
      case 'male':
        return MemberSex.male;
      case 'female':
        return MemberSex.female;
      case 'other':
        return MemberSex.other;
      default:
        return null;
    }
  }

  static String? _emptyToNull(String? value) {
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.parse(value).toLocal();
  }
}

/// Provides the [MemberLocalDataSource] instance.
@Riverpod(keepAlive: true)
MemberLocalDataSource memberLocalDataSource(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final baseUrl = ref.watch(pocketbaseProvider).baseURL;
  return MemberLocalDataSource(db, baseUrl);
}
