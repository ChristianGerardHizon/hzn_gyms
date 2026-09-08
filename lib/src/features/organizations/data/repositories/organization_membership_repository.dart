import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/organization_membership.dart';

part 'organization_membership_repository.g.dart';

/// Repository for per-organization user memberships.
abstract class OrganizationMembershipRepository {
  /// Active memberships for [userId].
  FutureEither<List<OrganizationMembership>> fetchActiveForUser(String userId);

  /// Active membership for [userId] in [organizationId], if any.
  FutureEither<OrganizationMembership?> fetchForUserInOrganization({
    required String userId,
    required String organizationId,
  });

  /// Accepts a pending organization invite by id.
  FutureEither<OrganizationMembership> acceptInvite(String inviteId);
}

@Riverpod(keepAlive: true)
OrganizationMembershipRepository organizationMembershipRepository(Ref ref) {
  return OrganizationMembershipRepositoryImpl(ref.watch(pocketbaseProvider));
}

class OrganizationMembershipRepositoryImpl
    implements OrganizationMembershipRepository {
  OrganizationMembershipRepositoryImpl(this._pb);

  final PocketBase _pb;

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.organizationMemberships);

  OrganizationMembership _toEntity(RecordModel record) {
    final json = record.toJson();
    DateTime? joinedAt;
    final joinedRaw = json['joinedAt'] as String?;
    if (joinedRaw != null && joinedRaw.isNotEmpty) {
      joinedAt = DateTime.tryParse(joinedRaw)?.toLocal();
    }
    return OrganizationMembership(
      id: json['id'] as String? ?? record.id,
      userId: json['user'] as String? ?? '',
      organizationId: json['organization'] as String? ?? '',
      roleId: json['role'] as String? ?? '',
      status: OrganizationMembershipStatus.fromString(
        json['status'] as String?,
      ),
      invitedById: json['invitedBy'] as String?,
      joinedAt: joinedAt,
    );
  }

  @override
  FutureEither<List<OrganizationMembership>> fetchActiveForUser(
    String userId,
  ) async {
    return TaskEither.tryCatch(() async {
      final filter = PBFilter()
          .relation('user', userId)
          .equals('status', 'active')
          .build();
      final records = await _collection.getFullList(filter: filter);
      return records.map(_toEntity).toList();
    }, Failure.handle).run();
  }

  @override
  FutureEither<OrganizationMembership?> fetchForUserInOrganization({
    required String userId,
    required String organizationId,
  }) async {
    return TaskEither.tryCatch(() async {
      final filter = PBFilter()
          .relation('user', userId)
          .relation('organization', organizationId)
          .equals('status', 'active')
          .build();
      final records = await _collection.getList(
        page: 1,
        perPage: 1,
        filter: filter,
      );
      if (records.items.isEmpty) return null;
      return _toEntity(records.items.first);
    }, Failure.handle).run();
  }

  @override
  FutureEither<OrganizationMembership> acceptInvite(String inviteId) async {
    return TaskEither.tryCatch(() async {
      final result = await _pb.send(
        '/api/organization-invites/${Uri.encodeComponent(inviteId)}/accept',
        method: 'POST',
      );
      if (result is Map<String, dynamic>) {
        return OrganizationMembership(
          id: result['id'] as String? ?? '',
          userId: result['user'] as String? ?? '',
          organizationId: result['organization'] as String? ?? '',
          roleId: result['role'] as String? ?? '',
          status: OrganizationMembershipStatus.fromString(
            result['status'] as String?,
          ),
          invitedById: result['invitedBy'] as String?,
        );
      }
      throw const DataFailure(
        'Unexpected accept-invite response',
        null,
        'accept_invite_failed',
      );
    }, Failure.handle).run();
  }
}
