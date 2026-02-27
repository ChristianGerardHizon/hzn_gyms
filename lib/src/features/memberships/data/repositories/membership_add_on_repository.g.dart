// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_add_on_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the MembershipAddOnRepository instance.

@ProviderFor(membershipAddOnRepository)
final membershipAddOnRepositoryProvider = MembershipAddOnRepositoryProvider._();

/// Provides the MembershipAddOnRepository instance.

final class MembershipAddOnRepositoryProvider extends $FunctionalProvider<
    MembershipAddOnRepository,
    MembershipAddOnRepository,
    MembershipAddOnRepository> with $Provider<MembershipAddOnRepository> {
  /// Provides the MembershipAddOnRepository instance.
  MembershipAddOnRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'membershipAddOnRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$membershipAddOnRepositoryHash();

  @$internal
  @override
  $ProviderElement<MembershipAddOnRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MembershipAddOnRepository create(Ref ref) {
    return membershipAddOnRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MembershipAddOnRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MembershipAddOnRepository>(value),
    );
  }
}

String _$membershipAddOnRepositoryHash() =>
    r'5e57ebcc1dae2b84372508cddb19c3665a703e59';
