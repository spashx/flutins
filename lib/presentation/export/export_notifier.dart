// RQ-EXP-001 / RQ-EXP-002 / RQ-EXP-003 / D-50
// Riverpod AsyncNotifier for export operations (PDF, ZIP, share).
// Owns the async state for the generated file path.
// Model: Claude Opus 4.6

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/export_providers.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/entities/item.dart';

part 'export_notifier.g.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class ExportErrors {
  ExportErrors._();

  static const String noItemsFound = 'No items found for the given ids.';
  static const String noPdfPath = 'No PDF has been generated yet.';
  static const String noFilePath = 'No file has been generated yet.';
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Async controller for export operations -- RQ-EXP-001 / RQ-EXP-002 / D-50.
///
/// State is `AsyncValue<String?>`:
/// - `AsyncData(null)` -- idle.
/// - `AsyncLoading` -- export in progress.
/// - `AsyncData(filePath)` -- export completed; holds the output file path.
/// - `AsyncError` -- generation failed.
@riverpod
class ExportNotifier extends _$ExportNotifier {
  /// Tracks the last generated PDF path so exportZip can reference it.
  String? _lastPdfPath;

  @override
  FutureOr<String?> build() => null;

  /// Generates a PDF report for the items identified by [itemIds] and stores
  /// the resulting file path in state -- RQ-EXP-001.
  Future<void> exportPdf(List<String> itemIds) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final items = await _loadItems(itemIds);

      // Resolve tags for label display in the PDF
      final tagRepo = ref.read(tagRepositoryProvider);
      final tags = await tagRepo.watchTags().first;

      final service = ref.read(pdfExportServiceProvider);
      final path = await service.exportToPdf(items, tags);
      _lastPdfPath = path;
      return path;
    });
  }

  /// Creates a ZIP archive containing the last generated PDF and all media
  /// files for the given [itemIds] -- RQ-EXP-002.
  Future<void> exportZip(List<String> itemIds) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (_lastPdfPath == null) {
        throw StateError(ExportErrors.noPdfPath);
      }

      final items = await _loadItems(itemIds);
      final service = ref.read(zipExportServiceProvider);
      return service.exportToZip(_lastPdfPath!, items);
    });
  }

  /// Shares the current exported file via the native OS share mechanism
  /// -- RQ-EXP-003.
  Future<void> shareFile() async {
    final currentPath = state.valueOrNull;
    if (currentPath == null) {
      state = AsyncError(StateError(ExportErrors.noFilePath), StackTrace.current);
      return;
    }

    final service = ref.read(shareServiceProvider);
    await service.shareFile(currentPath);
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  Future<List<Item>> _loadItems(List<String> itemIds) async {
    final repo = ref.read(itemRepositoryProvider);
    final items = <Item>[];
    for (final id in itemIds) {
      final item = await repo.getItemById(id);
      if (item != null) items.add(item);
    }
    if (items.isEmpty) {
      throw StateError(ExportErrors.noItemsFound);
    }
    return items;
  }
}
