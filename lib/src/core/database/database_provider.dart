import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';

part 'database_provider.g.dart';

/// Ensures the Drift database is opened and migrated.
@Riverpod(keepAlive: true)
Future<void> appDatabaseReady(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  await db.customSelect('SELECT 1').getSingle();
}

/// Provides a singleton [AppDatabase] instance for the app lifetime.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase.defaults();
  ref.onDispose(db.close);
  return db;
}
