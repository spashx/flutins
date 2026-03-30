// RQ-OBJ-002 / RQ-TAG-001
// Immutable domain entity for a reusable tag.
// Pure Dart -- no dependency on Flutter or any infrastructure package.

/// A reusable label that can be associated with multiple items -- RQ-OBJ-002.
///
/// Tags are managed on a dedicated screen (RQ-TAG-001) and referenced by id
/// from Item.tagIds.
class Tag {
  const Tag({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  /// Returns a copy of this tag with the given fields replaced.
  Tag copyWith({String? id, String? name}) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  /// Identity is based solely on [id].
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
