// RQ-OBJ-001 / RQ-OBJ-002 / RQ-OBJ-003 / RQ-OBJ-010 / D-16 / D-18
// Concrete implementation of ItemRepository using Drift DAOs.

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../database/app_database.dart';
import '../mappers/item_mapper.dart';
import '../mappers/media_attachment_mapper.dart';

/// UUID generator used when persisting custom property rows.
const _uuid = Uuid();

/// Concrete implementation of [ItemRepository] backed by Drift -- RQ-OBJ-001.
///
/// All multi-table writes (item + custom properties + tag associations) are
/// executed inside a single [AppDatabase.transaction] to guarantee atomicity
/// (D-16).
class ItemRepositoryImpl implements ItemRepository {
  ItemRepositoryImpl(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Emits the item list whenever the items table changes -- RQ-OBJ-001.
  ///
  /// Note: changes to the item_tags, item_custom_properties or media_attachments
  /// tables do not currently trigger a re-emission. This will be addressed in a
  /// future iteration using Drift's multi-table watch API.
  @override
  Stream<List<Item>> watchItems() {
    return _db.itemsDao
        .watchItemRows()
        .asyncMap((rows) => Future.wait(rows.map(_buildItem)));
  }

  @override
  Future<Item?> getItemById(String id) async {
    final row = await _db.itemsDao.getItemRowById(id);
    if (row == null) return null;
    return _buildItem(row);
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Persists [item] and all its associations atomically -- RQ-OBJ-001 / D-16.
  ///
  /// Custom property rows are replaced wholesale on each save (RQ-OBJ-003).
  /// Tag associations are replaced wholesale on each save (RQ-OBJ-002).
  /// Media attachments are replaced wholesale on each save (RQ-MED-001).
  @override
  Future<void> saveItem(Item item) async {
    final propCompanions = item.customProperties.entries.map((e) {
      return ItemCustomPropertiesCompanion(
        id: Value(_uuid.v4()),
        itemId: Value(item.id),
        key: Value(e.key),
        value: Value(e.value),
      );
    }).toList();

    final mediaCompanions = item.mediaAttachments
        .map(MediaAttachmentMapper.toCompanion)
        .toList();

    await _db.transaction(() async {
      await _db.itemsDao.upsertItem(ItemMapper.toCompanion(item));
      await _db.itemsDao.replacePropertiesForItem(item.id, propCompanions);
      await _db.itemsDao.replaceTagsForItem(item.id, item.tagIds);
      await _db.mediaDao.replaceAttachmentsForItem(item.id, mediaCompanions);
    });
  }

  /// Permanently deletes all items in [ids] -- RQ-OBJ-010.
  ///
  /// ON DELETE CASCADE on media_attachments, item_tags, and
  /// item_custom_properties removes related rows automatically.
  @override
  Future<void> deleteItems(List<String> ids) =>
      _db.itemsDao.deleteItemsByIds(ids);

  // ---------------------------------------------------------------------------
  // Assembly
  // ---------------------------------------------------------------------------

  Future<Item> _buildItem(ItemRow row) async {
    final tagIds = await _db.itemsDao.getTagIdsForItem(row.id);
    final propRows = await _db.itemsDao.getPropertiesForItem(row.id);
    final customProperties = {for (final p in propRows) p.key: p.value};
    final mediaRows = await _db.mediaDao.getAttachmentsForItem(row.id);
    final mediaAttachments = mediaRows.map(MediaAttachmentMapper.fromRow).toList();

    return ItemMapper.fromRow(
      row: row,
      tagIds: tagIds,
      customProperties: customProperties,
      mediaAttachments: mediaAttachments,
    );
  }
}
