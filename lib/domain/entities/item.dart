// RQ-OBJ-001 / RQ-OBJ-002 / RQ-OBJ-003
// Immutable domain entity representing an asset inventory item.
// Pure Dart -- no dependency on Flutter, Drift, or any infrastructure package.

import 'media_attachment.dart';

/// Domain entity for an inventory item.
///
/// Mandatory fields (RQ-OBJ-001): name, category, acquisitionDate, mainPhoto.
/// Tags are referenced by id (RQ-OBJ-002); custom key/value pairs are
/// per-item and NOT shared across items (RQ-OBJ-003).
class Item {
  const Item({
    required this.id,
    required this.name,
    required this.category,
    required this.acquisitionDate,
    this.serialNumber,
    required this.tagIds,
    required this.customProperties,
    required this.mediaAttachments,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String category;
  final DateTime acquisitionDate;

  /// Optional serial number (RQ-OBJ-001).
  final String? serialNumber;

  /// Identifiers of associated tags -- RQ-OBJ-002.
  /// Values reference Tag.id in the TagRepository.
  final List<String> tagIds;

  /// Per-item custom key/value properties -- RQ-OBJ-003.
  /// Keys are scoped to this item; they are NOT a shared schema.
  final Map<String, String> customProperties;

  /// Photos and documents attached to this item (RQ-OBJ-001, RQ-MED-001).
  final List<MediaAttachment> mediaAttachments;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Returns a copy of this item with the given fields replaced.
  Item copyWith({
    String? id,
    String? name,
    String? category,
    DateTime? acquisitionDate,
    String? serialNumber,
    List<String>? tagIds,
    Map<String, String>? customProperties,
    List<MediaAttachment>? mediaAttachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      serialNumber: serialNumber ?? this.serialNumber,
      tagIds: tagIds ?? this.tagIds,
      customProperties: customProperties ?? this.customProperties,
      mediaAttachments: mediaAttachments ?? this.mediaAttachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Identity is based solely on [id] -- two items with the same id are equal.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
