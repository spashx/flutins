// RQ-EXP-002
// Concrete ZIP export implementation using the `archive` package.
// Bundles the PDF report with all media files into a single ZIP archive.
// Model: Claude Opus 4.6

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/item.dart';
import '../../domain/services/zip_export_service.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _ZipStrings {
  _ZipStrings._();

  static const String filePrefix = 'flutins_export_';
  static const String fileExtension = '.zip';
  static const String mediaFolder = 'media';
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

/// Bundles a PDF report and all item media files into a ZIP archive
/// -- RQ-EXP-002.
class ZipExportServiceImpl implements ZipExportService {
  @override
  Future<String> exportToZip(String pdfPath, List<Item> items) async {
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

    // -- Encode and write
    final zipBytes = ZipEncoder().encode(archive);
    final outputPath = await _writeFile(zipBytes);
    return outputPath;
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  /// Replaces characters that are invalid in file/folder names with
  /// underscores.
  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Future<String> _writeFile(List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final timestamp =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}'
        '_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    final fileName =
        '${_ZipStrings.filePrefix}$timestamp${_ZipStrings.fileExtension}';
    final filePath = p.join(dir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }
}
