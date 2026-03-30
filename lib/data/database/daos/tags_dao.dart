// RQ-TAG-001 / RQ-TAG-002 / RQ-TAG-003 / D-16
// Drift DAO for tag rows and item-count queries.
// Scoped to Tags and ItemTags tables (D-16).

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/item_tags_table.dart';
import '../tables/tags_table.dart';

part 'tags_dao.g.dart';

@DriftAccessor(tables: [Tags, ItemTags])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.db);

  /// Emits the full tag list whenever the tags table changes.
  Stream<List<TagRow>> watchTagRows() => select(tags).watch();

  /// Inserts or replaces [companion] in the tags table.
  Future<void> upsertTag(TagsCompanion companion) =>
      into(tags).insertOnConflictUpdate(companion);

  /// Permanently deletes the tag with [id].
  ///
  /// ON DELETE CASCADE on item_tags removes all associations automatically
  /// (RQ-TAG-004).
  Future<void> deleteTag(String id) =>
      (delete(tags)..where((t) => t.id.equals(id))).go();

  /// Returns the number of items that reference the tag [tagId] -- RQ-TAG-003.
  Future<int> getItemCountForTag(String tagId) async {
    final count = itemTags.tagId.count();
    final query = selectOnly(itemTags)
      ..addColumns([count])
      ..where(itemTags.tagId.equals(tagId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
