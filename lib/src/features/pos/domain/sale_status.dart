import 'package:dart_mappable/dart_mappable.dart';

part 'sale_status.mapper.dart';

/// Status of a sale transaction.
@MappableEnum()
enum SaleStatus {
  pending,
  awaitingPayment,
  paid,
  completed,
  refunded,
  voided;

  String get displayName => switch (this) {
        SaleStatus.pending => 'Pending',
        SaleStatus.awaitingPayment => 'Awaiting Payment',
        SaleStatus.paid => 'Paid',
        SaleStatus.completed => 'Completed',
        SaleStatus.refunded => 'Refunded',
        SaleStatus.voided => 'Voided',
      };
}
