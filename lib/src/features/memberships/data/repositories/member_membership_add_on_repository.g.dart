// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_membership_add_on_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the MemberMembershipAddOnRepository instance.

@ProviderFor(memberMembershipAddOnRepository)
final memberMembershipAddOnRepositoryProvider =
    MemberMembershipAddOnRepositoryProvider._();

/// Provides the MemberMembershipAddOnRepository instance.

final class MemberMembershipAddOnRepositoryProvider extends $FunctionalProvider<
        MemberMembershipAddOnRepository,
        MemberMembershipAddOnRepository,
        MemberMembershipAddOnRepository>
    with $Provider<MemberMembershipAddOnRepository> {
  /// Provides the MemberMembershipAddOnRepository instance.
  MemberMembershipAddOnRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memberMembershipAddOnRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberMembershipAddOnRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemberMembershipAddOnRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemberMembershipAddOnRepository create(Ref ref) {
    return memberMembershipAddOnRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberMembershipAddOnRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<MemberMembershipAddOnRepository>(value),
    );
  }
}

String _$memberMembershipAddOnRepositoryHash() =>
    r'0532dc1fbf7fad2530dcd621102663a563211c19';
