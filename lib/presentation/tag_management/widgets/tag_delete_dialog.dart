// RQ-TAG-003 / RQ-TAG-004 / D-46
// Confirmation dialog for deleting a tag.
// Fetches and displays the number of items affected (RQ-TAG-003) before
// the user confirms. Deletion cascade is handled by the DB (RQ-TAG-004).
// Model: Claude Opus 4.6

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/repository_providers.dart';
import '../../../domain/entities/tag.dart';
import '../tag_management_notifier.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _Strings {
  _Strings._();

  static const String title = 'Delete tag?';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String contentNoRefs = 'Delete tag "';
  static const String contentNoRefsSuffix = '"? This cannot be undone.';
  static const String contentWithRefsPrefix = 'Deleting "';
  static const String contentWithRefsMid = '" will remove it from ';
  static const String contentWithRefsSuffix = ' item(s). This cannot be undone.';
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Shows a confirmation dialog before deleting [tag] -- RQ-TAG-003 / D-46.
///
/// Fetches the item count referencing the tag, displays the impact warning,
/// and on confirmation calls [TagManagementNotifier.deleteTag].
///
/// Returns `true` when the tag was deleted, `false` or `null` otherwise.
Future<bool?> showTagDeleteDialog(
  BuildContext context,
  WidgetRef ref,
  Tag tag,
) async {
  final itemCount =
      await ref.read(tagRepositoryProvider).getItemCountForTag(tag.id);

  if (!context.mounted) return null;

  final content = itemCount > 0
      ? '${_Strings.contentWithRefsPrefix}${tag.name}'
          '${_Strings.contentWithRefsMid}$itemCount'
          '${_Strings.contentWithRefsSuffix}'
      : '${_Strings.contentNoRefs}${tag.name}${_Strings.contentNoRefsSuffix}';

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text(_Strings.title),
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

  if (confirmed == true) {
    await ref
        .read(tagManagementNotifierProvider.notifier)
        .deleteTag(tag.id);
    return true;
  }

  return false;
}
