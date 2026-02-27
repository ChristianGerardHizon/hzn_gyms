// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that fetches payments for a specific sale.

@ProviderFor(salePayments)
final salePaymentsProvider = SalePaymentsFamily._();

/// Provider that fetches payments for a specific sale.

final class SalePaymentsProvider extends $FunctionalProvider<
        AsyncValue<List<Payment>>, List<Payment>, FutureOr<List<Payment>>>
    with $FutureModifier<List<Payment>>, $FutureProvider<List<Payment>> {
  /// Provider that fetches payments for a specific sale.
  SalePaymentsProvider._(
      {required SalePaymentsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'salePaymentsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salePaymentsHash();

  @override
  String toString() {
    return r'salePaymentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Payment>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Payment>> create(Ref ref) {
    final argument = this.argument as String;
    return salePayments(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SalePaymentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$salePaymentsHash() => r'009ab90f5e8f0563f8f867d05a400c294b520a45';

/// Provider that fetches payments for a specific sale.

final class SalePaymentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Payment>>, String> {
  SalePaymentsFamily._()
      : super(
          retry: null,
          name: r'salePaymentsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider that fetches payments for a specific sale.

  SalePaymentsProvider call(
    String saleId,
  ) =>
      SalePaymentsProvider._(argument: saleId, from: this);

  @override
  String toString() => r'salePaymentsProvider';
}

/// Provider that calculates the total paid amount for a sale.

@ProviderFor(saleTotalPaid)
final saleTotalPaidProvider = SaleTotalPaidFamily._();

/// Provider that calculates the total paid amount for a sale.

final class SaleTotalPaidProvider
    extends $FunctionalProvider<AsyncValue<num>, num, FutureOr<num>>
    with $FutureModifier<num>, $FutureProvider<num> {
  /// Provider that calculates the total paid amount for a sale.
  SaleTotalPaidProvider._(
      {required SaleTotalPaidFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'saleTotalPaidProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$saleTotalPaidHash();

  @override
  String toString() {
    return r'saleTotalPaidProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<num> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<num> create(Ref ref) {
    final argument = this.argument as String;
    return saleTotalPaid(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaleTotalPaidProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleTotalPaidHash() => r'02d024b499aa7b1171efd075b62fafcef74a921f';

/// Provider that calculates the total paid amount for a sale.

final class SaleTotalPaidFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<num>, String> {
  SaleTotalPaidFamily._()
      : super(
          retry: null,
          name: r'saleTotalPaidProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider that calculates the total paid amount for a sale.

  SaleTotalPaidProvider call(
    String saleId,
  ) =>
      SaleTotalPaidProvider._(argument: saleId, from: this);

  @override
  String toString() => r'saleTotalPaidProvider';
}

/// Controller for managing payments for a sale.

@ProviderFor(PaymentsController)
final paymentsControllerProvider = PaymentsControllerProvider._();

/// Controller for managing payments for a sale.
final class PaymentsControllerProvider
    extends $AsyncNotifierProvider<PaymentsController, void> {
  /// Controller for managing payments for a sale.
  PaymentsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'paymentsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$paymentsControllerHash();

  @$internal
  @override
  PaymentsController create() => PaymentsController();
}

String _$paymentsControllerHash() =>
    r'8fe0cc8064701ca626382ef03776e178f5d20c00';

/// Controller for managing payments for a sale.

abstract class _$PaymentsController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
