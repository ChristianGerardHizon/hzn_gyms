// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_membership_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the MemberMembershipRepository instance.

@ProviderFor(memberMembershipRepository)
final memberMembershipRepositoryProvider =
    MemberMembershipRepositoryProvider._();

/// Provides the MemberMembershipRepository instance.

final class MemberMembershipRepositoryProvider extends $FunctionalProvider<
    MemberMembershipRepository,
    MemberMembershipRepository,
    MemberMembershipRepository> with $Provider<MemberMembershipRepository> {
  /// Provides the MemberMembershipRepository instance.
  MemberMembershipRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memberMembershipRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberMembershipRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemberMembershipRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemberMembershipRepository create(Ref ref) {
    return memberMembershipRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberMembershipRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberMembershipRepository>(value),
    );
  }
}

String _$memberMembershipRepositoryHash() =>
    r'fdc9587d1be422dd8e6ebda86a5cdd1b6b2b5adf';
