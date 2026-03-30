// RQ-OBJ-001 / RQ-OBJ-002 / RQ-OBJ-003 / D-16
// Drift DAO for item rows, tag associations, and custom properties.
// Scoped to the Items, ItemTags and ItemCustomProperties tables only (D-16).

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/item_custom_properties_table.dart';
import '../tables/item_tags_table.dart';
import '../tables/items_table.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items, ItemTags, ItemCustomProperties])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(super.db);

  // ---------------------------------------------------------------------------
  // Item rows
  // ---------------------------------------------------------------------------

  /// Emits the full item row list whenever the items table changes.
  Stream<List<ItemRow>> watchItemRows() => select(items).watch();

  /// Returns the item row with [id], or null when not found.
  Future<ItemRow?> getItemRowById(String id) =>
      (select(items)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Inserts or replaces [companion] in the items table.
  Future<void> upsertItem(ItemsCompanion companion) =>
      into(items).insertOnConflictUpdate(companion);

  /// Permanently deletes all item rows whose ids appear in [ids].
  Future<void> deleteItemsByIds(List<String> ids) =>
      (delete(items)..where((t) => t.id.isIn(ids))).go();

  // ---------------------------------------------------------------------------
  // Custom properties (RQ-OBJ-003)
  // ---------------------------------------------------------------------------

  /// Returns all custom properties belonging to the item with [itemId].
  Future<List<ItemCustomProperty>> getPropertiesForItem(String itemId) =>
      (select(itemCustomProperties)
            ..where((t) => t.itemId.equals(itemId)))
          .get();

  /// Replaces all custom properties for [itemId] with [companions].
  ///
  /// Deletes existing rows first, then inserts the new set atomically.
  /// Call within a transaction when combined with other item writes.
  Future<void> replacePropertiesForItem(
    String itemId,
    List<ItemCustomPropertiesCompanion> companions,
  ) async {
    await (delete(itemCustomProperties)
          ..where((t) => t.itemId.equals(itemId)))
        .go();
    for (final c in companions) {
      await into(itemCustomProperties).insert(c);
    }
  }

  // ---------------------------------------------------------------------------
  // Tag associations (RQ-OBJ-002)
  // ---------------------------------------------------------------------------

  /// Returns the list of tag IDs associated with the item with [itemId].
  Future<List<String>> getTagIdsForItem(String itemId) async {
    final rows = await (select(itemTags)
          ..where((t) => t.itemId.equals(itemId)))
        .get();
    return rows.map((r) => r.tagId).toList();
  }

  /// Replaces all tag associations for [itemId] with [tagIds].
  ///
  /// Deletes existing rows first, then inserts the new set atomically.
  /// Call within a transaction when combined with other item writes.
  Future<void> replaceTagsForItem(String itemId, List<String> tagIds) async {
    await (delete(itemTags)..where((t) => t.itemId.equals(itemId))).go();
    for (final tagId in tagIds) {
      await into(itemTags).insert(
        ItemTagsCompanion.insert(itemId: itemId, tagId: tagId),
      );
    }
  }
}
