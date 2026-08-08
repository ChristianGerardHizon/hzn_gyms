import 'package:pocketbase/pocketbase.dart';

import '../../../core/packages/pocketbase/pb_filter.dart';
import '../../../core/packages/pocketbase/pocketbase_collections.dart';
import 'member.dart';

/// View fields safe to sort on for [membersWithMembershipStatus].
const activeBranchMembersSortableFields = {'name', 'mobileNumber'};

/// Builds a PocketBase filter for active members at a branch via the
/// [membersWithMembershipStatus] view.
///
/// [planIds] must be membership plans valid at the target branch
/// (`validBranches` contains it, or empty = all branches).
///
/// Returns `null` when [planIds] is empty — callers should return an empty page.
///
/// Always requires `membershipStatus = 'active'` and
/// `expirationDate >= start of today` (active / non-expired).
String? buildActiveMembersAtBranchViewFilter({
  required Iterable<String> planIds,
  DateTime? now,
  String? searchQuery,
}) {
  final uniquePlanIds = planIds.toSet().where((id) => id.isNotEmpty).toList();
  if (uniquePlanIds.isEmpty) return null;

  final filter = PBFilter();

  if (searchQuery != null && searchQuery.trim().isNotEmpty) {
    filter.searchFields(searchQuery.trim(), const ['name', 'mobileNumber']);
  }

  final orClause = uniquePlanIds
      .map((id) => 'membershipId = "${PBFilter.escape(id)}"')
      .join(' || ');
  filter.raw('($orClause)');

  filter.equals('membershipStatus', 'active');

  final effectiveNow = now ?? DateTime.now();
  final startOfToday = DateTime(
    effectiveNow.year,
    effectiveNow.month,
    effectiveNow.day,
  );
  filter.greaterOrEqual('expirationDate', startOfToday);

  return filter.build();
}

/// Sort string for the membership-status view, constrained to available fields.
String activeBranchMembersSortString({
  required String field,
  required bool descending,
}) {
  final safeField = activeBranchMembersSortableFields.contains(field)
      ? field
      : 'name';
  return descending ? '-$safeField' : safeField;
}

/// Maps a [membersWithMembershipStatus] view row to a list [Member].
///
/// Photo URLs use the underlying `members` collection (view file refs inherit).
Member memberFromMembershipStatusView(
  RecordModel record, {
  required String baseUrl,
}) {
  final id = record.id;
  final photoFile = record.getStringValue('photo');
  final mobileNumber = record.getStringValue('mobileNumber');

  String? photoUrl;
  if (photoFile.isNotEmpty) {
    photoUrl =
        '$baseUrl/api/files/${PocketBaseCollections.members}/$id/$photoFile';
  }

  return Member(
    id: id,
    name: record.getStringValue('name'),
    photo: photoUrl,
    mobileNumber: mobileNumber.isNotEmpty ? mobileNumber : null,
  );
}
