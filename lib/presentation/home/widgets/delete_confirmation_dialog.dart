// RQ-OBJ-011 / D-30
// Confirmation dialog shown before deleting selected items.
// Displays the count of items to be deleted and offers Cancel / Delete actions.
// Model: Claude Opus 4.6

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _Strings {
  _Strings._();

  static const String titleSingular = 'Delete item?';
  static const String titlePlural = 'Delete items?';
  static const String contentSingular = '1 item will be permanently deleted.';
  static const String contentPluralSuffix = ' items will be permanently deleted.';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Shows a confirmation dialog for deleting [count] items -- RQ-OBJ-011 / D-30.
///
/// Returns `true` when the user confirms deletion, `false` or `null` otherwise.
Future<bool?> showDeleteConfirmationDialog(
  BuildContext context,
  int count,
) {
  assert(count > 0, 'count must be positive');

  final isSingular = count == 1;
  final title = isSingular ? _Strings.titleSingular : _Strings.titlePlural;
  final content = isSingular
      ? _Strings.contentSingular
      : '$count${_Strings.contentPluralSuffix}';

  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(_Strings.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(_Strings.delete),
          ),
        ],
      );
    },
  );
}
