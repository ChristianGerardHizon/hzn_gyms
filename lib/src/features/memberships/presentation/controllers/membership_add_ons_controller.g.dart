// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_add_ons_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing add-ons for a specific membership plan.

@ProviderFor(MembershipAddOnsController)
final membershipAddOnsControllerProvider = MembershipAddOnsControllerFamily._();

/// Controller for managing add-ons for a specific membership plan.
final class MembershipAddOnsControllerProvider extends $AsyncNotifierProvider<
    MembershipAddOnsController, List<MembershipAddOn>> {
  /// Controller for managing add-ons for a specific membership plan.
  MembershipAddOnsControllerProvider._(
      {required MembershipAddOnsControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'membershipAddOnsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$membershipAddOnsControllerHash();

  @override
  String toString() {
    return r'membershipAddOnsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MembershipAddOnsController create() => MembershipAddOnsController();

  @override
  bool operator ==(Object other) {
    return other is MembershipAddOnsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$membershipAddOnsControllerHash() =>
    r'5fd625ea6163a9e85cab97eb32e6f6d34ea5184a';

/// Controller for managing add-ons for a specific membership plan.

final class MembershipAddOnsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            MembershipAddOnsController,
            AsyncValue<List<MembershipAddOn>>,
            List<MembershipAddOn>,
            FutureOr<List<MembershipAddOn>>,
            String> {
  MembershipAddOnsControllerFamily._()
      : super(
          retry: null,
          name: r'membershipAddOnsControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Controller for managing add-ons for a specific membership plan.

  MembershipAddOnsControllerProvider call(
    String membershipId,
  ) =>
      MembershipAddOnsControllerProvider._(argument: membershipId, from: this);

  @override
  String toString() => r'membershipAddOnsControllerProvider';
}

/// Controller for managing add-ons for a specific membership plan.

abstract class _$MembershipAddOnsController
    extends $AsyncNotifier<List<MembershipAddOn>> {
  late final _$args = ref.$arg as String;
  String get membershipId => _$args;

  FutureOr<List<MembershipAddOn>> build(
    String membershipId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<MembershipAddOn>>, List<MembershipAddOn>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<MembershipAddOn>>, List<MembershipAddOn>>,
        AsyncValue<List<MembershipAddOn>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
