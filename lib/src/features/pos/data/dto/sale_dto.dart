import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/sale.dart';

part 'sale_dto.mapper.dart';

@MappableClass()
class SaleDto with SaleDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String receiptNumber;
  final String branch;
  final String cashier;
  final num totalAmount;
  final String status;
  final bool isPaid;
  final String? customer;
  final String? customerName;
  final String? notes;
  final String? voidedBy;
  final String? created;
  final String? updated;

  const SaleDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.receiptNumber,
    required this.branch,
    required this.cashier,
    required this.totalAmount,
    required this.status,
    this.isPaid = false,
    this.customer,
    this.customerName,
    this.notes,
    this.voidedBy,
    this.created,
    this.updated,
  });

  factory SaleDto.fromRecord(RecordModel record) {
    return SaleDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      receiptNumber: record.getStringValue('receiptNumber'),
      branch: record.getStringValue('branch'),
      cashier: record.getStringValue('cashier'),
      totalAmount: record.getDoubleValue('totalAmount'),
      status: record.getStringValue('status'),
      isPaid: record.getBoolValue('isPaid'),
      customer: record.getStringValue('member'),
      customerName: record.getStringValue('customerName'),
      notes: record.getStringValue('notes'),
      voidedBy: record.getStringValue('voidedBy'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  Sale toEntity() {
    return Sale(
      id: id,
      receiptNumber: receiptNumber,
      branchId: branch,
      cashierId: cashier,
      totalAmount: totalAmount,
      status: status,
      isPaid: isPaid,
      customerId: customer != null && customer!.isNotEmpty ? customer : null,
      customerName: customerName != null && customerName!.isNotEmpty ? customerName : null,
      notes: notes,
      voidedById: voidedBy != null && voidedBy!.isNotEmpty ? voidedBy : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
