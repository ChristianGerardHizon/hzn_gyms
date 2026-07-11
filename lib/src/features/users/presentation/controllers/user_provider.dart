import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/user_repository.dart';
import '../../domain/user.dart';
import 'user_entity_cache.dart';

part 'user_provider.g.dart';

/// Provider for a single user by ID.
///
/// Checks the entity cache first (for newly created users),
/// then falls back to a network fetch.
@riverpod
Future<User?> user(Ref ref, String id) async {
  // Check cache first (handles newly created users)
  final cachedUser = ref.read(userEntityCacheProvider.notifier).getUser(id);
  if (cachedUser != null) {
    return cachedUser;
  }

  // Fetch from network
  final repository = ref.read(userRepositoryProvider);
  final result = await repository.fetchOne(id);

  return result.fold((failure) => null, (user) => user);
}
