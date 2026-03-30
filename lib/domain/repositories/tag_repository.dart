// RQ-DAT-001 / RQ-TAG-001 / RQ-TAG-002 / RQ-TAG-003 / RQ-TAG-004
// Repository interface for tag persistence.
// Lives in Domain; implementation lives in Data (Clean Architecture D-09).
// This file must NEVER import from lib/data/ or lib/presentation/.

import '../entities/tag.dart';

/// Contract for tag CRUD operations -- RQ-DAT-001 / RQ-TAG-002.
///
/// The concrete implementation is in lib/data/repositories/.
abstract interface class TagRepository {
  /// Emits the full, up-to-date list of tags whenever any tag changes.
  Stream<List<Tag>> watchTags();

  /// Returns the number of items that currently reference the tag [tagId].
  ///
  /// Used to show the impact count before a modification or deletion (RQ-TAG-003).
  Future<int> getItemCountForTag(String tagId);

  /// Persists [tag]; performs an insert if the id is new, update otherwise.
  Future<void> saveTag(Tag tag);

  /// Deletes the tag and silently removes it from all referencing items.
  ///
  /// The cascade removal of join rows is handled at the database level
  /// via foreign-key ON DELETE CASCADE (RQ-TAG-004).
  Future<void> deleteTag(String tagId);
}
