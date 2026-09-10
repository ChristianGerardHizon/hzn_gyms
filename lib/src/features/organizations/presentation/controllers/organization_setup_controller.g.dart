// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_setup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OrganizationSetupController)
final organizationSetupControllerProvider =
    OrganizationSetupControllerFamily._();

final class OrganizationSetupControllerProvider
    extends
        $AsyncNotifierProvider<
          OrganizationSetupController,
          OrganizationSetupState
        > {
  OrganizationSetupControllerProvider._({
    required OrganizationSetupControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'organizationSetupControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$organizationSetupControllerHash();

  @override
  String toString() {
    return r'organizationSetupControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OrganizationSetupController create() => OrganizationSetupController();

  @override
  bool operator ==(Object other) {
    return other is OrganizationSetupControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$organizationSetupControllerHash() =>
    r'88482b99f5a7d289f38223a34d0647ffd4497593';

final class OrganizationSetupControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          OrganizationSetupController,
          AsyncValue<OrganizationSetupState>,
          OrganizationSetupState,
          FutureOr<OrganizationSetupState>,
          String
        > {
  OrganizationSetupControllerFamily._()
    : super(
        retry: null,
        name: r'organizationSetupControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  OrganizationSetupControllerProvider call(String orgId) =>
      OrganizationSetupControllerProvider._(argument: orgId, from: this);

  @override
  String toString() => r'organizationSetupControllerProvider';
}

abstract class _$OrganizationSetupController
    extends $AsyncNotifier<OrganizationSetupState> {
  late final _$args = ref.$arg as String;
  String get orgId => _$args;

  FutureOr<OrganizationSetupState> build(String orgId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<OrganizationSetupState>, OrganizationSetupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<OrganizationSetupState>,
                OrganizationSetupState
              >,
              AsyncValue<OrganizationSetupState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
