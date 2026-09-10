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
    r'26b6dc4e9b5c8cd1f5af1e44f85b0d8d8b4e3d14';

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
///
/// Prefers the resolved [currentOrganizationControllerProvider] record, then
/// falls back to `auth.user.organization` so tenant-scoped lists (e.g. branches)
/// still work if the organization row cannot be fetched briefly.

@ProviderFor(currentOrganizationId)
final currentOrganizationIdProvider = CurrentOrganizationIdProvider._();

/// Convenience provider for the current organization ID, or null if
/// unresolved.
///
/// Prefers the resolved [currentOrganizationControllerProvider] record, then
/// falls back to `auth.user.organization` so tenant-scoped lists (e.g. branches)
/// still work if the organization row cannot be fetched briefly.

final class CurrentOrganizationIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Convenience provider for the current organization ID, or null if
  /// unresolved.
  ///
  /// Prefers the resolved [currentOrganizationControllerProvider] record, then
  /// falls back to `auth.user.organization` so tenant-scoped lists (e.g. branches)
  /// still work if the organization row cannot be fetched briefly.
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
    r'ed6f9eab0a21cebaada6576ca37bee93440ce4d5';

/// Convenience provider for an organization-scoped filter string.
///
/// Returns `organization = "id" && isDeleted = false`, or null while
/// unresolved. Use for collections that own an `organization` field.

@ProviderFor(currentOrganizationFilter)
final currentOrganizationFilterProvider = CurrentOrganizationFilterProvider._();

/// Convenience provider for an organization-scoped filter string.
///
/// Returns `organization = "id" && isDeleted = false`, or null while
/// unresolved. Use for collections that own an `organization` field.

final class CurrentOrganizationFilterProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Convenience provider for an organization-scoped filter string.
  ///
  /// Returns `organization = "id" && isDeleted = false`, or null while
  /// unresolved. Use for collections that own an `organization` field.
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

/// Filter for gym rows scoped via `branch.organization`.
///
/// Returns `branch.organization = "id" && isDeleted = false`, or null while
/// unresolved.

@ProviderFor(currentBranchOrganizationFilter)
final currentBranchOrganizationFilterProvider =
    CurrentBranchOrganizationFilterProvider._();

/// Filter for gym rows scoped via `branch.organization`.
///
/// Returns `branch.organization = "id" && isDeleted = false`, or null while
/// unresolved.

final class CurrentBranchOrganizationFilterProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Filter for gym rows scoped via `branch.organization`.
  ///
  /// Returns `branch.organization = "id" && isDeleted = false`, or null while
  /// unresolved.
  CurrentBranchOrganizationFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentBranchOrganizationFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentBranchOrganizationFilterHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentBranchOrganizationFilter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentBranchOrganizationFilterHash() =>
    r'ac8fdd776c31e25eb566dfeef6ccd1d9951b0703';
