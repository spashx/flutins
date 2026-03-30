// RQ-DAT-001 / RQ-OBJ-001 / RQ-OBJ-005 / RQ-OBJ-009 / RQ-OBJ-010
// Repository interface for item persistence.
// Lives in Domain; implementation lives in Data (Clean Architecture D-09).
// This file must NEVER import from lib/data/ or lib/presentation/.

import '../entities/item.dart';

/// Contract for item CRUD operations -- RQ-DAT-001.
///
/// The concrete implementation is in lib/data/repositories/.
abstract interface class ItemRepository {
  /// Emits the full, up-to-date list of items whenever any item changes.
  Stream<List<Item>> watchItems();

  /// Returns the item with [id], or null when not found.
  Future<Item?> getItemById(String id);

  /// Persists [item]; performs an insert if the id is new, update otherwise.
  Future<void> saveItem(Item item);

  /// Permanently deletes all items whose ids appear in [ids] -- RQ-OBJ-010.
  Future<void> deleteItems(List<String> ids);
}
