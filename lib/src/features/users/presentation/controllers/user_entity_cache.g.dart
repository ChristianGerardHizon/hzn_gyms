// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity_cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// In-memory cache for single user entities.
///
/// Used to pre-cache newly created users to avoid race conditions
/// where the detail page loads before the network fetch completes.

@ProviderFor(UserEntityCache)
final userEntityCacheProvider = UserEntityCacheProvider._();

/// In-memory cache for single user entities.
///
/// Used to pre-cache newly created users to avoid race conditions
/// where the detail page loads before the network fetch completes.
final class UserEntityCacheProvider
    extends $NotifierProvider<UserEntityCache, Map<String, User>> {
  /// In-memory cache for single user entities.
  ///
  /// Used to pre-cache newly created users to avoid race conditions
  /// where the detail page loads before the network fetch completes.
  UserEntityCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userEntityCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userEntityCacheHash();

  @$internal
  @override
  UserEntityCache create() => UserEntityCache();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, User> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, User>>(value),
    );
  }
}

String _$userEntityCacheHash() => r'0f65b5d3f035bc6a1e234b22863964eadb99772e';

/// In-memory cache for single user entities.
///
/// Used to pre-cache newly created users to avoid race conditions
/// where the detail page loads before the network fetch completes.

abstract class _$UserEntityCache extends $Notifier<Map<String, User>> {
  Map<String, User> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, User>, Map<String, User>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, User>, Map<String, User>>,
              Map<String, User>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
