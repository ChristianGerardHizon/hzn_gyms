import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:hzn_gyms/src/core/packages/pocketbase/pocketbase_collections.dart';
import 'package:hzn_gyms/src/features/organizations/data/repositories/organization_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../helpers/pb_test_helpers.dart';

void main() {
  late MockPocketBase pb;
  late MockRecordService organizations;
  late OrganizationRepositoryImpl repo;

  setUp(() {
    pb = MockPocketBase();
    organizations = MockRecordService();
    when(() => pb.baseURL).thenReturn('http://pb.test');
    stubCollection(pb, PocketBaseCollections.organizations, organizations);
    repo = OrganizationRepositoryImpl(pb);
  });

  test('fetchBySlugOrHostname calls public resolve endpoint', () async {
    when(
      () => pb.send(
        '/api/public/organizations/resolve?host=kyliegym.gyms.hznsystems.com',
      ),
    ).thenAnswer(
      (_) async => {
        'id': 'org-1',
        'name': 'Kylie Gym',
        'slug': 'kyliegym',
        'subdomain': 'kyliegym.gyms.hznsystems.com',
        'seedColor': '#1E88E5',
      },
    );

    final result = await repo.fetchBySlugOrHostname(
      'kyliegym.gyms.hznsystems.com',
    );

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected success'), (org) {
      expect(org.id, 'org-1');
      expect(org.slug, 'kyliegym');
      expect(org.subdomain, 'kyliegym.gyms.hznsystems.com');
    });
  });

  test('completeSetup posts to complete-setup then reloads org', () async {
    when(
      () => pb.send(
        '/api/organizations/org-1/complete-setup',
        method: 'POST',
      ),
    ).thenAnswer((_) async => {});

    when(() => organizations.getOne('org-1')).thenAnswer(
      (_) async => buildRecord(
        id: 'org-1',
        collectionName: PocketBaseCollections.organizations,
        data: {
          'name': 'Kylie Gym',
          'slug': 'kyliegym',
          'setupStatus': 'ready',
          'dnsStatus': 'created',
          'isDeleted': false,
        },
      ),
    );

    final result = await repo.completeSetup('org-1');

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected success'), (org) {
      expect(org.setupStatus.name, 'ready');
    });

    verify(
      () => pb.send(
        '/api/organizations/org-1/complete-setup',
        method: 'POST',
      ),
    ).called(1);
  });

  test('updateLogo uploads logoTransparent file', () async {
    when(
      () => organizations.update(
        'org-1',
        files: any(named: 'files'),
      ),
    ).thenAnswer(
      (_) async => buildRecord(
        id: 'org-1',
        collectionName: PocketBaseCollections.organizations,
        data: {
          'name': 'Kylie Gym',
          'slug': 'kyliegym',
          'logoTransparent': 'logo.png',
          'isDeleted': false,
        },
      ),
    );

    final file = http.MultipartFile.fromString(
      'logoTransparent',
      'png-bytes',
      filename: 'logo.png',
    );

    final result = await repo.updateLogo(
      'org-1',
      logoTransparent: file,
    );

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected success'), (org) {
      expect(org.logoTransparentUrl, contains('logo.png'));
    });
  });

  test('updateLogo clears logoTransparent when requested', () async {
    when(
      () => organizations.update(
        'org-1',
        body: {'logoTransparent': ''},
      ),
    ).thenAnswer(
      (_) async => buildRecord(
        id: 'org-1',
        collectionName: PocketBaseCollections.organizations,
        data: {
          'name': 'Kylie Gym',
          'slug': 'kyliegym',
          'logoTransparent': '',
          'isDeleted': false,
        },
      ),
    );

    final result = await repo.updateLogo(
      'org-1',
      removeLogoTransparent: true,
    );

    expect(result.isRight(), isTrue);
    verify(
      () => organizations.update('org-1', body: {'logoTransparent': ''}),
    ).called(1);
  });
}
