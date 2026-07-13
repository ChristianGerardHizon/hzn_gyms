import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:ebe_gym/src/core/packages/pocketbase/pocketbase_collections.dart';
import 'package:ebe_gym/src/features/products/data/repositories/product_repository.dart';
import 'package:ebe_gym/src/features/products/domain/product.dart';

import '../../../helpers/pb_test_helpers.dart';

void main() {
  late MockPocketBase pb;
  late MockRecordService products;
  late ProductRepositoryImpl repo;

  setUp(() {
    pb = MockPocketBase();
    products = MockRecordService();
    when(() => pb.baseURL).thenReturn('http://pb.test');
    stubCollection(pb, PocketBaseCollections.products, products);
    repo = ProductRepositoryImpl(pb);
  });

  test('fetchAll caches results for same filter/sort', () async {
    var calls = 0;
    when(
      () => products.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((_) async {
      calls++;
      return [buildProductRecord()];
    });

    final first = await repo.fetchAll();
    final second = await repo.fetchAll();
    expect(first.isRight(), isTrue);
    expect(second.isRight(), isTrue);
    expect(calls, 1);

    repo.invalidateCache();
    await repo.fetchAll();
    expect(calls, 2);
  });

  test('fetchOne rejects empty id', () async {
    final result = await repo.fetchOne('');
    expect(result.isLeft(), isTrue);
  });

  test('fetchOne maps product', () async {
    when(
      () => products.getOne(any(), expand: any(named: 'expand')),
    ).thenAnswer((_) async => buildProductRecord(name: 'Shake'));

    final result = await repo.fetchOne('prod-1');
    expect(result.getOrElse((_) => throw StateError('l')).name, 'Shake');
  });

  test('updateQuantity writes quantity body', () async {
    when(
      () => products.update(
        'prod-1',
        body: any(named: 'body'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((invocation) async {
      final body = invocation.namedArguments[#body] as Map<String, dynamic>;
      expect(body['quantity'], 7);
      return buildProductRecord(quantity: 7);
    });

    final result = await repo.updateQuantity('prod-1', 7);
    expect(result.getOrElse((_) => throw StateError('l')).quantity, 7);
  });

  test('delete soft-deletes via isDeleted', () async {
    when(
      () => products.update(any(), body: any(named: 'body')),
    ).thenAnswer((invocation) async {
      final body = invocation.namedArguments[#body] as Map<String, dynamic>;
      expect(body['isDeleted'], isTrue);
      return buildProductRecord(isDeleted: true);
    });

    expect((await repo.delete('prod-1')).isRight(), isTrue);
  });

  test('create invalidates cache', () async {
    when(
      () => products.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((_) async => [buildProductRecord()]);
    when(
      () => products.create(
        body: any(named: 'body'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((_) async => buildProductRecord(id: 'new'));

    await repo.fetchAll();
    await repo.create(const Product(id: '', name: 'X'));

    var calls = 0;
    when(
      () => products.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((_) async {
      calls++;
      return [buildProductRecord()];
    });
    await repo.fetchAll();
    expect(calls, 1);
  });
}
