// RQ-OBJ-008 / D-23
// Tag picker widget: displays all existing tags as selectable chips.
// Allows inline creation of a new tag via an AlertDialog.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/tag.dart';
import '../../../data/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _Strings {
  _Strings._();

  static const String newTagChipLabel = 'New tag...';
  static const String dialogTitle = 'New tag';
  static const String dialogHint = 'Tag name';
  static const String dialogCancel = 'Cancel';
  static const String dialogCreate = 'Create';
  static const String tagNameEmpty = 'Tag name cannot be empty.';
}

const _uuid = Uuid();

// ---------------------------------------------------------------------------
// Internal stream provider -- scoped to this file
// ---------------------------------------------------------------------------

/// Exposes TagRepository.watchTags as an [AsyncValue] for [TagPicker].
final _tagListProvider = StreamProvider.autoDispose<List<Tag>>((ref) {
  return ref.watch(tagRepositoryProvider).watchTags();
});

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

/// Inline tag selection and creation widget -- RQ-OBJ-008 / D-23.
///
/// Displays all existing tags as toggle chips. Selected tags (by id) are
/// highlighted. A "New tag..." chip opens an [AlertDialog] for inline creation.
///
/// [selectedTagIds] -- currently selected tag ids.
/// [onToggle]       -- called when the user taps an existing tag chip.
/// [onTagCreated]   -- called after a new tag is persisted; receives the new tag.
class TagPicker extends ConsumerWidget {
  const TagPicker({
    super.key,
    required this.selectedTagIds,
    required this.onToggle,
    required this.onTagCreated,
  });

  final List<String> selectedTagIds;
  final void Function(String tagId, bool selected) onToggle;
  final void Function(Tag tag) onTagCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(_tagListProvider);

    return tagsAsync.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, stack) => const SizedBox.shrink(),
      data: (tags) => Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          ...tags.map(
            (tag) => FilterChip(
              label: Text(tag.name),
              selected: selectedTagIds.contains(tag.id),
              onSelected: (selected) => onToggle(tag.id, selected),
            ),
          ),
          ActionChip(
            avatar: const Icon(Icons.add, size: 16),
            label: const Text(_Strings.newTagChipLabel),
            onPressed: () => _showCreateTagDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateTagDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? errorText;
        return StatefulBuilder(
          builder: (sbContext, setState) => AlertDialog(
            title: const Text(_Strings.dialogTitle),
            content: TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: _Strings.dialogHint,
                errorText: errorText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(sbContext).pop(),
                child: const Text(_Strings.dialogCancel),
              ),
              TextButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    setState(() => errorText = _Strings.tagNameEmpty);
                    return;
                  }
                  final newTag = Tag(id: _uuid.v4(), name: name);
                  await ref.read(tagRepositoryProvider).saveTag(newTag);
                  onTagCreated(newTag);
                  if (sbContext.mounted) Navigator.of(sbContext).pop();
                },
                child: const Text(_Strings.dialogCreate),
              ),
            ],
          ),
        );
      },
    );
  }
}
