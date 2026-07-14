// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the UserRoleRepository instance.

@ProviderFor(userRoleRepository)
final userRoleRepositoryProvider = UserRoleRepositoryProvider._();

/// Provides the UserRoleRepository instance.

final class UserRoleRepositoryProvider
    extends
        $FunctionalProvider<
          UserRoleRepository,
          UserRoleRepository,
          UserRoleRepository
        >
    with $Provider<UserRoleRepository> {
  /// Provides the UserRoleRepository instance.
  UserRoleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRoleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRoleRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRoleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserRoleRepository create(Ref ref) {
    return userRoleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRoleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRoleRepository>(value),
    );
  }
}

String _$userRoleRepositoryHash() =>
    r'd822b6b8de629429484ecf6cbc87c228c71ce10f';
