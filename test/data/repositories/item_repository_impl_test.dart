// RQ-OBJ-001 / RQ-OBJ-002 / RQ-OBJ-003 / RQ-OBJ-010 / D-16 / D-18
// Unit tests for ItemRepositoryImpl using an in-memory database.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/data/repositories/item_repository_impl.dart';
import 'package:flutins/domain/entities/item.dart';
import 'package:flutins/domain/entities/media_attachment.dart';

import '../../helpers/test_database.dart';

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

final _acquisitionDate = DateTime.utc(2024, 6);
final _createdAt = DateTime.utc(2024, 6, 1, 10);
final _updatedAt = DateTime.utc(2024, 6, 1, 10);

Item _makeItem({
  String id = 'item-001',
  String name = 'MacBook Pro',
  String category = 'Electronics',
  List<String> tagIds = const [],
  Map<String, String> customProperties = const {},
  List<MediaAttachment> mediaAttachments = const [],
}) {
  return Item(
    id: id,
    name: name,
    category: category,
    acquisitionDate: _acquisitionDate,
    tagIds: tagIds,
    customProperties: customProperties,
    mediaAttachments: mediaAttachments,
    createdAt: _createdAt,
    updatedAt: _updatedAt,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ItemRepositoryImpl --', () {
    late ItemRepositoryImpl repository;

    setUp(() {
      final db = createTestDatabase();
      repository = ItemRepositoryImpl(db);
    });

    // -----------------------------------------------------------------------
    // RQ-OBJ-001: basic CRUD
    // -----------------------------------------------------------------------

    group('RQ-OBJ-001 -- save and retrieve', () {
      test(
        'Given a new item, When saveItem is called, '
        'Then getItemById returns the item with its fields intact',
        () async {
          // Given
          final item = _makeItem();

          // When
          await repository.saveItem(item);

          // Then
          final result = await repository.getItemById('item-001');
          expect(result, isNotNull);
          expect(result!.id, 'item-001');
          expect(result.name, 'MacBook Pro');
          expect(result.category, 'Electronics');
                expect(
            result.acquisitionDate.millisecondsSinceEpoch,
            _acquisitionDate.millisecondsSinceEpoch,
          );
        },
      );

      test(
        'Given an item that does not exist, '
        'When getItemById is called, '
        'Then null is returned',
        () async {
          // When
          final result = await repository.getItemById('nonexistent');

          // Then
          expect(result, isNull);
        },
      );

      test(
        'Given an existing item, When saveItem is called again, '
        'Then the item is updated (upsert)',
        () async {
          // Given
          final original = _makeItem(name: 'Original');
          await repository.saveItem(original);

          // When
          final updated = original.copyWith(
            name: 'Updated',
            updatedAt: DateTime.utc(2024, 7),
          );
          await repository.saveItem(updated);

          // Then
          final result = await repository.getItemById('item-001');
          expect(result!.name, 'Updated');
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-OBJ-002: tag associations
    // -----------------------------------------------------------------------

    group('RQ-OBJ-002 -- tag associations', () {
      test(
        'Given an item with tag IDs, When saved and retrieved, '
        'Then tagIds match the saved values',
        () async {
          // Given
          final item = _makeItem(tagIds: ['tag-1', 'tag-2']);

          // When
          await repository.saveItem(item);

          // Then
          final result = await repository.getItemById('item-001');
          expect(result!.tagIds, containsAll(['tag-1', 'tag-2']));
          expect(result.tagIds.length, 2);
        },
      );

      test(
        'Given an item with tags, When resaved with new tags, '
        'Then only the new tags are present (wholesale replace)',
        () async {
          // Given
          final item = _makeItem(tagIds: ['tag-1', 'tag-2']);
          await repository.saveItem(item);

          // When
          final updated = item.copyWith(tagIds: ['tag-3']);
          await repository.saveItem(updated);

          // Then
          final result = await repository.getItemById('item-001');
          expect(result!.tagIds, equals(['tag-3']));
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-OBJ-003: custom properties
    // -----------------------------------------------------------------------

    group('RQ-OBJ-003 -- custom properties', () {
      test(
        'Given an item with custom properties, When saved and retrieved, '
        'Then the properties map is intact',
        () async {
          // Given
          final item = _makeItem(
            customProperties: {'color': 'silver', 'warranty': '2 years'},
          );

          // When
          await repository.saveItem(item);

          // Then
          final result = await repository.getItemById('item-001');
          expect(result!.customProperties['color'], 'silver');
          expect(result.customProperties['warranty'], '2 years');
        },
      );

      test(
        'Given an item with properties, When resaved with new properties, '
        'Then the old properties are gone (wholesale replace)',
        () async {
          // Given
          final item = _makeItem(customProperties: {'old': 'value'});
          await repository.saveItem(item);

          // When
          final updated = item.copyWith(customProperties: {'new': 'data'});
          await repository.saveItem(updated);

          // Then
          final result = await repository.getItemById('item-001');
          expect(result!.customProperties.containsKey('old'), isFalse);
          expect(result.customProperties['new'], 'data');
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-MED-001: media attachment persistence
    // -----------------------------------------------------------------------

    group('RQ-MED-001 -- media attachment persistence', () {
      test(
        'Given an item with a main photo, When saved and retrieved, '
        'Then the media attachment is present with correct fields',
        () async {
          // Given
          final photo = MediaAttachment(
            id: 'photo-001',
            itemId: 'item-001',
            type: MediaType.photo,
            fileName: 'main.jpg',
            filePath: '/app/media/item-001/main.jpg',
            isMainPhoto: true,
            createdAt: DateTime.utc(2024, 6),
          );
          final item = _makeItem(mediaAttachments: [photo]);

          // When
          await repository.saveItem(item);

          // Then
          final result = await repository.getItemById('item-001');
          expect(result!.mediaAttachments, hasLength(1));
          final loaded = result.mediaAttachments.first;
          expect(loaded.id, 'photo-001');
          expect(loaded.fileName, 'main.jpg');
          expect(loaded.filePath, '/app/media/item-001/main.jpg');
          expect(loaded.isMainPhoto, isTrue);
          expect(loaded.type, MediaType.photo);
        },
      );

      test(
        'Given an item with media, When resaved with different media, '
        'Then only the new attachments are present (wholesale replace)',
        () async {
          // Given
          final oldPhoto = MediaAttachment(
            id: 'photo-old',
            itemId: 'item-001',
            type: MediaType.photo,
            fileName: 'old.jpg',
            filePath: '/app/media/item-001/old.jpg',
            isMainPhoto: true,
            createdAt: DateTime.utc(2024, 6),
          );
          await repository.saveItem(_makeItem(mediaAttachments: [oldPhoto]));

          // When
          final newPhoto = MediaAttachment(
            id: 'photo-new',
            itemId: 'item-001',
            type: MediaType.photo,
            fileName: 'new.jpg',
            filePath: '/app/media/item-001/new.jpg',
            isMainPhoto: true,
            createdAt: DateTime.utc(2024, 7),
          );
          await repository.saveItem(_makeItem(mediaAttachments: [newPhoto]));

          // Then
          final result = await repository.getItemById('item-001');
          expect(result!.mediaAttachments, hasLength(1));
          expect(result.mediaAttachments.first.id, 'photo-new');
        },
      );

      test(
        'Given an item with a photo and a document, When saved and retrieved, '
        'Then both attachments are returned',
        () async {
          // Given
          final photo = MediaAttachment(
            id: 'photo-001',
            itemId: 'item-001',
            type: MediaType.photo,
            fileName: 'main.jpg',
            filePath: '/app/media/item-001/main.jpg',
            isMainPhoto: true,
            createdAt: DateTime.utc(2024, 6),
          );
          final doc = MediaAttachment(
            id: 'doc-001',
            itemId: 'item-001',
            type: MediaType.document,
            fileName: 'invoice.pdf',
            filePath: '/app/media/item-001/invoice.pdf',
            isMainPhoto: false,
            createdAt: DateTime.utc(2024, 6),
          );
          final item = _makeItem(mediaAttachments: [photo, doc]);

          // When
          await repository.saveItem(item);

          // Then
          final result = await repository.getItemById('item-001');
          expect(result!.mediaAttachments, hasLength(2));
          expect(
            result.mediaAttachments.map((a) => a.id),
            containsAll(['photo-001', 'doc-001']),
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-OBJ-010: deletion
    // -----------------------------------------------------------------------

    group('RQ-OBJ-010 -- deleteItems', () {
      test(
        'Given an existing item, When deleteItems is called, '
        'Then getItemById returns null',
        () async {
          // Given
          await repository.saveItem(_makeItem());

          // When
          await repository.deleteItems(['item-001']);

          // Then
          final result = await repository.getItemById('item-001');
          expect(result, isNull);
        },
      );
    });

    // -----------------------------------------------------------------------
    // watchItems stream
    // -----------------------------------------------------------------------

    group('watchItems', () {
      test(
        'Given two saved items, When watchItems emits, '
        'Then the list contains both items',
        () async {
          // Given
          await repository.saveItem(_makeItem(id: 'item-a', name: 'Camera'));
          await repository.saveItem(_makeItem(id: 'item-b', name: 'Lens'));

          // When / Then
          final items = await repository.watchItems().first;
          expect(items.map((i) => i.id), containsAll(['item-a', 'item-b']));
        },
      );
    });
  });
}
