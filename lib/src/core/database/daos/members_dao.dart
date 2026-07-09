import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/members_table.dart';

part 'members_dao.g.dart';

/// Data access object for cached member records.
@DriftAccessor(tables: [Members])
class MembersDao extends DatabaseAccessor<AppDatabase> with _$MembersDaoMixin {
  MembersDao(super.db);

  /// Inserts or updates members in bulk.
  Future<void> upsertMembers(List<MembersCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(members, entries);
    });
  }

  /// Returns a member by ID, if cached.
  Future<MemberRow?> getMemberById(String id) {
    return (select(members)..where((m) => m.id.equals(id))).getSingleOrNull();
  }

  /// Returns all cached members.
  Future<List<MemberRow>> getAll({String sort = 'name'}) {
    return (select(members)..orderBy([(m) => _orderingTerm(m, sort)])).get();
  }

  /// Returns a paginated slice of cached members.
  Future<List<MemberRow>> getPaginated({
    required int page,
    required int perPage,
    String sort = 'name',
  }) {
    final offset = (page - 1) * perPage;
    return (select(members)
          ..orderBy([(m) => _orderingTerm(m, sort)])
          ..limit(perPage, offset: offset))
        .get();
  }

  /// Searches cached members with pagination.
  Future<List<MemberRow>> searchPaginated({
    required String query,
    List<String> fields = const ['name', 'mobileNumber'],
    required int page,
    required int perPage,
    String sort = 'name',
  }) {
    final pattern = '%$query%';
    final offset = (page - 1) * perPage;

    return (select(members)
          ..where((m) => _searchExpression(m, fields, pattern))
          ..orderBy([(m) => _orderingTerm(m, sort)])
          ..limit(perPage, offset: offset))
        .get();
  }

  /// Counts all cached members.
  Future<int> countAll() async {
    final countExpr = members.id.count();
    final query = selectOnly(members)..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Counts members matching a search query.
  Future<int> countSearch(
    String query, {
    List<String> fields = const ['name', 'mobileNumber'],
  }) async {
    final pattern = '%$query%';
    final countExpr = members.id.count();
    final queryBuilder = selectOnly(members)
      ..addColumns([countExpr])
      ..where(_searchExpression(members, fields, pattern));

    final row = await queryBuilder.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Deletes a member from the cache.
  Future<void> deleteMember(String id) {
    return (delete(members)..where((m) => m.id.equals(id))).go();
  }

  /// Clears all cached members.
  Future<void> clearAll() {
    return delete(members).go();
  }

  /// Returns the most recent sync timestamp, if any.
  Future<DateTime?> getLastSyncedAt() async {
    final maxExpr = members.syncedAt.max();
    final query = selectOnly(members)..addColumns([maxExpr]);
    final row = await query.getSingleOrNull();
    return row?.read(maxExpr);
  }

  OrderingTerm _orderingTerm($MembersTable m, String sort) {
    final descending = sort.startsWith('-');
    final field = descending ? sort.substring(1) : sort;

    final column = switch (field) {
      'name' => m.name,
      'mobileNumber' => m.mobileNumber,
      'email' => m.email,
      'created' => m.created,
      'updated' => m.updated,
      _ => m.name,
    };

    return OrderingTerm(
      expression: column,
      mode: descending ? OrderingMode.desc : OrderingMode.asc,
    );
  }

  Expression<bool> _searchExpression(
    $MembersTable m,
    List<String> fields,
    String pattern,
  ) {
    Expression<bool>? expression;

    for (final field in fields) {
      final fieldExpression = switch (field) {
        'name' => m.name.like(pattern),
        'mobileNumber' => m.mobileNumber.like(pattern),
        'email' => m.email.like(pattern),
        _ => null,
      };

      if (fieldExpression == null) continue;
      expression = expression == null
          ? fieldExpression
          : expression | fieldExpression;
    }

    return expression ?? const Constant(false);
  }
}
