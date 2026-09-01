import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Current on-disk / IndexedDB Drift database name.
const driftDatabaseName = 'hzn_gyms';

/// Pre-rename Drift database name kept for one-time native file migration.
const legacyDriftDatabaseName = 'kylie_gym';

/// Renames `legacyName.sqlite` to `currentName.sqlite` when upgrading installs.
Future<void> migrateLegacyDriftDatabaseFileIfNeeded({
  String legacyName = legacyDriftDatabaseName,
  String currentName = driftDatabaseName,
}) async {
  if (kIsWeb) return;

  final dir = await getApplicationDocumentsDirectory();
  final newFile = File(p.join(dir.path, '$currentName.sqlite'));
  if (newFile.existsSync()) return;

  final legacyFile = File(p.join(dir.path, '$legacyName.sqlite'));
  if (legacyFile.existsSync()) {
    await legacyFile.rename(newFile.path);
  }
}
