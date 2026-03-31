// RQ-EXP-001 / RQ-EXP-002 / RQ-EXP-003 / D-49
// Riverpod providers for export services.
// Model: Claude Opus 4.6

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/services/pdf_export_service.dart';
import '../../domain/services/save_location_service.dart';
import '../../domain/services/share_service.dart';
import '../../domain/services/zip_export_service.dart';
import '../services/pdf_export_service_impl.dart';
import '../services/save_location_service_impl.dart';
import '../services/share_service_impl.dart';
import '../services/zip_export_service_impl.dart';

part 'export_providers.g.dart';

/// Provides the singleton [PdfExportService] backed by [PdfExportServiceImpl]
/// -- D-49 / RQ-EXP-001.
@Riverpod(keepAlive: true)
PdfExportService pdfExportService(PdfExportServiceRef ref) {
  return PdfExportServiceImpl();
}

/// Provides the singleton [ZipExportService] backed by [ZipExportServiceImpl]
/// -- RQ-EXP-002.
@Riverpod(keepAlive: true)
ZipExportService zipExportService(ZipExportServiceRef ref) {
  return ZipExportServiceImpl();
}

/// Provides the singleton [SaveLocationService] backed by
/// [SaveLocationServiceImpl] -- D-57 / RQ-EXP-002.
@Riverpod(keepAlive: true)
SaveLocationService saveLocationService(SaveLocationServiceRef ref) {
  return SaveLocationServiceImpl();
}

/// Provides the singleton [ShareService] backed by [ShareServiceImpl]
/// -- RQ-EXP-003.
@Riverpod(keepAlive: true)
ShareService shareService(ShareServiceRef ref) {
  return ShareServiceImpl();
}
