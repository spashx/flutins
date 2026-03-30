// RQ-OBJ-004
// Domain validation for item mandatory fields.
// Pure Dart -- no dependency on Flutter, Drift, or any infrastructure package.
//
// RQ-OBJ-004 (EARS): While an item is being created or edited, the system
// shall prevent the deletion of mandatory properties from the property
// collection.

import '../entities/item.dart';
import '../entities/media_attachment.dart';

// ---------------------------------------------------------------------------
// Field identifier constants
// ---------------------------------------------------------------------------

/// String keys that identify the mandatory item properties -- RQ-OBJ-004.
///
/// These keys are used:
///  - by [ItemValidator] to report which fields are invalid,
///  - by the presentation layer to know which properties must not be deleted.
abstract final class ItemMandatoryFields {
  ItemMandatoryFields._();

  static const String name = 'name';
  static const String category = 'category';
  static const String acquisitionDate = 'acquisitionDate';
  static const String mainPhoto = 'mainPhoto';

  /// All mandatory field identifiers in declaration order.
  static const List<String> all = [name, category, acquisitionDate, mainPhoto];

  /// Returns true when [fieldKey] identifies a mandatory property.
  static bool isMandatory(String fieldKey) => all.contains(fieldKey);
}

// ---------------------------------------------------------------------------
// Validation error messages
// ---------------------------------------------------------------------------

/// Human-readable error messages for each mandatory field.
///
/// Single source of truth: changing the message here propagates everywhere.
abstract final class _ItemValidationMessages {
  _ItemValidationMessages._();

  static const String nameBlank = 'Name is required.';
  static const String categoryBlank = 'Category is required.';
  static const String mainPhotoMissing = 'A main photo is required.';
}

// ---------------------------------------------------------------------------
// Validator
// ---------------------------------------------------------------------------

/// Validates the mandatory-field constraints for an [Item] -- RQ-OBJ-004.
///
/// Usage:
/// ```dart
/// final errors = ItemValidator.validate(item);
/// if (errors.isEmpty) { /* valid */ }
/// ```
abstract final class ItemValidator {
  ItemValidator._();

  /// Returns a map of field identifier to error message for every violated
  /// mandatory constraint.
  ///
  /// Returns an empty map when [item] satisfies all constraints.
  /// Field identifier keys match the constants defined in [ItemMandatoryFields].
  static Map<String, String> validate(Item item) {
    final errors = <String, String>{};

    if (item.name.trim().isEmpty) {
      errors[ItemMandatoryFields.name] = _ItemValidationMessages.nameBlank;
    }

    if (item.category.trim().isEmpty) {
      errors[ItemMandatoryFields.category] =
          _ItemValidationMessages.categoryBlank;
    }

    // acquisitionDate is a non-nullable DateTime -- always present by construction.

    final hasMainPhoto = item.mediaAttachments.any(
      (a) => a.isMainPhoto && a.type == MediaType.photo,
    );
    if (!hasMainPhoto) {
      errors[ItemMandatoryFields.mainPhoto] =
          _ItemValidationMessages.mainPhotoMissing;
    }

    return errors;
  }

  /// Convenience helper; returns true when [item] has no validation errors.
  static bool isValid(Item item) => validate(item).isEmpty;
}
