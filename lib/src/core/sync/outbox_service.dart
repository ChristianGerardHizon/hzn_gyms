import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../database/app_database.dart';
import '../database/daos/outbox_dao.dart';
import '../foundation/failure.dart';
import 'sync_status.dart';

const _maxSyncAttempts = 5;

/// PocketBase default id alphabet/length (must be ≤15 chars).
const _pbIdAlphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
const _pbIdLength = 15;

final _secureRandom = Random.secure();

/// Generates a client-side id compatible with PocketBase record creation.
String generateClientId() {
  final codes = List<int>.generate(
    _pbIdLength,
    (_) => _pbIdAlphabet.codeUnitAt(
      _secureRandom.nextInt(_pbIdAlphabet.length),
    ),
  );
  return String.fromCharCodes(codes);
}

/// Returns whether a failure is likely caused by network/connectivity issues.
bool isNetworkFailure(Failure failure) {
  final message = failure.message;
  if (message is ClientException) {
    final code = message.statusCode;
    return code == 0 || code >= 500;
  }
  if (message is SocketException) return true;
  final text = failure.messageString.toLowerCase();
  return text.contains('socket') ||
      text.contains('network') ||
      text.contains('connection') ||
      text.contains('timed out') ||
      text.contains('failed host lookup');
}

/// Whether offline writes and sync drain are allowed.
bool canWriteOffline(PocketBase pb, {required bool hasAuth}) {
  if (!hasAuth) return false;
  if (pb.authStore.token.isEmpty) return false;
  if (pb.authStore.isValid) return true;

  // 24h grace for recently expired tokens while offline.
  final updated = pb.authStore.record?.get<String>('updated');
  if (updated == null) return false;
  final updatedAt = DateTime.tryParse(updated);
  if (updatedAt == null) return false;
  return DateTime.now().difference(updatedAt.toUtc()) <
      const Duration(hours: 24);
}

/// Enqueues and manages outbox entries.
class OutboxService {
  OutboxService(this._db);

  final AppDatabase _db;

  OutboxDao get _dao => _db.outboxDao;

  /// Enqueues a member create operation.
  Future<String> enqueueMemberCreate({
    required String clientRecordId,
    required Map<String, dynamic> payload,
    List<int>? photoBytes,
    String? photoFilename,
  }) async {
    final outboxId = generateClientId();
    await _db.transaction(() async {
      await _dao.enqueue(
        OutboxEntriesCompanion.insert(
          id: outboxId,
          entityType: OutboxEntityType.member.value,
          operation: OutboxOperation.create.value,
          payload: jsonEncode(payload),
          clientRecordId: clientRecordId,
          createdAt: DateTime.now(),
        ),
      );
      if (photoBytes != null && photoFilename != null) {
        await _dao.saveAttachment(
          outboxId: outboxId,
          filename: photoFilename,
          bytes: photoBytes,
        );
      }
    });
    return outboxId;
  }

  /// Enqueues a member update (coalesces existing pending updates).
  Future<String> enqueueMemberUpdate({
    required String clientRecordId,
    required Map<String, dynamic> payload,
    List<int>? photoBytes,
    String? photoFilename,
  }) async {
    final outboxId = generateClientId();
    await _db.transaction(() async {
      await _dao.replacePendingMemberUpdate(
        clientRecordId: clientRecordId,
        newEntry: OutboxEntriesCompanion.insert(
          id: outboxId,
          entityType: OutboxEntityType.member.value,
          operation: OutboxOperation.update.value,
          payload: jsonEncode(payload),
          clientRecordId: clientRecordId,
          createdAt: DateTime.now(),
        ),
      );
      if (photoBytes != null && photoFilename != null) {
        await _dao.saveAttachment(
          outboxId: outboxId,
          filename: photoFilename,
          bytes: photoBytes,
        );
      }
    });
    return outboxId;
  }

  /// Enqueues a generic create operation with optional dependency.
  Future<String> enqueueCreate({
    required OutboxEntityType entityType,
    required String clientRecordId,
    required Map<String, dynamic> payload,
    String? dependsOnId,
  }) async {
    final outboxId = generateClientId();
    await _dao.enqueue(
      OutboxEntriesCompanion.insert(
        id: outboxId,
        entityType: entityType.value,
        operation: OutboxOperation.create.value,
        payload: jsonEncode(payload),
        clientRecordId: clientRecordId,
        dependsOnId: Value(dependsOnId),
        createdAt: DateTime.now(),
      ),
    );
    return outboxId;
  }

  /// Returns the outbox id of a pending/failed member create for [memberId].
  Future<String?> findPendingMemberCreateId(String memberId) async {
    final row = await _dao.findPendingMemberCreate(memberId);
    return row?.id;
  }

  Future<OutboxAttachmentRow?> getAttachment(String outboxId) =>
      _dao.getAttachment(outboxId);

  Future<int> countPending() => _dao.countPending();

  Stream<int> watchPendingCount() => _dao.watchPendingCount();

  Future<List<OutboxEntryRow>> getPendingAndFailed() =>
      _dao.getPendingAndFailed();

  int get maxSyncAttempts => _maxSyncAttempts;
}

/// Dispatches a single outbox entry to PocketBase.
class OutboxDispatcher {
  OutboxDispatcher(this._pb);

  final PocketBase _pb;

  Future<void> dispatch(
    OutboxEntryRow entry, {
    http.MultipartFile? photo,
  }) async {
    final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
    final entityType = OutboxEntityType.values.firstWhere(
      (t) => t.value == entry.entityType,
      orElse: () => OutboxEntityType.member,
    );
    final operation = OutboxOperation.values.firstWhere(
      (o) => o.value == entry.operation,
      orElse: () => OutboxOperation.create,
    );

    switch (entityType) {
      case OutboxEntityType.member:
        await _dispatchMember(entry, payload, operation, photo);
      case OutboxEntityType.sale:
        await _dispatchSale(entry, payload);
      case OutboxEntityType.saleItem:
        await _dispatchSaleItem(entry, payload);
      case OutboxEntityType.memberMembership:
        await _dispatchMemberMembership(entry, payload);
      case OutboxEntityType.memberMembershipAddOn:
        await _dispatchMemberMembershipAddOn(entry, payload);
    }
  }

  Future<void> _dispatchMember(
    OutboxEntryRow entry,
    Map<String, dynamic> payload,
    OutboxOperation operation,
    http.MultipartFile? photo,
  ) async {
    final collection = _pb.collection('members');
    if (operation == OutboxOperation.create) {
      final body = Map<String, dynamic>.from(payload)
        ..['id'] = entry.clientRecordId;
      await collection.create(body: body, files: photo != null ? [photo] : []);
    } else {
      if (photo != null) {
        await collection.update(entry.clientRecordId, files: [photo]);
      }
      await collection.update(entry.clientRecordId, body: payload);
    }
  }

  Future<void> _dispatchSale(
    OutboxEntryRow entry,
    Map<String, dynamic> payload,
  ) async {
    final body = Map<String, dynamic>.from(payload)
      ..['id'] = entry.clientRecordId;
    await _pb.collection('sales').create(body: body);
  }

  Future<void> _dispatchSaleItem(
    OutboxEntryRow entry,
    Map<String, dynamic> payload,
  ) async {
    final body = Map<String, dynamic>.from(payload)
      ..['id'] = entry.clientRecordId;
    await _pb.collection('saleItems').create(body: body);
  }

  Future<void> _dispatchMemberMembership(
    OutboxEntryRow entry,
    Map<String, dynamic> payload,
  ) async {
    final body = Map<String, dynamic>.from(payload)
      ..['id'] = entry.clientRecordId;
    await _pb.collection('memberMemberships').create(body: body);
  }

  Future<void> _dispatchMemberMembershipAddOn(
    OutboxEntryRow entry,
    Map<String, dynamic> payload,
  ) async {
    final body = Map<String, dynamic>.from(payload)
      ..['id'] = entry.clientRecordId;
    await _pb.collection('memberMembershipAddOns').create(body: body);
  }
}
