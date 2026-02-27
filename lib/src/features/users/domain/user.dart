import 'package:dart_mappable/dart_mappable.dart';

part 'user.mapper.dart';

/// User domain model for user management.
///
/// This is the comprehensive User model for the users management feature,
/// separate from the minimal auth User model used for authentication state.
@MappableClass()
class User with UserMappable {
  const User({
    required this.id,
    required this.name,
    required this.username,
    this.avatar,
    this.verified = false,
    this.roleId,
    this.roleName,
    this.branchId,
    this.branchName,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// User's display name.
  final String name;

  /// User's username (used for login).
  final String username;

  /// Avatar URL (full path).
  final String? avatar;

  /// Account verification status.
  final bool verified;

  /// FK to UserRole.
  final String? roleId;

  /// Role name (expanded from FK).
  final String? roleName;

  /// FK to Branch.
  final String? branchId;

  /// Branch name (expanded from FK).
  final String? branchName;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Returns true if user has an avatar.
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  /// Display role name or default text.
  String get displayRole => roleName ?? 'No Role';

  /// Display branch name or default text.
  String get displayBranch => branchName ?? 'No Branch';

  /// Get user initials from name.
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Display account verification status.
  String get verificationStatus => verified ? 'Verified' : 'Unverified';
}
