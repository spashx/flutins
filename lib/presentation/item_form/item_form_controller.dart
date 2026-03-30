// RQ-OBJ-005 / RQ-OBJ-006 / RQ-OBJ-008 / RQ-OBJ-009 / D-22 / D-24 / D-25
// Riverpod AsyncNotifier family managing the mutable draft state for the item
// create/edit form. Validates on each mutation; exposes a type-safe save result.
// Model: Claude Opus 4.6

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/media_attachment.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/validation/item_validation.dart';
import '../../data/providers/repository_providers.dart';

part 'item_form_controller.g.dart';

// ---------------------------------------------------------------------------
// Result sealed types
// ---------------------------------------------------------------------------

/// Returned by [ItemFormController.save] -- avoids coupling UI to exceptions.
sealed class ItemSaveResult {}

/// The draft was valid and successfully persisted.
class ItemSaveSuccess extends ItemSaveResult {
  ItemSaveSuccess(this.savedItem);
  final Item savedItem;
}

/// Validation or persistence failed.
class ItemSaveFailure extends ItemSaveResult {
  ItemSaveFailure(this.errors);

  /// Field-level validation errors (may be empty when failure is from the repo).
  final Map<String, String> errors;
}

// ---------------------------------------------------------------------------
// Draft state
// ---------------------------------------------------------------------------

const _uuid = Uuid();

/// Mutable draft state held by [ItemFormController] -- RQ-OBJ-005 / D-22 / D-25.
///
/// Created fresh for each form navigation. In create mode, [createdAt] is null
/// and [toItem] stamps a fresh UTC timestamp. In edit mode (D-25),
/// [ItemFormState.fromItem] preserves the original [createdAt].
class ItemFormState {
  ItemFormState({
    String? id,
    this.name = '',
    this.category = '',
    DateTime? acquisitionDate,
    this.serialNumber,
    List<String>? tagIds,
    Map<String, String>? customProperties,
    List<MediaAttachment>? mediaAttachments,
    this.createdAt,
  })  : id = id ?? _uuid.v4(),
        acquisitionDate = acquisitionDate ?? DateTime.now(),
        tagIds = tagIds ?? const [],
        customProperties = customProperties ?? const {},
        mediaAttachments = mediaAttachments ?? const [];

  /// Constructs a form state pre-populated from an existing [Item] -- D-25.
  factory ItemFormState.fromItem(Item item) {
    return ItemFormState(
      id: item.id,
      name: item.name,
      category: item.category,
      acquisitionDate: item.acquisitionDate,
      serialNumber: item.serialNumber,
      tagIds: List<String>.from(item.tagIds),
      customProperties: Map<String, String>.from(item.customProperties),
      mediaAttachments: List<MediaAttachment>.from(item.mediaAttachments),
      createdAt: item.createdAt,
    );
  }

  final String id;
  final String name;
  final String category;
  final DateTime acquisitionDate;
  final String? serialNumber;
  final List<String> tagIds;
  final Map<String, String> customProperties;
  final List<MediaAttachment> mediaAttachments;

  /// Original creation timestamp -- null in create mode, preserved in edit mode (D-25).
  final DateTime? createdAt;

  ItemFormState copyWith({
    String? name,
    String? category,
    DateTime? acquisitionDate,
    Object? serialNumber = _sentinel,
    List<String>? tagIds,
    Map<String, String>? customProperties,
    List<MediaAttachment>? mediaAttachments,
  }) {
    return ItemFormState(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      serialNumber: serialNumber == _sentinel
          ? this.serialNumber
          : serialNumber as String?,
      tagIds: tagIds ?? this.tagIds,
      customProperties: customProperties ?? this.customProperties,
      mediaAttachments: mediaAttachments ?? this.mediaAttachments,
      createdAt: createdAt,
    );
  }

  /// Returns the current form state as a domain [Item].
  ///
  /// In edit mode [createdAt] is preserved (D-25); in create mode a fresh
  /// UTC timestamp is used for both createdAt and updatedAt.
  Item toItem() {
    final now = DateTime.now().toUtc();
    return Item(
      id: id,
      name: name,
      category: category,
      acquisitionDate: acquisitionDate.toUtc(),
      serialNumber: serialNumber,
      tagIds: tagIds,
      customProperties: customProperties,
      mediaAttachments: mediaAttachments,
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
  }
}

/// Sentinel value used by ItemFormState.copyWith to distinguish
/// "not provided" from "explicitly set to null" for nullable serialNumber.
const _sentinel = Object();

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

/// Manages the mutable draft [ItemFormState] during item create/edit -- D-22 / D-24.
///
/// Parameterised by [itemId]:
/// - `null` (create mode): build returns a blank [ItemFormState].
/// - non-null (edit mode -- RQ-OBJ-009): build loads the item from the
///   repository and returns [ItemFormState.fromItem].
///
/// Auto-disposed: each form navigation gets a fresh draft; no stale data leaks.
@riverpod
class ItemFormController extends _$ItemFormController {
  @override
  Future<ItemFormState> build({String? itemId}) async {
    if (itemId == null) return ItemFormState();

    final ItemRepository repo = ref.read(itemRepositoryProvider);
    final item = await repo.getItemById(itemId);
    if (item == null) {
      throw StateError('Item not found: $itemId');
    }
    return ItemFormState.fromItem(item);
  }

  // -------------------------------------------------------------------------
  // Mutations -- RQ-OBJ-005
  // -------------------------------------------------------------------------

  void setName(String value) {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(name: value));
  }

  void setCategory(String value) {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(category: value));
  }

  void setAcquisitionDate(DateTime value) {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(acquisitionDate: value));
  }

  void setSerialNumber(String? value) {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(serialNumber: value));
  }

  // -------------------------------------------------------------------------
  // Tag mutations -- RQ-OBJ-008
  // -------------------------------------------------------------------------

  void addTag(String tagId) {
    final current = state.requireValue;
    if (current.tagIds.contains(tagId)) return;
    state = AsyncData(current.copyWith(tagIds: [...current.tagIds, tagId]));
  }

  void removeTag(String tagId) {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(
      tagIds: current.tagIds.where((id) => id != tagId).toList(),
    ));
  }

  // -------------------------------------------------------------------------
  // Custom properties -- RQ-OBJ-003
  // -------------------------------------------------------------------------

  void setCustomProperty(String key, String value) {
    final current = state.requireValue;
    final updated = Map<String, String>.from(current.customProperties)
      ..[key] = value;
    state = AsyncData(current.copyWith(customProperties: updated));
  }

  void removeCustomProperty(String key) {
    final current = state.requireValue;
    final updated = Map<String, String>.from(current.customProperties)
      ..remove(key);
    state = AsyncData(current.copyWith(customProperties: updated));
  }

  // -------------------------------------------------------------------------
  // Media -- RQ-OBJ-001 / RQ-MED-001
  // -------------------------------------------------------------------------

  void addMediaAttachment(MediaAttachment attachment) {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(
      mediaAttachments: [...current.mediaAttachments, attachment],
    ));
  }

  void removeMediaAttachment(String attachmentId) {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(
      mediaAttachments: current.mediaAttachments
          .where((a) => a.id != attachmentId)
          .toList(),
    ));
  }

  // -------------------------------------------------------------------------
  // Validation -- RQ-OBJ-006
  // -------------------------------------------------------------------------

  /// Live validation errors from [ItemValidator] for the current draft -- RQ-OBJ-006.
  ///
  /// Returns an empty map when the state is not yet loaded or all mandatory
  /// fields are satisfied.
  Map<String, String> get errors =>
      state.hasValue
          ? ItemValidator.validate(state.requireValue.toItem())
          : const {};

  /// True when [errors] is empty and the state is loaded -- RQ-OBJ-006.
  bool get isValid => state.hasValue && errors.isEmpty;

  // -------------------------------------------------------------------------
  // Persistence -- RQ-OBJ-005
  // -------------------------------------------------------------------------

  /// Validates and persists the draft. Returns [ItemSaveSuccess] or [ItemSaveFailure].
  ///
  /// Does NOT navigate -- the form screen is responsible for navigation after
  /// receiving [ItemSaveSuccess].
  Future<ItemSaveResult> save() async {
    final validationErrors = errors;
    if (validationErrors.isNotEmpty) {
      return ItemSaveFailure(validationErrors);
    }

    final item = state.requireValue.toItem();
    final ItemRepository repo = ref.read(itemRepositoryProvider);
    try {
      await repo.saveItem(item);
      return ItemSaveSuccess(item);
    } catch (_) {
      return ItemSaveFailure(const {});
    }
  }
}
