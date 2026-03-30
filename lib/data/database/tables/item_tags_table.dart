// RQ-DAT-001 / RQ-OBJ-002
// Many-to-many junction table linking items to tags.

import 'package:drift/drift.dart';

import 'items_table.dart';
import 'tags_table.dart';

/// Junction table for the Item <-> Tag many-to-many relationship -- RQ-OBJ-002.
///
/// Both foreign keys use ON DELETE CASCADE so that:
///  - Deleting an item removes all its tag associations automatically.
///  - Deleting a tag removes it from all items automatically (RQ-TAG-004).
class ItemTags extends Table {
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {itemId, tagId};
}
