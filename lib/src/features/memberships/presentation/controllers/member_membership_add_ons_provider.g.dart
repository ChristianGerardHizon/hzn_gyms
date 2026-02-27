// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_membership_add_ons_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for fetching add-ons selected for a specific member membership.

@ProviderFor(memberMembershipAddOns)
final memberMembershipAddOnsProvider = MemberMembershipAddOnsFamily._();

/// Provider for fetching add-ons selected for a specific member membership.

final class MemberMembershipAddOnsProvider extends $FunctionalProvider<
        AsyncValue<List<MemberMembershipAddOn>>,
        List<MemberMembershipAddOn>,
        FutureOr<List<MemberMembershipAddOn>>>
    with
        $FutureModifier<List<MemberMembershipAddOn>>,
        $FutureProvider<List<MemberMembershipAddOn>> {
  /// Provider for fetching add-ons selected for a specific member membership.
  MemberMembershipAddOnsProvider._(
      {required MemberMembershipAddOnsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'memberMembershipAddOnsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberMembershipAddOnsHash();

  @override
  String toString() {
    return r'memberMembershipAddOnsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<MemberMembershipAddOn>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemberMembershipAddOn>> create(Ref ref) {
    final argument = this.argument as String;
    return memberMembershipAddOns(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberMembershipAddOnsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberMembershipAddOnsHash() =>
    r'7ca41a21f81c00d156a786abe2e6d21468531755';

/// Provider for fetching add-ons selected for a specific member membership.

final class MemberMembershipAddOnsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<MemberMembershipAddOn>>,
            String> {
  MemberMembershipAddOnsFamily._()
      : super(
          retry: null,
          name: r'memberMembershipAddOnsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for fetching add-ons selected for a specific member membership.

  MemberMembershipAddOnsProvider call(
    String memberMembershipId,
  ) =>
      MemberMembershipAddOnsProvider._(
          argument: memberMembershipId, from: this);

  @override
  String toString() => r'memberMembershipAddOnsProvider';
}
