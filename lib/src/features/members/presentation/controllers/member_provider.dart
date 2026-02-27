import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/member_repository.dart';
import '../../domain/member.dart';

part 'member_provider.g.dart';

/// Provider for a single member by ID.
@riverpod
Future<Member?> member(Ref ref, String id) async {
  final repository = ref.read(memberRepositoryProvider);
  final result = await repository.fetchOne(id);

  return result.fold(
    (failure) => null,
    (member) => member,
  );
}
