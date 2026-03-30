// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemListNotifierHash() => r'd5f9c8427ee6888cdc2e41fd6503b6df0e5b98d5';

/// Stream-backed notifier that emits a sorted list of [Item] -- RQ-OBJ-007 / D-21.
///
/// Default sort: [SortOption.defaultSort] (name ascending, RQ-SCR-003).
/// Call [setSort] to change sort field or direction at runtime (RQ-SCR-002).
///
/// Copied from [ItemListNotifier].
@ProviderFor(ItemListNotifier)
final itemListNotifierProvider =
    AutoDisposeStreamNotifierProvider<ItemListNotifier, ItemListState>.internal(
      ItemListNotifier.new,
      name: r'itemListNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$itemListNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ItemListNotifier = AutoDisposeStreamNotifier<ItemListState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
