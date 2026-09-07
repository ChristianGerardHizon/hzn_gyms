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
  final String email;
  final String? avatar;
  final bool verified;
  final String? role;
  final String? branch;
  final String? organization;
  final List<String> allowedBranches;
  final bool isDeleted;
  final String? created;
  final String? updated;

  // Expanded fields (populated from expand)
  final String? roleName;
  final String? branchName;
  final List<String> allowedBranchNames;

  const UserDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    required this.email,
    this.avatar,
    this.verified = false,
    this.role,
    this.branch,
    this.organization,
    this.allowedBranches = const [],
    this.isDeleted = false,
    this.created,
    this.updated,
    this.roleName,
    this.branchName,
    this.allowedBranchNames = const [],
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

    final allowedBranches = _parseIdList(json['allowedBranches']);
    final allowedBranchNames = _parseExpandedNames(record, json['expand']);

    return UserDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      verified: json['verified'] as bool? ?? false,
      role: json['role'] as String?,
      branch: json['branch'] as String?,
      organization: json['organization'] as String?,
      allowedBranches: allowedBranches,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
      roleName: roleName,
      branchName: branchName,
      allowedBranchNames: allowedBranchNames,
    );
  }

  static List<String> _parseIdList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  static List<String> _parseExpandedNames(RecordModel record, dynamic expand) {
    // Prefer typed multi-relation expand (List<RecordModel>)
    final expanded = record.getListValue<RecordModel>(
      'expand.allowedBranches',
      const [],
    );
    if (expanded.isNotEmpty) {
      return expanded
          .map((item) => item.getStringValue('name'))
          .where((name) => name.isNotEmpty)
          .toList();
    }

    if (expand is! Map) return const [];
    final allowed = expand['allowedBranches'];
    if (allowed is! List) return const [];
    return allowed
        .map((item) {
          if (item is Map) return item['name']?.toString() ?? '';
          return '';
        })
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// Converts the DTO to a domain User entity.
  User toEntity({String? baseUrl}) {
    return User(
      id: id,
      name: name,
      email: email.isNotEmpty ? email : null,
      avatar: _buildAvatarUrl(baseUrl),
      verified: verified,
      roleId: role,
      roleName: roleName,
      branchId: branch,
      branchName: branchName,
      organizationId: organization,
      allowedBranchIds: allowedBranches,
      allowedBranchNames: allowedBranchNames,
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
