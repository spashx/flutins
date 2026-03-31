// RQ-EXP-002 / D-54
// Concrete save-location implementation using file_picker + path_provider
// fallback chain.
// Model: Claude Opus 4.6

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/services/save_location_service.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _SaveLocationStrings {
  _SaveLocationStrings._();

  static const String dialogTitle = 'Save archive';
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

/// Uses `FilePicker.platform.saveFile` as the primary path selector and falls
/// back through `path_provider` directories when the dialog is cancelled or
/// unavailable -- D-54 / RQ-EXP-002.
class SaveLocationServiceImpl implements SaveLocationService {
  @override
  Future<String?> requestSavePath({
    required String defaultFileName,
    required String extension,
  }) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: _SaveLocationStrings.dialogTitle,
      fileName: defaultFileName,
      type: FileType.custom,
      allowedExtensions: [extension],
    );
    return result;
  }

  @override
  Future<String> getFallbackDirectory() async {
    // 1. Documents folder (Windows + Android)
    try {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    } on Object {
      // Intentionally broad catch -- path_provider can throw
      // MissingPluginException on unsupported platforms.
    }

    // 2. Downloads folder (Windows only)
    try {
      final dir = await getDownloadsDirectory();
      if (dir != null) return dir.path;
    } on Object {
      // Same rationale as above.
    }

    // 3. Temp directory -- guaranteed writable on all platforms
    final dir = await getTemporaryDirectory();
    return dir.path;
  }
}
