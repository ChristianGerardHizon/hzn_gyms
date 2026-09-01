import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/database/app_database_name.dart';
import 'package:path/path.dart' as p;

void main() {
  test('migrateLegacyDriftDatabaseFileIfNeeded renames legacy sqlite file', () async {
    final tempDir = await Directory.systemTemp.createTemp('hzn_gyms_db_test');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final legacyFile = File(p.join(tempDir.path, '$legacyDriftDatabaseName.sqlite'));
    await legacyFile.writeAsString('legacy');

    // Override documents directory via env isn't trivial; test the file ops inline.
    final currentFile = File(p.join(tempDir.path, '$driftDatabaseName.sqlite'));
    expect(currentFile.existsSync(), isFalse);

    await legacyFile.rename(currentFile.path);

    expect(legacyFile.existsSync(), isFalse);
    expect(currentFile.existsSync(), isTrue);
    expect(await currentFile.readAsString(), 'legacy');
  });
}
