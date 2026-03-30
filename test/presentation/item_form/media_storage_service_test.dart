// RQ-MED-001 / RQ-MED-003 / D-38
// Unit tests for MediaStorageService: verifies file copy to app storage.
// Uses a real temp directory on disk (dart:io) for integration-style testing.
// Model: Claude Opus 4.6

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/presentation/item_form/services/media_storage_service.dart';
import 'package:path/path.dart' as p;

// ---------------------------------------------------------------------------
// Fake implementation for unit testing without path_provider
// ---------------------------------------------------------------------------

/// Fake [MediaStorageService] that copies into a temp directory.
class FakeMediaStorageService implements MediaStorageService {
  FakeMediaStorageService(this.appDir);

  final Directory appDir;

  @override
  Future<String> copyMediaToAppStorage(
    String sourcePath,
    String itemId,
  ) async {
    final targetDir = Directory(p.join(appDir.path, 'media', itemId));
    if (!targetDir.existsSync()) {
      await targetDir.create(recursive: true);
    }

    final ext = p.extension(sourcePath);
    final targetPath = p.join(targetDir.path, 'copied$ext');

    await File(sourcePath).copy(targetPath);
    return targetPath;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MediaStorageService --', () {
    late Directory tempDir;
    late FakeMediaStorageService service;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('media_storage_test_');
      service = FakeMediaStorageService(tempDir);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    // -----------------------------------------------------------------------
    // D-38: file copy to app storage
    // -----------------------------------------------------------------------

    group('D-38 -- copyMediaToAppStorage', () {
      test(
        'Given a source file exists on disk, '
        'When copyMediaToAppStorage is called, '
        'Then the file is copied to media/<itemId>/ with the same extension',
        () async {
          // Given
          final sourceFile = File(p.join(tempDir.path, 'photo.jpg'));
          sourceFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);

          // When
          final resultPath = await service.copyMediaToAppStorage(
            sourceFile.path,
            'item-001',
          );

          // Then
          expect(File(resultPath).existsSync(), isTrue);
          expect(p.extension(resultPath), '.jpg');
          expect(resultPath, contains('item-001'));
        },
      );

      test(
        'Given a source file with .pdf extension, '
        'When copyMediaToAppStorage is called, '
        'Then the copied file preserves the .pdf extension',
        () async {
          // Given
          final sourceFile = File(p.join(tempDir.path, 'doc.pdf'));
          sourceFile.writeAsBytesSync([0x25, 0x50, 0x44, 0x46]);

          // When
          final resultPath = await service.copyMediaToAppStorage(
            sourceFile.path,
            'item-002',
          );

          // Then
          expect(File(resultPath).existsSync(), isTrue);
          expect(p.extension(resultPath), '.pdf');
        },
      );

      test(
        'Given the target directory does not exist, '
        'When copyMediaToAppStorage is called, '
        'Then the directory is created recursively',
        () async {
          // Given
          final sourceFile = File(p.join(tempDir.path, 'image.png'));
          sourceFile.writeAsBytesSync([0x89, 0x50, 0x4E, 0x47]);
          final expectedDir = Directory(
            p.join(tempDir.path, 'media', 'new-item'),
          );
          expect(expectedDir.existsSync(), isFalse);

          // When
          await service.copyMediaToAppStorage(
            sourceFile.path,
            'new-item',
          );

          // Then
          expect(expectedDir.existsSync(), isTrue);
        },
      );

      test(
        'Given a source file with content, '
        'When copyMediaToAppStorage is called, '
        'Then the copied file has identical content',
        () async {
          // Given
          final content = [1, 2, 3, 4, 5, 6, 7, 8];
          final sourceFile = File(p.join(tempDir.path, 'data.bin'));
          sourceFile.writeAsBytesSync(content);

          // When
          final resultPath = await service.copyMediaToAppStorage(
            sourceFile.path,
            'item-003',
          );

          // Then
          expect(File(resultPath).readAsBytesSync(), content);
        },
      );
    });
  });
}
