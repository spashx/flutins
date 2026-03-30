// RQ-DAT-001 / RQ-MED-001 / RQ-MED-003 / RQ-MED-004
// Repository interface for media attachment persistence.
// Lives in Domain; implementation lives in Data (Clean Architecture D-09).
// This file must NEVER import from lib/data/ or lib/presentation/.

import '../entities/media_attachment.dart';

/// Contract for media attachment CRUD operations -- RQ-DAT-001.
///
/// The concrete implementation is in lib/data/repositories/.
abstract interface class MediaRepository {
  /// Returns all attachments belonging to the item with [itemId].
  Future<List<MediaAttachment>> getAttachmentsForItem(String itemId);

  /// Persists [attachment]; performs an insert if the id is new, update otherwise.
  Future<void> saveAttachment(MediaAttachment attachment);

  /// Permanently deletes all attachments whose ids appear in [ids] -- RQ-MED-004.
  Future<void> deleteAttachments(List<String> ids);
}
