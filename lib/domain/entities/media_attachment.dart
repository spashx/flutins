// RQ-MED-001 / RQ-MED-002 / RQ-MED-003 / RQ-MED-004
// Immutable domain entity for a media attachment (photo or document).
// Pure Dart -- no dependency on Flutter or any infrastructure package.

/// Distinguishes photos from documents -- RQ-MED-001 / RQ-MED-003.
enum MediaType { photo, document }

/// A photo or document attached to an inventory item.
///
/// Every item must have exactly one attachment where [isMainPhoto] is true
/// (RQ-OBJ-001). Additional photos and all documents have [isMainPhoto] false.
class MediaAttachment {
  const MediaAttachment({
    required this.id,
    required this.itemId,
    required this.type,
    required this.fileName,
    required this.filePath,
    required this.isMainPhoto,
    required this.createdAt,
  });

  final String id;
  final String itemId;
  final MediaType type;
  final String fileName;
  final String filePath;

  /// True only for the mandatory primary photo (RQ-OBJ-001).
  final bool isMainPhoto;

  final DateTime createdAt;

  /// Returns a copy of this attachment with the given fields replaced.
  MediaAttachment copyWith({
    String? id,
    String? itemId,
    MediaType? type,
    String? fileName,
    String? filePath,
    bool? isMainPhoto,
    DateTime? createdAt,
  }) {
    return MediaAttachment(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      isMainPhoto: isMainPhoto ?? this.isMainPhoto,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Identity is based solely on [id].
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaAttachment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
