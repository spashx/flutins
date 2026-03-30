// RQ-EXP-001 / D-48
// Domain-level interface for PDF report generation.
// Pure Dart -- no dependency on Flutter, pdf package, or any infrastructure.
// Model: Claude Opus 4.6

import '../entities/item.dart';
import '../entities/tag.dart';

/// Contract for generating a PDF export report -- RQ-EXP-001 / D-48.
///
/// The concrete implementation lives in lib/data/services/.
abstract interface class PdfExportService {
  /// Generates a PDF report containing the given [items] with [tags] for label
  /// resolution. Returns the absolute path of the written PDF file.
  Future<String> exportToPdf(List<Item> items, List<Tag> tags);
}
