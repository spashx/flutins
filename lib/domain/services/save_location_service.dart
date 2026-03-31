// RQ-EXP-002 / D-53
// Domain-level interface for user-driven save-path selection.
// Pure Dart -- no dependency on Flutter, file_picker, or any infrastructure.
// Model: Claude Opus 4.6

/// Contract for obtaining a user-chosen save-file path via the native OS
/// file dialog, with a guaranteed fallback when the dialog is unavailable
/// or cancelled -- RQ-EXP-002 / D-53.
///
/// The concrete implementation lives in lib/data/services/.
abstract interface class SaveLocationService {
  /// Shows the native OS save-file dialog pre-populated with
  /// [defaultFileName] and filtered to [extension] (e.g. 'zip').
  ///
  /// Returns the user-chosen absolute path, or `null` if the dialog is
  /// unavailable or the user cancels.
  Future<String?> requestSavePath({
    required String defaultFileName,
    required String extension,
  });

  /// Returns a guaranteed-writable fallback directory path when no dialog
  /// path is available (documents folder, then downloads, then temp).
  Future<String> getFallbackDirectory();
}
