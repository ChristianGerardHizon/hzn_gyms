import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../domain/organization.dart';
import '../../domain/organization_dns_status.dart';

part 'organization_dto.mapper.dart';

/// Data Transfer Object for Organization from PocketBase.
///
/// Handles conversion between PocketBase RecordModel and domain Organization.
@MappableClass()
class OrganizationDto with OrganizationDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String slug;
  final String? displayName;
  final String? seedColor;
  final String logoLight;
  final String logoTransparent;
  final String? splashBackgroundColor;
  final String? subdomain;
  final String? dnsStatus;
  final String? dnsError;
  final String? dnsLastAttempt;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const OrganizationDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    required this.slug,
    this.displayName,
    this.seedColor,
    this.logoLight = '',
    this.logoTransparent = '',
    this.splashBackgroundColor,
    this.subdomain,
    this.dnsStatus,
    this.dnsError,
    this.dnsLastAttempt,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory OrganizationDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return OrganizationDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      displayName: json['displayName'] as String?,
      seedColor: json['seedColor'] as String?,
      logoLight: json['logoLight'] as String? ?? '',
      logoTransparent: json['logoTransparent'] as String? ?? '',
      splashBackgroundColor: json['splashBackgroundColor'] as String?,
      subdomain: json['subdomain'] as String?,
      dnsStatus: json['dnsStatus'] as String?,
      dnsError: json['dnsError'] as String?,
      dnsLastAttempt: json['dnsLastAttempt'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  String? _fileUrl(String domain, String fileName) {
    if (fileName.isEmpty) return null;
    return '$domain/api/files/$collectionName/$id/$fileName';
  }

  /// Converts the DTO to a domain Organization entity.
  ///
  /// [domain] is the PocketBase base URL, used to build absolute file URLs
  /// for the uploaded logo fields (mirrors `AuthDto.toUser`).
  Organization toEntity({required String domain}) {
    return Organization(
      id: id,
      name: name,
      slug: slug,
      displayName: displayName,
      seedColor: seedColor,
      logoLightUrl: _fileUrl(domain, logoLight),
      logoTransparentUrl: _fileUrl(domain, logoTransparent),
      splashBackgroundColor: splashBackgroundColor,
      subdomain: subdomain,
      dnsStatus: OrganizationDnsStatus.fromValue(dnsStatus),
      dnsError: dnsError,
      dnsLastAttempt:
          dnsLastAttempt != null ? DateTime.tryParse(dnsLastAttempt!) : null,
      isDeleted: isDeleted,
      created: created != null ? DateTime.tryParse(created!) : null,
      updated: updated != null ? DateTime.tryParse(updated!) : null,
    );
  }
}
