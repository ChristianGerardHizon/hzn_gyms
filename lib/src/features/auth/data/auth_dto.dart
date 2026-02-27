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
  final String username;
  final String email;
  final String avatar;
  final bool verified;
  final String? role;
  final String? branch;

  const AuthDto({
    required this.token,
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    required this.username,
    required this.email,
    this.avatar = '',
    this.verified = false,
    this.role,
    this.branch,
  });

  /// Creates an AuthDto from a PocketBase auth result.
  factory AuthDto.fromAuthResult(RecordAuth result) {
    final json = result.record.toJson();

    return AuthDto(
      token: result.token,
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
      role: json['role'] as String?,
      branch: json['branch'] as String?,
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
      username: username,
      avatarUrl: _buildAvatarUrl(domain),
      verified: verified,
      branch: branch,
    );
  }

  /// Creates a RecordModel for restoring PocketBase authStore.
  RecordModel toRecordModel() {
    return RecordModel.fromJson({
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'name': name,
      'username': username,
      'email': email,
      'avatar': avatar,
      'verified': verified,
      'role': role,
      'branch': branch,
    });
  }
}
