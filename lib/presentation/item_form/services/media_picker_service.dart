// RQ-MED-001 / RQ-MED-002 / RQ-MED-003 / D-36
// Abstraction over image_picker and file_picker for testable media selection.
// Interface + concrete implementation + Riverpod provider.
// Model: Claude Opus 4.6

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_picker_service.g.dart';

// ---------------------------------------------------------------------------
// Value object
// ---------------------------------------------------------------------------

/// Represents a file selected by the user via camera or file picker.
class PickedFile {
  const PickedFile({required this.fileName, required this.filePath});

  final String fileName;
  final String filePath;
}

// ---------------------------------------------------------------------------
// Interface -- D-36
// ---------------------------------------------------------------------------

/// Abstraction over platform image/file pickers -- D-36.
///
/// Enables unit testing of form logic without invoking real platform dialogs.
abstract interface class MediaPickerService {
  /// Whether the device has a camera available -- RQ-MED-002.
  Future<bool> isCameraAvailable();

  /// Pick a photo from the device camera -- RQ-MED-001.
  Future<PickedFile?> pickPhotoFromCamera();

  /// Pick a photo from the file system (gallery) -- RQ-MED-001.
  Future<PickedFile?> pickPhotoFromGallery();

  /// Pick a document file from the file system -- RQ-MED-003.
  Future<PickedFile?> pickDocument();
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

/// Concrete [MediaPickerService] delegating to `image_picker` and
/// `file_picker` -- D-36.
class MediaPickerServiceImpl implements MediaPickerService {
  MediaPickerServiceImpl({
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<bool> isCameraAvailable() async {
    return _imagePicker.supportsImageSource(ImageSource.camera);
  }

  @override
  Future<PickedFile?> pickPhotoFromCamera() async {
    final XFile? xfile = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (xfile == null) return null;
    return PickedFile(fileName: xfile.name, filePath: xfile.path);
  }

  @override
  Future<PickedFile?> pickPhotoFromGallery() async {
    final XFile? xfile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (xfile == null) return null;
    return PickedFile(fileName: xfile.name, filePath: xfile.path);
  }

  @override
  Future<PickedFile?> pickDocument() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    if (file.path == null) return null;
    return PickedFile(fileName: file.name, filePath: file.path!);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Provides the [MediaPickerService] singleton -- D-36.
@Riverpod(keepAlive: true)
MediaPickerService mediaPickerService(MediaPickerServiceRef ref) {
  return MediaPickerServiceImpl();
}
