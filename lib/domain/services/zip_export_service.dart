// RQ-EXP-002 / D-48
// Domain-level interface for ZIP archive export.
// Pure Dart -- no dependency on Flutter, archive package, or any infrastructure.
// Model: Claude Opus 4.6

import '../entities/item.dart';

/// Contract for generating a ZIP archive containing a PDF and all media
/// files for the given items -- RQ-EXP-002.
///
/// The concrete implementation lives in lib/data/services/.
abstract interface class ZipExportService {
  /// Creates a ZIP archive containing the PDF at [pdfPath] and all media
  /// files referenced by [items]. Returns the absolute path of the ZIP file.
  Future<String> exportToZip(String pdfPath, List<Item> items);
}
