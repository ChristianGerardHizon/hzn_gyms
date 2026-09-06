import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/organization.dart';
import '../dto/organization_dto.dart';

part 'organization_repository.g.dart';

/// Repository interface for organization operations.
abstract class OrganizationRepository {
  /// Fetches all organizations (super-admin only per PocketBase rules).
  FutureEither<List<Organization>> fetchAll();

  /// Fetches a single organization by ID.
  FutureEither<Organization> fetchOne(String id);

  /// Fetches a single organization by its `slug` or full `subdomain`.
  ///
  /// Used to resolve the current organization from `window.location.hostname`
  /// before the user is authenticated, so this hits an unauthenticated
  /// PocketBase `view` rule scoped to a single known slug/subdomain.
  FutureEither<Organization> fetchBySlugOrHostname(String hostname);

  /// Creates a new organization.
  FutureEither<Organization> create(Organization organization);

  /// Updates an existing organization.
  FutureEither<Organization> update(Organization organization);

  /// Uploads or removes the organization transparent logo (`logoTransparent`).
  FutureEither<Organization> updateLogo(
    String id, {
    http.MultipartFile? logoTransparent,
    bool removeLogoTransparent = false,
  });

  /// Soft deletes an organization by ID.
  FutureEither<void> delete(String id);

  /// Re-triggers Porkbun DNS provisioning for a stuck/failed organization.
  FutureEither<Organization> retryDnsProvisioning(String id);

  /// Validates setup checklist server-side and marks org ready when passed.
  FutureEither<Organization> completeSetup(String id);
}

/// Provides the OrganizationRepository instance.
@Riverpod(keepAlive: true)
OrganizationRepository organizationRepository(Ref ref) {
  return OrganizationRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [OrganizationRepository] using PocketBase.
class OrganizationRepositoryImpl implements OrganizationRepository {
  final PocketBase _pb;

  OrganizationRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.organizations);

  Organization _toEntity(RecordModel record) {
    final dto = OrganizationDto.fromRecord(record);
    return dto.toEntity(domain: _pb.baseURL);
  }

  @override
  FutureEither<List<Organization>> fetchAll() async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilters.active.build();

        final records = await _collection.getFullList(
          filter: filter,
          sort: 'name',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Organization> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }

        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Organization> fetchBySlugOrHostname(String hostname) async {
    return TaskEither.tryCatch(
      () async {
        final trimmed = hostname.trim();
        if (trimmed.isEmpty) {
          throw const DataFailure(
            'Hostname cannot be empty',
            null,
            'invalid_hostname',
          );
        }

        final response = await _pb.send(
          '/api/public/organizations/resolve?host=${Uri.encodeComponent(trimmed)}',
        );

        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid organization resolve response',
            null,
            'invalid_resolve_response',
          );
        }

        return Organization(
          id: response['id'] as String? ?? '',
          name: response['name'] as String? ?? '',
          slug: response['slug'] as String? ?? '',
          displayName: response['displayName'] as String?,
          seedColor: response['seedColor'] as String?,
          logoLightUrl: response['logoLightUrl'] as String?,
          logoTransparentUrl: response['logoTransparentUrl'] as String?,
          splashBackgroundColor: response['splashBackgroundColor'] as String?,
          subdomain: response['subdomain'] as String?,
        );
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Organization> create(Organization organization) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': organization.name,
          'slug': organization.slug,
          'displayName': organization.displayName,
          'seedColor': organization.seedColor,
          'splashBackgroundColor': organization.splashBackgroundColor,
          'isDeleted': false,
        };

        final record = await _collection.create(body: body);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Organization> update(Organization organization) async {
    return TaskEither.tryCatch(
      () async {
        if (organization.id.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }

        final body = <String, dynamic>{
          'name': organization.name,
          'slug': organization.slug,
          'displayName': organization.displayName,
          'seedColor': organization.seedColor,
          'splashBackgroundColor': organization.splashBackgroundColor,
        };

        final record = await _collection.update(organization.id, body: body);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Organization> updateLogo(
    String id, {
    http.MultipartFile? logoTransparent,
    bool removeLogoTransparent = false,
  }) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }

        if (removeLogoTransparent) {
          final record = await _collection.update(
            id,
            body: {'logoTransparent': ''},
          );
          return _toEntity(record);
        }

        if (logoTransparent == null) {
          throw const DataFailure(
            'Logo file is required',
            null,
            'missing_logo_file',
          );
        }

        final record = await _collection.update(
          id,
          files: [logoTransparent],
        );
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }

        // Soft delete
        await _collection.update(id, body: {'isDeleted': true});
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Organization> retryDnsProvisioning(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }

        await _pb.send('/api/organizations/$id/retry-dns', method: 'POST');
        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Organization> completeSetup(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }

        await _pb.send('/api/organizations/$id/complete-setup', method: 'POST');
        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }
}
