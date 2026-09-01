import 'package:hzn_gyms/src/core/packages/sentry/sentry_startup_error_buffer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'queues errors until markReadyAndFlush and then captures them',
    () async {
      final captured = <(Object, StackTrace)>[];
      final buffer = SentryStartupErrorBuffer(
        capture: (error, stackTrace) async {
          captured.add((error, stackTrace));
        },
      );

      const first = FormatException('boot');
      final firstStack = StackTrace.current;
      buffer.add(first, firstStack);
      expect(buffer.isReady, isFalse);
      expect(buffer.pending, hasLength(1));
      expect(captured, isEmpty);

      await buffer.markReadyAndFlush();

      expect(buffer.isReady, isTrue);
      expect(buffer.pending, isEmpty);
      expect(captured, [(first, firstStack)]);
    },
  );

  test('ignores errors added after Sentry is ready', () async {
    final captured = <Object>[];
    final buffer = SentryStartupErrorBuffer(
      capture: (error, stackTrace) async {
        captured.add(error);
      },
    );

    await buffer.markReadyAndFlush();
    buffer.add(StateError('late'), StackTrace.current);

    expect(captured, isEmpty);
    expect(buffer.pending, isEmpty);
  });
}
