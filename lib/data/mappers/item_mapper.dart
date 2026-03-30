// RQ-OBJ-001 / D-17 / D-18
// Mapper between the Drift ItemRow persistence type and the Item domain entity.
// This file is the single source of truth for field-level type conversions.
//
// Timestamps are stored and restored as UTC milliseconds since epoch to avoid
// timezone-dependent behaviour across platforms.

import 'package:drift/drift.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/media_attachment.dart';
import '../database/app_database.dart';

/// Converts between [ItemRow] (Drift persistence type) and [Item] (domain entity).
///
/// No instance construction -- use static methods only (D-18).
abstract final class ItemMapper {
  ItemMapper._();

  /// Builds a domain [Item] from a Drift [ItemRow] and its related data.
  static Item fromRow({
    required ItemRow row,
    required List<String> tagIds,
    required Map<String, String> customProperties,
    required List<MediaAttachment> mediaAttachments,
  }) {
    return Item(
      id: row.id,
      name: row.name,
      category: row.category,
      acquisitionDate: DateTime.fromMillisecondsSinceEpoch(
        row.acquisitionDate,
        isUtc: true,
      ),
      serialNumber: row.serialNumber,
      tagIds: tagIds,
      customProperties: customProperties,
      mediaAttachments: mediaAttachments,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
    );
  }

  /// Produces an [ItemsCompanion] suitable for Drift upsert from a domain [Item].
  static ItemsCompanion toCompanion(Item item) {
    return ItemsCompanion(
      id: Value(item.id),
      name: Value(item.name),
      category: Value(item.category),
      acquisitionDate: Value(item.acquisitionDate.toUtc().millisecondsSinceEpoch),
      serialNumber: Value(item.serialNumber),
      createdAt: Value(item.createdAt.toUtc().millisecondsSinceEpoch),
      updatedAt: Value(item.updatedAt.toUtc().millisecondsSinceEpoch),
    );
  }
}
