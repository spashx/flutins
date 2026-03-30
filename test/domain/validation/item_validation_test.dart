// RQ-OBJ-004
// Unit tests for ItemValidator -- verifies mandatory-field enforcement.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/domain/entities/item.dart';
import 'package:flutins/domain/entities/media_attachment.dart';
import 'package:flutins/domain/validation/item_validation.dart';

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

final _mainPhoto = MediaAttachment(
  id: 'photo-1',
  itemId: 'item-1',
  type: MediaType.photo,
  fileName: 'cover.jpg',
  filePath: '/photos/cover.jpg',
  isMainPhoto: true,
  createdAt: DateTime.utc(2024),
);

/// A fully-valid Item that satisfies every mandatory-field constraint.
final _validItem = Item(
  id: 'item-1',
  name: 'MacBook Pro',
  category: 'Electronics',
  acquisitionDate: DateTime.utc(2024),
  tagIds: const [],
  customProperties: const {},
  mediaAttachments: [_mainPhoto],
  createdAt: DateTime.utc(2024),
  updatedAt: DateTime.utc(2024),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ItemValidator.validate -- RQ-OBJ-004', () {
    // -----------------------------------------------------------------------
    // Happy path
    // -----------------------------------------------------------------------

    test(
      'Given a valid item with name, category, and a main photo, '
      'When validate is called, '
      'Then the error map is empty',
      () {
        // When
        final errors = ItemValidator.validate(_validItem);

        // Then
        expect(errors, isEmpty);
        expect(ItemValidator.isValid(_validItem), isTrue);
      },
    );

    // -----------------------------------------------------------------------
    // Mandatory: name
    // -----------------------------------------------------------------------

    test(
      'Given an item with a blank name, '
      'When validate is called, '
      'Then errors contain a name entry',
      () {
        // Given
        final item = _validItem.copyWith(name: '');

        // When
        final errors = ItemValidator.validate(item);

        // Then
        expect(errors.containsKey(ItemMandatoryFields.name), isTrue);
      },
    );

    test(
      'Given an item whose name is only whitespace, '
      'When validate is called, '
      'Then errors contain a name entry',
      () {
        // Given
        final item = _validItem.copyWith(name: '   ');

        // When
        final errors = ItemValidator.validate(item);

        // Then
        expect(errors.containsKey(ItemMandatoryFields.name), isTrue);
      },
    );

    // -----------------------------------------------------------------------
    // Mandatory: category
    // -----------------------------------------------------------------------

    test(
      'Given an item with a blank category, '
      'When validate is called, '
      'Then errors contain a category entry',
      () {
        // Given
        final item = _validItem.copyWith(category: '');

        // When
        final errors = ItemValidator.validate(item);

        // Then
        expect(errors.containsKey(ItemMandatoryFields.category), isTrue);
      },
    );

    // -----------------------------------------------------------------------
    // Mandatory: main photo
    // -----------------------------------------------------------------------

    test(
      'Given an item with no media attachments, '
      'When validate is called, '
      'Then errors contain a mainPhoto entry',
      () {
        // Given
        final item = _validItem.copyWith(mediaAttachments: []);

        // When
        final errors = ItemValidator.validate(item);

        // Then
        expect(errors.containsKey(ItemMandatoryFields.mainPhoto), isTrue);
      },
    );

    test(
      'Given an item whose only attachment is a document (not a photo), '
      'When validate is called, '
      'Then errors contain a mainPhoto entry',
      () {
        // Given
        final doc = MediaAttachment(
          id: 'doc-1',
          itemId: 'item-1',
          type: MediaType.document,
          fileName: 'receipt.pdf',
          filePath: '/docs/receipt.pdf',
          isMainPhoto: false,
          createdAt: DateTime.utc(2024),
        );
        final item = _validItem.copyWith(mediaAttachments: [doc]);

        // When
        final errors = ItemValidator.validate(item);

        // Then
        expect(errors.containsKey(ItemMandatoryFields.mainPhoto), isTrue);
      },
    );

    test(
      'Given an item with a photo but isMainPhoto is false, '
      'When validate is called, '
      'Then errors contain a mainPhoto entry',
      () {
        // Given
        final nonMain = MediaAttachment(
          id: 'photo-2',
          itemId: 'item-1',
          type: MediaType.photo,
          fileName: 'extra.jpg',
          filePath: '/photos/extra.jpg',
          isMainPhoto: false,
          createdAt: DateTime.utc(2024),
        );
        final item = _validItem.copyWith(mediaAttachments: [nonMain]);

        // When
        final errors = ItemValidator.validate(item);

        // Then
        expect(errors.containsKey(ItemMandatoryFields.mainPhoto), isTrue);
      },
    );

    // -----------------------------------------------------------------------
    // Multiple violations
    // -----------------------------------------------------------------------

    test(
      'Given an item with blank name, blank category, and no main photo, '
      'When validate is called, '
      'Then errors contain all three entries',
      () {
        // Given
        final item = _validItem.copyWith(
          name: '',
          category: '',
          mediaAttachments: [],
        );

        // When
        final errors = ItemValidator.validate(item);

        // Then
        expect(errors.length, 3);
        expect(errors.containsKey(ItemMandatoryFields.name), isTrue);
        expect(errors.containsKey(ItemMandatoryFields.category), isTrue);
        expect(errors.containsKey(ItemMandatoryFields.mainPhoto), isTrue);
      },
    );
  });

  // -------------------------------------------------------------------------
  // ItemMandatoryFields helpers
  // -------------------------------------------------------------------------

  group('ItemMandatoryFields.isMandatory --', () {
    test(
      'Given a mandatory field key, When isMandatory is called, Then true',
      () {
        for (final key in ItemMandatoryFields.all) {
          expect(ItemMandatoryFields.isMandatory(key), isTrue, reason: key);
        }
      },
    );

    test(
      'Given an arbitrary non-mandatory key, When isMandatory is called, Then false',
      () {
        expect(ItemMandatoryFields.isMandatory('notes'), isFalse);
        expect(ItemMandatoryFields.isMandatory('serialNumber'), isFalse);
      },
    );
  });
}
