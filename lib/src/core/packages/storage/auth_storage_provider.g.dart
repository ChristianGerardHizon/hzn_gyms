// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides auth storage operations for saving/loading authentication data.

@ProviderFor(authStorage)
final authStorageProvider = AuthStorageProvider._();

/// Provides auth storage operations for saving/loading authentication data.

final class AuthStorageProvider
    extends
        $FunctionalProvider<
          AuthStorageService,
          AuthStorageService,
          AuthStorageService
        >
    with $Provider<AuthStorageService> {
  /// Provides auth storage operations for saving/loading authentication data.
  AuthStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStorageHash();

  @$internal
  @override
  $ProviderElement<AuthStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthStorageService create(Ref ref) {
    return authStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthStorageService>(value),
    );
  }
}

String _$authStorageHash() => r'9ef5d676c49ce832e75bdee96cd414bef4d68da0';
