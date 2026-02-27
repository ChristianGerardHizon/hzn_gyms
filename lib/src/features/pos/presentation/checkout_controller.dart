import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/foundation/failure.dart';
import '../../../core/utils/receipt_utils.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../settings/presentation/controllers/current_branch_controller.dart';
import '../../products/data/repositories/product_lot_repository.dart';
import '../../products/data/repositories/product_repository.dart';
import '../data/repositories/payment_repository.dart';
import '../data/repositories/sales_repository.dart';
import '../domain/payment_method.dart';
import '../domain/payment_type.dart';
import '../domain/sale.dart';
import '../domain/sale_item.dart';
import 'cart_controller.dart';

part 'checkout_controller.g.dart';

@riverpod
class CheckoutController extends _$CheckoutController {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Processes checkout and creates a sale from the current cart.
  ///
  /// If [payNow] is true, a payment record will be created with the specified
  /// [paymentMethod], [paymentAmount], and [paymentType].
  Future<Either<Failure, Sale>> processCheckout({
    required bool payNow,
    PaymentMethod? paymentMethod,
    num? paymentAmount,
    PaymentType? paymentType,
    String? paymentRef,
    String? notes,
    String? customerId,
    String? customerName,
    http.MultipartFile? paymentProofFile,
  }) async {
    final cartState = ref.read(cartControllerProvider).value;
    if (cartState == null || cartState.isEmpty) {
      return left(const GenericFailure('Cart is empty'));
    }

    final auth = ref.read(currentAuthProvider);
    if (auth == null) {
      return left(const GenericFailure('Not authenticated'));
    }

    final branchId = ref.read(currentBranchIdProvider);
    if (branchId == null) {
      return left(const GenericFailure('No branch selected'));
    }

    // Validate payment parameters if paying now
    if (payNow) {
      if (paymentMethod == null) {
        return left(const GenericFailure('Payment method is required'));
      }
      if (paymentAmount == null || paymentAmount <= 0) {
        return left(const GenericFailure('Payment amount is required'));
      }
      if (paymentType == null) {
        return left(const GenericFailure('Payment type is required'));
      }
    }

    final cashierId = auth.user.id;

    // Generate receipt number: S-YYMMDD-XXXX
    final receiptNumber = generateReceiptNumber();

    // Convert cart items to sale items (including lot info if present)
    final saleItems = cartState.items.map((cartItem) {
      final product = cartItem.product;
      return SaleItem(
        id: '',
        saleId: '',
        productId: cartItem.productId,
        productName: product?.name ?? 'Unknown Product',
        quantity: cartItem.quantity,
        unitPrice: cartItem.effectivePrice,
        subtotal: cartItem.total,
        productLotId: cartItem.productLotId,
        lotNumber: cartItem.lotNumber,
        itemType: 'product',
      );
    }).toList();

    // Determine initial status based on payment
    final String initialStatus;
    if (payNow && paymentAmount != null && paymentAmount >= cartState.total) {
      initialStatus = 'paid';
    } else if (payNow && paymentAmount != null && paymentAmount > 0) {
      initialStatus = 'awaitingPayment';
    } else {
      initialStatus = 'pending';
    }

    // Create the sale
    final sale = Sale(
      id: '', // Will be assigned by backend
      receiptNumber: receiptNumber,
      branchId: branchId,
      cashierId: cashierId,
      totalAmount: cartState.total,
      status: initialStatus,
      isPaid: initialStatus == 'paid',
      customerId: customerId,
      customerName: customerName,
      notes: notes,
    );

    // Get references before async operation to avoid disposed ref issues
    final salesRepo = ref.read(salesRepositoryProvider);
    final paymentRepo = ref.read(paymentRepositoryProvider);
    final cartNotifier = ref.read(cartControllerProvider.notifier);
    final lotRepo = ref.read(productLotRepositoryProvider);
    final productRepo = ref.read(productRepositoryProvider);

    // Save sale to backend
    final result = await salesRepo.createSale(
      sale,
      saleItems,
    );

    return result.fold(
      (failure) => left(failure),
      (createdSale) async {
        // If paying now, create payment record
        if (payNow && paymentMethod != null && paymentAmount != null && paymentType != null) {
          final paymentResult = await paymentRepo.create(
            saleId: createdSale.id,
            amount: paymentAmount,
            paymentMethod: paymentMethod,
            type: paymentType,
            paymentRef: paymentRef,
            paymentProofFile: paymentProofFile,
          );

          // If payment creation fails, we still have the sale, just log the error
          paymentResult.fold(
            (failure) {
              // Payment failed but sale was created
              // Log error but don't fail the whole checkout
            },
            (_) {
              // Payment created successfully
            },
          );
        }

        // Track products that need quantity sync
        final productIdsToSync = <String>{};

        // Decrement lot quantities for lot-tracked items
        for (final item in saleItems) {
          if (item.productLotId != null && item.productLotId!.isNotEmpty) {
            await lotRepo.decrementQuantity(item.productLotId!, item.quantity);
            productIdsToSync.add(item.productId);
          }
        }

        // Sync product quantities with their lot totals
        for (final productId in productIdsToSync) {
          final totalResult = await lotRepo.calculateTotalQuantity(productId);
          await totalResult.fold(
            (failure) async {},
            (total) async {
              await productRepo.updateQuantity(productId, total);
            },
          );
        }

        // Mark cart as converted and clear it
        await cartNotifier.markAsConverted();

        // Re-fetch the sale to get updated isPaid status
        final updatedSaleResult = await salesRepo.getSale(createdSale.id);
        return updatedSaleResult.fold(
          (failure) => right(createdSale), // Return original if re-fetch fails
          (updatedSale) => right(updatedSale),
        );
      },
    );
  }
}
