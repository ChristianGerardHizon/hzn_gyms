import 'package:drift/native.dart';
import 'package:kylie_gym/src/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  test(
    'v7 -> v8 migration renames duration_days to duration_value and '
    'adds duration_unit',
    () async {
      final raw = sqlite3.sqlite3.openInMemory();
      raw.execute('''
        CREATE TABLE membership_plans (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NULL,
          duration_days INTEGER NOT NULL,
          price REAL NOT NULL,
          branch_id TEXT NOT NULL,
          valid_branches_json TEXT NOT NULL DEFAULT '[]',
          is_active INTEGER NOT NULL DEFAULT 1,
          is_favorite INTEGER NOT NULL DEFAULT 0,
          member_not_required INTEGER NOT NULL DEFAULT 0,
          synced_at INTEGER NOT NULL
        )
      ''');
      raw.execute('''
        INSERT INTO membership_plans
          (id, name, description, duration_days, price, branch_id, synced_at)
        VALUES
          ('plan-1', 'Monthly', NULL, 30, 1000.0, 'branch-1', 0)
      ''');
      raw.userVersion = 7;

      final db = AppDatabase(NativeDatabase.opened(raw));
      addTearDown(db.close);

      final rows = await db
          .customSelect('SELECT * FROM membership_plans')
          .get();

      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row.data.containsKey('duration_days'), isFalse);
      expect(row.read<int>('duration_value'), 30);
      expect(row.read<String>('duration_unit'), 'days');
      expect(row.read<String>('id'), 'plan-1');
      expect(row.read<String>('name'), 'Monthly');
    },
  );

  test('migrating an already-migrated (v8) database is a no-op', () async {
    final raw = sqlite3.sqlite3.openInMemory();
    raw.execute('''
      CREATE TABLE membership_plans (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NULL,
        duration_value INTEGER NOT NULL,
        duration_unit TEXT NOT NULL DEFAULT 'days',
        price REAL NOT NULL,
        branch_id TEXT NOT NULL,
        valid_branches_json TEXT NOT NULL DEFAULT '[]',
        is_active INTEGER NOT NULL DEFAULT 1,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        member_not_required INTEGER NOT NULL DEFAULT 0,
        synced_at INTEGER NOT NULL
      )
    ''');
    raw.execute('''
      INSERT INTO membership_plans
        (id, name, description, duration_value, duration_unit, price, branch_id, synced_at)
      VALUES
        ('plan-1', 'Annual', NULL, 1, 'years', 500.0, 'branch-1', 0)
    ''');
    raw.userVersion = 7;

    final db = AppDatabase(NativeDatabase.opened(raw));
    addTearDown(db.close);

    final rows = await db.customSelect('SELECT * FROM membership_plans').get();

    expect(rows, hasLength(1));
    final row = rows.single;
    expect(row.read<int>('duration_value'), 1);
    expect(row.read<String>('duration_unit'), 'years');
  });
}
