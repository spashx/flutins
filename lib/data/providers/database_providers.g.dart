// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'b18e63a8b2cf0d362532a2143520f71fd21ac24e';

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
///
/// Copied from [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
