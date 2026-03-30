// RQ-TAG-002 / RQ-TAG-003 / D-45
// Modal dialog for creating a new tag or renaming an existing one.
// In rename mode, displays the number of affected items (RQ-TAG-003).
// Model: Claude Opus 4.6

import 'package:flutter/material.dart';

import '../../../domain/entities/tag.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _Strings {
  _Strings._();

  static const String titleCreate = 'New tag';
  static const String titleRename = 'Rename tag';
  static const String fieldLabel = 'Tag name';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String affectedSuffix = ' item(s).';
  static const String affectedPrefix = 'This tag is currently used by ';
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Shows a dialog to create or rename a tag -- RQ-TAG-002 / D-45.
///
/// - **Create mode** (`existing` is null): empty field, title "New tag".
/// - **Rename mode** (`existing` is non-null): pre-filled field, title
///   "Rename tag", and an item-count warning if [itemCount] > 0 (RQ-TAG-003).
///
/// Returns the entered tag name on save, or `null` on cancel.
Future<String?> showTagEditDialog(
  BuildContext context, {
  Tag? existing,
  int itemCount = 0,
}) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) {
      return _TagEditDialogContent(
        existing: existing,
        itemCount: itemCount,
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Dialog widget (local StatefulWidget for text field tracking)
// ---------------------------------------------------------------------------

class _TagEditDialogContent extends StatefulWidget {
  const _TagEditDialogContent({
    this.existing,
    this.itemCount = 0,
  });

  final Tag? existing;
  final int itemCount;

  @override
  State<_TagEditDialogContent> createState() => _TagEditDialogContentState();
}

class _TagEditDialogContentState extends State<_TagEditDialogContent> {
  late final TextEditingController _controller;
  bool _isValid = false;

  bool get _isRenameMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final initialText = widget.existing?.name ?? '';
    _controller = TextEditingController(text: initialText);
    _isValid = initialText.trim().isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final valid = _controller.text.trim().isNotEmpty;
    if (valid != _isValid) {
      setState(() => _isValid = valid);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isRenameMode ? _Strings.titleRename : _Strings.titleCreate,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isRenameMode && widget.itemCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '${_Strings.affectedPrefix}${widget.itemCount}${_Strings.affectedSuffix}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: _Strings.fieldLabel,
            ),
            onSubmitted: _isValid ? (_) => _onSave() : null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(_Strings.cancel),
        ),
        TextButton(
          onPressed: _isValid ? _onSave : null,
          child: const Text(_Strings.save),
        ),
      ],
    );
  }

  void _onSave() {
    final trimmed = _controller.text.trim();
    if (trimmed.isNotEmpty) {
      Navigator.of(context).pop(trimmed);
    }
  }
}
