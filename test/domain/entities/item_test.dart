// RQ-OBJ-001 / RQ-OBJ-002 / RQ-OBJ-003
// Unit tests for the Item domain entity.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutins/domain/entities/item.dart';
import 'package:flutins/domain/entities/media_attachment.dart';

void main() {
  group('Item entity -- RQ-OBJ-001 / RQ-OBJ-002 / RQ-OBJ-003', () {
    final baseItem = Item(
      id: 'item-1',
      name: 'MacBook Pro',
      category: 'Electronics',
      acquisitionDate: DateTime(2024, 1, 15),
      tagIds: const [],
      customProperties: const {},
      mediaAttachments: const [],
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    );

    test(
      // Given two Items with the same id
      // When equality is evaluated
      // Then they are considered equal regardless of other field values
      'Items with the same id are equal -- RQ-OBJ-001',
      () {
        final other = baseItem.copyWith(name: 'Different Name');
        expect(baseItem, equals(other));
        expect(baseItem.hashCode, equals(other.hashCode));
      },
    );

    test(
      // Given two Items with different ids
      // When equality is evaluated
      // Then they are not equal
      'Items with different ids are not equal',
      () {
        final other = baseItem.copyWith(id: 'item-2');
        expect(baseItem, isNot(equals(other)));
      },
    );

    test(
      // Given an Item
      // When copyWith is called with a new name
      // Then the copy has the new name and all other fields unchanged
      'copyWith replaces only the specified fields',
      () {
        final updated = baseItem.copyWith(name: 'MacBook Air');
        expect(updated.name, 'MacBook Air');
        expect(updated.id, baseItem.id);
        expect(updated.category, baseItem.category);
        expect(updated.acquisitionDate, baseItem.acquisitionDate);
      },
    );

    test(
      // Given an Item created without a serialNumber
      // When serialNumber is read
      // Then it is null (RQ-OBJ-001: serialNumber is optional)
      'serialNumber is null when not provided -- RQ-OBJ-001',
      () {
        expect(baseItem.serialNumber, isNull);
      },
    );

    test(
      // Given an Item
      // When custom properties are set with two key/value pairs
      // Then both pairs are accessible via customProperties -- RQ-OBJ-003
      'customProperties stores per-item key/value pairs -- RQ-OBJ-003',
      () {
        final item = baseItem.copyWith(
          customProperties: {'Color': 'Space Gray', 'Warranty': '2 years'},
        );
        expect(item.customProperties['Color'], 'Space Gray');
        expect(item.customProperties['Warranty'], '2 years');
        expect(item.customProperties.length, 2);
      },
    );

    test(
      // Given an Item
      // When tagIds are set to two tag identifiers
      // Then both identifiers are present and the list length is 2 -- RQ-OBJ-002
      'tagIds associates reusable tags with an item -- RQ-OBJ-002',
      () {
        final item = baseItem.copyWith(
          tagIds: ['tag-electronics', 'tag-apple'],
        );
        expect(item.tagIds, contains('tag-electronics'));
        expect(item.tagIds, contains('tag-apple'));
        expect(item.tagIds.length, 2);
      },
    );

    test(
      // Given an Item
      // When a MediaAttachment is added to mediaAttachments
      // Then it is accessible through the item
      'mediaAttachments are accessible on the item -- RQ-OBJ-001',
      () {
        final attachment = MediaAttachment(
          id: 'att-1',
          itemId: 'item-1',
          type: MediaType.photo,
          fileName: 'photo.jpg',
          filePath: '/storage/photo.jpg',
          isMainPhoto: true,
          createdAt: DateTime(2024, 1, 15),
        );
        final item = baseItem.copyWith(mediaAttachments: [attachment]);
        expect(item.mediaAttachments.length, 1);
        expect(item.mediaAttachments.first.isMainPhoto, isTrue);
      },
    );
  });
}
