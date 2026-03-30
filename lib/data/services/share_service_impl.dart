// RQ-EXP-003
// Concrete share implementation using the `share_plus` package.
// Dispatches a file to the native OS share mechanism.
// Model: Claude Opus 4.6

import 'package:share_plus/share_plus.dart';

import '../../domain/services/share_service.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _ShareStrings {
  _ShareStrings._();

  static const String defaultSubject = 'Flutins - Asset Inventory Export';
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

/// Shares files via the native OS share sheet using `share_plus` -- RQ-EXP-003.
class ShareServiceImpl implements ShareService {
  @override
  Future<void> shareFile(
    String filePath, {
    String subject = _ShareStrings.defaultSubject,
  }) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject,
    );
  }
}
