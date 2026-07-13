import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ebe_gym/src/core/packages/pocketbase/pocketbase_collections.dart';
import 'package:ebe_gym/src/features/pos/data/repositories/payment_repository.dart';
import 'package:ebe_gym/src/features/pos/domain/payment_method.dart';
import 'package:ebe_gym/src/features/pos/domain/payment_type.dart';

import '../../../helpers/pb_test_helpers.dart';

void main() {
  late MockPocketBase pb;
  late MockRecordService payments;
  late MockRecordService sales;
  late PaymentRepositoryImpl repo;

  setUp(() {
    pb = MockPocketBase();
    payments = MockRecordService();
    sales = MockRecordService();
    when(() => pb.baseURL).thenReturn('http://pb.test');
    stubCollection(pb, PocketBaseCollections.payments, payments);
    stubCollection(pb, PocketBaseCollections.sales, sales);
    repo = PaymentRepositoryImpl(pb);
  });

  void stubSalePaidUpdate({
    num totalAmount = 100,
    String status = 'pending',
    List<dynamic> paymentRecords = const [],
  }) {
    when(() => sales.getOne('sale-1')).thenAnswer(
      (_) async => buildSaleRecord(
        totalAmount: totalAmount,
        status: status,
      ),
    );
    when(
      () => payments.getFullList(filter: any(named: 'filter')),
    ).thenAnswer((_) async => List.from(paymentRecords));
    when(
      () => sales.update('sale-1', body: any(named: 'body')),
    ).thenAnswer((_) async => buildSaleRecord());
  }

  test('create payment and mark sale paid when covered', () async {
    when(
      () => payments.create(
        body: any(named: 'body'),
        files: any(named: 'files'),
      ),
    ).thenAnswer(
      (_) async => buildPaymentRecord(amount: 100),
    );
    stubSalePaidUpdate(
      paymentRecords: [buildPaymentRecord(amount: 100)],
    );

    final result = await repo.create(
      saleId: 'sale-1',
      amount: 100,
      paymentMethod: PaymentMethod.cash,
      type: PaymentType.payment,
    );
    expect(result.isRight(), isTrue);

    final captured = verify(
      () => sales.update('sale-1', body: captureAny(named: 'body')),
    ).captured.single as Map<String, dynamic>;
    expect(captured['isPaid'], isTrue);
    expect(captured['status'], 'paid');
  });

  test('getBySaleId maps payments', () async {
    when(
      () => payments.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => [buildPaymentRecord(id: 'p1')]);

    final result = await repo.getBySaleId('sale-1');
    expect(result.getOrElse((_) => []).single.id, 'p1');
  });

  test('getTotalPaidAmount nets refunds', () async {
    when(
      () => payments.getFullList(filter: any(named: 'filter')),
    ).thenAnswer(
      (_) async => [
        buildPaymentRecord(amount: 100, type: 'payment'),
        buildPaymentRecord(id: 'r1', amount: 25, type: 'refund'),
      ],
    );

    final result = await repo.getTotalPaidAmount('sale-1');
    expect(result.getOrElse((_) => -1), 75);
  });

  test('delete recalculates sale payment status', () async {
    when(() => payments.getOne('pay-1')).thenAnswer(
      (_) async => buildPaymentRecord(id: 'pay-1'),
    );
    when(() => payments.delete('pay-1')).thenAnswer((_) async {});
    stubSalePaidUpdate(paymentRecords: const []);

    final result = await repo.delete('pay-1');
    expect(result.isRight(), isTrue);

    final body = verify(
      () => sales.update('sale-1', body: captureAny(named: 'body')),
    ).captured.single as Map<String, dynamic>;
    expect(body['isPaid'], isFalse);
    expect(body['status'], 'pending');
  });
}
