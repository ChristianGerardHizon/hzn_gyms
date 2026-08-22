import 'package:kylie_gym/src/features/pos/domain/receipt_print_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('receipt print mode', () {
    test('auto-prints after checkout but not on reprint', () {
      expect(shouldAutoPrintReceipt(isReprint: false), isTrue);
      expect(shouldAutoPrintReceipt(isReprint: true), isFalse);
    });

    test('uses reprint copy for reprint mode', () {
      expect(
        receiptDialogHeadline(isReprint: true),
        'Reprint Receipt',
      );
      expect(
        receiptDialogHeadline(isReprint: false),
        'Sale Complete!',
      );
      expect(receiptDialogTitle(isReprint: true), 'Print Receipt');
      expect(receiptDialogTitle(isReprint: false), 'Receipt');
      expect(receiptDialogDismissLabel(isReprint: true), 'Close');
      expect(receiptDialogDismissLabel(isReprint: false), 'Done');
    });
  });
}
