// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_memberships_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active organization memberships for the signed-in user.

@ProviderFor(OrganizationMembershipsController)
final organizationMembershipsControllerProvider =
    OrganizationMembershipsControllerProvider._();

/// Active organization memberships for the signed-in user.
final class OrganizationMembershipsControllerProvider
    extends
        $AsyncNotifierProvider<
          OrganizationMembershipsController,
          List<OrganizationMembership>
        > {
  /// Active organization memberships for the signed-in user.
  OrganizationMembershipsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizationMembershipsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$organizationMembershipsControllerHash();

  @$internal
  @override
  OrganizationMembershipsController create() =>
      OrganizationMembershipsController();
}

String _$organizationMembershipsControllerHash() =>
    r'b1beb02ca932902f75fe41baac7aef460619fa9f';

/// Active organization memberships for the signed-in user.

abstract class _$OrganizationMembershipsController
    extends $AsyncNotifier<List<OrganizationMembership>> {
  FutureOr<List<OrganizationMembership>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<OrganizationMembership>>,
              List<OrganizationMembership>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<OrganizationMembership>>,
                List<OrganizationMembership>
              >,
              AsyncValue<List<OrganizationMembership>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Active membership for the current organization, if any.

@ProviderFor(currentOrganizationMembership)
final currentOrganizationMembershipProvider =
    CurrentOrganizationMembershipProvider._();

/// Active membership for the current organization, if any.

final class CurrentOrganizationMembershipProvider
    extends
        $FunctionalProvider<
          AsyncValue<OrganizationMembership?>,
          OrganizationMembership?,
          FutureOr<OrganizationMembership?>
        >
    with
        $FutureModifier<OrganizationMembership?>,
        $FutureProvider<OrganizationMembership?> {
  /// Active membership for the current organization, if any.
  CurrentOrganizationMembershipProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentOrganizationMembershipProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentOrganizationMembershipHash();

  @$internal
  @override
  $FutureProviderElement<OrganizationMembership?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OrganizationMembership?> create(Ref ref) {
    return currentOrganizationMembership(ref);
  }
}

String _$currentOrganizationMembershipHash() =>
    r'70b41ebfd0b40fdf51c02dc2872973571b1bd5dc';

/// Whether the signed-in user has at least one active org membership.

@ProviderFor(hasOrganizationMembership)
final hasOrganizationMembershipProvider = HasOrganizationMembershipProvider._();

/// Whether the signed-in user has at least one active org membership.

final class HasOrganizationMembershipProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the signed-in user has at least one active org membership.
  HasOrganizationMembershipProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasOrganizationMembershipProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasOrganizationMembershipHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasOrganizationMembership(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasOrganizationMembershipHash() =>
    r'0774f14ba0ab817f1e6fff5d20b30c2731c928ac';
