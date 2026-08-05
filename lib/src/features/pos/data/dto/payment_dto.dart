import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/payment.dart';
import '../../domain/payment_method.dart';
import '../../domain/payment_type.dart';

part 'payment_dto.mapper.dart';

@MappableClass()
class PaymentDto with PaymentDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String sale;
  final num amount;
  final String paymentMethod;
  final String type;
  final String? paymentRef;
  final String? paymentProof;
  final String? notes;
  final String? idempotencyKey;
  final String? created;
  final String? updated;

  const PaymentDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.sale,
    required this.amount,
    required this.paymentMethod,
    required this.type,
    this.paymentRef,
    this.paymentProof,
    this.notes,
    this.idempotencyKey,
    this.created,
    this.updated,
  });

  factory PaymentDto.fromRecord(RecordModel record) {
    return PaymentDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      sale: record.getStringValue('sale'),
      amount: record.getDoubleValue('amount'),
      paymentMethod: record.getStringValue('paymentMethod'),
      type: record.getStringValue('type'),
      paymentRef: record.getStringValue('paymentRef'),
      paymentProof: record.getStringValue('paymentProof'),
      notes: record.getStringValue('notes'),
      idempotencyKey: record.getStringValue('idempotencyKey'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  Payment toEntity({String? baseUrl}) {
    return Payment(
      id: id,
      saleId: sale,
      amount: amount,
      paymentMethod: _parsePaymentMethod(paymentMethod),
      type: _parsePaymentType(type),
      paymentRef: paymentRef != null && paymentRef!.isNotEmpty ? paymentRef : null,
      paymentProofUrl: _buildPaymentProofUrl(baseUrl),
      notes: notes != null && notes!.isNotEmpty ? notes : null,
      idempotencyKey:
          idempotencyKey != null && idempotencyKey!.isNotEmpty
              ? idempotencyKey
              : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  PaymentMethod _parsePaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      case 'banktransfer':
        return PaymentMethod.bankTransfer;
      case 'check':
        return PaymentMethod.check;
      default:
        return PaymentMethod.cash;
    }
  }

  PaymentType _parsePaymentType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'payment':
        return PaymentType.payment;
      case 'deposit':
        return PaymentType.deposit;
      case 'refund':
        return PaymentType.refund;
      default:
        return PaymentType.payment;
    }
  }

  String? _buildPaymentProofUrl(String? baseUrl) {
    if (paymentProof == null || paymentProof!.isEmpty || baseUrl == null) {
      return null;
    }
    return '$baseUrl/api/files/$collectionName/$id/$paymentProof';
  }
}
