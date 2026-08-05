import 'package:pocketbase/pocketbase.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a new UUID v4 for idempotent create requests.
String generateIdempotencyKey() => _uuid.v4();

/// Whether [error] is a PocketBase unique-constraint violation (HTTP 400).
bool isPocketBaseUniqueViolation(Object error) {
  if (error is! ClientException) return false;
  if (error.statusCode != 400) return false;

  final data = error.response['data'];
  if (data is Map) {
    for (final value in data.values) {
      if (value is Map && value['code'] == 'validation_not_unique') {
        return true;
      }
    }
  }

  final message = error.response['message']?.toString().toLowerCase() ?? '';
  return message.contains('unique');
}

/// Escapes a value for use inside a PocketBase filter string literal.
String escapeIdempotencyKeyForFilter(String key) =>
    key.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
