import 'package:drift/drift.dart';

import '../../utils/search_tokens.dart';
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
    String? branchId,
  }) {
    final offset = (page - 1) * perPage;
    final query = select(members)
      ..orderBy([(m) => _orderingTerm(m, sort)])
      ..limit(perPage, offset: offset);
    if (branchId != null) {
      query.where((m) => m.branch.equals(branchId));
    }
    return query.get();
  }

  /// Searches cached members with pagination.
  ///
  /// Query is split on whitespace; every token must match at least one field.
  Future<List<MemberRow>> searchPaginated({
    required String query,
    List<String> fields = const ['name', 'mobileNumber'],
    required int page,
    required int perPage,
    String sort = 'name',
    String? branchId,
  }) {
    final tokens = splitSearchTokens(query);
    final offset = (page - 1) * perPage;

    final q = select(members)
      ..where((m) {
        final search = _tokenizedSearchExpression(m, fields, tokens);
        if (branchId == null) return search;
        return search & m.branch.equals(branchId);
      })
      ..orderBy([(m) => _orderingTerm(m, sort)])
      ..limit(perPage, offset: offset);
    return q.get();
  }

  /// Counts all cached members.
  Future<int> countAll({String? branchId}) async {
    final countExpr = members.id.count();
    final query = selectOnly(members)..addColumns([countExpr]);
    if (branchId != null) {
      query.where(members.branch.equals(branchId));
    }
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Counts members matching a search query.
  ///
  /// Uses the same whitespace-tokenized matching as [searchPaginated].
  Future<int> countSearch(
    String query, {
    List<String> fields = const ['name', 'mobileNumber'],
    String? branchId,
  }) async {
    final tokens = splitSearchTokens(query);
    final countExpr = members.id.count();
    final queryBuilder = selectOnly(members)
      ..addColumns([countExpr])
      ..where(() {
        final search = _tokenizedSearchExpression(members, fields, tokens);
        if (branchId == null) return search;
        return search & members.branch.equals(branchId);
      }());

    final row = await queryBuilder.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Deletes a member from the cache.
  Future<void> deleteMember(String id) {
    return (delete(members)..where((m) => m.id.equals(id))).go();
  }

  /// Returns members that still have local pending/failed/conflict sync state.
  Future<List<MemberRow>> getUnsynced() {
    return (select(members)..where(
          (m) =>
              m.syncStatus.equals('pending') |
              m.syncStatus.equals('failed') |
              m.syncStatus.equals('conflict'),
        ))
        .get();
  }

  /// Returns IDs of members with non-synced local state.
  Future<Set<String>> getUnsyncedIds() async {
    final rows = await getUnsynced();
    return rows.map((r) => r.id).toSet();
  }

  /// Clears only synced cached members, preserving pending offline edits.
  Future<void> clearSynced() {
    return (delete(
      members,
    )..where((m) => m.syncStatus.equals('synced'))).go();
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

  /// AND of per-token OR-across-fields matches. Empty [tokens] matches all.
  Expression<bool> _tokenizedSearchExpression(
    $MembersTable m,
    List<String> fields,
    List<String> tokens,
  ) {
    if (tokens.isEmpty) return const Constant(true);

    Expression<bool>? allTokens;
    for (final token in tokens) {
      final tokenMatch = _searchExpression(m, fields, '%$token%');
      allTokens = allTokens == null ? tokenMatch : allTokens & tokenMatch;
    }
    return allTokens ?? const Constant(false);
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
