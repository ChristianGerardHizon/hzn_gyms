// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_sort_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for managing member list sort configuration.

@ProviderFor(MemberSortController)
final memberSortControllerProvider = MemberSortControllerProvider._();

/// Provider for managing member list sort configuration.
final class MemberSortControllerProvider
    extends $NotifierProvider<MemberSortController, SortConfig> {
  /// Provider for managing member list sort configuration.
  MemberSortControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memberSortControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberSortControllerHash();

  @$internal
  @override
  MemberSortController create() => MemberSortController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SortConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SortConfig>(value),
    );
  }
}

String _$memberSortControllerHash() =>
    r'ce3aa8f4686f98fa1de93baad365ffd5f7642466';

/// Provider for managing member list sort configuration.

abstract class _$MemberSortController extends $Notifier<SortConfig> {
  SortConfig build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SortConfig, SortConfig>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SortConfig, SortConfig>, SortConfig, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
