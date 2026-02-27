import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/check_in_repository.dart';
import '../../domain/check_in.dart';

part 'member_check_ins_controller.g.dart';

/// Provider for fetching a specific member's check-in history.
@riverpod
Future<List<CheckIn>> memberCheckIns(Ref ref, String memberId) async {
  final repository = ref.read(checkInRepositoryProvider);
  final result = await repository.fetchByMember(memberId);

  return result.fold(
    (failure) => [],
    (checkIns) => checkIns,
  );
}
