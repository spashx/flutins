// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectionNotifierHash() => r'd845d4bd746363ec41f09f57997f09e04d978ea2';

/// Manages multi-selection mode for the home screen item list -- D-28.
///
/// - [enterSelectionMode]: activates selection and marks the first item (RQ-SEL-001).
/// - [toggleItem]: adds or removes an item; exits if selection becomes empty.
/// - [selectAll]: replaces current selection with the given ids (RQ-SEL-003).
/// - [cancel]: clears all selections and exits selection mode (RQ-SEL-002).
///
/// Copied from [SelectionNotifier].
@ProviderFor(SelectionNotifier)
final selectionNotifierProvider =
    AutoDisposeNotifierProvider<SelectionNotifier, SelectionState>.internal(
      SelectionNotifier.new,
      name: r'selectionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectionNotifier = AutoDisposeNotifier<SelectionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
