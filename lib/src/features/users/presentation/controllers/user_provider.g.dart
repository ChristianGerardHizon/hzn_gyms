// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for a single user by ID.
///
/// Checks the entity cache first (for newly created users),
/// then falls back to a network fetch.

@ProviderFor(user)
final userProvider = UserFamily._();

/// Provider for a single user by ID.
///
/// Checks the entity cache first (for newly created users),
/// then falls back to a network fetch.

final class UserProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, FutureOr<User?>>
    with $FutureModifier<User?>, $FutureProvider<User?> {
  /// Provider for a single user by ID.
  ///
  /// Checks the entity cache first (for newly created users),
  /// then falls back to a network fetch.
  UserProvider._({
    required UserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userHash();

  @override
  String toString() {
    return r'userProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<User?> create(Ref ref) {
    final argument = this.argument as String;
    return user(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userHash() => r'c5095c53fa0b812f777764cd75dbb11f1012bcc9';

/// Provider for a single user by ID.
///
/// Checks the entity cache first (for newly created users),
/// then falls back to a network fetch.

final class UserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<User?>, String> {
  UserFamily._()
    : super(
        retry: null,
        name: r'userProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for a single user by ID.
  ///
  /// Checks the entity cache first (for newly created users),
  /// then falls back to a network fetch.

  UserProvider call(String id) => UserProvider._(argument: id, from: this);

  @override
  String toString() => r'userProvider';
}
