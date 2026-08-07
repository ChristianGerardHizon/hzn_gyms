import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/branch.dart';
import '../dto/branch_dto.dart';

part 'branch_repository.g.dart';

/// Repository interface for branch operations.
abstract class BranchRepository {
  /// Fetches all branches.
  FutureEither<List<Branch>> fetchAll();

  /// Fetches a single branch by ID.
  FutureEither<Branch> fetchOne(String id);

  /// Creates a new branch.
  FutureEither<Branch> create(Branch branch);

  /// Updates an existing branch.
  FutureEither<Branch> update(Branch branch);

  /// Soft deletes a branch by ID.
  FutureEither<void> delete(String id);
}

/// Provides the BranchRepository instance.
@Riverpod(keepAlive: true)
BranchRepository branchRepository(Ref ref) {
  return BranchRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [BranchRepository] using PocketBase.
class BranchRepositoryImpl implements BranchRepository {
  final PocketBase _pb;

  BranchRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.branches);

  Branch _toEntity(RecordModel record) {
    final dto = BranchDto.fromRecord(record);
    return dto.toEntity();
  }

  @override
  FutureEither<List<Branch>> fetchAll() async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilters.active.build();

        final records = await _collection.getFullList(
          filter: filter,
          sort: 'name',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Branch> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Branch ID cannot be empty',
            null,
            'invalid_branch_id',
          );
        }

        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Branch> create(Branch branch) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': branch.name,
          'code': branch.code,
          'address': branch.address,
          'contactNumber': branch.contactNumber,
          'operatingHours': branch.operatingHours,
          'cutOffTime': branch.cutOffTime,
          'color': branch.color,
          'isDeleted': false,
        };

        final record = await _collection.create(body: body);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Branch> update(Branch branch) async {
    return TaskEither.tryCatch(
      () async {
        if (branch.id.isEmpty) {
          throw const DataFailure(
            'Branch ID cannot be empty',
            null,
            'invalid_branch_id',
          );
        }

        final body = <String, dynamic>{
          'name': branch.name,
          'code': branch.code,
          'address': branch.address,
          'contactNumber': branch.contactNumber,
          'operatingHours': branch.operatingHours,
          'cutOffTime': branch.cutOffTime,
          'color': branch.color,
        };

        final record = await _collection.update(branch.id, body: body);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Branch ID cannot be empty',
            null,
            'invalid_branch_id',
          );
        }

        // Soft delete
        await _collection.update(id, body: {'isDeleted': true});
      },
      Failure.handle,
    ).run();
  }
}
