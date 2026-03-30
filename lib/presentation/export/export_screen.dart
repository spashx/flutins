// RQ-EXP-001 / D-52
// Scaffolded export screen showing progress and result.
// For RQ-EXP-001 this screen is minimal; future phases (RQ-EXP-002 / RQ-EXP-003)
// will add ZIP and share actions.
// Model: Claude Opus 4.6

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'export_notifier.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _Strings {
  _Strings._();

  static const String title = 'Export';
  static const String idle = 'Select items and tap export to generate a PDF.';
  static const String generating = 'Generating PDF...';
  static const String successPrefix = 'PDF saved to:\n';
  static const String errorPrefix = 'Export failed: ';
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Minimal export screen showing the current export status -- D-52.
///
/// The primary export trigger lives in the home screen selection AppBar (D-51).
/// This screen provides a dedicated view for longer-running exports and future
/// post-export actions (share, ZIP).
class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportState = ref.watch(exportNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(_Strings.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: exportState.when(
            loading: () => const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(_Strings.generating),
              ],
            ),
            error: (err, _) => Text(
              '${_Strings.errorPrefix}$err',
              textAlign: TextAlign.center,
            ),
            data: (filePath) => filePath == null
                ? const Text(_Strings.idle)
                : Text(
                    '${_Strings.successPrefix}$filePath',
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }
}
