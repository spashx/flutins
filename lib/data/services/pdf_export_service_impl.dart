// RQ-EXP-001 / D-48
// Concrete PDF export implementation using the `pdf` package.
// Assembles a multi-page PDF report with item data, photos, and metadata.
// Model: Claude Opus 4.6

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/item.dart';
import '../../domain/entities/media_attachment.dart';
import '../../domain/entities/tag.dart';
import '../../domain/services/pdf_export_service.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _PdfStrings {
  _PdfStrings._();

  static const String coverTitle = 'Flutins - Asset Inventory Report';
  static const String coverDatePrefix = 'Generated on: ';
  static const String coverItemCountPrefix = 'Items: ';
  static const String labelCategory = 'Category';
  static const String labelAcquisitionDate = 'Acquisition Date';
  static const String labelSerialNumber = 'Serial Number';
  static const String labelTags = 'Tags';
  static const String labelCustomProperties = 'Custom Properties';
  static const String labelDocuments = 'Documents';
  static const String filePrefix = 'flutins_export_';
  static const String fileExtension = '.pdf';
}

abstract final class _PdfLayout {
  _PdfLayout._();

  static const double coverTitleFontSize = 24.0;
  static const double coverSubtitleFontSize = 14.0;
  static const double sectionHeaderFontSize = 18.0;
  static const double labelFontSize = 10.0;
  static const double valueFontSize = 12.0;
  static const double mainPhotoMaxHeight = 200.0;
  static const double thumbnailSize = 80.0;
  static const double sectionSpacing = 12.0;
  static const double fieldSpacing = 4.0;
  static const int thumbnailsPerRow = 4;
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

/// Generates a styled PDF report from a list of items -- RQ-EXP-001 / D-48.
class PdfExportServiceImpl implements PdfExportService {
  @override
  Future<String> exportToPdf(List<Item> items, List<Tag> tags) async {
    final tagMap = {for (final t in tags) t.id: t.name};

    final pdf = pw.Document();

    // -- Cover page
    pdf.addPage(_buildCoverPage(items));

    // -- One section per item
    for (final item in items) {
      pdf.addPage(_buildItemPage(item, tagMap));
    }

    // -- Write file
    final bytes = await pdf.save();
    final outputPath = await _writeFile(bytes);
    return outputPath;
  }

  // -----------------------------------------------------------------------
  // Cover page
  // -----------------------------------------------------------------------

  pw.Page _buildCoverPage(List<Item> items) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}';

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                _PdfStrings.coverTitle,
                style: pw.TextStyle(
                  fontSize: _PdfLayout.coverTitleFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: _PdfLayout.sectionSpacing),
              pw.Text(
                '${_PdfStrings.coverDatePrefix}$dateStr',
                style: const pw.TextStyle(
                  fontSize: _PdfLayout.coverSubtitleFontSize,
                ),
              ),
              pw.SizedBox(height: _PdfLayout.fieldSpacing),
              pw.Text(
                '${_PdfStrings.coverItemCountPrefix}${items.length}',
                style: const pw.TextStyle(
                  fontSize: _PdfLayout.coverSubtitleFontSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------------------
  // Item page
  // -----------------------------------------------------------------------

  pw.Page _buildItemPage(Item item, Map<String, String> tagMap) {
    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        final widgets = <pw.Widget>[];

        // -- Header: item name
        widgets.add(
          pw.Text(
            item.name,
            style: pw.TextStyle(
              fontSize: _PdfLayout.sectionHeaderFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
        widgets.add(pw.SizedBox(height: _PdfLayout.sectionSpacing));

        // -- Core properties table
        widgets.add(_buildPropertyRow(
          _PdfStrings.labelCategory,
          item.category,
        ));
        widgets.add(_buildPropertyRow(
          _PdfStrings.labelAcquisitionDate,
          _formatDate(item.acquisitionDate),
        ));
        if (item.serialNumber != null && item.serialNumber!.isNotEmpty) {
          widgets.add(_buildPropertyRow(
            _PdfStrings.labelSerialNumber,
            item.serialNumber!,
          ));
        }

        // -- Tags
        if (item.tagIds.isNotEmpty) {
          final tagNames = item.tagIds
              .map((id) => tagMap[id] ?? id)
              .join(', ');
          widgets.add(_buildPropertyRow(_PdfStrings.labelTags, tagNames));
        }

        // -- Custom properties
        if (item.customProperties.isNotEmpty) {
          widgets.add(pw.SizedBox(height: _PdfLayout.sectionSpacing));
          widgets.add(
            pw.Text(
              _PdfStrings.labelCustomProperties,
              style: pw.TextStyle(
                fontSize: _PdfLayout.valueFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          );
          for (final entry in item.customProperties.entries) {
            widgets.add(_buildPropertyRow(entry.key, entry.value));
          }
        }

        // -- Main photo
        final mainPhoto = item.mediaAttachments
            .where((a) => a.isMainPhoto && a.type == MediaType.photo)
            .firstOrNull;
        if (mainPhoto != null) {
          final imageWidget = _tryBuildImage(mainPhoto.filePath,
              height: _PdfLayout.mainPhotoMaxHeight);
          if (imageWidget != null) {
            widgets.add(pw.SizedBox(height: _PdfLayout.sectionSpacing));
            widgets.add(imageWidget);
          }
        }

        // -- Additional photos as thumbnail grid
        final additionalPhotos = item.mediaAttachments
            .where((a) => !a.isMainPhoto && a.type == MediaType.photo)
            .toList();
        if (additionalPhotos.isNotEmpty) {
          widgets.add(pw.SizedBox(height: _PdfLayout.sectionSpacing));
          widgets.add(_buildPhotoGrid(additionalPhotos));
        }

        // -- Document filenames
        final documents = item.mediaAttachments
            .where((a) => a.type == MediaType.document)
            .toList();
        if (documents.isNotEmpty) {
          widgets.add(pw.SizedBox(height: _PdfLayout.sectionSpacing));
          widgets.add(
            pw.Text(
              _PdfStrings.labelDocuments,
              style: pw.TextStyle(
                fontSize: _PdfLayout.valueFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          );
          for (final doc in documents) {
            widgets.add(pw.Bullet(text: doc.fileName));
          }
        }

        return widgets;
      },
    );
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  pw.Widget _buildPropertyRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: _PdfLayout.fieldSpacing),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: _PdfLayout.labelFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: _PdfLayout.valueFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPhotoGrid(List<MediaAttachment> photos) {
    final rows = <pw.Widget>[];
    for (var i = 0; i < photos.length; i += _PdfLayout.thumbnailsPerRow) {
      final chunk = photos.skip(i).take(_PdfLayout.thumbnailsPerRow);
      final cells = <pw.Widget>[];
      for (final photo in chunk) {
        final img = _tryBuildImage(
          photo.filePath,
          width: _PdfLayout.thumbnailSize,
          height: _PdfLayout.thumbnailSize,
        );
        cells.add(img ?? pw.SizedBox(
          width: _PdfLayout.thumbnailSize,
          height: _PdfLayout.thumbnailSize,
        ));
      }
      rows.add(pw.Row(
        children: cells,
      ));
    }
    return pw.Column(children: rows);
  }

  pw.Widget? _tryBuildImage(
    String filePath, {
    double? width,
    double? height,
  }) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;
      final bytes = file.readAsBytesSync();
      if (bytes.isEmpty) return null;
      final image = pw.MemoryImage(Uint8List.fromList(bytes));
      return pw.Image(image, width: width, height: height);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_pad(date.month)}-${_pad(date.day)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Future<String> _writeFile(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final timestamp =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}'
        '_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    final fileName =
        '${_PdfStrings.filePrefix}$timestamp${_PdfStrings.fileExtension}';
    final filePath = p.join(dir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }
}
