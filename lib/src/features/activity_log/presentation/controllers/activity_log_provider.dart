import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/activity_log_repository.dart';
import '../../domain/activity_log.dart';

part 'activity_log_provider.g.dart';

@Riverpod(keepAlive: true)
Future<ActivityLog> activityLog(Ref ref, String id) async {
  final result = await ref.read(activityLogRepositoryProvider).fetchOne(id);
  return result.fold(
    (failure) => throw failure,
    (log) => log,
  );
}
