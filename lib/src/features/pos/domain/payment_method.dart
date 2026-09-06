import 'package:dart_mappable/dart_mappable.dart';

import 'payment_type.dart';

part 'payment_method.mapper.dart';

/// Payment methods supported by the POS system.
@MappableEnum()
enum PaymentMethod {
  cash,
  card,
  bankTransfer,
  check;

  /// Methods selectable when recording a payment against a sale.
  static const List<PaymentMethod> forRecording = PaymentMethod.values;

  String get displayName => switch (this) {
        PaymentMethod.cash => 'Cash',
        // Stored as `card` in PocketBase; shown as GCash in the PH gym UI.
        PaymentMethod.card => 'GCash',
        PaymentMethod.bankTransfer => 'Bank Transfer',
        PaymentMethod.check => 'Check',
      };

  /// Maps a recorded method to the PocketBase payment [PaymentType].
  ///
  /// Cash is a normal payment; other methods are treated as deposits
  /// (reference / proof optional in the UI).
  PaymentType get recordingPaymentType => switch (this) {
        PaymentMethod.cash => PaymentType.payment,
        PaymentMethod.card ||
        PaymentMethod.bankTransfer ||
        PaymentMethod.check =>
          PaymentType.deposit,
      };

  /// Whether proof-of-payment upload is offered for this method.
  bool get showsPaymentProof => this != PaymentMethod.cash;

  /// Whether a reference number field is offered for this method.
  bool get showsPaymentReference => this != PaymentMethod.cash;
}
