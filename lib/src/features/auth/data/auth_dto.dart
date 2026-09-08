import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../domain/user.dart';

part 'auth_dto.mapper.dart';

/// Combined DTO for authentication data including token and user info.
///
/// Used for both API responses (login/refresh) and storage persistence.
@MappableClass()
class AuthDto with AuthDtoMappable {
  /// The authentication token.
  final String token;

  /// User fields from PocketBase.
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String email;
  final String avatar;
  final bool verified;
  final String? role;
  final String? branch;
  final List<String> allowedBranches;
  final String? organization;
  final bool superAdmin;

  const AuthDto({
    required this.token,
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    required this.email,
    this.avatar = '',
    this.verified = false,
    this.role,
    this.branch,
    this.allowedBranches = const [],
    this.organization,
    this.superAdmin = false,
  });

  /// Creates an AuthDto from a PocketBase auth result.
  factory AuthDto.fromAuthResult(RecordAuth result) {
    final json = result.record.toJson();
    final allowed = json['allowedBranches'];
    final allowedBranches = allowed is List
        ? allowed.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    return AuthDto(
      token: result.token,
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
      role: json['role'] as String?,
      branch: json['branch'] as String?,
      allowedBranches: allowedBranches,
      organization: json['organization'] as String?,
      superAdmin: json['superAdmin'] as bool? ?? false,
    );
  }

  /// Builds the avatar URL from PocketBase file structure.
  String? _buildAvatarUrl(String domain) {
    if (avatar.isEmpty) return null;
    return '$domain/api/files/$collectionName/$id/$avatar';
  }

  /// Converts to a domain User entity.
  User toUser({required String domain}) {
    return User(
      id: id,
      name: name,
      email: email,
      avatarUrl: _buildAvatarUrl(domain),
      verified: verified,
      branch: branch,
      allowedBranches: allowedBranches,
      roleId: role != null && role!.isNotEmpty ? role : null,
      organization: organization,
      superAdmin: superAdmin,
    );
  }

  /// Creates a RecordModel for restoring PocketBase authStore.
  RecordModel toRecordModel() {
    return RecordModel.fromJson({
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'name': name,
      'email': email,
      'avatar': avatar,
      'verified': verified,
      'role': role,
      'branch': branch,
      'allowedBranches': allowedBranches,
      'organization': organization,
      'superAdmin': superAdmin,
    });
  }
}
