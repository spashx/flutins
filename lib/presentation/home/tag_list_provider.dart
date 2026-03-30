// RQ-SCR-004 / D-34
// Riverpod stream provider exposing the current list of tags. Used by the
// home screen to resolve tag ids to names for search filtering.
// Model: Claude Opus 4.6

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/repository_providers.dart';
import '../../domain/entities/tag.dart';

part 'tag_list_provider.g.dart';

/// Reactive tag list -- streams the full set of [Tag] entities from the
/// repository. Rebuilds automatically when tags are added, renamed, or
/// deleted -- D-34 / RQ-SCR-004.
@riverpod
Stream<List<Tag>> tagList(TagListRef ref) {
  return ref.watch(tagRepositoryProvider).watchTags();
}
