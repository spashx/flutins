// RQ-SCR-004 / D-32
// Riverpod synchronous Notifier managing the text search query on the home
// screen. Holds a single String representing the active filter query.
// Model: Claude Opus 4.6

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_notifier.g.dart';

/// Manages the search query state for the home screen -- D-32 / RQ-SCR-004.
///
/// - [setQuery]: replaces the current query; widgets rebuild and re-filter.
/// - [clear]: resets query to empty string; full unfiltered list is shown.
@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  String build() => '';

  /// Replaces the search query -- D-32.
  void setQuery(String query) => state = query;

  /// Resets the search query to empty -- D-32.
  void clear() => state = '';
}
