// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_purchase_catalog_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Membership plans available in purchase / renew / new-member flows.
///
/// When [allBranches] is false, returns plans valid at the current working
/// branch (same as [MembershipsController]). When true, returns every plan
/// so staff can sell a plan whose [Membership.validBranches] targets another
/// branch; the sale still stamps the selling branch.

@ProviderFor(membershipPurchaseCatalog)
final membershipPurchaseCatalogProvider = MembershipPurchaseCatalogFamily._();

/// Membership plans available in purchase / renew / new-member flows.
///
/// When [allBranches] is false, returns plans valid at the current working
/// branch (same as [MembershipsController]). When true, returns every plan
/// so staff can sell a plan whose [Membership.validBranches] targets another
/// branch; the sale still stamps the selling branch.

final class MembershipPurchaseCatalogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Membership>>,
          List<Membership>,
          FutureOr<List<Membership>>
        >
    with $FutureModifier<List<Membership>>, $FutureProvider<List<Membership>> {
  /// Membership plans available in purchase / renew / new-member flows.
  ///
  /// When [allBranches] is false, returns plans valid at the current working
  /// branch (same as [MembershipsController]). When true, returns every plan
  /// so staff can sell a plan whose [Membership.validBranches] targets another
  /// branch; the sale still stamps the selling branch.
  MembershipPurchaseCatalogProvider._({
    required MembershipPurchaseCatalogFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'membershipPurchaseCatalogProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$membershipPurchaseCatalogHash();

  @override
  String toString() {
    return r'membershipPurchaseCatalogProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Membership>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Membership>> create(Ref ref) {
    final argument = this.argument as bool;
    return membershipPurchaseCatalog(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MembershipPurchaseCatalogProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$membershipPurchaseCatalogHash() =>
    r'94721f932927717c9ecd4830a04aa12c0f54efa2';

/// Membership plans available in purchase / renew / new-member flows.
///
/// When [allBranches] is false, returns plans valid at the current working
/// branch (same as [MembershipsController]). When true, returns every plan
/// so staff can sell a plan whose [Membership.validBranches] targets another
/// branch; the sale still stamps the selling branch.

final class MembershipPurchaseCatalogFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Membership>>, bool> {
  MembershipPurchaseCatalogFamily._()
    : super(
        retry: null,
        name: r'membershipPurchaseCatalogProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Membership plans available in purchase / renew / new-member flows.
  ///
  /// When [allBranches] is false, returns plans valid at the current working
  /// branch (same as [MembershipsController]). When true, returns every plan
  /// so staff can sell a plan whose [Membership.validBranches] targets another
  /// branch; the sale still stamps the selling branch.

  MembershipPurchaseCatalogProvider call(bool allBranches) =>
      MembershipPurchaseCatalogProvider._(argument: allBranches, from: this);

  @override
  String toString() => r'membershipPurchaseCatalogProvider';
}
