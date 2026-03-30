// RQ-DAT-001 / RQ-OBJ-001
// Shared test helper: creates an unencrypted in-memory AppDatabase for unit tests.
// Uses NativeDatabase.memory() so no real files or encryption keys are needed.

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutins/data/database/app_database.dart';

/// Returns a fresh [AppDatabase] backed by an in-memory SQLite database.
///
/// Suitable for unit tests that exercise the Drift schema without encryption.
/// The multi-database warning is suppressed because each test deliberately
/// creates an isolated instance.  Call [AppDatabase.close] in tearDown.
AppDatabase createTestDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
