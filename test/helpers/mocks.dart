import 'package:drift/native.dart';
import 'package:ebe_gym/src/core/database/app_database.dart';
import 'package:ebe_gym/src/core/sync/outbox_service.dart';
import 'package:ebe_gym/src/features/check_in/data/repositories/check_in_repository.dart';
import 'package:ebe_gym/src/features/member_cards/data/repositories/member_card_repository.dart';
import 'package:ebe_gym/src/features/members/data/local/member_local_data_source.dart';
import 'package:ebe_gym/src/features/members/data/repositories/member_repository.dart';
import 'package:ebe_gym/src/features/memberships/data/repositories/member_membership_repository.dart';
import 'package:ebe_gym/src/features/pos/data/repositories/cart_repository.dart';
import 'package:ebe_gym/src/features/pos/data/repositories/payment_repository.dart';
import 'package:ebe_gym/src/features/pos/data/repositories/sales_repository.dart';
import 'package:ebe_gym/src/features/products/data/repositories/product_lot_repository.dart';
import 'package:ebe_gym/src/features/products/data/repositories/product_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckInRepository extends Mock implements CheckInRepository {}

class MockMemberCardRepository extends Mock implements MemberCardRepository {}

class MockMemberRepository extends Mock implements MemberRepository {}

class MockMemberLocalDataSource extends Mock implements MemberLocalDataSource {}

class MockMemberMembershipRepository extends Mock
    implements MemberMembershipRepository {}

class MockSalesRepository extends Mock implements SalesRepository {}

class MockPaymentRepository extends Mock implements PaymentRepository {}

class MockProductLotRepository extends Mock implements ProductLotRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockCartRepository extends Mock implements CartRepository {}

class MockOutboxService extends Mock implements OutboxService {}

/// In-memory Drift database for offline orchestrator tests.
AppDatabase createTestDatabase() => AppDatabase(NativeDatabase.memory());
