// RQ-MED-001 / RQ-MED-003 / RQ-MED-004 / D-39 / D-40
// Widget tests for MediaGallerySection: verifies gallery rendering,
// edit mode toggling, selection, and batch deletion flow.
// Model: Claude Opus 4.6

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/domain/entities/media_attachment.dart';
import 'package:flutins/presentation/item_form/services/media_picker_service.dart';
import 'package:flutins/presentation/item_form/services/media_storage_service.dart';
import 'package:flutins/presentation/item_form/widgets/media_gallery.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const String _testItemId = 'item-001';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeMediaPickerService implements MediaPickerService {
  PickedFile? photoResult;
  PickedFile? documentResult;
  bool cameraAvailable = false;

  @override
  Future<bool> isCameraAvailable() async => cameraAvailable;

  @override
  Future<PickedFile?> pickPhotoFromCamera() async => photoResult;

  @override
  Future<PickedFile?> pickPhotoFromGallery() async => photoResult;

  @override
  Future<PickedFile?> pickDocument() async => documentResult;
}

class _FakeMediaStorageService implements MediaStorageService {
  @override
  Future<String> copyMediaToAppStorage(
    String sourcePath,
    String itemId,
  ) async {
    return '/stored/$itemId/${sourcePath.split('/').last}';
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MediaAttachment _makePhoto(String id, {bool isMainPhoto = false}) {
  return MediaAttachment(
    id: id,
    itemId: _testItemId,
    type: MediaType.photo,
    fileName: '$id.jpg',
    filePath: 'nonexistent/$id.jpg',
    isMainPhoto: isMainPhoto,
    createdAt: DateTime.utc(2024),
  );
}

MediaAttachment _makeDocument(String id) {
  return MediaAttachment(
    id: id,
    itemId: _testItemId,
    type: MediaType.document,
    fileName: '$id.pdf',
    filePath: 'nonexistent/$id.pdf',
    isMainPhoto: false,
    createdAt: DateTime.utc(2024),
  );
}

Widget _buildGallery({
  required List<MediaAttachment> attachments,
  void Function(MediaAttachment)? onAdd,
  void Function(String)? onRemove,
  _FakeMediaPickerService? pickerService,
  _FakeMediaStorageService? storageService,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: MediaGallerySection(
          attachments: attachments,
          itemId: _testItemId,
          onAdd: onAdd ?? (_) {},
          onRemove: onRemove ?? (_) {},
          pickerService: pickerService ?? _FakeMediaPickerService(),
          storageService: storageService ?? _FakeMediaStorageService(),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MediaGallerySection --', () {
    // -----------------------------------------------------------------------
    // D-39: rendering
    // -----------------------------------------------------------------------

    group('D-39 -- gallery rendering', () {
      testWidgets(
        'Given no additional photos or documents, '
        'When the gallery is rendered, '
        'Then "No additional photos" and "No documents" hints are shown',
        (tester) async {
          // Given
          final mainPhoto = _makePhoto('main', isMainPhoto: true);

          // When
          await tester.pumpWidget(_buildGallery(
            attachments: [mainPhoto],
          ));

          // Then
          expect(find.text('No additional photos'), findsOneWidget);
          expect(find.text('No documents'), findsOneWidget);
        },
      );

      testWidgets(
        'Given additional photos exist (non-main), '
        'When the gallery is rendered, '
        'Then the photo grid is visible with broken-image icons (nonexistent paths)',
        (tester) async {
          // Given
          final photos = [
            _makePhoto('main', isMainPhoto: true),
            _makePhoto('extra-1'),
            _makePhoto('extra-2'),
          ];

          // When
          await tester.pumpWidget(_buildGallery(attachments: photos));

          // Then -- broken image icons for nonexistent paths
          expect(find.byIcon(Icons.broken_image_outlined), findsNWidgets(2));
          expect(find.text('No additional photos'), findsNothing);
        },
      );

      testWidgets(
        'Given documents exist, '
        'When the gallery is rendered, '
        'Then document file names are shown',
        (tester) async {
          // Given
          final attachments = [
            _makePhoto('main', isMainPhoto: true),
            _makeDocument('doc-1'),
            _makeDocument('doc-2'),
          ];

          // When
          await tester.pumpWidget(_buildGallery(attachments: attachments));

          // Then
          expect(find.text('doc-1.pdf'), findsOneWidget);
          expect(find.text('doc-2.pdf'), findsOneWidget);
          expect(find.text('No documents'), findsNothing);
        },
      );

      testWidgets(
        'Given the gallery has media, '
        'When rendered, '
        'Then "Add photo" and "Add document" buttons are visible',
        (tester) async {
          // Given
          final attachments = [
            _makePhoto('main', isMainPhoto: true),
            _makePhoto('extra-1'),
          ];

          // When
          await tester.pumpWidget(_buildGallery(attachments: attachments));

          // Then
          expect(find.text('Add photo'), findsOneWidget);
          expect(find.text('Add document'), findsOneWidget);
        },
      );

      testWidgets(
        'Given the main photo is the only attachment, '
        'When rendered, '
        'Then no Edit button is shown (no gallery media to edit)',
        (tester) async {
          // Given
          final attachments = [
            _makePhoto('main', isMainPhoto: true),
          ];

          // When
          await tester.pumpWidget(_buildGallery(attachments: attachments));

          // Then
          expect(find.text('Edit'), findsNothing);
        },
      );
    });

    // -----------------------------------------------------------------------
    // D-40: edit mode
    // -----------------------------------------------------------------------

    group('D-40 -- edit mode', () {
      testWidgets(
        'Given gallery has additional photos, '
        'When Edit is tapped, '
        'Then checkboxes appear and Edit toggles to Done',
        (tester) async {
          // Given
          final attachments = [
            _makePhoto('main', isMainPhoto: true),
            _makePhoto('extra-1'),
            _makePhoto('extra-2'),
          ];
          await tester.pumpWidget(_buildGallery(attachments: attachments));

          // When
          await tester.tap(find.text('Edit'));
          await tester.pump();

          // Then
          expect(find.text('Done'), findsOneWidget);
          expect(find.text('Edit'), findsNothing);
          expect(find.byType(Checkbox), findsNWidgets(2));
        },
      );

      testWidgets(
        'Given edit mode is active, '
        'When Done is tapped, '
        'Then checkboxes disappear and Done toggles back to Edit',
        (tester) async {
          // Given
          final attachments = [
            _makePhoto('main', isMainPhoto: true),
            _makePhoto('extra-1'),
          ];
          await tester.pumpWidget(_buildGallery(attachments: attachments));
          await tester.tap(find.text('Edit'));
          await tester.pump();

          // When
          await tester.tap(find.text('Done'));
          await tester.pump();

          // Then
          expect(find.text('Edit'), findsOneWidget);
          expect(find.byType(Checkbox), findsNothing);
        },
      );

      testWidgets(
        'Given edit mode is active with photos and documents, '
        'When a checkbox is tapped, '
        'Then "Delete selected" button appears',
        (tester) async {
          // Given
          final attachments = [
            _makePhoto('main', isMainPhoto: true),
            _makePhoto('extra-1'),
            _makeDocument('doc-1'),
          ];
          await tester.pumpWidget(_buildGallery(attachments: attachments));
          await tester.tap(find.text('Edit'));
          await tester.pump();

          // Pre-condition: no delete button yet
          expect(find.text('Delete selected'), findsNothing);

          // When -- tap the first checkbox (photo)
          final checkboxes = find.byType(Checkbox);
          await tester.tap(checkboxes.first);
          await tester.pump();

          // Then
          expect(find.text('Delete selected'), findsOneWidget);
        },
      );

      testWidgets(
        'Given edit mode with items selected, '
        'When "Delete selected" is tapped and confirmed, '
        'Then onRemove is called for each selected id',
        (tester) async {
          // Given
          final removedIds = <String>[];
          final attachments = [
            _makePhoto('main', isMainPhoto: true),
            _makePhoto('extra-1'),
            _makeDocument('doc-1'),
          ];
          await tester.pumpWidget(_buildGallery(
            attachments: attachments,
            onRemove: removedIds.add,
          ));

          // Enter edit mode
          await tester.tap(find.text('Edit'));
          await tester.pump();

          // Select both non-main items
          final checkboxes = find.byType(Checkbox);
          await tester.tap(checkboxes.at(0));
          await tester.pump();
          await tester.tap(checkboxes.at(1));
          await tester.pump();

          // When -- tap delete
          await tester.tap(find.text('Delete selected'));
          await tester.pumpAndSettle();

          // Confirm in dialog
          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          // Then
          expect(removedIds, containsAll(['extra-1', 'doc-1']));
        },
      );

      testWidgets(
        'Given edit mode with an item selected, '
        'When "Delete selected" is tapped and cancelled, '
        'Then onRemove is NOT called',
        (tester) async {
          // Given
          final removedIds = <String>[];
          final attachments = [
            _makePhoto('main', isMainPhoto: true),
            _makePhoto('extra-1'),
          ];
          await tester.pumpWidget(_buildGallery(
            attachments: attachments,
            onRemove: removedIds.add,
          ));

          // Enter edit mode and select
          await tester.tap(find.text('Edit'));
          await tester.pump();
          await tester.tap(find.byType(Checkbox).first);
          await tester.pump();

          // When -- tap delete then cancel
          await tester.tap(find.text('Delete selected'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();

          // Then
          expect(removedIds, isEmpty);
        },
      );

      testWidgets(
        'Given only a main photo exists (no non-main media), '
        'When gallery is rendered, '
        'Then the main photo does NOT appear in the gallery grid (protected)',
        (tester) async {
          // Given -- only main photo
          final attachments = [
            _makePhoto('main', isMainPhoto: true),
          ];

          // When
          await tester.pumpWidget(_buildGallery(attachments: attachments));

          // Then -- no grid tile for main photo, no edit button
          expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
          expect(find.text('Edit'), findsNothing);
        },
      );
    });
  });
}
