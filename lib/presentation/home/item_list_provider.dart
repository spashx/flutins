// RQ-OBJ-007 / RQ-SCR-002 / RQ-SCR-003 / D-21
// Riverpod AsyncNotifier that exposes a sorted item list to the home screen.
// Watches ItemRepository.watchItems() and re-sorts whenever the stream emits
// or the active SortOption changes.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/item.dart';
import '../../domain/value_objects/sort_option.dart';
import '../../data/providers/repository_providers.dart';

part 'item_list_provider.g.dart';

// ---------------------------------------------------------------------------
// Comparators -- one per ItemSortField (D-20)
// ---------------------------------------------------------------------------

int _compareByField(Item a, Item b, ItemSortField field) {
  switch (field) {
    case ItemSortField.name:
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    case ItemSortField.category:
      return a.category.toLowerCase().compareTo(b.category.toLowerCase());
    case ItemSortField.acquisitionDate:
      return a.acquisitionDate.compareTo(b.acquisitionDate);
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// State held by [ItemListNotifier]: the sorted item list and active sort.
class ItemListState {
  const ItemListState({
    required this.items,
    required this.sort,
  });

  final List<Item> items;
  final SortOption sort;

  ItemListState copyWith({List<Item>? items, SortOption? sort}) {
    return ItemListState(
      items: items ?? this.items,
      sort: sort ?? this.sort,
    );
  }
}

/// Stream-backed notifier that emits a sorted list of [Item] -- RQ-OBJ-007 / D-21.
///
/// Default sort: [SortOption.defaultSort] (name ascending, RQ-SCR-003).
/// Call [setSort] to change sort field or direction at runtime (RQ-SCR-002).
@riverpod
class ItemListNotifier extends _$ItemListNotifier {
  @override
  Stream<ItemListState> build() {
    final repo = ref.watch(itemRepositoryProvider);
    const SortOption currentSort = SortOption.defaultSort;

    return repo.watchItems().map((rawItems) {
      final sorted = List<Item>.from(rawItems)
        ..sort((a, b) {
          final cmp = _compareByField(a, b, currentSort.field);
          return currentSort.direction == SortDirection.ascending ? cmp : -cmp;
        });
      return ItemListState(items: sorted, sort: currentSort);
    });
  }

  /// Changes the active sort and triggers an immediate re-sort -- RQ-SCR-002.
  void setSort(SortOption sort) {
    final previous = state.valueOrNull;
    if (previous == null) return;

    final sorted = List<Item>.from(previous.items)
      ..sort((a, b) {
        final cmp = _compareByField(a, b, sort.field);
        return sort.direction == SortDirection.ascending ? cmp : -cmp;
      });
    state = AsyncValue.data(previous.copyWith(items: sorted, sort: sort));
  }
}
