// RQ-DAT-001 / RQ-OBJ-002 / RQ-TAG-001
// Drift table definition for reusable tags.

import 'package:drift/drift.dart';

/// Persisted columns for a reusable tag -- RQ-OBJ-002 / RQ-TAG-001.
///
/// @DataClassName('TagRow') prevents collision with the domain entity Tag.
@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}
