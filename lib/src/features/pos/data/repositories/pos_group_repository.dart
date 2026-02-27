import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/pos_group.dart';
import '../../domain/pos_group_item.dart';
import '../dto/pos_group_dto.dart';
import '../dto/pos_group_item_dto.dart';

part 'pos_group_repository.g.dart';

abstract class PosGroupRepository {
  // Groups
  FutureEither<List<PosGroup>> fetchGroupsForBranch(String branchId);
  FutureEither<List<PosGroup>> fetchGroupsWithItems(String branchId);
  FutureEither<PosGroup> createGroup(PosGroup group);
  FutureEither<PosGroup> updateGroup(PosGroup group);
  FutureEither<void> deleteGroup(String id);
  FutureEither<void> reorderGroups(List<PosGroup> groups);

  // Group Items
  FutureEither<List<PosGroupItem>> fetchItemsForGroup(String groupId);
  FutureEither<PosGroupItem> addItemToGroup(PosGroupItem item);
  FutureEither<void> removeItemFromGroup(String itemId);
  FutureEither<void> reorderItems(String groupId, List<PosGroupItem> items);

  /// Invalidates cached data.
  void invalidateCache();
}

@Riverpod(keepAlive: true)
PosGroupRepository posGroupRepository(Ref ref) {
  return PosGroupRepositoryImpl(ref.watch(pocketbaseProvider));
}

class PosGroupRepositoryImpl implements PosGroupRepository {
  final PocketBase _pb;

  PosGroupRepositoryImpl(this._pb);

  // Cache
  List<PosGroup>? _cachedGroups;
  String? _cachedBranchId;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  RecordService get _groups =>
      _pb.collection(PocketBaseCollections.posGroups);
  RecordService get _groupItems =>
      _pb.collection(PocketBaseCollections.posGroupItems);

  bool get _isCacheValid =>
      _cachedGroups != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < _cacheDuration;

  PosGroup _toGroupEntity(RecordModel record,
      {List<PosGroupItem> items = const []}) {
    return PosGroupDto.fromRecord(record).toEntity(items: items);
  }

  PosGroupItem _toGroupItemEntity(RecordModel record) {
    final productExpanded = record.get<RecordModel?>('expand.product');
    return PosGroupItemDto.fromRecord(record).toEntity(
      productExpanded: productExpanded,
    );
  }

  @override
  FutureEither<List<PosGroup>> fetchGroupsForBranch(String branchId) async {
    if (_isCacheValid && _cachedBranchId == branchId) {
      return right(_cachedGroups!);
    }

    return TaskEither.tryCatch(
      () async {
        final records = await _groups.getFullList(
          filter: 'branch = "$branchId" && isDeleted = false',
          sort: 'sortOrder',
        );
        final groups = records.map((r) => _toGroupEntity(r)).toList();
        _cachedGroups = groups;
        _cachedBranchId = branchId;
        _cacheTime = DateTime.now();
        return groups;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<PosGroup>> fetchGroupsWithItems(String branchId) async {
    return TaskEither.tryCatch(
      () async {
        // Fetch groups for branch
        final groupRecords = await _groups.getFullList(
          filter: 'branch = "$branchId" && isDeleted = false',
          sort: 'sortOrder',
        );

        final groups = <PosGroup>[];

        for (final groupRecord in groupRecords) {
          // Fetch items for each group with product expansion (including quantityUnit)
          final itemRecords = await _groupItems.getFullList(
            filter: 'group = "${groupRecord.id}"',
            sort: 'sortOrder',
            expand: 'product.quantityUnit',
          );

          final items = itemRecords
              .map(_toGroupItemEntity)
              // Filter out deleted or not-for-sale products
              .where((item) {
            if (item.isProduct && item.product != null) {
              return !item.product!.isDeleted && item.product!.forSale;
            }
            return false;
          }).toList();

          groups.add(_toGroupEntity(groupRecord, items: items));
        }

        // Update cache
        _cachedGroups = groups;
        _cachedBranchId = branchId;
        _cacheTime = DateTime.now();

        return groups;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<PosGroup> createGroup(PosGroup group) async {
    return TaskEither.tryCatch(
      () async {
        final body = {
          'name': group.name,
          'branch': group.branchId,
          'sortOrder': group.sortOrder,
          'isDeleted': false,
        };
        final record = await _groups.create(body: body);
        invalidateCache();
        return _toGroupEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<PosGroup> updateGroup(PosGroup group) async {
    return TaskEither.tryCatch(
      () async {
        final body = {
          'name': group.name,
          'sortOrder': group.sortOrder,
        };
        final record = await _groups.update(group.id, body: body);
        invalidateCache();
        return _toGroupEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> deleteGroup(String id) async {
    return TaskEither.tryCatch(
      () async {
        // Soft delete the group
        await _groups.update(id, body: {'isDeleted': true});
        invalidateCache();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> reorderGroups(List<PosGroup> groups) async {
    return TaskEither.tryCatch(
      () async {
        for (int i = 0; i < groups.length; i++) {
          await _groups.update(groups[i].id, body: {'sortOrder': i});
        }
        invalidateCache();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<PosGroupItem>> fetchItemsForGroup(String groupId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _groupItems.getFullList(
          filter: 'group = "$groupId"',
          sort: 'sortOrder',
          expand: 'product.quantityUnit',
        );
        return records.map(_toGroupItemEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<PosGroupItem> addItemToGroup(PosGroupItem item) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'group': item.groupId,
          'sortOrder': item.sortOrder,
        };
        if (item.productId != null && item.productId!.isNotEmpty) {
          body['product'] = item.productId;
        }
        final record = await _groupItems.create(body: body);
        invalidateCache();

        // Re-fetch with expansion to get product data (including quantityUnit)
        final expanded = await _groupItems.getOne(
          record.id,
          expand: 'product.quantityUnit',
        );
        return _toGroupItemEntity(expanded);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> removeItemFromGroup(String itemId) async {
    return TaskEither.tryCatch(
      () async {
        await _groupItems.delete(itemId);
        invalidateCache();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> reorderItems(
      String groupId, List<PosGroupItem> items) async {
    return TaskEither.tryCatch(
      () async {
        for (int i = 0; i < items.length; i++) {
          await _groupItems.update(items[i].id, body: {'sortOrder': i});
        }
        invalidateCache();
      },
      Failure.handle,
    ).run();
  }

  @override
  void invalidateCache() {
    _cachedGroups = null;
    _cachedBranchId = null;
    _cacheTime = null;
  }
}
