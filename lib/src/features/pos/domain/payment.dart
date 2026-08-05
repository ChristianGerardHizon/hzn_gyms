import 'package:dart_mappable/dart_mappable.dart';

import 'payment_method.dart';
import 'payment_type.dart';

part 'payment.mapper.dart';

/// Payment domain model.
///
/// Represents a payment transaction against a sale.
@MappableClass()
class Payment with PaymentMappable {
  const Payment({
    required this.id,
    required this.saleId,
    required this.amount,
    required this.paymentMethod,
    required this.type,
    this.paymentRef,
    this.paymentProofUrl,
    this.notes,
    this.idempotencyKey,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// FK to sale record.
  final String saleId;

  /// Payment amount.
  final num amount;

  /// Payment method (cash, card, etc.).
  final PaymentMethod paymentMethod;

  /// Type of payment (payment, deposit, refund).
  final PaymentType type;

  /// External payment reference.
  final String? paymentRef;

  /// URL of the payment proof image.
  final String? paymentProofUrl;

  /// Optional notes.
  final String? notes;

  /// Client-generated key so retries reuse this payment instead of duplicating.
  final String? idempotencyKey;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
