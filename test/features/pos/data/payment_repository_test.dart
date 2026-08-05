import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';
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
    when(() => sales.getOne('sale-1')).thenAnswer(
      (_) async => buildSaleRecord(totalAmount: 100, status: 'pending'),
    );
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
      idempotencyKey: 'pay-key-1',
    );
    expect(result.isRight(), isTrue);

    final createBody = verify(
      () => payments.create(
        body: captureAny(named: 'body'),
        files: any(named: 'files'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(createBody['idempotencyKey'], 'pay-key-1');

    final captured = verify(
      () => sales.update('sale-1', body: captureAny(named: 'body')),
    ).captured.single as Map<String, dynamic>;
    expect(captured['isPaid'], isTrue);
    expect(captured['status'], 'paid');
  });

  test('create on already-paid sale returns existing payment without insert',
      () async {
    when(() => sales.getOne('sale-1')).thenAnswer(
      (_) async => buildSaleRecord(isPaid: true, status: 'paid'),
    );
    when(
      () => payments.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => [buildPaymentRecord(id: 'existing-pay')]);

    final result = await repo.create(
      saleId: 'sale-1',
      amount: 100,
      paymentMethod: PaymentMethod.cash,
      type: PaymentType.payment,
      idempotencyKey: 'retry-key',
    );

    expect(result.isRight(), isTrue);
    final created = result.getOrElse((_) => throw StateError('expected right'));
    expect(created.payment.id, 'existing-pay');
    expect(created.saleIsPaid, isTrue);
    verifyNever(
      () => payments.create(
        body: any(named: 'body'),
        files: any(named: 'files'),
      ),
    );
  });

  test('create on paid sale with no payment rows skips insert', () async {
    when(() => sales.getOne('sale-1')).thenAnswer(
      (_) async => buildSaleRecord(
        isPaid: true,
        status: 'paid',
        totalAmount: 150,
      ),
    );
    when(
      () => payments.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => const []);

    final result = await repo.create(
      saleId: 'sale-1',
      amount: 150,
      paymentMethod: PaymentMethod.cash,
      type: PaymentType.payment,
      idempotencyKey: 'orphan-paid-key',
    );

    expect(result.isRight(), isTrue);
    final created = result.getOrElse((_) => throw StateError('expected right'));
    expect(created.saleIsPaid, isTrue);
    expect(created.payment.saleId, 'sale-1');
    expect(created.payment.amount, 150);
    verifyNever(
      () => payments.create(
        body: any(named: 'body'),
        files: any(named: 'files'),
      ),
    );
  });

  test('create reuses payment when idempotencyKey already exists', () async {
    when(() => sales.getOne('sale-1')).thenAnswer(
      (_) async => buildSaleRecord(totalAmount: 100, status: 'pending'),
    );
    when(
      () => payments.create(
        body: any(named: 'body'),
        files: any(named: 'files'),
      ),
    ).thenThrow(
      ClientException(
        url: Uri.parse('https://pb.test'),
        statusCode: 400,
        response: {
          'data': {
            'idempotencyKey': {
              'code': 'validation_not_unique',
              'message': 'Value must be unique.',
            },
          },
        },
      ),
    );
    when(
      () => payments.getList(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer(
      (_) async => ResultList<RecordModel>(
        items: [buildPaymentRecord(id: 'dup-pay', amount: 100)],
      ),
    );
    stubSalePaidUpdate(
      paymentRecords: [buildPaymentRecord(id: 'dup-pay', amount: 100)],
    );

    final result = await repo.create(
      saleId: 'sale-1',
      amount: 100,
      paymentMethod: PaymentMethod.cash,
      type: PaymentType.payment,
      idempotencyKey: 'dup-key',
    );

    expect(result.isRight(), isTrue);
    expect(
      result.getOrElse((_) => throw StateError('expected right')).payment.id,
      'dup-pay',
    );
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
