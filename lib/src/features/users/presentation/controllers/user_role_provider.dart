import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/user_role_repository.dart';
import '../../domain/user_role.dart';

part 'user_role_provider.g.dart';

/// Provider for a single user role by ID.
@riverpod
Future<UserRole?> userRole(Ref ref, String id) async {
  final repository = ref.read(userRoleRepositoryProvider);
  final result = await repository.fetchOne(id);

  return result.fold((failure) => null, (role) => role);
}
