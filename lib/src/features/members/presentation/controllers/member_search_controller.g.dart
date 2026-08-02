// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for managing which fields are included in member search.

@ProviderFor(MemberSearchFields)
final memberSearchFieldsProvider = MemberSearchFieldsProvider._();

/// Provider for managing which fields are included in member search.
final class MemberSearchFieldsProvider
    extends $NotifierProvider<MemberSearchFields, Set<String>> {
  /// Provider for managing which fields are included in member search.
  MemberSearchFieldsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberSearchFieldsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberSearchFieldsHash();

  @$internal
  @override
  MemberSearchFields create() => MemberSearchFields();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$memberSearchFieldsHash() =>
    r'e6ae16fae16d50864f4ae8b47e7c53c99c2e35b4';

/// Provider for managing which fields are included in member search.

abstract class _$MemberSearchFields extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
