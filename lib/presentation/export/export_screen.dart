// RQ-EXP-001 / RQ-EXP-002 / RQ-EXP-003 / D-52
// Export screen showing progress, result, and post-export actions.
// ZIP (RQ-EXP-002) and Share (RQ-EXP-003) actions become available after
// a successful PDF export.
// Model: Claude Opus 4.6

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/selection_notifier.dart';
import 'export_notifier.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _Strings {
  _Strings._();

  static const String title = 'Export';
  static const String idle = 'Select items and tap export to generate a PDF.';
  static const String generating = 'Generating...';
  static const String successPrefix = 'Saved to:\n';
  static const String errorPrefix = 'Export failed: ';
  static const String exportZip = 'Export ZIP';
  static const String share = 'Share';
  static const String tooltipZip = 'Bundle PDF and media into a ZIP archive';
  static const String tooltipShare = 'Share via native OS share sheet';
}

abstract final class _Layout {
  _Layout._();

  static const double screenPadding = 24.0;
  static const double verticalSpacing = 16.0;
  static const double buttonSpacing = 12.0;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Export screen showing current export status and post-export actions -- D-52.
///
/// After a successful PDF export (RQ-EXP-001), the user can:
/// - Export as ZIP archive including all media (RQ-EXP-002).
/// - Share the exported file via native OS share (RQ-EXP-003).
class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportState = ref.watch(exportNotifierProvider);
    final selectionState = ref.watch(selectionNotifierProvider);
    final selectedIds = selectionState.selectedIds.toList();

    return Scaffold(
      appBar: AppBar(title: const Text(_Strings.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(_Layout.screenPadding),
          child: exportState.when(
            loading: () => const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: _Layout.verticalSpacing),
                Text(_Strings.generating),
              ],
            ),
            error: (err, _) => Text(
              '${_Strings.errorPrefix}$err',
              textAlign: TextAlign.center,
            ),
            data: (filePath) => filePath == null
                ? const Text(_Strings.idle)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_Strings.successPrefix}$filePath',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: _Layout.verticalSpacing),
                      _ActionButtons(
                        filePath: filePath,
                        selectedIds: selectedIds,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons -- RQ-EXP-002 / RQ-EXP-003
// ---------------------------------------------------------------------------

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({
    required this.filePath,
    required this.selectedIds,
  });

  final String filePath;
  final List<String> selectedIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // -- RQ-EXP-002: Export ZIP
        Tooltip(
          message: _Strings.tooltipZip,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.archive_outlined),
            label: const Text(_Strings.exportZip),
            onPressed: () => ref
                .read(exportNotifierProvider.notifier)
                .exportZip(selectedIds),
          ),
        ),
        const SizedBox(width: _Layout.buttonSpacing),
        // -- RQ-EXP-003: Share
        Tooltip(
          message: _Strings.tooltipShare,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.share_outlined),
            label: const Text(_Strings.share),
            onPressed: () => ref
                .read(exportNotifierProvider.notifier)
                .shareFile(),
          ),
        ),
      ],
    );
  }
}
