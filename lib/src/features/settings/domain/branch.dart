import 'package:dart_mappable/dart_mappable.dart';

part 'branch.mapper.dart';

/// Branch domain model.
///
/// Represents a physical branch/location of the business.
@MappableClass()
class Branch with BranchMappable {
  const Branch({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.contactNumber,
    this.operatingHours,
    this.cutOffTime,
    this.color,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Full branch name (e.g. "Bacolod Branch").
  final String name;

  /// Short pill label (max 5 alphanumeric), e.g. "BCD", "TAL".
  final String code;

  /// Branch address.
  final String address;

  /// Branch contact number.
  final String contactNumber;

  /// Operating hours (e.g., "Mon-Sat 8:00 AM - 5:00 PM").
  final String? operatingHours;

  /// Cut-off time for daily operations (e.g., "10:00 PM").
  final String? cutOffTime;

  /// Pill accent preset id (e.g. `teal`, `indigo`). See [BranchColorPreset].
  final String? color;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Compact label for chips/pills — prefer [code], never the full name.
  String get pillLabel {
    final trimmed = code.trim();
    if (trimmed.isNotEmpty) return trimmed.toUpperCase();
    return _fallbackPillLabel(name);
  }
}

/// Display value for optional branch fields on detail screens.
String branchDetailValue(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? '—' : trimmed;
}

/// Fallback when [Branch.code] is missing: strip trailing "Branch" and truncate.
String _fallbackPillLabel(String name) {
  final stripped = name
      .replaceAll(RegExp(r'\s*Branch\s*$', caseSensitive: false), '')
      .trim();
  final alnum = stripped.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
  if (alnum.isEmpty) return '???';
  return alnum.length <= 5 ? alnum : alnum.substring(0, 5);
}
