import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/payment.dart';
import '../../domain/payment_method.dart';
import '../../domain/payment_type.dart';
import '../dto/payment_dto.dart';

part 'payment_repository.g.dart';

abstract class PaymentRepository {
  /// Creates a new payment and updates the sale's isPaid status.
  FutureEither<Payment> create({
    required String saleId,
    required num amount,
    required PaymentMethod paymentMethod,
    required PaymentType type,
    String? paymentRef,
    String? notes,
    http.MultipartFile? paymentProofFile,
  });

  /// Gets all payments for a sale.
  FutureEither<List<Payment>> getBySaleId(String saleId);

  /// Deletes a payment and updates the sale's isPaid status.
  FutureEither<void> delete(String id);

  /// Gets the total paid amount for a sale.
  FutureEither<num> getTotalPaidAmount(String saleId);
}

@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepositoryImpl(ref.watch(pocketbaseProvider));
}

class PaymentRepositoryImpl implements PaymentRepository {
  final PocketBase _pb;

  PaymentRepositoryImpl(this._pb);

  RecordService get _payments => _pb.collection(PocketBaseCollections.payments);
  RecordService get _sales => _pb.collection(PocketBaseCollections.sales);

  Payment _toEntity(RecordModel record) {
    return PaymentDto.fromRecord(record).toEntity(baseUrl: _pb.baseURL);
  }

  @override
  FutureEither<Payment> create({
    required String saleId,
    required num amount,
    required PaymentMethod paymentMethod,
    required PaymentType type,
    String? paymentRef,
    String? notes,
    http.MultipartFile? paymentProofFile,
  }) async {
    return TaskEither.tryCatch(
      () async {
        // Create payment record
        final body = {
          'sale': saleId,
          'amount': amount,
          'paymentMethod': paymentMethod.name,
          'type': type.name,
          'paymentRef': paymentRef,
          'notes': notes,
        };

        final record = await _payments.create(
          body: body,
          files: paymentProofFile != null ? [paymentProofFile] : [],
        );

        // Update sale's isPaid status
        await _updateSaleIsPaid(saleId);

        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<Payment>> getBySaleId(String saleId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _payments.getFullList(
          filter: 'sale = "$saleId"',
          sort: '-created',
        );
        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(
      () async {
        // Get payment first to know which sale to update
        final record = await _payments.getOne(id);
        final saleId = record.getStringValue('sale');

        // Delete the payment
        await _payments.delete(id);

        // Update sale's isPaid status
        await _updateSaleIsPaid(saleId);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<num> getTotalPaidAmount(String saleId) async {
    return TaskEither.tryCatch(
      () async {
        return await _calculateTotalPaid(saleId);
      },
      Failure.handle,
    ).run();
  }

  /// Calculates total paid amount for a sale, accounting for refunds.
  Future<num> _calculateTotalPaid(String saleId) async {
    final records = await _payments.getFullList(
      filter: 'sale = "$saleId"',
    );

    num total = 0;
    for (final record in records) {
      final amount = record.getDoubleValue('amount');
      final type = record.getStringValue('type').toLowerCase();
      if (type == 'refund') {
        total -= amount;
      } else {
        total += amount;
      }
    }
    return total;
  }

  /// Updates sale.isPaid and status based on total payments vs totalAmount.
  Future<void> _updateSaleIsPaid(String saleId) async {
    // Get sale to know total amount and current status
    final sale = await _sales.getOne(saleId);
    final totalAmount = sale.getDoubleValue('totalAmount');
    final currentStatus = sale.getStringValue('status');

    // Calculate total paid
    final totalPaid = await _calculateTotalPaid(saleId);

    // Update isPaid
    final isPaid = totalPaid >= totalAmount;
    final body = <String, dynamic>{'isPaid': isPaid};

    // Auto-update status based on payment state
    // Only update if not already refunded or voided
    if (currentStatus != 'refunded' && currentStatus != 'voided') {
      if (isPaid) {
        body['status'] = 'paid';
      } else if (totalPaid > 0) {
        body['status'] = 'awaitingPayment';
      } else {
        body['status'] = 'pending';
      }
    }

    await _sales.update(saleId, body: body);
  }
}
