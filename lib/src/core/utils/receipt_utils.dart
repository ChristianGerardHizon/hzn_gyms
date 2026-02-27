import 'dart:math';

/// Generates a receipt number in format: S-YYMMDD-XXXX
/// Uses random alphanumeric suffix to avoid race conditions.
String generateReceiptNumber() {
  final now = DateTime.now();
  final year = (now.year % 100).toString().padLeft(2, '0');
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  final datePart = '$year$month$day';

  // Generate random 4-character alphanumeric suffix
  final random = Random();
  const chars =
      'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Excluded I,O,0,1 for clarity
  final suffix =
      List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();

  return 'S-$datePart-$suffix';
}
