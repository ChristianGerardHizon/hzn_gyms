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
import '../../domain/sale_payment_status.dart';
import '../dto/payment_dto.dart';

part 'payment_repository.g.dart';

/// Result of [PaymentRepository.create]: the created payment plus the sale's
/// resolved isPaid/status, so callers don't need a separate round trip to
/// re-fetch the sale just to learn what [create] already computed.
typedef PaymentCreateResult = ({
  Payment payment,
  bool saleIsPaid,
  String saleStatus,
});

abstract class PaymentRepository {
  /// Creates a new payment and updates the sale's isPaid status.
  FutureEither<PaymentCreateResult> create({
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
  FutureEither<PaymentCreateResult> create({
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
        final resolved = await _updateSaleIsPaid(saleId);

        return (
          payment: _toEntity(record),
          saleIsPaid: resolved.isPaid,
          saleStatus: resolved.status,
        );
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

    return calculateNetPaidAmount(
      records.map(
        (record) => (
          type: record.getStringValue('type'),
          amount: record.getDoubleValue('amount'),
        ),
      ),
    );
  }

  /// Updates sale.isPaid and status based on total payments vs totalAmount,
  /// returning the resolved values so callers don't need to re-fetch the
  /// sale to learn what was just written.
  Future<({bool isPaid, String status})> _updateSaleIsPaid(
    String saleId,
  ) async {
    final sale = await _sales.getOne(saleId);
    final totalAmount = sale.getDoubleValue('totalAmount');
    final currentStatus = sale.getStringValue('status');
    final totalPaid = await _calculateTotalPaid(saleId);

    final resolved = resolveSalePaymentState(
      totalAmount: totalAmount,
      totalPaid: totalPaid,
      currentStatus: currentStatus,
    );
    final status = resolved.status ?? currentStatus;

    final body = <String, dynamic>{'isPaid': resolved.isPaid};
    if (resolved.status != null) {
      body['status'] = resolved.status;
    }

    await _sales.update(saleId, body: body);

    return (isPaid: resolved.isPaid, status: status);
  }
}
