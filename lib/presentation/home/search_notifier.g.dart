// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchNotifierHash() => r'668188ebcf843de29f71ee82c1553441f193b2e6';

/// Manages the search query state for the home screen -- D-32 / RQ-SCR-004.
///
/// - [setQuery]: replaces the current query; widgets rebuild and re-filter.
/// - [clear]: resets query to empty string; full unfiltered list is shown.
///
/// Copied from [SearchNotifier].
@ProviderFor(SearchNotifier)
final searchNotifierProvider =
    AutoDisposeNotifierProvider<SearchNotifier, String>.internal(
      SearchNotifier.new,
      name: r'searchNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchNotifier = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
