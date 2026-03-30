// RQ-SCR-001 / RQ-OBJ-005 / RQ-OBJ-007 / RQ-SCR-003 / RQ-SCR-004
// RQ-SEL-001 / RQ-SEL-002 / RQ-SEL-003 / RQ-OBJ-010 / RQ-OBJ-011
// Home screen: displays the sorted item list, provides navigation to the
// item creation form, supports multi-selection with batch deletion, and
// text search filtering across all item properties and tags.
// Model: Claude Opus 4.6

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_routes.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/entities/item.dart';
import 'item_list_provider.dart';
import 'item_search_filter.dart';
import 'search_notifier.dart';
import 'selection_notifier.dart';
import 'tag_list_provider.dart';
import 'widgets/delete_confirmation_dialog.dart';
import 'widgets/filter_select_sheet.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _Strings {
  _Strings._();

  static const String empty = 'No items yet. Tap + to add one.';
  static const String noResults = 'No items match your search.';
  static const String errorPrefix = 'Error: ';
  static const String searchHint = 'Search items...';
  static const String tooltipAddItem = 'Add item';
  static const String tooltipCancelSelection = 'Cancel selection';
  static const String tooltipDelete = 'Delete selected';
  static const String tooltipFilter = 'Select by...';
  static const String selectedSuffix = ' selected';
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Main screen: sorted item list (RQ-SCR-001 / RQ-SCR-003) with FAB to create
/// a new item (RQ-OBJ-005 / RQ-OBJ-007), multi-selection mode for batch
/// operations (RQ-SEL-001 / RQ-SEL-002 / RQ-OBJ-011), and text search bar
/// for filtering across all item properties and tags (RQ-SCR-004 / D-33).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double _searchBarPadding = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(itemListNotifierProvider);
    final selectionState = ref.watch(selectionNotifierProvider);
    final query = ref.watch(searchNotifierProvider);
    final tagsAsync = ref.watch(tagListProvider);

    return Scaffold(
      appBar: selectionState.isActive
          ? _buildSelectionAppBar(context, ref, selectionState, listAsync)
          : _buildDefaultAppBar(),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('${_Strings.errorPrefix}$err'),
        ),
        data: (state) {
          // -- D-34: build tag name lookup for search filtering
          final tags = tagsAsync.valueOrNull ?? const [];
          final tagMap = {
            for (final t in tags) t.id: t.name.toLowerCase(),
          };

          // -- D-34: apply search filter
          final lowerQuery = query.toLowerCase();
          final displayItems = lowerQuery.isEmpty
              ? state.items
              : state.items
                  .where((i) => itemMatchesQuery(i, lowerQuery, tagMap))
                  .toList();

          return Column(
            children: [
              // -- D-33: search bar (hidden during selection mode)
              if (!selectionState.isActive)
                _SearchBar(query: query),
              Expanded(
                child: displayItems.isEmpty
                    ? Center(
                        child: Text(
                          state.items.isEmpty
                              ? _Strings.empty
                              : _Strings.noResults,
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayItems.length,
                        itemBuilder: (context, index) => _ItemTile(
                          item: displayItems[index],
                          isSelectionActive: selectionState.isActive,
                          isSelected: selectionState.selectedIds
                              .contains(displayItems[index].id),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: selectionState.isActive
          ? null
          : FloatingActionButton(
              tooltip: _Strings.tooltipAddItem,
              onPressed: () => context.push(AppRoutes.itemCreate),
              child: const Icon(Icons.add),
            ),
    );
  }

  // -------------------------------------------------------------------------
  // AppBar builders -- D-29
  // -------------------------------------------------------------------------

  /// Default AppBar with app title.
  PreferredSizeWidget _buildDefaultAppBar() {
    return AppBar(
      title: const Text(AppConstants.appName),
    );
  }

  /// Selection-mode AppBar showing count, cancel, delete, and filter -- D-29.
  PreferredSizeWidget _buildSelectionAppBar(
    BuildContext context,
    WidgetRef ref,
    SelectionState selectionState,
    AsyncValue<ItemListState> listAsync,
  ) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: _Strings.tooltipCancelSelection,
        onPressed: () =>
            ref.read(selectionNotifierProvider.notifier).cancel(),
      ),
      title: Text('${selectionState.count}${_Strings.selectedSuffix}'),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: _Strings.tooltipDelete,
          onPressed: () => _onDeletePressed(context, ref, selectionState),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: _Strings.tooltipFilter,
          onPressed: () {
            final items = listAsync.valueOrNull?.items ?? const [];
            showFilterSelectSheet(
              context: context,
              ref: ref,
              items: items,
            );
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Delete handler -- D-30
  // -------------------------------------------------------------------------

  Future<void> _onDeletePressed(
    BuildContext context,
    WidgetRef ref,
    SelectionState selectionState,
  ) async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      selectionState.count,
    );
    if (confirmed != true) return;

    final ids = selectionState.selectedIds.toList();
    await ref.read(itemRepositoryProvider).deleteItems(ids);
    ref.read(selectionNotifierProvider.notifier).cancel();
  }
}

// ---------------------------------------------------------------------------
// Item tile
// ---------------------------------------------------------------------------

/// One row in the home item list -- RQ-SCR-001 / RQ-SEL-001.
///
/// In normal mode, tap navigates to edit (RQ-OBJ-009).
/// Long-press enters selection mode (RQ-SEL-001 / D-28).
/// In selection mode, tap toggles the item (D-28).
class _ItemTile extends ConsumerWidget {
  const _ItemTile({
    required this.item,
    required this.isSelectionActive,
    required this.isSelected,
  });

  final Item item;
  final bool isSelectionActive;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: isSelectionActive
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => ref
                  .read(selectionNotifierProvider.notifier)
                  .toggleItem(item.id),
            )
          : _ItemThumbnail(item: item),
      title: Text(item.name),
      subtitle: Text(item.category),
      selected: isSelected,
      onTap: isSelectionActive
          ? () => ref
              .read(selectionNotifierProvider.notifier)
              .toggleItem(item.id)
          : () => context.push(
                AppRoutes.itemEdit.replaceAll(':id', item.id),
              ),
      onLongPress: isSelectionActive
          ? null
          : () => ref
              .read(selectionNotifierProvider.notifier)
              .enterSelectionMode(item.id),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar -- D-33
// ---------------------------------------------------------------------------

/// Always-visible search bar above the item list -- D-33 / RQ-SCR-004.
///
/// Hidden during selection mode (the parent conditionally excludes it).
class _SearchBar extends ConsumerWidget {
  const _SearchBar({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(HomeScreen._searchBarPadding),
      child: TextField(
        // Sync controller text with provider state (e.g. after clear()).
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: query,
            selection: TextSelection.collapsed(offset: query.length),
          ),
        ),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: _Strings.searchHint,
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () =>
                      ref.read(searchNotifierProvider.notifier).clear(),
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) =>
            ref.read(searchNotifierProvider.notifier).setQuery(value),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Item thumbnail
// ---------------------------------------------------------------------------

/// Small thumbnail placeholder -- replaced by a real image when RQ-MED-001
/// is implemented.
// TODO(RQ-MED-001): show actual main photo thumbnail.
class _ItemThumbnail extends StatelessWidget {
  const _ItemThumbnail({required this.item});

  final Item item;

  static const double _size = 48.0;

  @override
  Widget build(BuildContext context) {
    final mainPhoto = item.mediaAttachments
        .where((a) => a.isMainPhoto)
        .firstOrNull;

    if (mainPhoto == null) {
      return const SizedBox(
        width: _size,
        height: _size,
        child: Icon(Icons.image_not_supported_outlined),
      );
    }

    return const SizedBox(
      width: _size,
      height: _size,
      child: Icon(Icons.photo),
    );
  }
}


