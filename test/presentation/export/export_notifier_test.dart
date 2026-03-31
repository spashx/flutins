// RQ-EXP-001 / RQ-EXP-002 / D-50 / D-56
// Unit tests for ExportNotifier: verifies PDF export, ZIP export with
// save-location dialog + fallback, and share. Uses fake services to avoid
// real file I/O in tests.
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
import 'package:flutins/domain/services/save_location_service.dart';
import 'package:flutins/domain/services/share_service.dart';
import 'package:flutins/domain/services/zip_export_service.dart';
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
const _fakeChosenPath = '/user/chosen/path/flutins_export_2026-03-30.zip';
const _fakeFallbackDir = '/fake/fallback/documents';

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
// Mock ZipExportService
// ---------------------------------------------------------------------------

class _FakeZipExportService implements ZipExportService {
  int callCount = 0;
  String? lastPdfPath;
  List<Item>? lastItems;
  String? lastTargetPath;
  bool shouldThrow = false;
  static const errorMessage = 'ZIP generation failed';

  @override
  Future<String> exportToZip(
    String pdfPath,
    List<Item> items,
    String targetPath,
  ) async {
    callCount++;
    lastPdfPath = pdfPath;
    lastItems = items;
    lastTargetPath = targetPath;
    if (shouldThrow) {
      throw StateError(errorMessage);
    }
    return targetPath;
  }
}

// ---------------------------------------------------------------------------
// Mock SaveLocationService
// ---------------------------------------------------------------------------

class _FakeSaveLocationService implements SaveLocationService {
  /// When non-null, requestSavePath returns this path (simulates user pick).
  /// When null, simulates dialog cancelled / unavailable.
  String? pathToReturn;
  String fallbackDir = _fakeFallbackDir;
  int requestCallCount = 0;
  int fallbackCallCount = 0;

  @override
  Future<String?> requestSavePath({
    required String defaultFileName,
    required String extension,
  }) async {
    requestCallCount++;
    return pathToReturn;
  }

  @override
  Future<String> getFallbackDirectory() async {
    fallbackCallCount++;
    return fallbackDir;
  }
}

// ---------------------------------------------------------------------------
// Mock ShareService
// ---------------------------------------------------------------------------

class _FakeShareService implements ShareService {
  int callCount = 0;
  String? lastFilePath;
  String? lastSubject;
  bool shouldThrow = false;
  static const errorMessage = 'Share failed';

  @override
  Future<void> shareFile(String filePath, {String subject = ''}) async {
    callCount++;
    lastFilePath = filePath;
    lastSubject = subject;
    if (shouldThrow) {
      throw StateError(errorMessage);
    }
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer(
  AppDatabase db,
  _FakePdfExportService fakeService, {
  _FakeZipExportService? zipService,
  _FakeShareService? shareService,
  _FakeSaveLocationService? saveLocationService,
}) {
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      pdfExportServiceProvider.overrideWithValue(fakeService),
      if (zipService != null)
        zipExportServiceProvider.overrideWithValue(zipService),
      if (shareService != null)
        shareServiceProvider.overrideWithValue(shareService),
      if (saveLocationService != null)
        saveLocationServiceProvider.overrideWithValue(saveLocationService),
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

  // =========================================================================
  // RQ-EXP-002: exportZip
  // =========================================================================

  group('ExportNotifier -- exportZip --', () {
    late AppDatabase db;
    late ProviderContainer container;
    late ExportNotifier notifier;
    late _FakePdfExportService fakePdfService;
    late _FakeZipExportService fakeZipService;
    late _FakeSaveLocationService fakeSaveLocationService;

    setUp(() {
      db = createTestDatabase();
      fakePdfService = _FakePdfExportService();
      fakeZipService = _FakeZipExportService();
      fakeSaveLocationService = _FakeSaveLocationService();
      container = _makeContainer(
        db,
        fakePdfService,
        zipService: fakeZipService,
        saveLocationService: fakeSaveLocationService,
      );
      container.listen(exportNotifierProvider, (_, next) {});
      notifier = _readNotifier(container);
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    // -----------------------------------------------------------------------
    // RQ-EXP-002: exportZip -- success with user-chosen path (D-56)
    // -----------------------------------------------------------------------

    group('RQ-EXP-002 -- exportZip (user picks save location)', () {
      test(
        'Given a PDF was already generated and items exist, '
        'When the user chooses a save location via the OS file dialog, '
        'Then the ZIP is written to the user-chosen path',
        () async {
          // Given
          await _seedItem(container);
          await _seedTag(container);
          await notifier.exportPdf([_itemId]);
          fakeSaveLocationService.pathToReturn = _fakeChosenPath;

          // When
          await notifier.exportZip([_itemId]);

          // Then
          final state = container.read(exportNotifierProvider);
          expect(state.valueOrNull, _fakeChosenPath);
          expect(fakeZipService.callCount, 1);
          expect(fakeZipService.lastPdfPath, _fakePdfPath);
          expect(fakeZipService.lastTargetPath, _fakeChosenPath);
          expect(fakeZipService.lastItems, hasLength(1));
          expect(fakeZipService.lastItems!.first.id, _itemId);
          expect(fakeSaveLocationService.requestCallCount, 1);
          expect(fakeSaveLocationService.fallbackCallCount, 0);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-EXP-002: exportZip -- fallback when dialog cancelled (D-56)
    // -----------------------------------------------------------------------

    group('RQ-EXP-002 -- exportZip (dialog cancelled, fallback used)', () {
      test(
        'Given a PDF was already generated and items exist, '
        'When the save dialog returns null (cancelled or unavailable), '
        'Then the ZIP is written to the fallback documents directory',
        () async {
          // Given
          await _seedItem(container);
          await _seedTag(container);
          await notifier.exportPdf([_itemId]);
          fakeSaveLocationService.pathToReturn = null;

          // When
          await notifier.exportZip([_itemId]);

          // Then
          final state = container.read(exportNotifierProvider);
          expect(state.hasValue, isTrue);
          final path = state.valueOrNull!;
          expect(path, startsWith(_fakeFallbackDir));
          expect(path, endsWith('.zip'));
          expect(fakeZipService.callCount, 1);
          expect(fakeZipService.lastTargetPath, path);
          expect(fakeSaveLocationService.requestCallCount, 1);
          expect(fakeSaveLocationService.fallbackCallCount, 1);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-EXP-002: exportZip -- no PDF generated
    // -----------------------------------------------------------------------

    group('RQ-EXP-002 -- exportZip (no PDF generated)', () {
      test(
        'Given no PDF has been generated yet, '
        'When exportZip is called, '
        'Then the notifier state is AsyncError with noPdfPath message',
        () async {
          // Given
          await _seedItem(container);

          // When
          await notifier.exportZip([_itemId]);

          // Then
          final state = container.read(exportNotifierProvider);
          expect(state.hasError, isTrue);
          expect(
            state.error.toString(),
            contains(ExportErrors.noPdfPath),
          );
          expect(fakeZipService.callCount, 0);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-EXP-002: exportZip -- service failure
    // -----------------------------------------------------------------------

    group('RQ-EXP-002 -- exportZip (service error)', () {
      test(
        'Given the ZIP export service throws an error, '
        'When exportZip is called, '
        'Then the notifier state is AsyncError with the service error',
        () async {
          // Given
          await _seedItem(container);
          await _seedTag(container);
          await notifier.exportPdf([_itemId]);
          fakeSaveLocationService.pathToReturn = _fakeChosenPath;
          fakeZipService.shouldThrow = true;

          // When
          await notifier.exportZip([_itemId]);

          // Then
          final state = container.read(exportNotifierProvider);
          expect(state.hasError, isTrue);
          expect(
            state.error.toString(),
            contains(_FakeZipExportService.errorMessage),
          );
        },
      );
    });
  });

  // =========================================================================
  // RQ-EXP-003: shareFile
  // =========================================================================

  group('ExportNotifier -- shareFile --', () {
    late AppDatabase db;
    late ProviderContainer container;
    late ExportNotifier notifier;
    late _FakePdfExportService fakePdfService;
    late _FakeShareService fakeShareService;

    setUp(() {
      db = createTestDatabase();
      fakePdfService = _FakePdfExportService();
      fakeShareService = _FakeShareService();
      container = _makeContainer(
        db,
        fakePdfService,
        shareService: fakeShareService,
      );
      container.listen(exportNotifierProvider, (_, next) {});
      notifier = _readNotifier(container);
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    // -----------------------------------------------------------------------
    // RQ-EXP-003: shareFile -- success
    // -----------------------------------------------------------------------

    group('RQ-EXP-003 -- shareFile (success)', () {
      test(
        'Given a PDF was already generated, '
        'When shareFile is called, '
        'Then the share service receives the current file path',
        () async {
          // Given
          await _seedItem(container);
          await _seedTag(container);
          await notifier.exportPdf([_itemId]);

          // When
          await notifier.shareFile();

          // Then
          expect(fakeShareService.callCount, 1);
          expect(fakeShareService.lastFilePath, _fakePdfPath);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-EXP-003: shareFile -- no file generated
    // -----------------------------------------------------------------------

    group('RQ-EXP-003 -- shareFile (no file generated)', () {
      test(
        'Given no file has been generated yet, '
        'When shareFile is called, '
        'Then the notifier state is AsyncError with noFilePath message',
        () async {
          // When
          await notifier.shareFile();

          // Then
          final state = container.read(exportNotifierProvider);
          expect(state.hasError, isTrue);
          expect(
            state.error.toString(),
            contains(ExportErrors.noFilePath),
          );
          expect(fakeShareService.callCount, 0);
        },
      );
    });
  });
}
