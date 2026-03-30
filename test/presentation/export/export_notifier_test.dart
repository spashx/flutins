// RQ-EXP-001 / D-50
// Unit tests for ExportNotifier: verifies PDF export triggers the service
// and handles error states. Uses a mock PdfExportService to avoid real
// file I/O and PDF generation in tests.
// Model: Claude Opus 4.6

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/data/database/app_database.dart';
import 'package:flutins/data/providers/database_providers.dart';
import 'package:flutins/data/providers/export_providers.dart';
import 'package:flutins/data/providers/repository_providers.dart';
import 'package:flutins/domain/entities/item.dart';
import 'package:flutins/domain/entities/tag.dart';
import 'package:flutins/domain/services/pdf_export_service.dart';
import 'package:flutins/presentation/export/export_notifier.dart';

import '../../helpers/test_database.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _itemId = 'item-001';
const _itemName = 'Test Item';
const _itemCategory = 'Electronics';
const _tagId = 'tag-001';
const _tagName = 'Valuable';
const _fakePdfPath = '/fake/path/flutins_export_2026-03-30.pdf';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _testItem = Item(
  id: _itemId,
  name: _itemName,
  category: _itemCategory,
  acquisitionDate: DateTime(2025, 1, 15),
  tagIds: const [_tagId],
  customProperties: const {},
  mediaAttachments: const [],
  createdAt: DateTime(2025, 1, 15),
  updatedAt: DateTime(2025, 1, 15),
);

const _testTag = Tag(id: _tagId, name: _tagName);

// ---------------------------------------------------------------------------
// Mock PdfExportService
// ---------------------------------------------------------------------------

class _FakePdfExportService implements PdfExportService {
  int callCount = 0;
  List<Item>? lastItems;
  List<Tag>? lastTags;
  bool shouldThrow = false;
  static const errorMessage = 'PDF generation failed';

  @override
  Future<String> exportToPdf(List<Item> items, List<Tag> tags) async {
    callCount++;
    lastItems = items;
    lastTags = tags;
    if (shouldThrow) {
      throw StateError(errorMessage);
    }
    return _fakePdfPath;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer(
  AppDatabase db,
  _FakePdfExportService fakeService,
) {
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      pdfExportServiceProvider.overrideWithValue(fakeService),
    ],
  );
}

ExportNotifier _readNotifier(ProviderContainer container) =>
    container.read(exportNotifierProvider.notifier);

/// Saves a test item via the repository so it can be found by the notifier.
Future<void> _seedItem(ProviderContainer container) async {
  final repo = container.read(itemRepositoryProvider);
  await repo.saveItem(_testItem);
}

/// Saves a test tag via the repository.
Future<void> _seedTag(ProviderContainer container) async {
  final repo = container.read(tagRepositoryProvider);
  await repo.saveTag(_testTag);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ExportNotifier --', () {
    late AppDatabase db;
    late ProviderContainer container;
    late ExportNotifier notifier;
    late _FakePdfExportService fakeService;

    setUp(() {
      db = createTestDatabase();
      fakeService = _FakePdfExportService();
      container = _makeContainer(db, fakeService);
      container.listen(exportNotifierProvider, (_, next) {});
      notifier = _readNotifier(container);
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    // -----------------------------------------------------------------------
    // RQ-EXP-001: exportPdf -- success
    // -----------------------------------------------------------------------

    group('RQ-EXP-001 -- exportPdf (success)', () {
      test(
        'Given an item and tag exist in the database, '
        'When exportPdf is called with the item id, '
        'Then the notifier state contains the PDF file path',
        () async {
          // Given
          await _seedItem(container);
          await _seedTag(container);

          // When
          await notifier.exportPdf([_itemId]);

          // Then
          final state = container.read(exportNotifierProvider);
          expect(state.valueOrNull, _fakePdfPath);
          expect(fakeService.callCount, 1);
          expect(fakeService.lastItems, hasLength(1));
          expect(fakeService.lastItems!.first.id, _itemId);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-EXP-001: exportPdf -- empty selection
    // -----------------------------------------------------------------------

    group('RQ-EXP-001 -- exportPdf (no items found)', () {
      test(
        'Given no items exist for the given ids, '
        'When exportPdf is called, '
        'Then the notifier state is AsyncError with noItemsFound message',
        () async {
          // When
          await notifier.exportPdf(['nonexistent-id']);

          // Then
          final state = container.read(exportNotifierProvider);
          expect(state.hasError, isTrue);
          expect(
            state.error.toString(),
            contains(ExportErrors.noItemsFound),
          );
          expect(fakeService.callCount, 0);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-EXP-001: exportPdf -- service failure
    // -----------------------------------------------------------------------

    group('RQ-EXP-001 -- exportPdf (service error)', () {
      test(
        'Given the PDF export service throws an error, '
        'When exportPdf is called, '
        'Then the notifier state is AsyncError with the service error',
        () async {
          // Given
          await _seedItem(container);
          await _seedTag(container);
          fakeService.shouldThrow = true;

          // When
          await notifier.exportPdf([_itemId]);

          // Then
          final state = container.read(exportNotifierProvider);
          expect(state.hasError, isTrue);
          expect(
            state.error.toString(),
            contains(_FakePdfExportService.errorMessage),
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-EXP-001: initial state is idle (null)
    // -----------------------------------------------------------------------

    group('RQ-EXP-001 -- initial state', () {
      test(
        'Given the notifier is freshly built, '
        'When its state is read, '
        'Then it is AsyncData(null) (idle)',
        () {
          // Then
          final state = container.read(exportNotifierProvider);
          expect(state.hasValue, isTrue);
          expect(state.valueOrNull, isNull);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-EXP-001: tags are passed to service
    // -----------------------------------------------------------------------

    group('RQ-EXP-001 -- tag resolution', () {
      test(
        'Given an item with tagIds and corresponding tags exist, '
        'When exportPdf is called, '
        'Then the service receives the resolved tag list',
        () async {
          // Given
          await _seedItem(container);
          await _seedTag(container);

          // When
          await notifier.exportPdf([_itemId]);

          // Then
          expect(fakeService.lastTags, isNotNull);
          expect(fakeService.lastTags!.any((t) => t.id == _tagId), isTrue);
        },
      );
    });
  });
}
