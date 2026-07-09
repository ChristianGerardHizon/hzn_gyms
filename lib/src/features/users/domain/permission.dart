import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'permission.mapper.dart';

/// Permission domain model with rich metadata.
///
/// This is a local-only entity (not stored in PocketBase) that provides
/// display names, descriptions, and categories for UI rendering.
/// Permission keys are stored as JSON arrays in the UserRole collection.
@MappableClass()
class Permission with PermissionMappable {
  const Permission({
    required this.key,
    required this.name,
    required this.category,
    this.description,
    this.icon,
  });

  /// The permission key (e.g., "members.view").
  /// This is what gets stored in PocketBase.
  final String key;

  /// Display name (e.g., "View Members").
  final String name;

  /// Category for grouping (e.g., "Members", "Users").
  final String category;

  /// Optional description explaining what this permission grants.
  final String? description;

  /// Optional icon for UI display.
  @MappableField(hook: IconDataHook())
  final IconData? icon;

  /// Unique identifier (same as key for consistency).
  String get id => key;

  /// Gets the action part of the permission key (e.g., "view" from "members.view").
  String get action {
    final parts = key.split('.');
    return parts.length > 1 ? parts[1] : key;
  }

  /// Gets the resource part of the permission key (e.g., "members" from "members.view").
  String get resource {
    final parts = key.split('.');
    return parts.isNotEmpty ? parts[0] : key;
  }
}

/// Hook to handle IconData serialization (icons are not serialized).
class IconDataHook extends MappingHook {
  const IconDataHook();

  @override
  Object? beforeDecode(Object? value) => null;

  @override
  Object? beforeEncode(Object? value) => null;
}
