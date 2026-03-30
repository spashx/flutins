// RQ-MED-001 / RQ-MED-003 / RQ-MED-004 / D-16 / D-18
// Concrete implementation of MediaRepository using Drift MediaDao.

import '../../domain/entities/media_attachment.dart';
import '../../domain/repositories/media_repository.dart';
import '../database/app_database.dart';
import '../mappers/media_attachment_mapper.dart';

/// Concrete implementation of [MediaRepository] backed by Drift -- RQ-MED-001.
class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<MediaAttachment>> getAttachmentsForItem(String itemId) async {
    final rows = await _db.mediaDao.getAttachmentsForItem(itemId);
    return rows.map(MediaAttachmentMapper.fromRow).toList();
  }

  @override
  Future<void> saveAttachment(MediaAttachment attachment) =>
      _db.mediaDao.upsertAttachment(
        MediaAttachmentMapper.toCompanion(attachment),
      );

  /// Permanently deletes the attachments in [ids] -- RQ-MED-004.
  @override
  Future<void> deleteAttachments(List<String> ids) =>
      _db.mediaDao.deleteAttachmentsByIds(ids);
}
