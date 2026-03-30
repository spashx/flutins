// RQ-DAT-001 / RQ-OBJ-003
// Table for per-item custom key/value properties.
// Keys are scoped to a single item; they are NOT shared across items.

import 'package:drift/drift.dart';

import 'items_table.dart';

/// Per-item custom property (key/value pair) -- RQ-OBJ-003.
///
/// ON DELETE CASCADE ensures properties are removed when their parent item
/// is deleted (RQ-OBJ-010).
class ItemCustomProperties extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();

  /// Arbitrary property name chosen by the user for this specific item.
  TextColumn get key => text()();

  /// Value for this property.
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {id};
}
