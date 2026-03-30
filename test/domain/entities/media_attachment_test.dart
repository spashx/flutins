// RQ-MED-001 / RQ-MED-003
// Unit tests for the MediaAttachment domain entity.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutins/domain/entities/media_attachment.dart';

void main() {
  group('MediaAttachment entity -- RQ-MED-001 / RQ-MED-003', () {
    final baseAttachment = MediaAttachment(
      id: 'att-1',
      itemId: 'item-1',
      type: MediaType.photo,
      fileName: 'front.jpg',
      filePath: '/storage/front.jpg',
      isMainPhoto: true,
      createdAt: DateTime(2024, 6),
    );

    test(
      // Given a MediaAttachment
      // When type is MediaType.photo
      // Then it is recognised as a photo -- RQ-MED-001
      'photo type is correctly stored -- RQ-MED-001',
      () {
        expect(baseAttachment.type, MediaType.photo);
      },
    );

    test(
      // Given a MediaAttachment with type document
      // When type is read
      // Then it is recognised as a document -- RQ-MED-003
      'document type is correctly stored -- RQ-MED-003',
      () {
        final doc = baseAttachment.copyWith(
          id: 'att-2',
          type: MediaType.document,
          isMainPhoto: false,
        );
        expect(doc.type, MediaType.document);
        expect(doc.isMainPhoto, isFalse);
      },
    );

    test(
      // Given two MediaAttachments with the same id
      // When equality is evaluated
      // Then they are equal
      'MediaAttachments with the same id are equal',
      () {
        final other = baseAttachment.copyWith(fileName: 'other.jpg');
        expect(baseAttachment, equals(other));
      },
    );

    test(
      // Given a MediaAttachment
      // When copyWith replaces filePath
      // Then only filePath changes
      'copyWith replaces only the specified fields',
      () {
        final updated = baseAttachment.copyWith(filePath: '/new/path.jpg');
        expect(updated.filePath, '/new/path.jpg');
        expect(updated.fileName, baseAttachment.fileName);
        expect(updated.isMainPhoto, baseAttachment.isMainPhoto);
      },
    );
  });
}
