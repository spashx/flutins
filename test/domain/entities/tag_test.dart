// RQ-OBJ-002 / RQ-TAG-001
// Unit tests for the Tag domain entity.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutins/domain/entities/tag.dart';

void main() {
  group('Tag entity -- RQ-OBJ-002 / RQ-TAG-001', () {
    const baseTag = Tag(id: 'tag-1', name: 'Electronics');

    test(
      // Given two Tags with the same id
      // When equality is evaluated
      // Then they are considered equal regardless of name
      'Tags with the same id are equal',
      () {
        const other = Tag(id: 'tag-1', name: 'Tech');
        expect(baseTag, equals(other));
        expect(baseTag.hashCode, equals(other.hashCode));
      },
    );

    test(
      // Given two Tags with different ids
      // When equality is evaluated
      // Then they are not equal
      'Tags with different ids are not equal',
      () {
        const other = Tag(id: 'tag-2', name: 'Electronics');
        expect(baseTag, isNot(equals(other)));
      },
    );

    test(
      // Given a Tag
      // When copyWith is called with a new name
      // Then the copy has the new name and the same id
      'copyWith replaces only the specified fields',
      () {
        final updated = baseTag.copyWith(name: 'Technology');
        expect(updated.name, 'Technology');
        expect(updated.id, baseTag.id);
      },
    );

    test(
      // Given a Tag
      // When copyWith is called with a new id
      // Then the copy has the new id and the same name
      'copyWith can override the id',
      () {
        final updated = baseTag.copyWith(id: 'tag-99');
        expect(updated.id, 'tag-99');
        expect(updated.name, baseTag.name);
      },
    );
  });
}
