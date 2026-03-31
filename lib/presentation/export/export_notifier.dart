// RQ-EXP-001 / RQ-EXP-002 / RQ-EXP-003 / D-50 / D-56
// Riverpod AsyncNotifier for export operations (PDF, ZIP, share).
// Owns the async state for the generated file path.
// Model: Claude Opus 4.6

import 'dart:async';

import 'package:path/path.dart' as p;
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

abstract final class _ExportFileNames {
  _ExportFileNames._();

  static const String prefix = 'flutins_export_';
  static const String zipExtension = 'zip';
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
  /// files for the given [itemIds]. Shows a native OS save dialog to let the
  /// user choose the destination; falls back to the documents/home folder
  /// if the dialog is unavailable or cancelled -- RQ-EXP-002 / D-56.
  Future<void> exportZip(List<String> itemIds) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (_lastPdfPath == null) {
        throw StateError(ExportErrors.noPdfPath);
      }

      final items = await _loadItems(itemIds);

      // -- Resolve destination path via dialog + fallback (D-56)
      final saveLocationSvc = ref.read(saveLocationServiceProvider);
      final defaultFileName = _buildZipFileName(DateTime.now());
      final chosenPath = await saveLocationSvc.requestSavePath(
        defaultFileName: defaultFileName,
        extension: _ExportFileNames.zipExtension,
      );

      final String targetPath;
      if (chosenPath != null) {
        targetPath = chosenPath;
      } else {
        final fallbackDir = await saveLocationSvc.getFallbackDirectory();
        targetPath = p.join(fallbackDir, defaultFileName);
      }

      final service = ref.read(zipExportServiceProvider);
      return service.exportToZip(_lastPdfPath!, items, targetPath);
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

  /// Builds a default ZIP file name with a timestamp -- D-56.
  /// Example: `flutins_export_2026-03-31_130045.zip`
  String _buildZipFileName(DateTime now) {
    final timestamp =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}'
        '_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    return '${_ExportFileNames.prefix}$timestamp.${_ExportFileNames.zipExtension}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
