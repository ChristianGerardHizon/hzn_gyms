import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/payment_repository.dart';
import '../domain/payment.dart';
import '../domain/payment_method.dart';
import '../domain/payment_type.dart';

part 'payments_controller.g.dart';

/// Provider that fetches payments for a specific sale.
@riverpod
Future<List<Payment>> salePayments(Ref ref, String saleId) async {
  final repo = ref.watch(paymentRepositoryProvider);
  final result = await repo.getBySaleId(saleId);
  return result.fold(
    (failure) => throw Exception(failure.messageString),
    (payments) => payments,
  );
}

/// Provider that calculates the total paid amount for a sale.
@riverpod
Future<num> saleTotalPaid(Ref ref, String saleId) async {
  final payments = await ref.watch(salePaymentsProvider(saleId).future);
  num total = 0;
  for (final payment in payments) {
    if (payment.type == PaymentType.refund) {
      total -= payment.amount;
    } else {
      total += payment.amount;
    }
  }
  return total;
}

/// Controller for managing payments for a sale.
@riverpod
class PaymentsController extends _$PaymentsController {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Records a new payment for a sale.
  Future<Payment?> recordPayment({
    required String saleId,
    required num amount,
    required PaymentMethod paymentMethod,
    required PaymentType type,
    String? paymentRef,
    String? notes,
    http.MultipartFile? paymentProofFile,
  }) async {
    final repo = ref.read(paymentRepositoryProvider);
    final result = await repo.create(
      saleId: saleId,
      amount: amount,
      paymentMethod: paymentMethod,
      type: type,
      paymentRef: paymentRef,
      notes: notes,
      paymentProofFile: paymentProofFile,
    );

    return result.fold(
      (failure) {
        if (ref.mounted) {
          state = AsyncError(failure, StackTrace.current);
        }
        return null;
      },
      (payment) {
        // Invalidate the payments list to trigger refresh
        if (ref.mounted) {
          ref.invalidate(salePaymentsProvider(saleId));
        }
        return payment;
      },
    );
  }

  /// Deletes a payment.
  Future<bool> deletePayment(String paymentId, String saleId) async {
    final repo = ref.read(paymentRepositoryProvider);
    final result = await repo.delete(paymentId);

    return result.fold(
      (failure) {
        if (ref.mounted) {
          state = AsyncError(failure, StackTrace.current);
        }
        return false;
      },
      (_) {
        // Invalidate the payments list to trigger refresh
        if (ref.mounted) {
          ref.invalidate(salePaymentsProvider(saleId));
        }
        return true;
      },
    );
  }
}
