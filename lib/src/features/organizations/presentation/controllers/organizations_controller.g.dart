// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizations_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for super-admin organization list and CRUD.

@ProviderFor(OrganizationsController)
final organizationsControllerProvider = OrganizationsControllerProvider._();

/// Controller for super-admin organization list and CRUD.
final class OrganizationsControllerProvider
    extends
        $AsyncNotifierProvider<OrganizationsController, List<Organization>> {
  /// Controller for super-admin organization list and CRUD.
  OrganizationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizationsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizationsControllerHash();

  @$internal
  @override
  OrganizationsController create() => OrganizationsController();
}

String _$organizationsControllerHash() =>
    r'23a3271e2e50b48dd1d23ea1b2f777c685f60d8c';

/// Controller for super-admin organization list and CRUD.

abstract class _$OrganizationsController
    extends $AsyncNotifier<List<Organization>> {
  FutureOr<List<Organization>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Organization>>, List<Organization>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Organization>>, List<Organization>>,
              AsyncValue<List<Organization>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
