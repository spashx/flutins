// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tagListHash() => r'20829631ac0608f758126563a204c508cfd8301f';

/// Reactive tag list -- streams the full set of [Tag] entities from the
/// repository. Rebuilds automatically when tags are added, renamed, or
/// deleted -- D-34 / RQ-SCR-004.
///
/// Copied from [tagList].
@ProviderFor(tagList)
final tagListProvider = AutoDisposeStreamProvider<List<Tag>>.internal(
  tagList,
  name: r'tagListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tagListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TagListRef = AutoDisposeStreamProviderRef<List<Tag>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
