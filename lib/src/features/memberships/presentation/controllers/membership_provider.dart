import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/membership_repository.dart';
import '../../domain/membership.dart';

part 'membership_provider.g.dart';

/// Provider for a single membership plan by ID.
@riverpod
Future<Membership?> membership(Ref ref, String id) async {
  final repository = ref.read(membershipRepositoryProvider);
  final result = await repository.fetchOne(id);

  return result.fold(
    (failure) => null,
    (membership) => membership,
  );
}
