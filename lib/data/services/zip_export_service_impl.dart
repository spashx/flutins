// RQ-EXP-002 / D-55
// Concrete ZIP export implementation using the `archive` package.
// Bundles the PDF report with all media files into a single ZIP archive.
// Writes to the caller-provided targetPath (D-55).
// Model: Claude Opus 4.6

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/item.dart';
import '../../domain/services/zip_export_service.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _ZipStrings {
  _ZipStrings._();

  static const String mediaFolder = 'media';
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

/// Bundles a PDF report and all item media files into a ZIP archive
/// -- RQ-EXP-002 / D-55.
class ZipExportServiceImpl implements ZipExportService {
  @override
  Future<String> exportToZip(
    String pdfPath,
    List<Item> items,
    String targetPath,
  ) async {
    final archive = Archive();

    // -- Add the PDF report
    final pdfFile = File(pdfPath);
    final pdfBytes = await pdfFile.readAsBytes();
    archive.addFile(ArchiveFile(
      p.basename(pdfPath),
      pdfBytes.length,
      pdfBytes,
    ));

    // -- Add all media files, organized per item
    final addedPaths = <String>{};
    for (final item in items) {
      for (final attachment in item.mediaAttachments) {
        // Avoid duplicates if items share a file path
        if (addedPaths.contains(attachment.filePath)) continue;

        final mediaFile = File(attachment.filePath);
        if (!mediaFile.existsSync()) continue;

        final bytes = await mediaFile.readAsBytes();
        final archivePath = p.join(
          _ZipStrings.mediaFolder,
          _sanitizeFileName(item.name),
          attachment.fileName,
        );
        archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
        addedPaths.add(attachment.filePath);
      }
    }

    // -- Encode and write to the caller-provided path (D-55)
    final zipBytes = ZipEncoder().encode(archive);
    final file = File(targetPath);
    await file.writeAsBytes(zipBytes);
    return targetPath;
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  /// Replaces characters that are invalid in file/folder names with
  /// underscores.
  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}
