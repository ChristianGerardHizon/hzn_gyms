import 'package:ebe_gym/src/features/members/domain/member.dart';
import 'package:ebe_gym/src/features/members/domain/member_duplicate_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizePhoneDigits', () {
    test('strips non-digits and PH country / trunk prefixes', () {
      expect(normalizePhoneDigits('+63 917-123-4567'), '9171234567');
      expect(normalizePhoneDigits('0917 123 4567'), '9171234567');
      expect(normalizePhoneDigits('9171234567'), '9171234567');
      expect(normalizePhoneDigits(null), '');
      expect(normalizePhoneDigits('abc'), '');
    });
  });

  group('isDuplicateMemberLookupReady', () {
    test('requires name and enough phone digits', () {
      expect(
        isDuplicateMemberLookupReady(name: 'Jo', phone: '0917123'),
        isTrue,
      );
      expect(
        isDuplicateMemberLookupReady(name: 'J', phone: '09171234567'),
        isFalse,
      );
      expect(
        isDuplicateMemberLookupReady(name: 'Jo', phone: '091712'),
        isFalse,
      );
    });
  });

  group('stringEditDistance', () {
    test('counts substitutions insertions and deletions', () {
      expect(stringEditDistance('kitten', 'sitting'), 3);
      expect(stringEditDistance('juan', 'juann'), 1);
      expect(stringEditDistance('abc', 'abc'), 0);
      expect(stringEditDistance('', 'ab'), 2);
    });
  });

  group('phonesRoughlyMatch', () {
    test('matches exact and suffix variants', () {
      expect(phonesRoughlyMatch('09171234567', '09171234567'), isTrue);
      expect(phonesRoughlyMatch('09171234567', '9171234567'), isTrue);
      expect(phonesRoughlyMatch('+63 917 123 4567', '09171234567'), isTrue);
      expect(phonesRoughlyMatch('09171234567', '09170000000'), isFalse);
      expect(phonesRoughlyMatch('09171', '09171'), isFalse);
    });

    test('allows up to 3 digit typos', () {
      expect(phonesRoughlyMatch('09171234567', '09171234599'), isTrue);
      expect(phonesRoughlyMatch('09171234567', '09171239967'), isTrue);
      expect(phonesRoughlyMatch('09171234567', '09171234999'), isTrue);
      // 4 trailing digit changes — beyond the allowance
      expect(phonesRoughlyMatch('09171234567', '09171239999'), isFalse);
      // 123→000 is exactly 3 edits (still allowed); 12345→00000 is 5
      expect(phonesRoughlyMatch('09171234567', '09170000067'), isFalse);
    });
  });

  group('namesRoughlyMatch', () {
    test('matches exact ignoring case and spacing', () {
      expect(namesRoughlyMatch('Jane Doe', '  jane   doe '), isTrue);
    });

    test('matches first and last when middle differs', () {
      expect(namesRoughlyMatch('Juan Dela Cruz', 'Juan Cruz'), isTrue);
      expect(namesRoughlyMatch('Maria Clara Santos', 'Maria Santos'), isTrue);
    });

    test('allows up to 3 letter typos', () {
      expect(namesRoughlyMatch('Juan Cruz', 'Juann Cruz'), isTrue);
      expect(namesRoughlyMatch('Jane Doe', 'Jame Doe'), isTrue);
      expect(namesRoughlyMatch('Maria Santos', 'Maraia Santos'), isTrue);
      expect(namesRoughlyMatch('Jane Doe', 'John Smith'), isFalse);
    });

    test('rejects unrelated names', () {
      expect(namesRoughlyMatch('Jane Doe', 'John Smith'), isFalse);
      expect(namesRoughlyMatch('Jane', 'Jane Doe'), isFalse);
    });
  });

  group('duplicateMemberSearchQueries', () {
    test('includes name prefix and phone prefix for typo retrieval', () {
      final queries = duplicateMemberSearchQueries(
        name: 'Juan Cruz',
        phone: '09171234567',
      );
      expect(queries, contains('Juan Cruz'));
      expect(queries, contains('Jua'));
      expect(queries, contains('9171234567'));
      expect(queries, contains('9171'));
    });
  });
  group('findLikelyDuplicateMembers', () {
    final candidates = [
      const Member(
        id: '1',
        name: 'Juan Dela Cruz',
        mobileNumber: '09171234567',
      ),
      const Member(
        id: '2',
        name: 'Juan Cruz',
        mobileNumber: '9171234567',
      ),
      const Member(
        id: '3',
        name: 'Other Person',
        mobileNumber: '09171234567',
      ),
      const Member(
        id: '4',
        name: 'Juan Dela Cruz',
        mobileNumber: '09998887777',
      ),
    ];

    test('requires both name and phone to roughly match', () {
      final matches = findLikelyDuplicateMembers(
        enteredName: 'Juan Cruz',
        enteredPhone: '0917-123-4567',
        candidates: candidates,
      );
      expect(matches.map((m) => m.id), unorderedEquals(['1', '2']));
    });

    test('returns empty when only one field matches', () {
      expect(
        findLikelyDuplicateMembers(
          enteredName: 'Juan Cruz',
          enteredPhone: '09990001111',
          candidates: candidates,
        ),
        isEmpty,
      );
      expect(
        findLikelyDuplicateMembers(
          enteredName: 'Someone Else',
          enteredPhone: '09171234567',
          candidates: candidates,
        ),
        isEmpty,
      );
    });

    test('prefers exact name matches when phones normalize equally', () {
      final matches = findLikelyDuplicateMembers(
        enteredName: 'Juan Cruz',
        enteredPhone: '09171234567',
        candidates: candidates,
      );
      expect(matches.first.id, '2');
    });
  });

  group('lookupLikelyDuplicateMembers', () {
    test('returns empty when lookup is not ready', () async {
      final matches = await lookupLikelyDuplicateMembers(
        name: 'J',
        phone: '0917',
        search: (_) async => [
          const Member(id: '1', name: 'Jane', mobileNumber: '09171234567'),
        ],
      );
      expect(matches, isEmpty);
    });

    test('filters search results to rough name+phone matches', () async {
      final matches = await lookupLikelyDuplicateMembers(
        name: 'Juan Cruz',
        phone: '09171234567',
        search: (query) async {
          if (query.contains('Juan') || query.contains('917')) {
            return [
              const Member(
                id: '1',
                name: 'Juan Cruz',
                mobileNumber: '09171234567',
              ),
              const Member(
                id: '2',
                name: 'Other Person',
                mobileNumber: '09171234567',
              ),
            ];
          }
          return const [];
        },
      );
      expect(matches.map((m) => m.id), ['1']);
    });

    test('returns empty and continues when lookup times out', () async {
      final matches = await lookupLikelyDuplicateMembers(
        name: 'Juan Cruz',
        phone: '09171234567',
        timeout: const Duration(milliseconds: 20),
        search: (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return [
            const Member(
              id: '1',
              name: 'Juan Cruz',
              mobileNumber: '09171234567',
            ),
          ];
        },
      );
      expect(matches, isEmpty);
    });
  });

  group('memberFormValuesFromMember', () {
    test('maps profile fields for form pre-fill', () {
      final values = memberFormValuesFromMember(
        const Member(
          id: '1',
          name: 'Jane Doe',
          mobileNumber: '09171234567',
          email: 'jane@example.com',
          address: 'Manila',
        ),
      );
      expect(values['name'], 'Jane Doe');
      expect(values['mobileNumber'], '09171234567');
      expect(values['email'], 'jane@example.com');
      expect(values['address'], 'Manila');
    });
  });
}
