// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the MembershipRepository instance.

@ProviderFor(membershipRepository)
final membershipRepositoryProvider = MembershipRepositoryProvider._();

/// Provides the MembershipRepository instance.

final class MembershipRepositoryProvider extends $FunctionalProvider<
    MembershipRepository,
    MembershipRepository,
    MembershipRepository> with $Provider<MembershipRepository> {
  /// Provides the MembershipRepository instance.
  MembershipRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'membershipRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$membershipRepositoryHash();

  @$internal
  @override
  $ProviderElement<MembershipRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MembershipRepository create(Ref ref) {
    return membershipRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MembershipRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MembershipRepository>(value),
    );
  }
}

String _$membershipRepositoryHash() =>
    r'27afb6a3f735ac889f121b3908bac0412bbc6940';
