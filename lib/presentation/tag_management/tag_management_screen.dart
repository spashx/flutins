// RQ-TAG-001 / RQ-TAG-002 / RQ-TAG-003 / RQ-TAG-004 / D-44
// Tag management screen: reactive list of all tags with create, rename,
// and delete capabilities. Entry point from HomeScreen AppBar (D-43).
// Model: Claude Opus 4.6

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/providers/repository_providers.dart';
import '../../domain/entities/tag.dart';
import '../home/tag_list_provider.dart';
import 'tag_management_notifier.dart';
import 'widgets/tag_delete_dialog.dart';
import 'widgets/tag_edit_dialog.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _Strings {
  _Strings._();

  static const String screenTitle = 'Tags';
  static const String empty = 'No tags yet. Tap + to create one.';
  static const String errorPrefix = 'Error: ';
  static const String tooltipCreate = 'Create tag';
  static const String tooltipEdit = 'Rename tag';
  static const String tooltipDelete = 'Delete tag';
  static const String snackbarErrorPrefix = 'Operation failed: ';
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Tag management screen listing all tags with CRUD support -- RQ-TAG-001 / D-44.
///
/// Watches [tagListProvider] for the reactive tag list. Mutations go through
/// [TagManagementNotifier] (D-41). Errors surface via SnackBar.
class TagManagementScreen extends ConsumerWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagListProvider);

    // -- Phase 3 / D-46: listen for mutation errors and show SnackBar.
    ref.listen<AsyncValue<void>>(
      tagManagementNotifierProvider,
      (_, next) {
        if (next is AsyncError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_Strings.snackbarErrorPrefix}${next.error}',
              ),
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text(_Strings.screenTitle)),
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('${_Strings.errorPrefix}$err'),
        ),
        data: (tags) {
          if (tags.isEmpty) {
            return const Center(child: Text(_Strings.empty));
          }
          return ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) => _TagTile(tag: tags[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: _Strings.tooltipCreate,
        onPressed: () => _onCreateTag(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Opens the create-tag dialog and saves the result -- RQ-TAG-002 / D-45.
  Future<void> _onCreateTag(BuildContext context, WidgetRef ref) async {
    final name = await showTagEditDialog(context);
    if (name == null || name.isEmpty) return;

    final tag = Tag(id: const Uuid().v4(), name: name);
    await ref.read(tagManagementNotifierProvider.notifier).saveTag(tag);
  }
}

// ---------------------------------------------------------------------------
// Tag tile
// ---------------------------------------------------------------------------

/// One row in the tag list -- RQ-TAG-001 / D-44.
///
/// Trailing actions: rename (D-45) and delete (D-46).
class _TagTile extends ConsumerWidget {
  const _TagTile({required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.label),
      title: Text(tag.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: _Strings.tooltipEdit,
            onPressed: () => _onRenameTag(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: _Strings.tooltipDelete,
            onPressed: () => _onDeleteTag(context, ref),
          ),
        ],
      ),
    );
  }

  /// Fetches item count, opens rename dialog, and saves -- D-45 / RQ-TAG-003.
  Future<void> _onRenameTag(BuildContext context, WidgetRef ref) async {
    final itemCount =
        await ref.read(tagRepositoryProvider).getItemCountForTag(tag.id);
    if (!context.mounted) return;

    final newName = await showTagEditDialog(
      context,
      existing: tag,
      itemCount: itemCount,
    );
    if (newName == null || newName.isEmpty) return;

    final updated = tag.copyWith(name: newName);
    await ref.read(tagManagementNotifierProvider.notifier).saveTag(updated);
  }

  /// Opens the delete confirmation dialog -- D-46 / RQ-TAG-003 / RQ-TAG-004.
  Future<void> _onDeleteTag(BuildContext context, WidgetRef ref) async {
    await showTagDeleteDialog(context, ref, tag);
  }
}
