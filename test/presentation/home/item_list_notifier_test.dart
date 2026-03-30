// RQ-OBJ-007 / RQ-SCR-002 / RQ-SCR-003 / D-21
// Unit tests for ItemListNotifier: verifies sorted item-list emission,
// default sort order, and runtime sort changes.
//
// SETUP RULE: items are inserted into the DB *before* the notifier listener
// is added. This ensures Drift's stream first-emission includes all pre-seeded
// rows, eliminating race conditions between async inserts and stream events.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/data/database/app_database.dart';
import 'package:flutins/data/providers/database_providers.dart';
import 'package:flutins/data/providers/repository_providers.dart';
import 'package:flutins/domain/entities/item.dart';
import 'package:flutins/domain/value_objects/sort_option.dart';
import 'package:flutins/presentation/home/item_list_provider.dart';

import '../../helpers/test_database.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _date = DateTime.utc(2024);

Item _makeItem({
  required String id,
  required String name,
  String category = 'Electronics',
  DateTime? acquisitionDate,
}) {
  final now = DateTime.utc(2024, 1, 12, 12);
  return Item(
    id: id,
    name: name,
    category: category,
    acquisitionDate: acquisitionDate ?? _date,
    tagIds: const [],
    customProperties: const {},
    mediaAttachments: const [],
    createdAt: now,
    updatedAt: now,
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer(AppDatabase db) {
  return ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
  );
}

/// Starts [itemListNotifierProvider] and returns the first [ItemListState].
///
/// Call this AFTER all pre-seeding inserts so the first snapshot is complete.
Future<ItemListState> _startAndAwaitFirst(ProviderContainer container) {
  // Adding a listener triggers the provider build and keeps it alive.
  container.listen(itemListNotifierProvider, (prev, next) {});
  return container.read(itemListNotifierProvider.future);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ItemListNotifier --', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = createTestDatabase();
      container = _makeContainer(db);
      // NOTE: do NOT listen to itemListNotifierProvider here.
      // Each test inserts items first, then starts the notifier so the
      // first stream emission already reflects the pre-seeded state.
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    // -----------------------------------------------------------------------
    // RQ-SCR-003: default sort is name ascending
    // -----------------------------------------------------------------------

    group('RQ-SCR-003 -- default sort', () {
      test(
        'Given empty database, '
        'When the notifier builds, '
        'Then it emits an empty list with SortOption.defaultSort',
        () async {
          // When: no inserts, just start and read first emission
          final state = await _startAndAwaitFirst(container);

          // Then
          expect(state.items, isEmpty);
          expect(state.sort, equals(SortOption.defaultSort));
        },
      );

      test(
        'Given three items with names Zebra, Apple, Mango in the DB, '
        'When the notifier builds with default sort, '
        'Then items are emitted in name-ascending order',
        () async {
          // Given: insert BEFORE starting the notifier
          final repo = container.read(itemRepositoryProvider);
          await repo.saveItem(_makeItem(id: 'z', name: 'Zebra'));
          await repo.saveItem(_makeItem(id: 'a', name: 'Apple'));
          await repo.saveItem(_makeItem(id: 'm', name: 'Mango'));

          // When
          final state = await _startAndAwaitFirst(container);

          // Then
          expect(
            state.items.map((i) => i.name).toList(),
            ['Apple', 'Mango', 'Zebra'],
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-SCR-002: runtime sort change
    // -----------------------------------------------------------------------

    group('RQ-SCR-002 -- setSort', () {
      test(
        'Given items sorted ascending, '
        'When setSort is called with descending direction, '
        'Then items are immediately reversed in the current state',
        () async {
          // Given: insert before starting
          final repo = container.read(itemRepositoryProvider);
          await repo.saveItem(_makeItem(id: 'a', name: 'Apple'));
          await repo.saveItem(_makeItem(id: 'z', name: 'Zebra'));
          await _startAndAwaitFirst(container);

          // When
          container.read(itemListNotifierProvider.notifier).setSort(
                SortOption.defaultSort.toggleDirection(),
              );

          // Then: setSort is synchronous -- state updates immediately
          final state = container.read(itemListNotifierProvider).requireValue;
          expect(
            state.items.map((i) => i.name).toList(),
            ['Zebra', 'Apple'],
          );
          expect(state.sort.direction, SortDirection.descending);
        },
      );

      test(
        'Given items sorted by name, '
        'When setSort is called with category field, '
        'Then items are emitted sorted by category ascending',
        () async {
          // Given: insert before starting
          final repo = container.read(itemRepositoryProvider);
          await repo.saveItem(
              _makeItem(id: 'a', name: 'Apple', category: 'Furniture'));
          await repo.saveItem(_makeItem(id: 'b', name: 'Banana'));
          await _startAndAwaitFirst(container);

          // When
          container.read(itemListNotifierProvider.notifier).setSort(
                const SortOption(
                  field: ItemSortField.category,
                  direction: SortDirection.ascending,
                ),
              );

          // Then
          final state = container.read(itemListNotifierProvider).requireValue;
          expect(
            state.items.map((i) => i.category).toList(),
            ['Electronics', 'Furniture'],
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-OBJ-007: new item appears at sort-order position
    // -----------------------------------------------------------------------

    group('RQ-OBJ-007 -- new item at sort position', () {
      test(
        'Given two items (Apple, Zebra) already in list, '
        'When a new item (Mango) is saved to the repository, '
        'Then the list is re-emitted with Mango inserted between Apple and Zebra',
        () async {
          // Given: pre-seed Apple and Zebra, then start the notifier
          final repo = container.read(itemRepositoryProvider);
          await repo.saveItem(_makeItem(id: 'a', name: 'Apple'));
          await repo.saveItem(_makeItem(id: 'z', name: 'Zebra'));

          // Set up Completer BEFORE the listen so we capture the second emission
          final secondEmission = Completer<ItemListState>();
          var emissionCount = 0;
          container.listen<AsyncValue<ItemListState>>(
            itemListNotifierProvider,
            (_, next) {
              if (next.hasValue) {
                emissionCount++;
                if (emissionCount == 2 && !secondEmission.isCompleted) {
                  secondEmission.complete(next.requireValue);
                }
              }
            },
          );

          // Await first emission (Apple + Zebra)
          await container.read(itemListNotifierProvider.future);

          // When: insert Mango to trigger a second stream emission
          await repo.saveItem(_makeItem(id: 'm', name: 'Mango'));
          final state = await secondEmission.future.timeout(
            const Duration(seconds: 5),
          );

          // Then
          expect(
            state.items.map((i) => i.name).toList(),
            ['Apple', 'Mango', 'Zebra'],
          );
        },
      );
    });
  });
}
