// RQ-MED-001 / RQ-MED-003 / D-38
// Copies picked media files from temporary/source location to the app's
// persistent documents directory under media/<itemId>/<uuid>.<ext>.
// Model: Claude Opus 4.6

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'media_storage_service.g.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _uuid = Uuid();

/// Sub-directory under app documents for all media files.
const String _mediaSubDir = 'media';

// ---------------------------------------------------------------------------
// Interface
// ---------------------------------------------------------------------------

/// Copies picked media to persistent app storage -- D-38.
abstract interface class MediaStorageService {
  /// Copies the file at [sourcePath] into
  /// `<appDocuments>/media/<itemId>/<uuid>.<ext>`.
  ///
  /// Returns the absolute path of the copied file.
  Future<String> copyMediaToAppStorage(String sourcePath, String itemId);
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

/// Concrete [MediaStorageService] using `path_provider` + `dart:io` -- D-38.
class MediaStorageServiceImpl implements MediaStorageService {
  @override
  Future<String> copyMediaToAppStorage(
    String sourcePath,
    String itemId,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory(p.join(appDir.path, _mediaSubDir, itemId));
    if (!targetDir.existsSync()) {
      await targetDir.create(recursive: true);
    }

    final ext = p.extension(sourcePath);
    final targetFileName = '${_uuid.v4()}$ext';
    final targetPath = p.join(targetDir.path, targetFileName);

    await File(sourcePath).copy(targetPath);
    return targetPath;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Provides the [MediaStorageService] singleton -- D-38.
@Riverpod(keepAlive: true)
MediaStorageService mediaStorageService(MediaStorageServiceRef ref) {
  return MediaStorageServiceImpl();
}
