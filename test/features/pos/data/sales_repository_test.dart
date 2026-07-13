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
      expect(body['descriptor'], 'WATER');
      return buildSaleRecord(id: 'sale-1', descriptor: body['descriptor'] as String);
    });
    when(
      () => saleItems.create(body: any(named: 'body')),
    ).thenAnswer(
      (_) async => buildRecord(
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
      ),
    );

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
}
