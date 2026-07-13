import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';

class MockPocketBase extends Mock implements PocketBase {}

class MockRecordService extends Mock implements RecordService {}

/// Builds a [RecordModel] with common PocketBase metadata fields.
RecordModel buildRecord({
  required String id,
  String collectionId = 'col',
  String collectionName = 'collection',
  Map<String, dynamic>? data,
}) {
  return RecordModel({
    'id': id,
    'collectionId': collectionId,
    'collectionName': collectionName,
    ...?data,
  });
}

RecordModel buildCartRecord({
  String id = 'cart-1',
  String branch = 'branch-1',
  String status = 'active',
  String? user,
  num? totalAmount,
}) {
  return buildRecord(
    id: id,
    collectionName: 'carts',
    data: {
      'branch': branch,
      'status': status,
      if (user != null) 'user': user,
      if (totalAmount != null) 'totalAmount': totalAmount,
    },
  );
}

RecordModel buildCartItemRecord({
  String id = 'ci-1',
  String cart = 'cart-1',
  String product = 'prod-1',
  num quantity = 1,
  num? customPrice,
  String? productLot,
  String? lotNumber,
}) {
  return buildRecord(
    id: id,
    collectionName: 'cartItems',
    data: {
      'cart': cart,
      'product': product,
      'quantity': quantity,
      if (customPrice != null) 'customPrice': customPrice,
      if (productLot != null) 'productLot': productLot,
      if (lotNumber != null) 'lotNumber': lotNumber,
    },
  );
}

RecordModel buildPaymentRecord({
  String id = 'pay-1',
  String sale = 'sale-1',
  num amount = 100,
  String paymentMethod = 'cash',
  String type = 'payment',
}) {
  return buildRecord(
    id: id,
    collectionName: 'payments',
    data: {
      'sale': sale,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'type': type,
    },
  );
}

RecordModel buildSaleRecord({
  String id = 'sale-1',
  String receiptNumber = 'S-250101-ABCD',
  String branch = 'branch-1',
  String cashier = 'user-1',
  num totalAmount = 100,
  String status = 'pending',
  bool isPaid = false,
  String? customerName,
  String? descriptor,
}) {
  return buildRecord(
    id: id,
    collectionName: 'sales',
    data: {
      'receiptNumber': receiptNumber,
      'branch': branch,
      'cashier': cashier,
      'totalAmount': totalAmount,
      'status': status,
      'isPaid': isPaid,
      if (customerName != null) 'customerName': customerName,
      if (descriptor != null) 'descriptor': descriptor,
    },
  );
}

RecordModel buildProductRecord({
  String id = 'prod-1',
  String name = 'Water',
  num price = 50,
  num? quantity = 10,
  bool isDeleted = false,
}) {
  return buildRecord(
    id: id,
    collectionName: 'products',
    data: {
      'name': name,
      'price': price,
      'quantity': quantity,
      'forSale': true,
      'trackStock': true,
      'requireStock': false,
      'trackByLot': false,
      'isDeleted': isDeleted,
    },
  );
}

RecordModel buildMemberRecord({
  String id = 'member-1',
  String name = 'Jane Doe',
  String? branch,
  String? sex,
  String? photo,
}) {
  return buildRecord(
    id: id,
    collectionName: 'members',
    data: {
      'name': name,
      if (branch != null) 'branch': branch,
      if (sex != null) 'sex': sex,
      if (photo != null) 'photo': photo,
    },
  );
}

/// Wires [pb.collection] to return [service] for [name].
void stubCollection(MockPocketBase pb, String name, MockRecordService service) {
  when(() => pb.collection(name)).thenReturn(service);
}
