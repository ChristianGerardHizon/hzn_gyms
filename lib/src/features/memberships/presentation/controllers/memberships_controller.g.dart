// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memberships_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing the list of membership plans.

@ProviderFor(MembershipsController)
final membershipsControllerProvider = MembershipsControllerProvider._();

/// Controller for managing the list of membership plans.
final class MembershipsControllerProvider
    extends $AsyncNotifierProvider<MembershipsController, List<Membership>> {
  /// Controller for managing the list of membership plans.
  MembershipsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membershipsControllerHash();

  @$internal
  @override
  MembershipsController create() => MembershipsController();
}

String _$membershipsControllerHash() =>
    r'17cec3eb7b7f8a4852a19b3613a57c78964c7505';

/// Controller for managing the list of membership plans.

abstract class _$MembershipsController
    extends $AsyncNotifier<List<Membership>> {
  FutureOr<List<Membership>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Membership>>, List<Membership>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Membership>>, List<Membership>>,
              AsyncValue<List<Membership>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
