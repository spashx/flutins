// RQ-DAT-001 / RQ-MED-001 / RQ-MED-003 / RQ-MED-004
// Table for media attachments (photos and documents) linked to an item.

import 'package:drift/drift.dart';

import 'items_table.dart';

/// Persisted columns for a media attachment -- RQ-MED-001 / RQ-MED-003.
///
/// @DataClassName('MediaAttachmentRow') prevents collision with the domain
/// entity MediaAttachment.
/// [type] stores the string representation of MediaType ('photo' or 'document').
/// ON DELETE CASCADE removes all attachments when the parent item is deleted.
@DataClassName('MediaAttachmentRow')
class MediaAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();

  /// 'photo' or 'document' -- matches MediaType.name (RQ-MED-001 / RQ-MED-003).
  TextColumn get type => text()();

  TextColumn get fileName => text()();
  TextColumn get filePath => text()();

  /// True only for the mandatory primary photo (RQ-OBJ-001).
  BoolColumn get isMainPhoto =>
      boolean().withDefault(const Constant(false))();

  /// Milliseconds since epoch (UTC).
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
