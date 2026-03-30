// RQ-SCR-004 / D-32
// Unit tests for SearchNotifier: verifies setQuery, clear, and initial state.
// Model: Claude Opus 4.6

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/presentation/home/search_notifier.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer() {
  return ProviderContainer();
}

String _readQuery(ProviderContainer container) =>
    container.read(searchNotifierProvider);

SearchNotifier _readNotifier(ProviderContainer container) =>
    container.read(searchNotifierProvider.notifier);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SearchNotifier -- D-32 / RQ-SCR-004', () {
    late ProviderContainer container;
    late SearchNotifier notifier;

    setUp(() {
      container = _makeContainer();
      // Keep alive so auto-dispose does not fire mid-test.
      container.listen(searchNotifierProvider, (_, _) {});
      notifier = _readNotifier(container);
    });

    tearDown(() {
      container.dispose();
    });

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------

    test(
      'Given a fresh SearchNotifier, '
      'When no action has been taken, '
      'Then the query is an empty string',
      () {
        // Then
        expect(_readQuery(container), isEmpty);
      },
    );

    // -----------------------------------------------------------------------
    // setQuery
    // -----------------------------------------------------------------------

    test(
      'Given an empty query, '
      'When setQuery is called with "camera", '
      'Then the query equals "camera"',
      () {
        // When
        notifier.setQuery('camera');

        // Then
        expect(_readQuery(container), equals('camera'));
      },
    );

    test(
      'Given query is "camera", '
      'When setQuery is called with "lens", '
      'Then the query equals "lens"',
      () {
        // Given
        notifier.setQuery('camera');

        // When
        notifier.setQuery('lens');

        // Then
        expect(_readQuery(container), equals('lens'));
      },
    );

    // -----------------------------------------------------------------------
    // clear
    // -----------------------------------------------------------------------

    test(
      'Given query is "camera", '
      'When clear is called, '
      'Then the query is an empty string',
      () {
        // Given
        notifier.setQuery('camera');

        // When
        notifier.clear();

        // Then
        expect(_readQuery(container), isEmpty);
      },
    );

    test(
      'Given query is already empty, '
      'When clear is called, '
      'Then the query remains an empty string',
      () {
        // When
        notifier.clear();

        // Then
        expect(_readQuery(container), isEmpty);
      },
    );
  });
}
