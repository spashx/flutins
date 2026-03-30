// RQ-MED-001 / RQ-MED-003 / RQ-MED-004 / D-16
// Drift DAO for media attachment rows.
// Scoped to the MediaAttachments table only (D-16).

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/media_attachments_table.dart';

part 'media_dao.g.dart';

@DriftAccessor(tables: [MediaAttachments])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  MediaDao(super.db);

  /// Returns all attachment rows belonging to the item with [itemId].
  Future<List<MediaAttachmentRow>> getAttachmentsForItem(String itemId) =>
      (select(mediaAttachments)..where((t) => t.itemId.equals(itemId))).get();

  /// Inserts or replaces [companion] in the media_attachments table.
  Future<void> upsertAttachment(MediaAttachmentsCompanion companion) =>
      into(mediaAttachments).insertOnConflictUpdate(companion);

  /// Permanently deletes all attachment rows whose ids appear in [ids] -- RQ-MED-004.
  Future<void> deleteAttachmentsByIds(List<String> ids) =>
      (delete(mediaAttachments)..where((t) => t.id.isIn(ids))).go();

  /// Replaces all attachment rows for [itemId] with [companions] -- RQ-MED-001.
  ///
  /// Follows the same wholesale-replace pattern used by
  /// `ItemsDao.replacePropertiesForItem` and `replaceTagsForItem`.
  Future<void> replaceAttachmentsForItem(
    String itemId,
    List<MediaAttachmentsCompanion> companions,
  ) async {
    await (delete(mediaAttachments)
          ..where((t) => t.itemId.equals(itemId)))
        .go();
    for (final c in companions) {
      await into(mediaAttachments).insert(c);
    }
  }
}
