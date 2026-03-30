// RQ-EXP-003
// Domain-level interface for native OS share.
// Pure Dart -- no dependency on Flutter or any share plugin.
// Model: Claude Opus 4.6

/// Contract for sharing a file via the native OS share mechanism -- RQ-EXP-003.
///
/// The concrete implementation lives in lib/data/services/.
abstract interface class ShareService {
  /// Shares the file at [filePath] via the native OS share sheet/dialog.
  /// [subject] is used as the share subject (e.g. email subject line).
  Future<void> shareFile(String filePath, {String subject});
}
