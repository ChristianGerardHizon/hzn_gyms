// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for user search query state.

@ProviderFor(UserSearchQuery)
final userSearchQueryProvider = UserSearchQueryProvider._();

/// Provider for user search query state.
final class UserSearchQueryProvider
    extends $NotifierProvider<UserSearchQuery, String> {
  /// Provider for user search query state.
  UserSearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userSearchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userSearchQueryHash();

  @$internal
  @override
  UserSearchQuery create() => UserSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$userSearchQueryHash() => r'cf2c324fa4f99b5506092fc42decff6599e98c1f';

/// Provider for user search query state.

abstract class _$UserSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provider for managing which fields are included in user search.

@ProviderFor(UserSearchFields)
final userSearchFieldsProvider = UserSearchFieldsProvider._();

/// Provider for managing which fields are included in user search.
final class UserSearchFieldsProvider
    extends $NotifierProvider<UserSearchFields, Set<String>> {
  /// Provider for managing which fields are included in user search.
  UserSearchFieldsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userSearchFieldsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userSearchFieldsHash();

  @$internal
  @override
  UserSearchFields create() => UserSearchFields();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$userSearchFieldsHash() => r'd17e475ffe272d0766af01a32c37386d7abfc3c4';

/// Provider for managing which fields are included in user search.

abstract class _$UserSearchFields extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Set<String>, Set<String>>, Set<String>, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
