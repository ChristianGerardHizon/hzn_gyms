import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:ebe_gym/src/core/packages/pocketbase/pocketbase_collections.dart';
import 'package:ebe_gym/src/features/pos/data/repositories/sales_repository.dart';
import 'package:ebe_gym/src/features/pos/domain/sale.dart';
import 'package:ebe_gym/src/features/pos/domain/sale_item.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pb_test_helpers.dart';

void main() {
  late MockPocketBase pb;
  late MockRecordService sales;
  late MockRecordService saleItems;
  late SalesRepositoryImpl repo;

  setUp(() {
    pb = MockPocketBase();
    sales = MockRecordService();
    saleItems = MockRecordService();
    when(() => pb.baseURL).thenReturn('http://pb.test');
    stubCollection(pb, PocketBaseCollections.sales, sales);
    stubCollection(pb, PocketBaseCollections.saleItems, saleItems);
    repo = SalesRepositoryImpl(pb);
  });

  test('createSale auto-builds descriptor and creates items', () async {
    when(
      () => sales.create(body: any(named: 'body')),
    ).thenAnswer((invocation) async {
      final body = invocation.namedArguments[#body] as Map<String, dynamic>;
      expect(body['descriptor'], 'Walk-in · WATER');
      expect(body['customerName'], Sale.walkInLabel);
      expect(body.containsKey('member'), isFalse);
      return buildSaleRecord(id: 'sale-1', descriptor: body['descriptor'] as String);
    });
    when(
      () => saleItems.getFullList(filter: any(named: 'filter')),
    ).thenAnswer((_) async => const []);
    when(
      () => saleItems.create(body: any(named: 'body')),
    ).thenAnswer((invocation) async {
      final body = invocation.namedArguments[#body] as Map<String, dynamic>;
      expect(body['product'], 'prod-1');
      return buildRecord(
        id: 'si-1',
        collectionName: 'saleItems',
        data: {
          'sale': 'sale-1',
          'product': 'prod-1',
          'productName': 'WATER',
          'quantity': 1,
          'unitPrice': 50,
          'subtotal': 50,
          'itemType': 'product',
        },
      );
    });

    final result = await repo.createSale(
      buildSale(id: ''),
      [
        const SaleItem(
          id: '',
          saleId: '',
          productId: 'prod-1',
          productName: 'WATER',
          quantity: 1,
          unitPrice: 50,
          subtotal: 50,
          itemType: 'product',
        ),
      ],
    );
    expect(result.isRight(), isTrue);
    verify(() => saleItems.create(body: any(named: 'body'))).called(1);
  });

  test('createSale reuses sale when idempotencyKey already exists', () async {
    when(
      () => sales.create(body: any(named: 'body')),
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
      () => sales.getList(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer(
      (_) async => ResultList<RecordModel>(
        items: [
          buildSaleRecord(id: 'existing-sale', descriptor: 'WATER'),
        ],
      ),
    );
    when(
      () => saleItems.getFullList(filter: any(named: 'filter')),
    ).thenAnswer(
      (_) async => [
        buildRecord(
          id: 'si-existing',
          collectionName: 'saleItems',
          data: {
            'sale': 'existing-sale',
            'product': 'prod-1',
            'productName': 'WATER',
            'quantity': 1,
            'unitPrice': 50,
            'subtotal': 50,
            'itemType': 'product',
          },
        ),
      ],
    );

    final result = await repo.createSale(
      buildSale(id: '', idempotencyKey: 'sale-key-1'),
      [
        const SaleItem(
          id: '',
          saleId: '',
          productId: 'prod-1',
          productName: 'WATER',
          quantity: 1,
          unitPrice: 50,
          subtotal: 50,
          itemType: 'product',
        ),
      ],
    );

    expect(result.isRight(), isTrue);
    expect(
      result.getOrElse((_) => throw StateError('expected right')).id,
      'existing-sale',
    );
    verifyNever(() => saleItems.create(body: any(named: 'body')));
  });

  test('createSale fills missing line items on idempotent retry', () async {
    when(
      () => sales.create(body: any(named: 'body')),
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
      () => sales.getList(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer(
      (_) async => ResultList<RecordModel>(
        items: [
          buildSaleRecord(id: 'existing-sale', descriptor: 'WATER'),
        ],
      ),
    );
    when(
      () => saleItems.getFullList(filter: any(named: 'filter')),
    ).thenAnswer((_) async => const []);
    when(
      () => saleItems.create(body: any(named: 'body')),
    ).thenAnswer((invocation) async {
      final body = invocation.namedArguments[#body] as Map<String, dynamic>;
      expect(body['sale'], 'existing-sale');
      expect(body['productName'], 'WATER');
      return buildRecord(
        id: 'si-1',
        collectionName: 'saleItems',
        data: body,
      );
    });

    final result = await repo.createSale(
      buildSale(id: '', idempotencyKey: 'sale-key-incomplete'),
      [
        const SaleItem(
          id: '',
          saleId: '',
          productId: 'prod-1',
          productName: 'WATER',
          quantity: 1,
          unitPrice: 50,
          subtotal: 50,
          itemType: 'product',
        ),
      ],
    );

    expect(result.isRight(), isTrue);
    expect(
      result.getOrElse((_) => throw StateError('expected right')).id,
      'existing-sale',
    );
    verify(() => saleItems.create(body: any(named: 'body'))).called(1);
  });

  test('createSale omits empty product for membership walk-in items', () async {
    when(
      () => sales.create(body: any(named: 'body')),
    ).thenAnswer((invocation) async {
      final body = invocation.namedArguments[#body] as Map<String, dynamic>;
      expect(body['descriptor'], 'Walk-in · Jane · Day Pass');
      expect(body['customerName'], 'Jane');
      expect(body.containsKey('member'), isFalse);
      return buildSaleRecord(
        id: 'sale-2',
        descriptor: body['descriptor'] as String,
        customerName: 'Jane',
      );
    });
    when(
      () => saleItems.getFullList(filter: any(named: 'filter')),
    ).thenAnswer((_) async => const []);
    when(
      () => saleItems.create(body: any(named: 'body')),
    ).thenAnswer((invocation) async {
      final body = invocation.namedArguments[#body] as Map<String, dynamic>;
      expect(body.containsKey('product'), isFalse);
      expect(body['itemType'], 'membership');
      return buildRecord(
        id: 'si-2',
        collectionName: 'saleItems',
        data: body,
      );
    });

    final result = await repo.createSale(
      buildSale(id: '', customerName: 'Jane'),
      [
        const SaleItem(
          id: '',
          saleId: '',
          productId: '',
          productName: 'Day Pass',
          quantity: 1,
          unitPrice: 100,
          subtotal: 100,
          itemType: 'membership',
        ),
      ],
    );
    expect(result.isRight(), isTrue);
  });

  test('searchPaginated treats walk-in queries as no-member sales', () async {
    when(
      () => sales.getList(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        fields: any(named: 'fields'),
      ),
    ).thenAnswer((invocation) async {
      final filter = invocation.namedArguments[#filter] as String;
      expect(filter.contains('Walk-in'), isTrue);
      expect(filter.contains('member = null'), isTrue);
      return ResultList<RecordModel>(
        page: 1,
        perPage: 20,
        totalItems: 1,
        totalPages: 1,
        items: [buildSaleRecord(customerName: 'Walk-in')],
      );
    });

    final result = await repo.searchPaginated('walk-in');
    expect(result.isRight(), isTrue);
    expect(
      result.getOrElse((_) => throw StateError('l')).items.single.customerDisplay,
      'Walk-in',
    );
  });

  test('getSale and updateSaleStatus', () async {
    when(() => sales.getOne('sale-1')).thenAnswer(
      (_) async => buildSaleRecord(status: 'pending'),
    );
    when(
      () => sales.update('sale-1', body: any(named: 'body')),
    ).thenAnswer((invocation) async {
      final body = invocation.namedArguments[#body] as Map<String, dynamic>;
      expect(body['status'], 'voided');
      return buildSaleRecord(status: 'voided');
    });

    expect(
      (await repo.getSale('sale-1')).getOrElse((_) => throw StateError('l')).id,
      'sale-1',
    );
    final updated = await repo.updateSaleStatus('sale-1', 'voided');
    expect(updated.getOrElse((_) => throw StateError('l')).status, 'voided');
  });

  test('getSales applies branch filter', () async {
    when(
      () => sales.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        fields: any(named: 'fields'),
      ),
    ).thenAnswer((invocation) async {
      expect(
        (invocation.namedArguments[#filter] as String).contains('branch'),
        isTrue,
      );
      return [buildSaleRecord()];
    });

    final result = await repo.getSales(branchId: 'branch-1');
    expect(result.getOrElse((_) => []).single.id, 'sale-1');
  });

  test('getSales with limit uses getList instead of getFullList', () async {
    when(
      () => sales.getList(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        fields: any(named: 'fields'),
      ),
    ).thenAnswer((invocation) async {
      expect(invocation.namedArguments[#page], 1);
      expect(invocation.namedArguments[#perPage], 50);
      expect(
        (invocation.namedArguments[#filter] as String).contains('branch'),
        isTrue,
      );
      return ResultList<RecordModel>(
        page: 1,
        perPage: 50,
        totalItems: 1,
        totalPages: 1,
        items: [buildSaleRecord()],
      );
    });

    final result = await repo.getSales(branchId: 'branch-1', limit: 50);
    expect(result.getOrElse((_) => []).single.id, 'sale-1');
    verifyNever(
      () => sales.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        fields: any(named: 'fields'),
      ),
    );
  });

  test('getSales applies statuses filter for completed and paid', () async {
    when(
      () => sales.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        fields: any(named: 'fields'),
      ),
    ).thenAnswer((invocation) async {
      final filter = invocation.namedArguments[#filter] as String;
      expect(filter, contains('status = "completed"'));
      expect(filter, contains('status = "paid"'));
      expect(filter, contains(' || '));
      return [buildSaleRecord()];
    });

    final result = await repo.getSales(
      branchId: 'branch-1',
      statuses: const ['completed', 'paid'],
    );
    expect(result.getOrElse((_) => []).single.id, 'sale-1');
  });

  test('getSaleItems expands product', () async {
    when(
      () => saleItems.getFullList(
        filter: any(named: 'filter'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((invocation) async {
      expect(invocation.namedArguments[#expand], 'product');
      return [
        buildRecord(
          id: 'si-1',
          collectionName: 'saleItems',
          data: {
            'sale': 'sale-1',
            'product': 'p1',
            'productName': 'WATER',
            'quantity': 1,
            'unitPrice': 10,
            'subtotal': 10,
          },
        ),
      ];
    });

    final result = await repo.getSaleItems('sale-1');
    expect(result.getOrElse((_) => []).single.productName, 'WATER');
  });

  test('getSaleItemsByProduct filters by product and expands sale', () async {
    final saleRecord = buildSaleRecord(
      id: 'sale-9',
      receiptNumber: 'S-250802-XYZ',
      status: 'completed',
      isPaid: true,
      customerName: 'Juan',
    );

    when(
      () => saleItems.getList(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((invocation) async {
      expect(invocation.namedArguments[#page], 1);
      expect(invocation.namedArguments[#perPage], 50);
      expect(invocation.namedArguments[#filter], 'product = "prod-1"');
      expect(invocation.namedArguments[#sort], '-created');
      expect(invocation.namedArguments[#expand], 'sale');
      return ResultList<RecordModel>(
        page: 1,
        perPage: 50,
        totalItems: 1,
        totalPages: 1,
        items: [
          buildRecord(
            id: 'si-9',
            collectionName: 'saleItems',
            data: {
              'sale': 'sale-9',
              'product': 'prod-1',
              'productName': 'WATER',
              'quantity': 2,
              'unitPrice': 25,
              'subtotal': 50,
              'lotNumber': 'LOT-A',
              'created': '2025-08-02 10:00:00.000Z',
              'expand': {
                'sale': saleRecord.toJson(),
              },
            },
          ),
        ],
      );
    });

    final result = await repo.getSaleItemsByProduct('prod-1');
    final line = result.getOrElse((_) => throw StateError('expected right')).single;
    expect(line.saleItemId, 'si-9');
    expect(line.saleId, 'sale-9');
    expect(line.receiptNumber, 'S-250802-XYZ');
    expect(line.quantity, 2);
    expect(line.unitPrice, 25);
    expect(line.subtotal, 50);
    expect(line.isPaid, isTrue);
    expect(line.status, 'completed');
    expect(line.customerName, 'Juan');
    expect(line.lotNumber, 'LOT-A');
  });

  test('getSaleItemsByProduct respects custom limit', () async {
    when(
      () => saleItems.getList(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((invocation) async {
      expect(invocation.namedArguments[#perPage], 10);
      return ResultList<RecordModel>(
        page: 1,
        perPage: 10,
        totalItems: 0,
        totalPages: 0,
        items: const [],
      );
    });

    final result = await repo.getSaleItemsByProduct('prod-1', limit: 10);
    expect(result.isRight(), isTrue);
    expect(result.getOrElse((_) => throw StateError('l')), isEmpty);
  });
}
