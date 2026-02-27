import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/user.dart';

part 'user_dto.mapper.dart';

/// Data Transfer Object for User from PocketBase.
///
/// Handles conversion between PocketBase RecordModel and domain User.
@MappableClass()
class UserDto with UserDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String username;
  final String email;
  final String? avatar;
  final bool verified;
  final String? role;
  final String? branch;
  final bool isDeleted;
  final String? created;
  final String? updated;

  // Expanded fields (populated from expand)
  final String? roleName;
  final String? branchName;

  const UserDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    required this.username,
    required this.email,
    this.avatar,
    this.verified = false,
    this.role,
    this.branch,
    this.isDeleted = false,
    this.created,
    this.updated,
    this.roleName,
    this.branchName,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory UserDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    // Get expanded role name
    final roleExpanded = record.get<String>('expand.role.name');
    final roleName = roleExpanded.isNotEmpty ? roleExpanded : null;

    // Get expanded branch name
    final branchExpanded = record.get<String>('expand.branch.name');
    final branchName = branchExpanded.isNotEmpty ? branchExpanded : null;

    return UserDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      verified: json['verified'] as bool? ?? false,
      role: json['role'] as String?,
      branch: json['branch'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
      roleName: roleName,
      branchName: branchName,
    );
  }

  /// Converts the DTO to a domain User entity.
  User toEntity({String? baseUrl}) {
    return User(
      id: id,
      name: name,
      username: username,
      avatar: _buildAvatarUrl(baseUrl),
      verified: verified,
      roleId: role,
      roleName: roleName,
      branchId: branch,
      branchName: branchName,
      isDeleted: isDeleted,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  String? _buildAvatarUrl(String? baseUrl) {
    if (avatar == null || avatar!.isEmpty || baseUrl == null) return null;
    return '$baseUrl/api/files/$collectionName/$id/$avatar';
  }
}
