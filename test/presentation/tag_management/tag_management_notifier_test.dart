// RQ-TAG-002 / RQ-TAG-004 / D-41
// Unit tests for TagManagementNotifier: verifies save and delete mutations
// against a real in-memory database.
// Model: Claude Opus 4.6

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/data/database/app_database.dart';
import 'package:flutins/data/providers/database_providers.dart';
import 'package:flutins/domain/entities/tag.dart';
import 'package:flutins/presentation/home/tag_list_provider.dart';
import 'package:flutins/presentation/tag_management/tag_management_notifier.dart';

import '../../helpers/test_database.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _tagId = 'tag-001';
const _tagName = 'Electronics';
const _tagNameRenamed = 'Appliances';
const _tag = Tag(id: _tagId, name: _tagName);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer(AppDatabase db) {
  return ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
  );
}

TagManagementNotifier _readNotifier(ProviderContainer container) =>
    container.read(tagManagementNotifierProvider.notifier);

/// Waits for the tag list stream to emit its first non-loading value.
Future<List<Tag>> _awaitTagList(ProviderContainer container) async {
  container.listen(tagListProvider, (_, next) {});
  return container.read(tagListProvider.future);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TagManagementNotifier --', () {
    late AppDatabase db;
    late ProviderContainer container;
    late TagManagementNotifier notifier;

    setUp(() {
      db = createTestDatabase();
      container = _makeContainer(db);
      // Keep notifier alive for the duration of the test.
      container.listen(tagManagementNotifierProvider, (_, next) {});
      notifier = _readNotifier(container);
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    // -----------------------------------------------------------------------
    // RQ-TAG-002: save (create)
    // -----------------------------------------------------------------------

    group('RQ-TAG-002 -- saveTag (create)', () {
      test(
        'Given an empty database, '
        'When saveTag is called with a new Tag, '
        'Then the tag list stream contains that tag',
        () async {
          // When
          await notifier.saveTag(_tag);

          // Then
          final tags = await _awaitTagList(container);
          expect(tags, hasLength(1));
          expect(tags.first.id, _tagId);
          expect(tags.first.name, _tagName);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-TAG-002: save (update / rename)
    // -----------------------------------------------------------------------

    group('RQ-TAG-002 -- saveTag (rename)', () {
      test(
        'Given a tag exists in the database, '
        'When saveTag is called with the same id and a new name, '
        'Then the tag list stream contains the tag with the updated name',
        () async {
          // Given
          await notifier.saveTag(_tag);

          // When
          final renamed = _tag.copyWith(name: _tagNameRenamed);
          await notifier.saveTag(renamed);

          // Then
          final tags = await _awaitTagList(container);
          expect(tags, hasLength(1));
          expect(tags.first.name, _tagNameRenamed);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-TAG-002 / RQ-TAG-004: delete
    // -----------------------------------------------------------------------

    group('RQ-TAG-002 / RQ-TAG-004 -- deleteTag', () {
      test(
        'Given a tag exists in the database, '
        'When deleteTag is called with that tag id, '
        'Then the tag list stream is empty',
        () async {
          // Given
          await notifier.saveTag(_tag);

          // When
          await notifier.deleteTag(_tagId);

          // Then
          final tags = await _awaitTagList(container);
          expect(tags, isEmpty);
        },
      );
    });

    // -----------------------------------------------------------------------
    // State transitions
    // -----------------------------------------------------------------------

    group('state transitions', () {
      test(
        'Given an idle notifier, '
        'When saveTag completes successfully, '
        'Then state is AsyncData',
        () async {
          // When
          await notifier.saveTag(_tag);

          // Then
          final state = container.read(tagManagementNotifierProvider);
          expect(state, isA<AsyncData<void>>());
        },
      );

      test(
        'Given an idle notifier, '
        'When deleteTag completes successfully, '
        'Then state is AsyncData',
        () async {
          // Given
          await notifier.saveTag(_tag);

          // When
          await notifier.deleteTag(_tagId);

          // Then
          final state = container.read(tagManagementNotifierProvider);
          expect(state, isA<AsyncData<void>>());
        },
      );
    });
  });
}
