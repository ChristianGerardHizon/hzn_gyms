import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_logo_draft.dart';

void main() {
  group('OrganizationLogoDraft', () {
    test('buildOrganizationLogoMultipart returns file for upload draft', () {
      final draft = OrganizationLogoDraft.upload(
        bytes: Uint8List.fromList([1, 2, 3]),
        filename: 'gym-logo.png',
      );

      final file = buildOrganizationLogoMultipart(draft);

      expect(file, isNotNull);
      expect(file!.field, 'logoTransparent');
      expect(file.filename, 'gym-logo.png');
    });

    test('buildOrganizationLogoMultipart returns null for remove draft', () {
      expect(
        buildOrganizationLogoMultipart(const OrganizationLogoDraft.remove()),
        isNull,
      );
    });
  });
}
