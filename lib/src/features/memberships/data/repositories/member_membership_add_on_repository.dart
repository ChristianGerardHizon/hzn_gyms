import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/member_membership_add_on.dart';
import '../dto/member_membership_add_on_dto.dart';

part 'member_membership_add_on_repository.g.dart';

/// Repository interface for member membership add-on operations.
abstract class MemberMembershipAddOnRepository {
  /// Fetches all add-ons for a member membership.
  FutureEither<List<MemberMembershipAddOn>> fetchByMemberMembership(
    String memberMembershipId,
  );

  /// Creates a new member membership add-on record.
  FutureEither<MemberMembershipAddOn> create({
    required String memberMembershipId,
    required String membershipAddOnId,
    required String addOnName,
    required num price,
  });
}

/// Provides the MemberMembershipAddOnRepository instance.
@Riverpod(keepAlive: true)
MemberMembershipAddOnRepository memberMembershipAddOnRepository(Ref ref) {
  return MemberMembershipAddOnRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [MemberMembershipAddOnRepository] using PocketBase.
class MemberMembershipAddOnRepositoryImpl
    implements MemberMembershipAddOnRepository {
  final PocketBase _pb;

  MemberMembershipAddOnRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.memberMembershipAddOns);

  MemberMembershipAddOn _toEntity(RecordModel record) {
    return MemberMembershipAddOnDto.fromRecord(record).toEntity();
  }

  @override
  FutureEither<List<MemberMembershipAddOn>> fetchByMemberMembership(
    String memberMembershipId,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final filter =
            PBFilter().relation('memberMembership', memberMembershipId);

        final records = await _collection.getFullList(
          filter: filter.build(),
          sort: 'addOnName',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<MemberMembershipAddOn> create({
    required String memberMembershipId,
    required String membershipAddOnId,
    required String addOnName,
    required num price,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'memberMembership': memberMembershipId,
          'membershipAddOn': membershipAddOnId,
          'addOnName': addOnName,
          'price': price,
        };

        final record = await _collection.create(body: body);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }
}
