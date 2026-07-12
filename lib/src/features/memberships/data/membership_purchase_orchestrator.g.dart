// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_purchase_orchestrator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(membershipPurchaseOrchestrator)
final membershipPurchaseOrchestratorProvider =
    MembershipPurchaseOrchestratorProvider._();

final class MembershipPurchaseOrchestratorProvider
    extends
        $FunctionalProvider<
          MembershipPurchaseOrchestrator,
          MembershipPurchaseOrchestrator,
          MembershipPurchaseOrchestrator
        >
    with $Provider<MembershipPurchaseOrchestrator> {
  MembershipPurchaseOrchestratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipPurchaseOrchestratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membershipPurchaseOrchestratorHash();

  @$internal
  @override
  $ProviderElement<MembershipPurchaseOrchestrator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MembershipPurchaseOrchestrator create(Ref ref) {
    return membershipPurchaseOrchestrator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MembershipPurchaseOrchestrator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MembershipPurchaseOrchestrator>(
        value,
      ),
    );
  }
}

String _$membershipPurchaseOrchestratorHash() =>
    r'054d4cc82fee92fe9b1b93c1ba6721e687389803';
