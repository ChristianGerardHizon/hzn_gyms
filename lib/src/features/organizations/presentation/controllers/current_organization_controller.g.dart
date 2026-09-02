// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_organization_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for resolving/switching the current organization.
///
/// Login is organization-agnostic — no tenant is resolved from the URL/hostname
/// before sign-in. After authentication, resolution order is:
/// 1. The signed-in user's `organization` field.
/// 2. A persisted choice in secure storage (super-admin org switcher).

@ProviderFor(CurrentOrganizationController)
final currentOrganizationControllerProvider =
    CurrentOrganizationControllerProvider._();

/// Controller for resolving/switching the current organization.
///
/// Login is organization-agnostic — no tenant is resolved from the URL/hostname
/// before sign-in. After authentication, resolution order is:
/// 1. The signed-in user's `organization` field.
/// 2. A persisted choice in secure storage (super-admin org switcher).
final class CurrentOrganizationControllerProvider
    extends
        $AsyncNotifierProvider<CurrentOrganizationController, Organization?> {
  /// Controller for resolving/switching the current organization.
  ///
  /// Login is organization-agnostic — no tenant is resolved from the URL/hostname
  /// before sign-in. After authentication, resolution order is:
  /// 1. The signed-in user's `organization` field.
  /// 2. A persisted choice in secure storage (super-admin org switcher).
  CurrentOrganizationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentOrganizationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentOrganizationControllerHash();

  @$internal
  @override
  CurrentOrganizationController create() => CurrentOrganizationController();
}

String _$currentOrganizationControllerHash() =>
    r'affa330fa3b8fa2601372d2e516dd47c7cceba5a';

/// Controller for resolving/switching the current organization.
///
/// Login is organization-agnostic — no tenant is resolved from the URL/hostname
/// before sign-in. After authentication, resolution order is:
/// 1. The signed-in user's `organization` field.
/// 2. A persisted choice in secure storage (super-admin org switcher).

abstract class _$CurrentOrganizationController
    extends $AsyncNotifier<Organization?> {
  FutureOr<Organization?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Organization?>, Organization?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Organization?>, Organization?>,
              AsyncValue<Organization?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Convenience provider for the current organization ID, or null if
/// unresolved.

@ProviderFor(currentOrganizationId)
final currentOrganizationIdProvider = CurrentOrganizationIdProvider._();

/// Convenience provider for the current organization ID, or null if
/// unresolved.

final class CurrentOrganizationIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Convenience provider for the current organization ID, or null if
  /// unresolved.
  CurrentOrganizationIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentOrganizationIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentOrganizationIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentOrganizationId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentOrganizationIdHash() =>
    r'ac7eab489dba76f0b27102077ebd74f5074e8569';

/// Convenience provider for an organization-scoped filter string.
///
/// Returns `organization = "id" && isDeleted = false`, or null while
/// unresolved.

@ProviderFor(currentOrganizationFilter)
final currentOrganizationFilterProvider = CurrentOrganizationFilterProvider._();

/// Convenience provider for an organization-scoped filter string.
///
/// Returns `organization = "id" && isDeleted = false`, or null while
/// unresolved.

final class CurrentOrganizationFilterProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Convenience provider for an organization-scoped filter string.
  ///
  /// Returns `organization = "id" && isDeleted = false`, or null while
  /// unresolved.
  CurrentOrganizationFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentOrganizationFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentOrganizationFilterHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentOrganizationFilter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentOrganizationFilterHash() =>
    r'825ec6f5bc3dd9f3b33303112e794336264283b5';
