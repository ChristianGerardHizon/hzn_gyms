// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_active_branch_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selected branch for filtering the Members list to active members.
///
/// `null` means All (no branch filter — full member list).

@ProviderFor(MemberActiveBranchFilter)
final memberActiveBranchFilterProvider = MemberActiveBranchFilterProvider._();

/// Selected branch for filtering the Members list to active members.
///
/// `null` means All (no branch filter — full member list).
final class MemberActiveBranchFilterProvider
    extends $NotifierProvider<MemberActiveBranchFilter, String?> {
  /// Selected branch for filtering the Members list to active members.
  ///
  /// `null` means All (no branch filter — full member list).
  MemberActiveBranchFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberActiveBranchFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberActiveBranchFilterHash();

  @$internal
  @override
  MemberActiveBranchFilter create() => MemberActiveBranchFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$memberActiveBranchFilterHash() =>
    r'd3a085fe03ce5b30839fa3c2563f3cd200dd2567';

/// Selected branch for filtering the Members list to active members.
///
/// `null` means All (no branch filter — full member list).

abstract class _$MemberActiveBranchFilter extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
