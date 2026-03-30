// RQ-EXP-001 / D-49
// Riverpod providers for export services.
// Model: Claude Opus 4.6

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/services/pdf_export_service.dart';
import '../services/pdf_export_service_impl.dart';

part 'export_providers.g.dart';

/// Provides the singleton [PdfExportService] backed by [PdfExportServiceImpl]
/// -- D-49 / RQ-EXP-001.
@Riverpod(keepAlive: true)
PdfExportService pdfExportService(PdfExportServiceRef ref) {
  return PdfExportServiceImpl();
}
