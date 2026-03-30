// RQ-OBJ-002 / RQ-TAG-001 / D-17 / D-18
// Mapper between the Drift TagRow persistence type and the Tag domain entity.

import 'package:drift/drift.dart';

import '../../domain/entities/tag.dart';
import '../database/app_database.dart';

/// Converts between [TagRow] (Drift persistence type) and [Tag] (domain entity).
///
/// No instance construction -- use static methods only (D-18).
abstract final class TagMapper {
  TagMapper._();

  /// Builds a domain [Tag] from a Drift [TagRow].
  static Tag fromRow(TagRow row) => Tag(id: row.id, name: row.name);

  /// Produces a [TagsCompanion] suitable for Drift upsert from a domain [Tag].
  static TagsCompanion toCompanion(Tag tag) => TagsCompanion(
        id: Value(tag.id),
        name: Value(tag.name),
      );
}
