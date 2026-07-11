import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/member_local_data_source.dart';
import '../../data/repositories/member_repository.dart';
import '../../domain/member.dart';

part 'member_provider.g.dart';

/// Provider for a single member by ID.
@riverpod
Future<Member?> member(Ref ref, String id) async {
  final localDataSource = ref.read(memberLocalDataSourceProvider);
  final repository = ref.read(memberRepositoryProvider);

  final cached = await localDataSource.getMemberById(id);
  if (cached != null) {
    // Revalidate in the background without blocking the cached result.
    Future(() async {
      final result = await repository.fetchOne(id);
      if (!ref.mounted) return;
      result.fold((_) => null, (_) => ref.invalidateSelf());
    });
    return cached;
  }

  final result = await repository.fetchOne(id);

  return result.fold((failure) => null, (member) => member);
}
