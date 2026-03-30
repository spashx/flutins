// RQ-DAT-001 / RQ-OBJ-001
// Drift table definition for inventory items.

import 'package:drift/drift.dart';

/// Persisted columns for an inventory item -- RQ-OBJ-001.
///
/// @DataClassName('ItemRow') prevents collision with the domain entity Item.
/// Timestamps are stored as milliseconds since epoch (integer) so that
/// the schema has no platform-specific date type dependency.
@DataClassName('ItemRow')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();

  /// Milliseconds since epoch (UTC) -- RQ-OBJ-001: acquisitionDate.
  IntColumn get acquisitionDate => integer()();

  /// Optional serial number (RQ-OBJ-001).
  TextColumn get serialNumber => text().nullable()();

  /// Milliseconds since epoch (UTC).
  IntColumn get createdAt => integer()();

  /// Milliseconds since epoch (UTC).
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
