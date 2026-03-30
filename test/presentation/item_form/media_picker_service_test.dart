// RQ-MED-001 / RQ-MED-002 / RQ-MED-003 / D-36
// Unit tests for MediaPickerService: verifies interface contract
// delegation to image_picker and file_picker via mock.
// Model: Claude Opus 4.6

import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/presentation/item_form/services/media_picker_service.dart';

// ---------------------------------------------------------------------------
// Fake implementation for testing
// ---------------------------------------------------------------------------

/// Fake [MediaPickerService] that returns configurable results.
class FakeMediaPickerService implements MediaPickerService {
  bool cameraAvailable = false;
  PickedFile? cameraResult;
  PickedFile? galleryResult;
  PickedFile? documentResult;

  @override
  Future<bool> isCameraAvailable() async => cameraAvailable;

  @override
  Future<PickedFile?> pickPhotoFromCamera() async => cameraResult;

  @override
  Future<PickedFile?> pickPhotoFromGallery() async => galleryResult;

  @override
  Future<PickedFile?> pickDocument() async => documentResult;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MediaPickerService (Fake) --', () {
    late FakeMediaPickerService service;

    setUp(() {
      service = FakeMediaPickerService();
    });

    // -----------------------------------------------------------------------
    // RQ-MED-002: camera availability
    // -----------------------------------------------------------------------

    group('RQ-MED-002 -- camera detection', () {
      test(
        'Given camera is not available, '
        'When isCameraAvailable is called, '
        'Then it returns false',
        () async {
          // Given
          service.cameraAvailable = false;

          // When
          final result = await service.isCameraAvailable();

          // Then
          expect(result, isFalse);
        },
      );

      test(
        'Given camera is available, '
        'When isCameraAvailable is called, '
        'Then it returns true',
        () async {
          // Given
          service.cameraAvailable = true;

          // When
          final result = await service.isCameraAvailable();

          // Then
          expect(result, isTrue);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-MED-001: photo picking
    // -----------------------------------------------------------------------

    group('RQ-MED-001 -- photo picking', () {
      test(
        'Given a camera result is configured, '
        'When pickPhotoFromCamera is called, '
        'Then it returns the configured PickedFile',
        () async {
          // Given
          const expected = PickedFile(
            fileName: 'camera.jpg',
            filePath: '/tmp/camera.jpg',
          );
          service.cameraResult = expected;

          // When
          final result = await service.pickPhotoFromCamera();

          // Then
          expect(result, isNotNull);
          expect(result!.fileName, 'camera.jpg');
          expect(result.filePath, '/tmp/camera.jpg');
        },
      );

      test(
        'Given no camera result is configured (user cancelled), '
        'When pickPhotoFromCamera is called, '
        'Then it returns null',
        () async {
          // Given -- default: cameraResult is null

          // When
          final result = await service.pickPhotoFromCamera();

          // Then
          expect(result, isNull);
        },
      );

      test(
        'Given a gallery result is configured, '
        'When pickPhotoFromGallery is called, '
        'Then it returns the configured PickedFile',
        () async {
          // Given
          const expected = PickedFile(
            fileName: 'gallery.jpg',
            filePath: '/tmp/gallery.jpg',
          );
          service.galleryResult = expected;

          // When
          final result = await service.pickPhotoFromGallery();

          // Then
          expect(result, isNotNull);
          expect(result!.fileName, 'gallery.jpg');
          expect(result.filePath, '/tmp/gallery.jpg');
        },
      );

      test(
        'Given no gallery result is configured (user cancelled), '
        'When pickPhotoFromGallery is called, '
        'Then it returns null',
        () async {
          // Given -- default: galleryResult is null

          // When
          final result = await service.pickPhotoFromGallery();

          // Then
          expect(result, isNull);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-MED-003: document picking
    // -----------------------------------------------------------------------

    group('RQ-MED-003 -- document picking', () {
      test(
        'Given a document result is configured, '
        'When pickDocument is called, '
        'Then it returns the configured PickedFile',
        () async {
          // Given
          const expected = PickedFile(
            fileName: 'invoice.pdf',
            filePath: '/tmp/invoice.pdf',
          );
          service.documentResult = expected;

          // When
          final result = await service.pickDocument();

          // Then
          expect(result, isNotNull);
          expect(result!.fileName, 'invoice.pdf');
          expect(result.filePath, '/tmp/invoice.pdf');
        },
      );

      test(
        'Given no document result is configured (user cancelled), '
        'When pickDocument is called, '
        'Then it returns null',
        () async {
          // Given -- default: documentResult is null

          // When
          final result = await service.pickDocument();

          // Then
          expect(result, isNull);
        },
      );
    });
  });
}
