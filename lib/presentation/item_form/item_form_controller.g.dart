// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemFormControllerHash() =>
    r'1ada4fe507fef8e620105d882c596d25a39b0e70';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ItemFormController
    extends BuildlessAutoDisposeAsyncNotifier<ItemFormState> {
  late final String? itemId;

  FutureOr<ItemFormState> build({String? itemId});
}

/// Manages the mutable draft [ItemFormState] during item create/edit -- D-22 / D-24.
///
/// Parameterised by [itemId]:
/// - `null` (create mode): build returns a blank [ItemFormState].
/// - non-null (edit mode -- RQ-OBJ-009): build loads the item from the
///   repository and returns [ItemFormState.fromItem].
///
/// Auto-disposed: each form navigation gets a fresh draft; no stale data leaks.
///
/// Copied from [ItemFormController].
@ProviderFor(ItemFormController)
const itemFormControllerProvider = ItemFormControllerFamily();

/// Manages the mutable draft [ItemFormState] during item create/edit -- D-22 / D-24.
///
/// Parameterised by [itemId]:
/// - `null` (create mode): build returns a blank [ItemFormState].
/// - non-null (edit mode -- RQ-OBJ-009): build loads the item from the
///   repository and returns [ItemFormState.fromItem].
///
/// Auto-disposed: each form navigation gets a fresh draft; no stale data leaks.
///
/// Copied from [ItemFormController].
class ItemFormControllerFamily extends Family<AsyncValue<ItemFormState>> {
  /// Manages the mutable draft [ItemFormState] during item create/edit -- D-22 / D-24.
  ///
  /// Parameterised by [itemId]:
  /// - `null` (create mode): build returns a blank [ItemFormState].
  /// - non-null (edit mode -- RQ-OBJ-009): build loads the item from the
  ///   repository and returns [ItemFormState.fromItem].
  ///
  /// Auto-disposed: each form navigation gets a fresh draft; no stale data leaks.
  ///
  /// Copied from [ItemFormController].
  const ItemFormControllerFamily();

  /// Manages the mutable draft [ItemFormState] during item create/edit -- D-22 / D-24.
  ///
  /// Parameterised by [itemId]:
  /// - `null` (create mode): build returns a blank [ItemFormState].
  /// - non-null (edit mode -- RQ-OBJ-009): build loads the item from the
  ///   repository and returns [ItemFormState.fromItem].
  ///
  /// Auto-disposed: each form navigation gets a fresh draft; no stale data leaks.
  ///
  /// Copied from [ItemFormController].
  ItemFormControllerProvider call({String? itemId}) {
    return ItemFormControllerProvider(itemId: itemId);
  }

  @override
  ItemFormControllerProvider getProviderOverride(
    covariant ItemFormControllerProvider provider,
  ) {
    return call(itemId: provider.itemId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemFormControllerProvider';
}

/// Manages the mutable draft [ItemFormState] during item create/edit -- D-22 / D-24.
///
/// Parameterised by [itemId]:
/// - `null` (create mode): build returns a blank [ItemFormState].
/// - non-null (edit mode -- RQ-OBJ-009): build loads the item from the
///   repository and returns [ItemFormState.fromItem].
///
/// Auto-disposed: each form navigation gets a fresh draft; no stale data leaks.
///
/// Copied from [ItemFormController].
class ItemFormControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ItemFormController,
          ItemFormState
        > {
  /// Manages the mutable draft [ItemFormState] during item create/edit -- D-22 / D-24.
  ///
  /// Parameterised by [itemId]:
  /// - `null` (create mode): build returns a blank [ItemFormState].
  /// - non-null (edit mode -- RQ-OBJ-009): build loads the item from the
  ///   repository and returns [ItemFormState.fromItem].
  ///
  /// Auto-disposed: each form navigation gets a fresh draft; no stale data leaks.
  ///
  /// Copied from [ItemFormController].
  ItemFormControllerProvider({String? itemId})
    : this._internal(
        () => ItemFormController()..itemId = itemId,
        from: itemFormControllerProvider,
        name: r'itemFormControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$itemFormControllerHash,
        dependencies: ItemFormControllerFamily._dependencies,
        allTransitiveDependencies:
            ItemFormControllerFamily._allTransitiveDependencies,
        itemId: itemId,
      );

  ItemFormControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
  }) : super.internal();

  final String? itemId;

  @override
  FutureOr<ItemFormState> runNotifierBuild(
    covariant ItemFormController notifier,
  ) {
    return notifier.build(itemId: itemId);
  }

  @override
  Override overrideWith(ItemFormController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ItemFormControllerProvider._internal(
        () => create()..itemId = itemId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemId: itemId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ItemFormController, ItemFormState>
  createElement() {
    return _ItemFormControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemFormControllerProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemFormControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ItemFormState> {
  /// The parameter `itemId` of this provider.
  String? get itemId;
}

class _ItemFormControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ItemFormController,
          ItemFormState
        >
    with ItemFormControllerRef {
  _ItemFormControllerProviderElement(super.provider);

  @override
  String? get itemId => (origin as ItemFormControllerProvider).itemId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
