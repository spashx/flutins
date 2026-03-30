// RQ-OBJ-007 / RQ-SCR-002 / RQ-SCR-003 / D-20
// Sort configuration value objects for the item list.
// Pure Dart -- no dependency on Flutter, Drift, or Riverpod.

/// The item property by which the list can be sorted -- RQ-SCR-002 / D-20.
enum ItemSortField {
  name,
  category,
  acquisitionDate,
}

/// Sort direction.
enum SortDirection { ascending, descending }

/// Immutable combination of [ItemSortField] and [SortDirection] -- D-20.
///
/// The default sort (RQ-SCR-003) is [ItemSortField.name] / [SortDirection.ascending].
class SortOption {
  const SortOption({
    required this.field,
    required this.direction,
  });

  /// Default sort: ascending alphabetical by name (RQ-SCR-003).
  static const SortOption defaultSort = SortOption(
    field: ItemSortField.name,
    direction: SortDirection.ascending,
  );

  final ItemSortField field;
  final SortDirection direction;

  /// Returns a copy with [direction] toggled between ascending and descending.
  SortOption toggleDirection() => SortOption(
        field: field,
        direction: direction == SortDirection.ascending
            ? SortDirection.descending
            : SortDirection.ascending,
      );

  /// Returns a copy with [field] changed; direction resets to ascending.
  SortOption withField(ItemSortField field) => SortOption(
        field: field,
        direction: SortDirection.ascending,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortOption &&
          field == other.field &&
          direction == other.direction;

  @override
  int get hashCode => Object.hash(field, direction);
}
