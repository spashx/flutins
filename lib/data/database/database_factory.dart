// RQ-DAT-001 / RQ-DAT-002 / RQ-SEC-001 / D-13 / D-15 / ISS-003
// Factory that opens the encrypted AppDatabase.
// Called once in main() before runApp(); the result is injected via ProviderScope.

import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';

import 'app_database.dart';

// ---------------------------------------------------------------------------
// Android SQLCipher library loader -- ISS-003
// ---------------------------------------------------------------------------

/// Opens the SQLCipher shared library on Android.
///
/// Attempts a bare `dlopen("libsqlcipher.so")` first, which succeeds when the
/// APK extracts native libraries (`extractNativeLibs=true`, the default for
/// debug builds and many release configurations). When that fails
/// (`ArgumentError`), the full path is resolved via `/proc/self/cmdline` --
/// the same fallback used by `package:sqlite3` for `libsqlite3.so`.
///
/// On non-Android platforms this function is never called via
/// [_overrideSqliteLibraryForAndroid]; if invoked directly it rethrows the
/// [ArgumentError] so that tests can assert the expected behaviour.
///
/// Non-private so that `database_factory_test.dart` can call it directly.
// ignore: library_private_types_in_public_api
DynamicLibrary openSqlcipherLibrary() {
  try {
    return DynamicLibrary.open('libsqlcipher.so');
  } on ArgumentError {
    // On non-Android platforms, rethrow -- this function must not be called
    // outside of the Android isolateSetup path (see _overrideSqliteLibraryForAndroid).
    if (!Platform.isAndroid) rethrow;

    // Android fallback: read the app package ID from /proc/self/cmdline and
    // build the absolute path to the extracted library.  This mirrors the
    // approach documented in https://github.com/simolus3/moor/issues/420.
    final appIdAsBytes = File('/proc/self/cmdline').readAsBytesSync();
    final endOfAppId = max(appIdAsBytes.indexOf(0), 0);
    final appId = String.fromCharCodes(appIdAsBytes.sublist(0, endOfAppId));
    return DynamicLibrary.open('/data/data/$appId/lib/libsqlcipher.so');
  }
}

/// Registers [openSqlcipherLibrary] with the `sqlite3` FFI loader inside a
/// background isolate.
///
/// Must be a top-level function (not a closure) so that Dart can serialise it
/// for transfer to the isolate spawned by [NativeDatabase.createInBackground].
void _overrideSqliteLibraryForAndroid() {
  open.overrideFor(OperatingSystem.android, openSqlcipherLibrary);
}

// ---------------------------------------------------------------------------
// Database factory
// ---------------------------------------------------------------------------

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
      // ISS-003: isolateSetup runs inside the background isolate before the
      // database is opened.  Each isolate has its own copy of global state, so
      // open.overrideFor must be applied here -- a call in the main isolate is
      // invisible to the background isolate and has no effect.
      isolateSetup: Platform.isAndroid ? _overrideSqliteLibraryForAndroid : null,
      setup: (rawDatabase) {
        // Apply the cipher key before any other SQL statement -- D-13.
        // Single quotes around the key value are required by SQLCipher.
        rawDatabase.execute("PRAGMA key = '$encryptionKey'");
      },
    ),
  );
}
