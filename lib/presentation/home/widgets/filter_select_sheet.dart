// RQ-SEL-003 / D-31
// Bottom sheet providing filter-based batch selection: select all, by tag,
// or by category. Operates on the in-memory item list (no extra DB query).
// Model: Claude Opus 4.6

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/item.dart';
import '../../../domain/entities/tag.dart';
import '../../../data/providers/repository_providers.dart';
import '../selection_notifier.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _Strings {
  _Strings._();

  static const String title = 'Select by...';
  static const String selectAll = 'Select all';
  static const String selectByTag = 'By tag';
  static const String selectByCategory = 'By category';
  static const String noTags = 'No tags available';
  static const String noCategories = 'No categories available';
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Shows the filter-select bottom sheet -- RQ-SEL-003 / D-31.
///
/// [items] is the current in-memory item list from `ItemListNotifier`.
/// Selection results are pushed to `SelectionNotifier.selectAll`.
void showFilterSelectSheet({
  required BuildContext context,
  required WidgetRef ref,
  required List<Item> items,
}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) {
      return _FilterSelectContent(items: items, ref: ref);
    },
  );
}

// ---------------------------------------------------------------------------
// Content widget
// ---------------------------------------------------------------------------

class _FilterSelectContent extends StatelessWidget {
  const _FilterSelectContent({
    required this.items,
    required this.ref,
  });

  final List<Item> items;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _Strings.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // Select all
          ListTile(
            leading: const Icon(Icons.select_all),
            title: const Text(_Strings.selectAll),
            onTap: () {
              _selectAllItems(context);
            },
          ),
          // Select by tag
          ListTile(
            leading: const Icon(Icons.label_outline),
            title: const Text(_Strings.selectByTag),
            onTap: () {
              Navigator.of(context).pop();
              _showTagSubList(context);
            },
          ),
          // Select by category
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text(_Strings.selectByCategory),
            onTap: () {
              Navigator.of(context).pop();
              _showCategorySubList(context);
            },
          ),
        ],
      ),
    );
  }

  void _selectAllItems(BuildContext context) {
    final allIds = items.map((item) => item.id).toList();
    ref.read(selectionNotifierProvider.notifier).selectAll(allIds);
    Navigator.of(context).pop();
  }

  void _showTagSubList(BuildContext outerContext) {
    final tagRepo = ref.read(tagRepositoryProvider);

    showModalBottomSheet<void>(
      context: outerContext,
      builder: (BuildContext sheetContext) {
        return StreamBuilder<List<Tag>>(
          stream: tagRepo.watchTags(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text(_Strings.noTags)),
                ),
              );
            }
            final tags = snapshot.data!;
            return SafeArea(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  return ListTile(
                    leading: const Icon(Icons.label),
                    title: Text(tag.name),
                    onTap: () {
                      final matchingIds = items
                          .where((item) => item.tagIds.contains(tag.id))
                          .map((item) => item.id)
                          .toList();
                      ref
                          .read(selectionNotifierProvider.notifier)
                          .selectAll(matchingIds);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showCategorySubList(BuildContext outerContext) {
    final categories = items
        .map((item) => item.category)
        .toSet()
        .toList()
      ..sort();

    if (categories.isEmpty) {
      showModalBottomSheet<void>(
        context: outerContext,
        builder: (BuildContext sheetContext) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text(_Strings.noCategories)),
            ),
          );
        },
      );
      return;
    }

    showModalBottomSheet<void>(
      context: outerContext,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: const Icon(Icons.category),
                title: Text(category),
                onTap: () {
                  final matchingIds = items
                      .where((item) => item.category == category)
                      .map((item) => item.id)
                      .toList();
                  ref
                      .read(selectionNotifierProvider.notifier)
                      .selectAll(matchingIds);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        );
      },
    );
  }
}
