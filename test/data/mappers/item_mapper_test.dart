// RQ-OBJ-001 / D-17 / D-18
// Unit tests for ItemMapper -- verifies field-level type conversions.

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/data/mappers/item_mapper.dart';
import 'package:flutins/domain/entities/item.dart';

import '../../helpers/test_database.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _acquisitionDate = DateTime.utc(2024, 3, 15);
final _createdAt = DateTime.utc(2024, 3, 15, 9);
final _updatedAt = DateTime.utc(2024, 3, 20, 12);

final _fixedItem = Item(
  id: 'item-mapper-001',
  name: 'Vintage Camera',
  category: 'Photography',
  acquisitionDate: DateTime.utc(2024, 3, 15),
  serialNumber: 'SN-12345',
  tagIds: const [],
  customProperties: const {},
  mediaAttachments: const [],
  createdAt: DateTime.utc(2024, 3, 15, 9),
  updatedAt: DateTime.utc(2024, 3, 20, 12),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ItemMapper --', () {
    // -----------------------------------------------------------------------
    // toCompanion
    // -----------------------------------------------------------------------

    group('toCompanion', () {
      test(
        'Given an Item, When toCompanion is called, '
        'Then the companion contains the correct field values',
        () {
          // When
          final companion = ItemMapper.toCompanion(_fixedItem);

          // Then
          expect(companion.id.value, 'item-mapper-001');
          expect(companion.name.value, 'Vintage Camera');
          expect(companion.category.value, 'Photography');
          expect(
            companion.acquisitionDate.value,
            _acquisitionDate.millisecondsSinceEpoch,
          );
          expect(companion.serialNumber.value, 'SN-12345');
          expect(companion.createdAt.value, _createdAt.millisecondsSinceEpoch);
          expect(companion.updatedAt.value, _updatedAt.millisecondsSinceEpoch);
        },
      );

      test(
        'Given an Item with null serialNumber, When toCompanion is called, '
        'Then serialNumber wraps null in Value',
        () {
          // Given
          final noSerial = Item(
            id: 'i',
            name: 'n',
            category: 'c',
            acquisitionDate: DateTime.utc(2024),
            tagIds: const [],
            customProperties: const {},
            mediaAttachments: const [],
            createdAt: DateTime.utc(2024),
            updatedAt: DateTime.utc(2024),
          );

          // When
          final companion = ItemMapper.toCompanion(noSerial);

          // Then
          expect(companion.serialNumber, const Value<String?>(null));
        },
      );
    });

    // -----------------------------------------------------------------------
    // fromRow (round-trip via in-memory database)
    // -----------------------------------------------------------------------

    group('fromRow -- round-trip via in-memory DB', () {
      test(
        'Given a companion persisted to the DB, When fromRow is called, '
        'Then the restored Item has identical field values',
        () async {
          // Given
          final db = createTestDatabase();
          addTearDown(db.close);

          final companion = ItemMapper.toCompanion(_fixedItem);
          await db.into(db.items).insert(companion);

          // When
          final row =
              await (db.select(db.items)
                    ..where((t) => t.id.equals('item-mapper-001')))
                  .getSingle();
          final restored = ItemMapper.fromRow(
            row: row,
            tagIds: const [],
            customProperties: const {},
            mediaAttachments: const [],
          );

          // Then
          expect(restored.id, _fixedItem.id);
          expect(restored.name, _fixedItem.name);
          expect(restored.category, _fixedItem.category);
          expect(
            restored.acquisitionDate.millisecondsSinceEpoch,
            _fixedItem.acquisitionDate.millisecondsSinceEpoch,
          );
          expect(restored.serialNumber, _fixedItem.serialNumber);
          expect(
            restored.createdAt.millisecondsSinceEpoch,
            _fixedItem.createdAt.millisecondsSinceEpoch,
          );
          expect(
            restored.updatedAt.millisecondsSinceEpoch,
            _fixedItem.updatedAt.millisecondsSinceEpoch,
          );
        },
      );
    });
  });
}
