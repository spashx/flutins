// RQ-DAT-001 / RQ-DAT-002 / RQ-SEC-001
// Drift database class -- registers all tables and DAOs.
// The database file is opened with SQLCipher encryption in database_factory.dart.

import 'package:drift/drift.dart';

import 'daos/items_dao.dart';
import 'daos/media_dao.dart';
import 'daos/tags_dao.dart';
import 'tables/item_custom_properties_table.dart';
import 'tables/item_tags_table.dart';
import 'tables/items_table.dart';
import 'tables/media_attachments_table.dart';
import 'tables/tags_table.dart';

part 'app_database.g.dart';

/// Database-scoped constants -- no inline literals anywhere in the data layer.
abstract final class AppDatabaseConstants {
  AppDatabaseConstants._();

  /// Incremented whenever the schema changes; triggers Drift migrations.
  static const int schemaVersion = 1;

  /// SQLite file name inside the app documents directory.
  static const String databaseFileName = 'flutins.db';
}

/// Root Drift database -- RQ-DAT-001.
///
/// Encrypted via SQLCipher (RQ-DAT-002) using a key from the OS keystore
/// (RQ-SEC-001). The QueryExecutor is supplied by createEncryptedDatabase()
/// in database_factory.dart; this class has no knowledge of the key.
@DriftDatabase(
  tables: [
    Items,
    Tags,
    ItemTags,
    ItemCustomProperties,
    MediaAttachments,
  ],
  daos: [
    ItemsDao,
    TagsDao,
    MediaDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => AppDatabaseConstants.schemaVersion;
}
