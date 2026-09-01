import 'package:dart_mappable/dart_mappable.dart';

part 'payment_type.mapper.dart';

/// Type of payment transaction.
@MappableEnum()
enum PaymentType {
  payment,
  deposit,
  refund;

  /// Types selectable when recording a payment against a sale.
  /// Excludes [refund], which is not offered in the payment UI.
  static const List<PaymentType> forRecording = [
    PaymentType.payment,
    PaymentType.deposit,
  ];

  String get displayName => switch (this) {
        PaymentType.payment => 'Cash',
        PaymentType.deposit => 'GCash/Bank',
        PaymentType.refund => 'Refund',
      };
}
