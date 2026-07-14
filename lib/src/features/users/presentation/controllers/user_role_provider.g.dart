// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for a single user role by ID.

@ProviderFor(userRole)
final userRoleProvider = UserRoleFamily._();

/// Provider for a single user role by ID.

final class UserRoleProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserRole?>,
          UserRole?,
          FutureOr<UserRole?>
        >
    with $FutureModifier<UserRole?>, $FutureProvider<UserRole?> {
  /// Provider for a single user role by ID.
  UserRoleProvider._({
    required UserRoleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userRoleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userRoleHash();

  @override
  String toString() {
    return r'userRoleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserRole?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserRole?> create(Ref ref) {
    final argument = this.argument as String;
    return userRole(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserRoleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userRoleHash() => r'b4c49e5431183bac3d3ba9cdb9f40a03724eef26';

/// Provider for a single user role by ID.

final class UserRoleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserRole?>, String> {
  UserRoleFamily._()
    : super(
        retry: null,
        name: r'userRoleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for a single user role by ID.

  UserRoleProvider call(String id) =>
      UserRoleProvider._(argument: id, from: this);

  @override
  String toString() => r'userRoleProvider';
}
