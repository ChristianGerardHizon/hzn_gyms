// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_membership_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(organizationMembershipRepository)
final organizationMembershipRepositoryProvider =
    OrganizationMembershipRepositoryProvider._();

final class OrganizationMembershipRepositoryProvider
    extends
        $FunctionalProvider<
          OrganizationMembershipRepository,
          OrganizationMembershipRepository,
          OrganizationMembershipRepository
        >
    with $Provider<OrganizationMembershipRepository> {
  OrganizationMembershipRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizationMembershipRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizationMembershipRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrganizationMembershipRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OrganizationMembershipRepository create(Ref ref) {
    return organizationMembershipRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizationMembershipRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrganizationMembershipRepository>(
        value,
      ),
    );
  }
}

String _$organizationMembershipRepositoryHash() =>
    r'1f827464573975c42a34fba06e8bba7f18f784d1';
