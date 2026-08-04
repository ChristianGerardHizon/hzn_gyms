import 'package:ebe_gym/src/core/foundation/failure.dart';
import 'package:ebe_gym/src/features/memberships/domain/member_membership.dart';
import 'package:ebe_gym/src/features/pos/domain/sale_item.dart';
import 'package:ebe_gym/src/features/sales/data/sale_side_effects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockSalesRepository salesRepo;
  late MockMemberMembershipRepository membershipRepo;
  late MockProductLotRepository lotRepo;
  late MockProductRepository productRepo;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(MemberMembershipStatus.voided);
  });

  setUp(() {
    salesRepo = MockSalesRepository();
    membershipRepo = MockMemberMembershipRepository();
    lotRepo = MockProductLotRepository();
    productRepo = MockProductRepository();
  });

  group('voidSaleWithSideEffects', () {
    test('voids sale, voids memberships, and restores lot stock', () async {
      final voided = buildSale(id: 'sale-1', status: 'voided', isPaid: false);
      final items = [
        SaleItem(
          id: 'si-1',
          saleId: 'sale-1',
          productId: 'prod-1',
          productName: 'Protein',
          quantity: 2,
          unitPrice: 100,
          subtotal: 200,
          productLotId: 'lot-1',
          itemType: 'product',
        ),
        SaleItem(
          id: 'si-2',
          saleId: 'sale-1',
          productId: 'plan-1',
          productName: 'Monthly',
          quantity: 1,
          unitPrice: 1500,
          subtotal: 1500,
          itemType: 'membership',
        ),
      ];

      when(
        () => salesRepo.updateSale('sale-1', any()),
      ).thenAnswer((_) async => Right(voided));
      when(
        () => membershipRepo.updateStatusBySaleId(
          'sale-1',
          MemberMembershipStatus.voided,
        ),
      ).thenAnswer((_) async => const Right(null));
      when(() => salesRepo.getSaleItems('sale-1'))
          .thenAnswer((_) async => Right(items));
      when(() => lotRepo.incrementQuantity('lot-1', 2)).thenAnswer(
        (_) async => Right(buildProductLot(id: 'lot-1', quantity: 7)),
      );
      when(() => lotRepo.calculateTotalQuantity('prod-1'))
          .thenAnswer((_) async => const Right(7));
      when(() => productRepo.updateQuantity('prod-1', 7)).thenAnswer(
        (_) async => Right(buildProduct(id: 'prod-1', quantity: 7)),
      );

      final result = await voidSaleWithSideEffects(
        salesRepo: salesRepo,
        memberMembershipRepo: membershipRepo,
        lotRepo: lotRepo,
        productRepo: productRepo,
        saleId: 'sale-1',
        voidedById: 'user-1',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => salesRepo.updateSale(
          'sale-1',
          {'status': 'voided', 'voidedBy': 'user-1'},
        ),
      ).called(1);
      verify(
        () => membershipRepo.updateStatusBySaleId(
          'sale-1',
          MemberMembershipStatus.voided,
        ),
      ).called(1);
      verify(() => lotRepo.incrementQuantity('lot-1', 2)).called(1);
      verify(() => productRepo.updateQuantity('prod-1', 7)).called(1);
    });

    test('returns failure when sale update fails', () async {
      when(() => salesRepo.updateSale('sale-1', any())).thenAnswer(
        (_) async => Left(GenericFailure('boom', StackTrace.current, null)),
      );

      final result = await voidSaleWithSideEffects(
        salesRepo: salesRepo,
        memberMembershipRepo: membershipRepo,
        lotRepo: lotRepo,
        productRepo: productRepo,
        saleId: 'sale-1',
      );

      expect(result.isLeft(), isTrue);
      verifyNever(
        () => membershipRepo.updateStatusBySaleId(any(), any()),
      );
    });
  });

  group('activateMembershipsForPaidSale', () {
    test('activates memberships when sale is paid', () async {
      when(
        () => membershipRepo.updateStatusBySaleId(
          'sale-1',
          MemberMembershipStatus.active,
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await activateMembershipsForPaidSale(
        memberMembershipRepo: membershipRepo,
        saleId: 'sale-1',
        isPaid: true,
        status: 'paid',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => membershipRepo.updateStatusBySaleId(
          'sale-1',
          MemberMembershipStatus.active,
        ),
      ).called(1);
    });

    test('is a no-op when sale is still unpaid', () async {
      final result = await activateMembershipsForPaidSale(
        memberMembershipRepo: membershipRepo,
        saleId: 'sale-1',
        isPaid: false,
        status: 'awaitingPayment',
      );

      expect(result.isRight(), isTrue);
      verifyNever(
        () => membershipRepo.updateStatusBySaleId(any(), any()),
      );
    });
  });
}
