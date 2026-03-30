// RQ-DAT-001 / D-07 / D-15
// Riverpod provider for the AppDatabase singleton.
// The provider is overridden at app startup in main() after the encrypted
// database is opened; no widget code ever opens the database directly.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';

part 'database_providers.g.dart';

/// Provides the singleton [AppDatabase] instance to the widget tree.
///
/// MUST be overridden in ProviderScope before any widget accesses it:
///   ProviderScope(
///     overrides: [appDatabaseProvider.overrideWithValue(database)],
///     child: const FlutinsApp(),
///   )
///
/// Throws [UnimplementedError] if accessed without the override, which
/// catches missing-setup bugs at runtime during development (D-15).
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden in ProviderScope at app startup.',
  );
}
