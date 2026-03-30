// RQ-SCR-004 / D-34
// Pure function for client-side item filtering across all searchable fields.
// No Flutter or Riverpod dependency -- trivially unit-testable.
// Model: Claude Opus 4.6

import '../../domain/entities/item.dart';

/// Returns `true` when [item] matches [lowerQuery] (already lower-cased) in
/// any searchable field -- D-34 / RQ-SCR-004.
///
/// Searchable fields:
/// - [Item.name]
/// - [Item.category]
/// - [Item.serialNumber]
/// - [Item.customProperties] keys AND values
/// - Tag names resolved via [tagNamesByIdLower] (tag id -> lower-case name)
bool itemMatchesQuery(
  Item item,
  String lowerQuery,
  Map<String, String> tagNamesByIdLower,
) {
  if (lowerQuery.isEmpty) return true;

  // Name
  if (item.name.toLowerCase().contains(lowerQuery)) return true;

  // Category
  if (item.category.toLowerCase().contains(lowerQuery)) return true;

  // Serial number
  final serial = item.serialNumber;
  if (serial != null && serial.toLowerCase().contains(lowerQuery)) return true;

  // Custom properties -- keys and values
  for (final entry in item.customProperties.entries) {
    if (entry.key.toLowerCase().contains(lowerQuery)) return true;
    if (entry.value.toLowerCase().contains(lowerQuery)) return true;
  }

  // Tag names
  for (final tagId in item.tagIds) {
    final tagName = tagNamesByIdLower[tagId];
    if (tagName != null && tagName.contains(lowerQuery)) return true;
  }

  return false;
}
