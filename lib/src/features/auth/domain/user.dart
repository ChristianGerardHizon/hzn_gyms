import 'package:dart_mappable/dart_mappable.dart';

part 'user.mapper.dart';

/// User model representing an authenticated user.
///
/// Contains only essential user profile information for the auth domain.
/// Branch and other related data belong in their respective features.
/// Role permissions are managed by the user_roles feature.
@MappableClass()
class User with UserMappable {
  /// The user's unique ID.
  final String id;

  /// The user's display name.
  final String name;

  /// The user's username (used for login).
  final String username;

  /// The user's avatar URL (pre-computed).
  final String? avatarUrl;

  /// Whether the user's account has been verified.
  final bool verified;

  /// The user's default/home branch ID (if assigned).
  final String? branch;

  /// Branch IDs the user may switch to.
  final List<String> allowedBranches;

  /// FK to UserRole (PocketBase `role` relation id).
  final String? roleId;

  const User({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.verified = false,
    this.branch,
    this.allowedBranches = const [],
    this.roleId,
  });
}
