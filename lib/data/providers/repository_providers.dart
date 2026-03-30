// RQ-OBJ-001 / RQ-TAG-001 / RQ-MED-001 / D-07 / D-16
// Riverpod providers for the three domain repository implementations.
// Each provider is keepAlive -- repositories are app-lifetime singletons.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/item_repository.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../providers/database_providers.dart';
import '../repositories/item_repository_impl.dart';
import '../repositories/media_repository_impl.dart';
import '../repositories/tag_repository_impl.dart';

part 'repository_providers.g.dart';

/// Provides the singleton [ItemRepository] backed by [ItemRepositoryImpl].
///
/// Depends on [appDatabaseProvider] which must be overridden in ProviderScope
/// at app startup (D-15).
@Riverpod(keepAlive: true)
ItemRepository itemRepository(ItemRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return ItemRepositoryImpl(db);
}

/// Provides the singleton [TagRepository] backed by [TagRepositoryImpl].
@Riverpod(keepAlive: true)
TagRepository tagRepository(TagRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return TagRepositoryImpl(db);
}

/// Provides the singleton [MediaRepository] backed by [MediaRepositoryImpl].
@Riverpod(keepAlive: true)
MediaRepository mediaRepository(MediaRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return MediaRepositoryImpl(db);
}
