import 'package:drift/native.dart';
import 'package:hzn_gyms/src/core/database/app_database.dart';
import 'package:hzn_gyms/src/core/sync/outbox_service.dart';
import 'package:hzn_gyms/src/features/activity_log/data/repositories/activity_log_repository.dart';
import 'package:hzn_gyms/src/features/check_in/data/repositories/check_in_repository.dart';
import 'package:hzn_gyms/src/features/member_cards/data/repositories/member_card_repository.dart';
import 'package:hzn_gyms/src/features/members/data/local/member_local_data_source.dart';
import 'package:hzn_gyms/src/features/members/data/repositories/member_repository.dart';
import 'package:hzn_gyms/src/features/memberships/data/repositories/member_membership_repository.dart';
import 'package:hzn_gyms/src/features/memberships/data/repositories/membership_repository.dart';
import 'package:hzn_gyms/src/features/pos/data/repositories/cart_repository.dart';
import 'package:hzn_gyms/src/features/pos/data/repositories/payment_repository.dart';
import 'package:hzn_gyms/src/features/pos/data/repositories/sales_repository.dart';
import 'package:hzn_gyms/src/features/products/data/repositories/product_lot_repository.dart';
import 'package:hzn_gyms/src/features/products/data/repositories/product_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckInRepository extends Mock implements CheckInRepository {}

class MockMemberCardRepository extends Mock implements MemberCardRepository {}

class MockMemberRepository extends Mock implements MemberRepository {}

class MockMemberLocalDataSource extends Mock implements MemberLocalDataSource {}

class MockMemberMembershipRepository extends Mock
    implements MemberMembershipRepository {}

class MockMembershipRepository extends Mock implements MembershipRepository {}

class MockSalesRepository extends Mock implements SalesRepository {}

class MockPaymentRepository extends Mock implements PaymentRepository {}

class MockProductLotRepository extends Mock implements ProductLotRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockCartRepository extends Mock implements CartRepository {}

class MockOutboxService extends Mock implements OutboxService {}

class MockActivityLogRepository extends Mock implements ActivityLogRepository {}

/// In-memory Drift database for offline orchestrator tests.
AppDatabase createTestDatabase() => AppDatabase(NativeDatabase.memory());
