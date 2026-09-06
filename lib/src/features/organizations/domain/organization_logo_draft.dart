import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Pending organization logo changes selected in the form before save.
class OrganizationLogoDraft {
  const OrganizationLogoDraft.upload({
    required this.bytes,
    required this.filename,
  }) : removeExisting = false;

  const OrganizationLogoDraft.remove() : bytes = null, filename = null, removeExisting = true;

  final Uint8List? bytes;
  final String? filename;
  final bool removeExisting;

  bool get hasChanges => removeExisting || bytes != null;
}

/// Builds a PocketBase multipart file for [logoTransparent].
http.MultipartFile? buildOrganizationLogoMultipart(OrganizationLogoDraft? draft) {
  if (draft == null || !draft.hasChanges || draft.removeExisting) {
    return null;
  }
  final bytes = draft.bytes;
  if (bytes == null || bytes.isEmpty) return null;

  return http.MultipartFile.fromBytes(
    'logoTransparent',
    bytes,
    filename: draft.filename?.trim().isNotEmpty == true
        ? draft.filename!.trim()
        : 'logo.png',
  );
}
