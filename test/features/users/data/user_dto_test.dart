import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:hzn_gyms/src/features/users/data/dto/user_dto.dart';

void main() {
  group('UserDto.fromRecord', () {
    test('parses superAdmin and expanded organization name', () {
      final record = RecordModel({
        'id': 'user-1',
        'collectionId': 'users_col',
        'collectionName': 'users',
        'name': 'Pat',
        'email': 'pat@example.com',
        'superAdmin': true,
        'organization': 'org-1',
        'role': 'role-1',
        'branch': 'branch-1',
        'allowedBranches': <String>[],
        'isDeleted': false,
        'expand': {
          'organization': {
            'id': 'org-1',
            'name': 'Horizon Gym',
          },
          'role': {
            'id': 'role-1',
            'name': 'Staff',
          },
          'branch': {
            'id': 'branch-1',
            'name': 'Main',
          },
        },
      });

      final dto = UserDto.fromRecord(record);
      final user = dto.toEntity();

      expect(dto.superAdmin, isTrue);
      expect(dto.organizationName, 'Horizon Gym');
      expect(user.superAdmin, isTrue);
      expect(user.organizationName, 'Horizon Gym');
      expect(user.displayOrganization, 'Horizon Gym');
    });

    test('defaults superAdmin to false when missing', () {
      final record = RecordModel({
        'id': 'user-2',
        'collectionId': 'users_col',
        'collectionName': 'users',
        'name': 'Sam',
        'email': 'sam@example.com',
      });

      final dto = UserDto.fromRecord(record);
      expect(dto.superAdmin, isFalse);
      expect(dto.toEntity().superAdmin, isFalse);
      expect(dto.toEntity().displayOrganization, 'No Organization');
    });
  });
}
