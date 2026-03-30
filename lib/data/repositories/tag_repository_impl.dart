// RQ-TAG-001 / RQ-TAG-002 / RQ-TAG-003 / RQ-TAG-004 / D-16 / D-18
// Concrete implementation of TagRepository using Drift TagsDao.

import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../database/app_database.dart';
import '../mappers/tag_mapper.dart';

/// Concrete implementation of [TagRepository] backed by Drift -- RQ-TAG-002.
class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Tag>> watchTags() {
    return _db.tagsDao
        .watchTagRows()
        .map((rows) => rows.map(TagMapper.fromRow).toList());
  }

  /// Returns the count of items referencing [tagId] -- RQ-TAG-003.
  @override
  Future<int> getItemCountForTag(String tagId) =>
      _db.tagsDao.getItemCountForTag(tagId);

  @override
  Future<void> saveTag(Tag tag) =>
      _db.tagsDao.upsertTag(TagMapper.toCompanion(tag));

  /// Deletes the tag; ON DELETE CASCADE removes it from all items -- RQ-TAG-004.
  @override
  Future<void> deleteTag(String tagId) => _db.tagsDao.deleteTag(tagId);
}
