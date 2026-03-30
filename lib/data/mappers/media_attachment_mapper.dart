// RQ-MED-001 / RQ-MED-003 / D-17 / D-18
// Mapper between the Drift MediaAttachmentRow persistence type and the
// MediaAttachment domain entity.

import 'package:drift/drift.dart';

import '../../domain/entities/media_attachment.dart';
import '../database/app_database.dart';

/// Converts between [MediaAttachmentRow] (Drift) and [MediaAttachment] (domain).
///
/// [MediaType] is stored as its name string ('photo' or 'document') in the
/// database and restored via MediaType.values.byName.
///
/// No instance construction -- use static methods only (D-18).
abstract final class MediaAttachmentMapper {
  MediaAttachmentMapper._();

  /// Builds a domain [MediaAttachment] from a Drift [MediaAttachmentRow].
  static MediaAttachment fromRow(MediaAttachmentRow row) {
    return MediaAttachment(
      id: row.id,
      itemId: row.itemId,
      type: MediaType.values.byName(row.type),
      fileName: row.fileName,
      filePath: row.filePath,
      isMainPhoto: row.isMainPhoto,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
    );
  }

  /// Produces a [MediaAttachmentsCompanion] suitable for Drift upsert.
  static MediaAttachmentsCompanion toCompanion(MediaAttachment attachment) {
    return MediaAttachmentsCompanion(
      id: Value(attachment.id),
      itemId: Value(attachment.itemId),
      type: Value(attachment.type.name),
      fileName: Value(attachment.fileName),
      filePath: Value(attachment.filePath),
      isMainPhoto: Value(attachment.isMainPhoto),
      createdAt: Value(attachment.createdAt.toUtc().millisecondsSinceEpoch),
    );
  }
}
