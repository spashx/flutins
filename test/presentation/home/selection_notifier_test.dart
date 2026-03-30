// RQ-SEL-001 / RQ-SEL-002 / RQ-SEL-003 / D-28
// Unit tests for SelectionNotifier: verifies enter, toggle, selectAll, cancel.
// Model: Claude Opus 4.6

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/presentation/home/selection_notifier.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer() {
  return ProviderContainer();
}

SelectionState _readState(ProviderContainer container) =>
    container.read(selectionNotifierProvider);

SelectionNotifier _readNotifier(ProviderContainer container) =>
    container.read(selectionNotifierProvider.notifier);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SelectionNotifier --', () {
    late ProviderContainer container;
    late SelectionNotifier notifier;

    setUp(() {
      container = _makeContainer();
      // Keep alive so auto-dispose does not fire mid-test.
      container.listen(selectionNotifierProvider, (_, next) {});
      notifier = _readNotifier(container);
    });

    tearDown(() {
      container.dispose();
    });

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------

    group('initial state', () {
      test(
        'Given a fresh SelectionNotifier, '
        'When no action has been taken, '
        'Then isActive is false and selectedIds is empty',
        () {
          // Then
          final state = _readState(container);
          expect(state.isActive, isFalse);
          expect(state.selectedIds, isEmpty);
          expect(state.count, isZero);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-SEL-001: enter selection mode on long-press
    // -----------------------------------------------------------------------

    group('RQ-SEL-001 -- enterSelectionMode', () {
      test(
        'Given inactive selection, '
        'When enterSelectionMode is called with item id, '
        'Then isActive is true and selectedIds contains that id',
        () {
          // When
          notifier.enterSelectionMode('item-1');

          // Then
          final state = _readState(container);
          expect(state.isActive, isTrue);
          expect(state.selectedIds, equals({'item-1'}));
          expect(state.count, equals(1));
        },
      );
    });

    // -----------------------------------------------------------------------
    // D-28: toggleItem
    // -----------------------------------------------------------------------

    group('D-28 -- toggleItem', () {
      test(
        'Given selection mode active with item-1 selected, '
        'When toggleItem is called with item-2, '
        'Then both item-1 and item-2 are selected',
        () {
          // Given
          notifier.enterSelectionMode('item-1');

          // When
          notifier.toggleItem('item-2');

          // Then
          final state = _readState(container);
          expect(state.isActive, isTrue);
          expect(state.selectedIds, equals({'item-1', 'item-2'}));
          expect(state.count, equals(2));
        },
      );

      test(
        'Given selection mode active with item-1 and item-2 selected, '
        'When toggleItem is called with item-1 (deselect), '
        'Then only item-2 remains selected',
        () {
          // Given
          notifier.enterSelectionMode('item-1');
          notifier.toggleItem('item-2');

          // When
          notifier.toggleItem('item-1');

          // Then
          final state = _readState(container);
          expect(state.isActive, isTrue);
          expect(state.selectedIds, equals({'item-2'}));
        },
      );

      test(
        'Given selection mode active with only item-1 selected, '
        'When toggleItem is called with item-1 (last item deselected), '
        'Then selection mode exits automatically',
        () {
          // Given
          notifier.enterSelectionMode('item-1');

          // When
          notifier.toggleItem('item-1');

          // Then
          final state = _readState(container);
          expect(state.isActive, isFalse);
          expect(state.selectedIds, isEmpty);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-SEL-003: selectAll
    // -----------------------------------------------------------------------

    group('RQ-SEL-003 -- selectAll', () {
      test(
        'Given selection mode active with item-1 selected, '
        'When selectAll is called with [item-2, item-3], '
        'Then selectedIds is replaced with {item-2, item-3}',
        () {
          // Given
          notifier.enterSelectionMode('item-1');

          // When
          notifier.selectAll(['item-2', 'item-3']);

          // Then
          final state = _readState(container);
          expect(state.isActive, isTrue);
          expect(state.selectedIds, equals({'item-2', 'item-3'}));
        },
      );

      test(
        'Given selection mode active, '
        'When selectAll is called with empty list, '
        'Then selection is unchanged (no-op)',
        () {
          // Given
          notifier.enterSelectionMode('item-1');

          // When
          notifier.selectAll([]);

          // Then
          final state = _readState(container);
          expect(state.selectedIds, equals({'item-1'}));
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-SEL-002: cancel
    // -----------------------------------------------------------------------

    group('RQ-SEL-002 -- cancel', () {
      test(
        'Given selection mode active with multiple items selected, '
        'When cancel is called, '
        'Then isActive is false and selectedIds is empty',
        () {
          // Given
          notifier.enterSelectionMode('item-1');
          notifier.toggleItem('item-2');
          notifier.toggleItem('item-3');

          // When
          notifier.cancel();

          // Then
          final state = _readState(container);
          expect(state.isActive, isFalse);
          expect(state.selectedIds, isEmpty);
          expect(state.count, isZero);
        },
      );
    });

    // -----------------------------------------------------------------------
    // D-28: count getter
    // -----------------------------------------------------------------------

    group('D-28 -- count getter', () {
      test(
        'Given 3 items selected, '
        'When count is read, '
        'Then it returns 3',
        () {
          // Given
          notifier.enterSelectionMode('a');
          notifier.toggleItem('b');
          notifier.toggleItem('c');

          // Then
          expect(_readState(container).count, equals(3));
        },
      );
    });
  });
}
