// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemRepositoryHash() => r'150d40828d49eb1f6694ffa1bfc9d24b41f81c73';

/// Provides the singleton [ItemRepository] backed by [ItemRepositoryImpl].
///
/// Depends on [appDatabaseProvider] which must be overridden in ProviderScope
/// at app startup (D-15).
///
/// Copied from [itemRepository].
@ProviderFor(itemRepository)
final itemRepositoryProvider = Provider<ItemRepository>.internal(
  itemRepository,
  name: r'itemRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itemRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItemRepositoryRef = ProviderRef<ItemRepository>;
String _$tagRepositoryHash() => r'63ed0caea505c198c5eca22f4978264327e9b291';

/// Provides the singleton [TagRepository] backed by [TagRepositoryImpl].
///
/// Copied from [tagRepository].
@ProviderFor(tagRepository)
final tagRepositoryProvider = Provider<TagRepository>.internal(
  tagRepository,
  name: r'tagRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tagRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TagRepositoryRef = ProviderRef<TagRepository>;
String _$mediaRepositoryHash() => r'86b6d997db32f277b38a6927abb36b932bc00a39';

/// Provides the singleton [MediaRepository] backed by [MediaRepositoryImpl].
///
/// Copied from [mediaRepository].
@ProviderFor(mediaRepository)
final mediaRepositoryProvider = Provider<MediaRepository>.internal(
  mediaRepository,
  name: r'mediaRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mediaRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MediaRepositoryRef = ProviderRef<MediaRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
