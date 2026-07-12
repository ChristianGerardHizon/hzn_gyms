import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../foundation/failure.dart';
import '../packages/pocketbase/pb_connectivity_provider.dart';
import '../packages/pocketbase/pocketbase_provider.dart';
import 'outbox_service.dart';
import 'sync_status.dart';

part 'outbox_sync_worker.g.dart';

/// Drains the outbox queue when online and auth allows writes.
@Riverpod(keepAlive: true)
class OutboxSyncWorker extends _$OutboxSyncWorker {
  bool _isDraining = false;

  @override
  Future<void> build() async {
    // Ensure migration completes before any outbox queries run.
    try {
      await _ensureDatabaseReady();
    } catch (e, st) {
      debugPrint('OutboxSyncWorker: database not ready: $e\n$st');
      return;
    }

    ref.listen(pbConnectivityProvider, (prev, next) {
      final wasOnline = prev?.value ?? false;
      final isOnline = next.value ?? false;
      if (!wasOnline && isOnline) {
        unawaited(drain());
      }
    });

    // Drain on startup if already online.
    final isOnline = ref.read(pbConnectivityProvider).value ?? false;
    if (isOnline) {
      unawaited(drain());
    }
  }

  Future<void> _ensureDatabaseReady() async {
    final db = ref.read(appDatabaseProvider);
    await db.customSelect('SELECT 1').getSingle();
  }

  /// Forces an immediate drain attempt.
  Future<void> drain() async {
    if (_isDraining) return;
    _isDraining = true;

    try {
      await _ensureDatabaseReady();

      final pb = ref.read(pocketbaseProvider);
      final auth = ref.read(currentAuthProvider);
      if (!canWriteOffline(pb, hasAuth: auth != null)) return;

      final isOnline = ref.read(pbConnectivityProvider).value ?? false;
      if (!isOnline) return;

      final db = ref.read(appDatabaseProvider);
      final outbox = OutboxService(db);
      final dispatcher = OutboxDispatcher(pb);
      final dao = db.outboxDao;

      while (true) {
        final entry = await dao.getNextReady();
        if (entry == null) break;

        try {
          http.MultipartFile? photo;
          if (entry.entityType == OutboxEntityType.member.value) {
            final attachment = await outbox.getAttachment(entry.id);
            if (attachment != null) {
              photo = http.MultipartFile.fromBytes(
                'photo',
                attachment.bytes,
                filename: attachment.filename,
              );
            }
          }

          await dispatcher.dispatch(entry, photo: photo);
          await dao.markStatus(entry.id, status: OutboxStatus.synced.value);
          await dao.deleteAttachment(entry.id);

          if (entry.entityType == OutboxEntityType.member.value) {
            await _markMemberSynced(db, entry.clientRecordId);
          }
          if (entry.entityType == OutboxEntityType.memberMembership.value) {
            await db.pendingMemberMembershipsDao.markSynced(
              entry.clientRecordId,
            );
          }
        } catch (e, st) {
          final failure = Failure.handle(e, st);
          final attempts = entry.attempts + 1;
          final isMoney = _isMoneyEntity(entry.entityType);

          if (isMoney && !isNetworkFailure(failure)) {
            await dao.markStatus(
              entry.id,
              status: OutboxStatus.conflict.value,
              lastError: failure.messageString,
              attempts: attempts,
            );
          } else if (attempts >= outbox.maxSyncAttempts) {
            await dao.markStatus(
              entry.id,
              status: OutboxStatus.failed.value,
              lastError: failure.messageString,
              attempts: attempts,
            );
            if (entry.entityType == OutboxEntityType.member.value) {
              await _markMemberStatus(
                db,
                entry.clientRecordId,
                SyncStatus.failed,
              );
            }
          } else {
            await dao.markStatus(
              entry.id,
              status: OutboxStatus.pending.value,
              lastError: failure.messageString,
              attempts: attempts,
            );
          }

          // Stop draining on auth errors; retry later.
          if (failure is AuthFailure) break;
          // Stop on non-network money conflict already handled above.
          if (isMoney && !isNetworkFailure(failure)) break;
        }
      }

      await db.pendingMemberMembershipsDao.deleteSynced();
      if (ref.mounted) {
        ref.invalidate(outboxPendingEntriesProvider);
      }
    } catch (e, st) {
      debugPrint('OutboxSyncWorker.drain failed: $e\n$st');
    } finally {
      _isDraining = false;
    }
  }

  Future<void> _markMemberSynced(AppDatabase db, String memberId) async {
    await _markMemberStatus(db, memberId, SyncStatus.synced);
    await (db.update(db.members)..where((m) => m.id.equals(memberId))).write(
      MembersCompanion(
        localPhotoPath: const Value(null),
        syncedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _markMemberStatus(
    AppDatabase db,
    String memberId,
    SyncStatus status,
  ) async {
    await (db.update(db.members)..where((m) => m.id.equals(memberId))).write(
      MembersCompanion(syncStatus: Value(status.name)),
    );
  }

  bool _isMoneyEntity(String entityType) {
    return entityType == OutboxEntityType.sale.value ||
        entityType == OutboxEntityType.saleItem.value ||
        entityType == OutboxEntityType.memberMembership.value ||
        entityType == OutboxEntityType.memberMembershipAddOn.value;
  }
}

/// Provider for pending outbox count stream.
@Riverpod(keepAlive: true)
Stream<int> outboxPendingCount(Ref ref) async* {
  await ref.watch(appDatabaseReadyProvider.future);
  final db = ref.watch(appDatabaseProvider);
  yield* OutboxService(db).watchPendingCount();
}

/// Provider for pending/failed outbox entries list.
@Riverpod(keepAlive: true)
Future<List<OutboxPendingItem>> outboxPendingEntries(Ref ref) async {
  await ref.watch(appDatabaseReadyProvider.future);
  final db = ref.watch(appDatabaseProvider);
  final outbox = OutboxService(db);
  final rows = await outbox.getPendingAndFailed();
  final items = <OutboxPendingItem>[];
  for (final r in rows) {
    final attachment = await outbox.getAttachment(r.id);
    items.add(
      OutboxPendingItem(
        id: r.id,
        entityType: r.entityType,
        operation: r.operation,
        status: r.status,
        attempts: r.attempts,
        clientRecordId: r.clientRecordId,
        createdAt: r.createdAt,
        dependsOnId: r.dependsOnId,
        lastError: r.lastError,
        payloadJson: r.payload,
        hasAttachment: attachment != null,
      ),
    );
  }
  return items;
}
