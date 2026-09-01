import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/core/sync/outbox_service.dart';
import 'package:hzn_gyms/src/core/sync/sync_status.dart';

void main() {
  group('generateClientId', () {
    test('is 15 chars from pocketbase alphabet', () {
      const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
      final id = generateClientId();
      expect(id.length, 15);
      expect(id.split('').every(alphabet.contains), isTrue);
    });
  });

  group('isNetworkFailure', () {
    test('true for status 0 or 5xx ClientException', () {
      expect(
        isNetworkFailure(
          PocketbaseFailure(
            ClientException(
              url: Uri.parse('https://x'),
              statusCode: 0,
              response: const {},
            ),
          ),
        ),
        isTrue,
      );
      expect(
        isNetworkFailure(
          PocketbaseFailure(
            ClientException(
              url: Uri.parse('https://x'),
              statusCode: 503,
              response: const {},
            ),
          ),
        ),
        isTrue,
      );
    });

    test('true for SocketException message', () {
      expect(
        isNetworkFailure(GenericFailure(const SocketException('down'))),
        isTrue,
      );
    });

    test('true when message mentions network', () {
      expect(
        isNetworkFailure(const GenericFailure('network unreachable')),
        isTrue,
      );
    });

    test('false for ordinary 400', () {
      expect(
        isNetworkFailure(
          PocketbaseFailure(
            ClientException(
              url: Uri.parse('https://x'),
              statusCode: 400,
              response: {'message': 'bad'},
            ),
          ),
        ),
        isFalse,
      );
    });
  });

  group('canWriteOffline', () {
    test('false without auth', () {
      final pb = PocketBase('http://127.0.0.1');
      expect(canWriteOffline(pb, hasAuth: false), isFalse);
    });

    test('false with empty token', () {
      final pb = PocketBase('http://127.0.0.1');
      expect(canWriteOffline(pb, hasAuth: true), isFalse);
    });

    test('true when authStore is valid', () {
      final pb = PocketBase('http://127.0.0.1');
      // JWT-shaped token with far-future exp for isValid.
      const token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJleHAiOjQ4MzgzODQwMDB9.'
          'signature';
      pb.authStore.save(token, null);
      expect(canWriteOffline(pb, hasAuth: true), isTrue);
    });
  });

  group('SyncStatus / OutboxStatus', () {
    test('fromString falls back', () {
      expect(SyncStatus.fromString('pending'), SyncStatus.pending);
      expect(SyncStatus.fromString('nope'), SyncStatus.synced);
      expect(OutboxStatus.fromString('failed'), OutboxStatus.failed);
      expect(OutboxStatus.fromString('nope'), OutboxStatus.pending);
    });

    test('OutboxPendingItem.displayTitle', () {
      final item = OutboxPendingItem(
        id: '1',
        entityType: 'memberMembership',
        operation: 'create',
        status: 'pending',
        attempts: 0,
        clientRecordId: 'c1',
        createdAt: DateTime(2024),
      );
      expect(item.displayTitle, 'Create Membership');
    });
  });
}
