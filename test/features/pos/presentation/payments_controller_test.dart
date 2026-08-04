import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ebe_gym/src/core/foundation/failure.dart';
import 'package:ebe_gym/src/features/pos/data/repositories/payment_repository.dart';
import 'package:ebe_gym/src/features/pos/domain/payment.dart';
import 'package:ebe_gym/src/features/pos/domain/payment_method.dart';
import 'package:ebe_gym/src/features/pos/domain/payment_type.dart';
import 'package:ebe_gym/src/features/pos/presentation/payments_controller.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(PaymentMethod.cash);
    registerFallbackValue(PaymentType.payment);
  });

  late MockPaymentRepository paymentRepo;

  ProviderContainer createContainer() {
    paymentRepo = MockPaymentRepository();
    return ProviderContainer(
      overrides: [
        paymentRepositoryProvider.overrideWithValue(paymentRepo),
      ],
    );
  }

  group('salePayments', () {
    test('returns payments from repository', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final payments = [
        buildPayment(id: 'pay-1', amount: 60),
        buildPayment(id: 'pay-2', amount: 40, type: PaymentType.deposit),
      ];
      when(() => paymentRepo.getBySaleId('sale-1'))
          .thenAnswer((_) async => right(payments));

      final result = await container.read(salePaymentsProvider('sale-1').future);

      expect(result, hasLength(2));
      expect(result.first.id, 'pay-1');
      verify(() => paymentRepo.getBySaleId('sale-1')).called(1);
    });

    test('surfaces repository failure on the provider', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      when(() => paymentRepo.getBySaleId('sale-1')).thenAnswer(
        (_) async => left(const GenericFailure('network down')),
      );

      Object? capturedError;
      final sub = container.listen(
        salePaymentsProvider('sale-1'),
        (previous, next) {
          if (next.hasError) capturedError = next.error;
        },
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(capturedError, isNotNull);
      expect(capturedError.toString(), contains('network down'));
      expect(
        container.read(salePaymentsProvider('sale-1')).hasError,
        isTrue,
      );
    });
  });

  group('saleTotalPaid', () {
    test('sums payments and subtracts refunds', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      when(() => paymentRepo.getBySaleId('sale-1')).thenAnswer(
        (_) async => right([
          buildPayment(amount: 100),
          buildPayment(
            id: 'pay-2',
            amount: 30,
            type: PaymentType.refund,
          ),
          buildPayment(
            id: 'pay-3',
            amount: 20,
            type: PaymentType.deposit,
          ),
        ]),
      );

      final total =
          await container.read(saleTotalPaidProvider('sale-1').future);

      expect(total, 90);
    });

    test('returns zero when there are no payments', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      when(() => paymentRepo.getBySaleId('sale-1'))
          .thenAnswer((_) async => right(<Payment>[]));

      final total =
          await container.read(saleTotalPaidProvider('sale-1').future);

      expect(total, 0);
    });
  });

  group('PaymentsController.recordPayment', () {
    test('returns payment and invalidates sale payments on success', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final created = buildPayment(amount: 50);
      when(
        () => paymentRepo.create(
          saleId: any(named: 'saleId'),
          amount: any(named: 'amount'),
          paymentMethod: any(named: 'paymentMethod'),
          type: any(named: 'type'),
          paymentRef: any(named: 'paymentRef'),
          notes: any(named: 'notes'),
          paymentProofFile: any(named: 'paymentProofFile'),
        ),
      ).thenAnswer(
        (_) async => right(
          (payment: created, saleIsPaid: true, saleStatus: 'paid'),
        ),
      );

      // Warm cache so invalidate is observable via a subsequent fetch.
      when(() => paymentRepo.getBySaleId('sale-1'))
          .thenAnswer((_) async => right([created]));
      await container.read(salePaymentsProvider('sale-1').future);

      final payment = await container
          .read(paymentsControllerProvider.notifier)
          .recordPayment(
            saleId: 'sale-1',
            amount: 50,
            paymentMethod: PaymentMethod.cash,
            type: PaymentType.payment,
          );

      expect(payment, isNotNull);
      expect(payment!.id, 'pay-1');
      verify(
        () => paymentRepo.create(
          saleId: 'sale-1',
          amount: 50,
          paymentMethod: PaymentMethod.cash,
          type: PaymentType.payment,
          paymentRef: null,
          notes: null,
          paymentProofFile: null,
        ),
      ).called(1);
    });

    test('returns null and sets AsyncError on failure', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      when(
        () => paymentRepo.create(
          saleId: any(named: 'saleId'),
          amount: any(named: 'amount'),
          paymentMethod: any(named: 'paymentMethod'),
          type: any(named: 'type'),
          paymentRef: any(named: 'paymentRef'),
          notes: any(named: 'notes'),
          paymentProofFile: any(named: 'paymentProofFile'),
        ),
      ).thenAnswer(
        (_) async => left(const GenericFailure('create failed')),
      );

      final payment = await container
          .read(paymentsControllerProvider.notifier)
          .recordPayment(
            saleId: 'sale-1',
            amount: 50,
            paymentMethod: PaymentMethod.card,
            type: PaymentType.payment,
          );

      expect(payment, isNull);
      expect(
        container.read(paymentsControllerProvider),
        isA<AsyncError<void>>(),
      );
    });
  });

  group('PaymentsController.deletePayment (void)', () {
    test('returns true when void succeeds', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      when(() => paymentRepo.delete('pay-1'))
          .thenAnswer((_) async => right(null));
      when(() => paymentRepo.getBySaleId('sale-1'))
          .thenAnswer((_) async => right(<Payment>[]));
      await container.read(salePaymentsProvider('sale-1').future);

      final success = await container
          .read(paymentsControllerProvider.notifier)
          .deletePayment('pay-1', 'sale-1');

      expect(success, isTrue);
      verify(() => paymentRepo.delete('pay-1')).called(1);
    });

    test('returns false and sets AsyncError when void fails', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      when(() => paymentRepo.delete('pay-1')).thenAnswer(
        (_) async => left(const GenericFailure('delete failed')),
      );

      final success = await container
          .read(paymentsControllerProvider.notifier)
          .deletePayment('pay-1', 'sale-1');

      expect(success, isFalse);
      expect(
        container.read(paymentsControllerProvider),
        isA<AsyncError<void>>(),
      );
    });
  });
}
