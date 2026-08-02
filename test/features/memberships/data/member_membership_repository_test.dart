import 'package:ebe_gym/src/core/packages/pocketbase/pb_filter.dart';
import 'package:ebe_gym/src/core/packages/pocketbase/pocketbase_collections.dart';
import 'package:ebe_gym/src/core/utils/date_utils.dart';
import 'package:ebe_gym/src/features/memberships/data/repositories/member_membership_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../helpers/pb_test_helpers.dart';

RecordModel buildMemberMembershipRecord({
  String id = 'mm-1',
  String member = 'member-1',
  String membership = 'plan-1',
  String status = 'active',
  DateTime? startDate,
  DateTime? endDate,
  String branch = 'branch-1',
  List<String> validBranches = const [],
}) {
  final start = startDate ?? DateTime.now().subtract(const Duration(days: 1));
  final end = endDate ?? DateTime.now().add(const Duration(days: 29));

  final membershipExpand = buildRecord(
    id: membership,
    collectionName: 'memberships',
    data: {
      'name': 'Monthly',
      'validBranches': validBranches,
    },
  );

  return buildRecord(
    id: id,
    collectionName: PocketBaseCollections.memberMemberships,
    data: {
      'member': member,
      'membership': membership,
      'startDate': start.toUtcIso8601(),
      'endDate': end.toUtcIso8601(),
      'status': status,
      'branch': branch,
      'expand': {
        'membership': membershipExpand.toJson(),
      },
    },
  );
}

void main() {
  late MockPocketBase pb;
  late MockRecordService memberMemberships;
  late MemberMembershipRepositoryImpl repo;

  setUp(() {
    pb = MockPocketBase();
    memberMemberships = MockRecordService();
    repo = MemberMembershipRepositoryImpl(pb);
    stubCollection(
      pb,
      PocketBaseCollections.memberMemberships,
      memberMemberships,
    );
  });

  test('fetchActiveByMemberIds returns empty map for empty input', () async {
    final result = await repo.fetchActiveByMemberIds([]);
    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected right'),
      (map) => expect(map, isEmpty),
    );
    verifyNever(
      () => memberMemberships.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        expand: any(named: 'expand'),
      ),
    );
  });

  test('fetchActiveByMemberIds groups records by member', () async {
    when(
      () => memberMemberships.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer(
      (_) async => [
        buildMemberMembershipRecord(
          id: 'mm-1',
          member: 'member-1',
          validBranches: const ['branch-1'],
        ),
        buildMemberMembershipRecord(
          id: 'mm-2',
          member: 'member-2',
          validBranches: const ['branch-2'],
        ),
        buildMemberMembershipRecord(
          id: 'mm-3',
          member: 'member-1',
          membership: 'plan-2',
          validBranches: const ['branch-3'],
        ),
      ],
    );

    final result = await repo.fetchActiveByMemberIds(['member-1', 'member-2']);
    expect(result.isRight(), isTrue);

    result.fold(
      (_) => fail('expected right'),
      (map) {
        expect(map.keys, containsAll(['member-1', 'member-2']));
        expect(map['member-1'], hasLength(2));
        expect(map['member-2'], hasLength(1));
        expect(
          map['member-1']!.first.membershipValidBranches,
          ['branch-1'],
        );
      },
    );

    final captured = verify(
      () => memberMemberships.getFullList(
        filter: captureAny(named: 'filter'),
        sort: '-endDate',
        expand: 'membership',
      ),
    ).captured.single as String?;

    expect(captured, isNotNull);
    expect(captured, contains('member = "member-1"'));
    expect(captured, contains('member = "member-2"'));
    expect(captured, contains("status = 'active'"));
  });

  group('PBFilter.relationAny', () {
    test('builds OR clause for relation IDs', () {
      final filter = PBFilter()
          .relationAny('member', ['a', 'b'])
          .equals('status', 'active')
          .build();

      expect(
        filter,
        "(member = \"a\" || member = \"b\") && status = 'active'",
      );
    });

    test('is no-op for empty ids', () {
      final filter = PBFilter().relationAny('member', []).build();
      expect(filter, isNull);
    });
  });
}
