// RQ-TAG-002 / D-41
// Riverpod AsyncNotifier for tag mutation operations (save, delete).
// The tag list is read from the existing `tagListProvider` stream;
// this notifier owns only the async mutation state.
// Model: Claude Opus 4.6

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/repository_providers.dart';
import '../../domain/entities/tag.dart';

part 'tag_management_notifier.g.dart';

/// Async mutation controller for tag CRUD operations -- RQ-TAG-002 / D-41.
///
/// State is `AsyncValue<void>`:
/// - `AsyncData(null)` -- idle or last operation succeeded.
/// - `AsyncLoading` -- operation in progress.
/// - `AsyncError` -- last operation failed.
@riverpod
class TagManagementNotifier extends _$TagManagementNotifier {
  @override
  FutureOr<void> build() {}

  /// Persists [tag] (insert or update) -- RQ-TAG-002.
  Future<void> saveTag(Tag tag) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tagRepositoryProvider).saveTag(tag),
    );
  }

  /// Deletes the tag with [tagId]; cascade to item_tags is handled by the
  /// database ON DELETE CASCADE (RQ-TAG-004).
  Future<void> deleteTag(String tagId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tagRepositoryProvider).deleteTag(tagId),
    );
  }
}
