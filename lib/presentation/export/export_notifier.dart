// RQ-EXP-001 / D-50
// Riverpod AsyncNotifier for export operations (PDF, future: ZIP).
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
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Async controller for export operations -- RQ-EXP-001 / D-50.
///
/// State is `AsyncValue<String?>`:
/// - `AsyncData(null)` -- idle.
/// - `AsyncLoading` -- export in progress.
/// - `AsyncData(filePath)` -- export completed; holds the output file path.
/// - `AsyncError` -- generation failed.
@riverpod
class ExportNotifier extends _$ExportNotifier {
  @override
  FutureOr<String?> build() => null;

  /// Generates a PDF report for the items identified by [itemIds] and stores
  /// the resulting file path in state -- RQ-EXP-001.
  Future<void> exportPdf(List<String> itemIds) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(itemRepositoryProvider);
      final items = <Item>[];
      for (final id in itemIds) {
        final item = await repo.getItemById(id);
        if (item != null) items.add(item);
      }
      if (items.isEmpty) {
        throw StateError(ExportErrors.noItemsFound);
      }

      // Resolve tags for label display in the PDF
      final tagRepo = ref.read(tagRepositoryProvider);
      final tags = await tagRepo.watchTags().first;

      final service = ref.read(pdfExportServiceProvider);
      return service.exportToPdf(items, tags);
    });
  }
}
