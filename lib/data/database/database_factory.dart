// RQ-DAT-001 / RQ-DAT-002 / RQ-SEC-001 / D-13 / D-15
// Factory that opens the encrypted AppDatabase.
// Called once in main() before runApp(); the result is injected via ProviderScope.

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

/// Creates and opens the [AppDatabase] protected by SQLCipher -- RQ-DAT-002.
///
/// [encryptionKey] must be the 256-bit hex key obtained from KeystoreService
/// (RQ-SEC-001). It is applied via `PRAGMA key` as the very first statement,
/// before any schema read or write, as required by SQLCipher (D-13).
///
/// The database file is stored in the app documents directory so that it is
/// included in OS-managed backups and is isolated from other applications.
Future<AppDatabase> createEncryptedDatabase(String encryptionKey) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final dbFile = File(
    p.join(docsDir.path, AppDatabaseConstants.databaseFileName),
  );

  return AppDatabase(
    NativeDatabase.createInBackground(
      dbFile,
      setup: (rawDatabase) {
        // Apply the cipher key before any other SQL statement -- D-13.
        // Single quotes around the key value are required by SQLCipher.
        rawDatabase.execute("PRAGMA key = '$encryptionKey'");
      },
    ),
  );
}
