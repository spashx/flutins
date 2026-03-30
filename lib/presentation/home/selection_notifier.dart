// RQ-SEL-001 / RQ-SEL-002 / RQ-SEL-003 / D-28
// Riverpod synchronous Notifier managing multi-selection state on the home
// screen. Owns the set of selected item ids and the active/inactive flag.
// Model: Claude Opus 4.6

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selection_notifier.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// Immutable selection state held by [SelectionNotifier] -- D-28.
class SelectionState {
  const SelectionState({
    this.selectedIds = const {},
    this.isActive = false,
  });

  /// Ids of currently selected items.
  final Set<String> selectedIds;

  /// Whether multi-selection mode is active.
  final bool isActive;

  /// Number of selected items (convenience getter).
  int get count => selectedIds.length;

  SelectionState copyWith({Set<String>? selectedIds, bool? isActive}) {
    return SelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      isActive: isActive ?? this.isActive,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Manages multi-selection mode for the home screen item list -- D-28.
///
/// - [enterSelectionMode]: activates selection and marks the first item (RQ-SEL-001).
/// - [toggleItem]: adds or removes an item; exits if selection becomes empty.
/// - [selectAll]: replaces current selection with the given ids (RQ-SEL-003).
/// - [cancel]: clears all selections and exits selection mode (RQ-SEL-002).
@riverpod
class SelectionNotifier extends _$SelectionNotifier {
  @override
  SelectionState build() => const SelectionState();

  /// Enters multi-selection mode and selects [itemId] -- RQ-SEL-001 / D-28.
  void enterSelectionMode(String itemId) {
    state = SelectionState(
      selectedIds: {itemId},
      isActive: true,
    );
  }

  /// Toggles the selection of [itemId] -- D-28.
  ///
  /// If the resulting set is empty, selection mode is exited automatically.
  void toggleItem(String itemId) {
    final current = Set<String>.from(state.selectedIds);
    if (current.contains(itemId)) {
      current.remove(itemId);
    } else {
      current.add(itemId);
    }

    if (current.isEmpty) {
      state = const SelectionState();
    } else {
      state = state.copyWith(selectedIds: current);
    }
  }

  /// Replaces the current selection with [ids] -- RQ-SEL-003 / D-31.
  ///
  /// If [ids] is empty the call is ignored (selection mode stays active).
  void selectAll(List<String> ids) {
    if (ids.isEmpty) return;
    state = state.copyWith(selectedIds: Set<String>.from(ids));
  }

  /// Clears all selections and exits selection mode -- RQ-SEL-002 / D-28.
  void cancel() {
    state = const SelectionState();
  }
}
