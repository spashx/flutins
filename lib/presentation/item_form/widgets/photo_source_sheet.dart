// RQ-MED-001 / RQ-MED-002 / D-37
// Bottom sheet for choosing a photo source (camera or gallery).
// Conditionally hides the camera option when no camera is detected (RQ-MED-002).
// When only one option is available, skips the sheet entirely (D-37).
// Model: Claude Opus 4.6

import 'package:flutter/material.dart';

import '../services/media_picker_service.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _Strings {
  _Strings._();

  static const String sheetTitle = 'Add photo';
  static const String optionCamera = 'Take a photo';
  static const String optionGallery = 'Choose from gallery';
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Shows a photo source selection sheet -- D-37.
///
/// When camera is unavailable (RQ-MED-002), opens the gallery picker
/// directly without showing a sheet. Returns a [PickedFile] or null
/// if the user cancelled.
Future<PickedFile?> showPhotoSourceSheet(
  BuildContext context,
  MediaPickerService pickerService,
) async {
  final hasCamera = await pickerService.isCameraAvailable();

  // D-37: Skip sheet when only one option exists.
  if (!hasCamera) {
    return pickerService.pickPhotoFromGallery();
  }

  if (!context.mounted) return null;

  final _PhotoSource? source = await showModalBottomSheet<_PhotoSource>(
    context: context,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _Strings.sheetTitle,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text(_Strings.optionCamera),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_PhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(_Strings.optionGallery),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_PhotoSource.gallery),
            ),
          ],
        ),
      );
    },
  );

  if (source == null) return null;

  return switch (source) {
    _PhotoSource.camera => pickerService.pickPhotoFromCamera(),
    _PhotoSource.gallery => pickerService.pickPhotoFromGallery(),
  };
}

/// Internal enum for the two photo source options.
enum _PhotoSource { camera, gallery }
