// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the OrganizationRepository instance.

@ProviderFor(organizationRepository)
final organizationRepositoryProvider = OrganizationRepositoryProvider._();

/// Provides the OrganizationRepository instance.

final class OrganizationRepositoryProvider
    extends
        $FunctionalProvider<
          OrganizationRepository,
          OrganizationRepository,
          OrganizationRepository
        >
    with $Provider<OrganizationRepository> {
  /// Provides the OrganizationRepository instance.
  OrganizationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizationRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrganizationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OrganizationRepository create(Ref ref) {
    return organizationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrganizationRepository>(value),
    );
  }
}

String _$organizationRepositoryHash() =>
    r'8b2fde059ac2605f8efd4b6db0b95b45e5175aba';
