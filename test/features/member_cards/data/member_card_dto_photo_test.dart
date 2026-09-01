import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:hzn_gyms/src/features/member_cards/data/dto/member_card_dto.dart';

void main() {
  group('MemberCardDto member photo', () {
    test('builds photo URL from expanded member when baseUrl is set', () {
      final record = RecordModel({
        'id': 'card-1',
        'collectionId': 'memberCards',
        'collectionName': 'memberCards',
        'member': 'member-1',
        'cardValue': 'RFID123',
        'status': 'active',
        'expand': {
          'member': {
            'id': 'member-1',
            'collectionId': 'members',
            'collectionName': 'members',
            'name': 'Jane Doe',
            'photo': 'avatar.jpg',
            'updated': '2026-04-01 12:00:00.000Z',
          },
        },
      });

      final card = MemberCardDto.fromRecord(record).toEntity(
        baseUrl: 'https://pb.example',
      );

      expect(card.memberName, 'Jane Doe');
      expect(
        card.memberPhoto,
        'https://pb.example/api/files/members/member-1/avatar.jpg'
        '?t=2026-04-01 12:00:00.000Z',
      );
    });

    test('omits photo when expand has empty photo or no baseUrl', () {
      final record = RecordModel({
        'id': 'card-1',
        'collectionId': 'memberCards',
        'collectionName': 'memberCards',
        'member': 'member-1',
        'cardValue': 'RFID123',
        'status': 'active',
        'expand': {
          'member': {
            'id': 'member-1',
            'collectionId': 'members',
            'collectionName': 'members',
            'name': 'Jane Doe',
            'photo': '',
          },
        },
      });

      final withoutUrl = MemberCardDto.fromRecord(record).toEntity();
      expect(withoutUrl.memberPhoto, isNull);

      final withEmptyPhoto = MemberCardDto.fromRecord(record).toEntity(
        baseUrl: 'https://pb.example',
      );
      expect(withEmptyPhoto.memberPhoto, isNull);
    });
  });
}
