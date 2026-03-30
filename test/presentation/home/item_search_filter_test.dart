// RQ-SCR-004 / D-34
// Unit tests for itemMatchesQuery: verifies filtering across all searchable
// fields (name, category, serialNumber, customProperties, tag names).
// Model: Claude Opus 4.6

import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/domain/entities/item.dart';
import 'package:flutins/presentation/home/item_search_filter.dart';

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

const String _tagIdElectronics = 'tag-1';
const String _tagIdInsured = 'tag-2';
const String _tagNameElectronics = 'electronics';
const String _tagNameInsured = 'insured';

final Map<String, String> _tagMap = {
  _tagIdElectronics: _tagNameElectronics,
  _tagIdInsured: _tagNameInsured,
};

Item _makeItem({
  String name = 'Canon EOS R5',
  String category = 'Camera',
  String? serialNumber,
  Map<String, String> customProperties = const {},
  List<String> tagIds = const [],
}) {
  final now = DateTime(2026);
  return Item(
    id: 'item-1',
    name: name,
    category: category,
    acquisitionDate: now,
    serialNumber: serialNumber,
    tagIds: tagIds,
    customProperties: customProperties,
    mediaAttachments: const [],
    createdAt: now,
    updatedAt: now,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('itemMatchesQuery -- D-34 / RQ-SCR-004', () {
    // -----------------------------------------------------------------------
    // Empty query
    // -----------------------------------------------------------------------

    test(
      'Given any item, '
      'When query is empty, '
      'Then the item matches',
      () {
        final item = _makeItem();
        expect(itemMatchesQuery(item, '', _tagMap), isTrue);
      },
    );

    // -----------------------------------------------------------------------
    // Name matching
    // -----------------------------------------------------------------------

    test(
      'Given an item named "Canon EOS R5", '
      'When query is "canon", '
      'Then the item matches (case-insensitive name)',
      () {
        final item = _makeItem();
        expect(itemMatchesQuery(item, 'canon', _tagMap), isTrue);
      },
    );

    test(
      'Given an item named "Canon EOS R5", '
      'When query is "nikon", '
      'Then the item does not match',
      () {
        final item = _makeItem();
        expect(itemMatchesQuery(item, 'nikon', _tagMap), isFalse);
      },
    );

    // -----------------------------------------------------------------------
    // Category matching
    // -----------------------------------------------------------------------

    test(
      'Given an item in category "Camera", '
      'When query is "camera", '
      'Then the item matches (case-insensitive category)',
      () {
        final item = _makeItem();
        expect(itemMatchesQuery(item, 'camera', _tagMap), isTrue);
      },
    );

    // -----------------------------------------------------------------------
    // Serial number matching
    // -----------------------------------------------------------------------

    test(
      'Given an item with serial number "SN-12345", '
      'When query is "12345", '
      'Then the item matches',
      () {
        final item = _makeItem(serialNumber: 'SN-12345');
        expect(itemMatchesQuery(item, '12345', _tagMap), isTrue);
      },
    );

    test(
      'Given an item with null serial number, '
      'When query is "12345", '
      'Then the item does not match on serial number alone',
      () {
        final item = _makeItem(
          name: 'Desk',
          category: 'Furniture',
        );
        expect(itemMatchesQuery(item, '12345', _tagMap), isFalse);
      },
    );

    // -----------------------------------------------------------------------
    // Custom properties matching
    // -----------------------------------------------------------------------

    test(
      'Given an item with custom property key "color", '
      'When query is "color", '
      'Then the item matches on property key',
      () {
        final item = _makeItem(
          name: 'Desk',
          category: 'Furniture',
          customProperties: {'color': 'black'},
        );
        expect(itemMatchesQuery(item, 'color', _tagMap), isTrue);
      },
    );

    test(
      'Given an item with custom property value "black", '
      'When query is "black", '
      'Then the item matches on property value',
      () {
        final item = _makeItem(
          name: 'Desk',
          category: 'Furniture',
          customProperties: {'color': 'black'},
        );
        expect(itemMatchesQuery(item, 'black', _tagMap), isTrue);
      },
    );

    // -----------------------------------------------------------------------
    // Tag name matching
    // -----------------------------------------------------------------------

    test(
      'Given an item tagged with "electronics", '
      'When query is "electr", '
      'Then the item matches on tag name',
      () {
        final item = _makeItem(
          name: 'Desk',
          category: 'Furniture',
          tagIds: [_tagIdElectronics],
        );
        expect(itemMatchesQuery(item, 'electr', _tagMap), isTrue);
      },
    );

    test(
      'Given an item with tagIds referencing an unknown tag, '
      'When query is "missing", '
      'Then the item does not match',
      () {
        final item = _makeItem(
          name: 'Desk',
          category: 'Furniture',
          tagIds: ['tag-unknown'],
        );
        expect(itemMatchesQuery(item, 'missing', _tagMap), isFalse);
      },
    );

    // -----------------------------------------------------------------------
    // Combined: no match on any field
    // -----------------------------------------------------------------------

    test(
      'Given an item with no matching fields, '
      'When query is "zzzzz", '
      'Then the item does not match',
      () {
        final item = _makeItem(
          serialNumber: 'SN-12345',
          customProperties: {'color': 'black'},
          tagIds: [_tagIdElectronics],
        );
        expect(itemMatchesQuery(item, 'zzzzz', _tagMap), isFalse);
      },
    );
  });
}
