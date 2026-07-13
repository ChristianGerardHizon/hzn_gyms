import 'package:flutter_test/flutter_test.dart';
import 'package:ebe_gym/src/core/packages/pocketbase/pb_expand.dart';
import 'package:ebe_gym/src/core/utils/receipt_utils.dart';

void main() {
  group('Expand', () {
    test('flat joins paths', () {
      expect(Expand.flat(['branch', 'category']).toString(), 'branch, category');
    });

    test('nested includes root and children', () {
      expect(
        Expand.nested('member', ['branch', 'cards']).toString(),
        'member, member.branch, member.cards',
      );
    });

    test('combine merges expands', () {
      final combined = Expand.combine([
        Expand.flat(['a']),
        Expand.nested('b', ['c']),
      ]);
      expect(combined.toString(), 'a, b, b.c');
    });
  });

  group('PBExpand presets', () {
    test('known presets', () {
      expect(PBExpand.user.toString(), 'branch');
      expect(PBExpand.product.toString(), 'category, branch');
      expect(PBExpand.sale.toString(), 'items, branch');
    });
  });

  group('generateReceiptNumber', () {
    test('matches S-YYMMDD-XXXX format', () {
      final now = DateTime.now();
      final yy = (now.year % 100).toString().padLeft(2, '0');
      final mm = now.month.toString().padLeft(2, '0');
      final dd = now.day.toString().padLeft(2, '0');
      final receipt = generateReceiptNumber();

      expect(receipt, matches(RegExp(r'^S-\d{6}-[A-Z2-9]{4}$')));
      expect(receipt.substring(2, 8), '$yy$mm$dd');
      final suffix = receipt.substring(9);
      expect(suffix.contains('I'), isFalse);
      expect(suffix.contains('O'), isFalse);
      expect(suffix.contains('0'), isFalse);
      expect(suffix.contains('1'), isFalse);
    });
  });
}
