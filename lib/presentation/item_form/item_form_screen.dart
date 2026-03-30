// RQ-OBJ-005 / RQ-OBJ-006 / RQ-OBJ-007 / RQ-OBJ-008 / RQ-OBJ-009
// RQ-MED-001 / RQ-MED-002 / RQ-MED-003 / RQ-MED-004
// Item create / edit form screen -- D-26 / D-38 / D-39.
//
// Responsibilities:
//   - Collect all item properties (name, category, acquisitionDate, serialNumber,
//     custom properties, tags, main photo) -- RQ-OBJ-005.
//   - Disable Save until all mandatory fields are satisfied -- RQ-OBJ-006.
//   - On successful save, pop so the home list (sorted by ItemListNotifier)
//     reflects the new item at the correct position -- RQ-OBJ-007.
//   - Embed TagPicker for tag association -- RQ-OBJ-008.
//   - Main photo picker with camera/gallery support -- RQ-MED-001 / D-38.
//   - Media gallery with photo grid and document list -- RQ-MED-003 / D-39.
//   - In edit mode (RQ-OBJ-009), pre-populate from the existing item.
// Model: Claude Opus 4.6

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/media_attachment.dart';
import '../../domain/validation/item_validation.dart';
import 'item_form_controller.dart';
import 'services/media_picker_service.dart';
import 'services/media_storage_service.dart';
import 'widgets/media_gallery.dart';
import 'widgets/photo_source_sheet.dart';
import 'widgets/tag_picker.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

abstract final class _Strings {
  _Strings._();

  static const String screenTitleCreate = 'Add item';
  static const String screenTitleEdit = 'Edit item';
  static const String labelName = 'Name *';
  static const String labelCategory = 'Category *';
  static const String labelAcquisitionDate = 'Acquisition date *';
  static const String labelSerialNumber = 'Serial number (optional)';
  static const String labelTags = 'Tags';
  static const String labelMainPhoto = 'Main photo *';
  static const String labelMediaGallery = 'Media gallery';
  static const String labelCustomProperties = 'Custom properties';
  static const String hintCustomKey = 'Property name';
  static const String hintCustomValue = 'Value';
  static const String buttonSave = 'Save';
  static const String buttonAddProperty = 'Add property';
  static const String photoPlaceholderHint = 'Tap to add a main photo';
  static const String saveErrorTitle = 'Could not save';
  static const String loadingError = 'Could not load item';
}

const _uuid = Uuid();

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Item creation / edit form screen -- RQ-OBJ-005 / RQ-OBJ-009 / D-22 / D-23 / D-26.
///
/// Uses [ItemFormController] for all mutable state; pure Riverpod,
/// no local form key required (validation is domain-driven via [ItemValidator]).
///
/// When [itemId] is null the screen operates in create mode (RQ-OBJ-005).
/// When [itemId] is non-null the screen operates in edit mode (RQ-OBJ-009).
class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({super.key, this.itemId});

  /// The id of the item to edit, or null for create mode.
  final String? itemId;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _serialController = TextEditingController();

  /// Guard flag: true once the controllers have been synced with loaded data.
  bool _controllersSynced = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  /// Provider key for this screen instance -- parameterised by item id (D-24).
  ItemFormControllerProvider get _provider =>
      itemFormControllerProvider(itemId: widget.itemId);

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(_provider);
    final isEdit = widget.itemId != null;
    final title = isEdit ? _Strings.screenTitleEdit : _Strings.screenTitleCreate;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('${_Strings.loadingError}: $err'),
        ),
        data: (formState) {
          _syncControllersOnce(formState);
          final notifier = ref.read(_provider.notifier);
          final errors = notifier.errors;
          final valid = notifier.isValid;

          return _buildForm(context, formState, notifier, errors, valid);
        },
      ),
    );
  }

  /// Populate TextEditingControllers once from loaded state (D-26).
  void _syncControllersOnce(ItemFormState formState) {
    if (_controllersSynced) return;
    _controllersSynced = true;
    _nameController.text = formState.name;
    _categoryController.text = formState.category;
    _serialController.text = formState.serialNumber ?? '';
  }

  Widget _buildForm(
    BuildContext context,
    ItemFormState formState,
    ItemFormController notifier,
    Map<String, String> errors,
    bool valid,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.formPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            // ---------------------------------------------------------------
            // Name
            // ---------------------------------------------------------------
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _Strings.labelName,
                errorText: errors[ItemMandatoryFields.name],
              ),
              onChanged: notifier.setName,
              textInputAction: TextInputAction.next,
              autofocus: true,
            ),
            const SizedBox(height: AppConstants.formFieldSpacing),

            // ---------------------------------------------------------------
            // Category
            // ---------------------------------------------------------------
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: _Strings.labelCategory,
                errorText: errors[ItemMandatoryFields.category],
              ),
              onChanged: notifier.setCategory,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppConstants.formFieldSpacing),

            // ---------------------------------------------------------------
            // Acquisition date
            // ---------------------------------------------------------------
            _DateField(
              value: formState.acquisitionDate,
              label: _Strings.labelAcquisitionDate,
              onChanged: notifier.setAcquisitionDate,
            ),
            const SizedBox(height: AppConstants.formFieldSpacing),

            // ---------------------------------------------------------------
            // Serial number (optional)
            // ---------------------------------------------------------------
            TextField(
              controller: _serialController,
              decoration: const InputDecoration(
                labelText: _Strings.labelSerialNumber,
              ),
              onChanged: (v) =>
                  notifier.setSerialNumber(v.trim().isEmpty ? null : v.trim()),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppConstants.formSectionSpacing),

            // ---------------------------------------------------------------
            // Main photo -- RQ-OBJ-001 / RQ-MED-001 / D-38
            // ---------------------------------------------------------------
            _SectionHeader(
              label: _Strings.labelMainPhoto,
              errorText: errors[ItemMandatoryFields.mainPhoto],
            ),
            const SizedBox(height: AppConstants.formFieldSpacing),
            _MainPhotoSection(
              mainPhoto: formState.mediaAttachments
                  .where((a) => a.isMainPhoto && a.type == MediaType.photo)
                  .firstOrNull,
              itemId: formState.id,
              onPhotoPicked: notifier.addMediaAttachment,
              onPhotoReplaced: (oldId, newAttachment) {
                notifier.removeMediaAttachment(oldId);
                notifier.addMediaAttachment(newAttachment);
              },
              pickerService: ref.read(mediaPickerServiceProvider),
              storageService: ref.read(mediaStorageServiceProvider),
            ),
            const SizedBox(height: AppConstants.formSectionSpacing),

            // ---------------------------------------------------------------
            // Media gallery -- RQ-MED-001 / RQ-MED-003 / RQ-MED-004 / D-39 / D-40
            // ---------------------------------------------------------------
            const _SectionHeader(label: _Strings.labelMediaGallery),
            const SizedBox(height: AppConstants.formFieldSpacing),
            MediaGallerySection(
              attachments: formState.mediaAttachments,
              itemId: formState.id,
              onAdd: notifier.addMediaAttachment,
              onRemove: notifier.removeMediaAttachment,
              pickerService: ref.read(mediaPickerServiceProvider),
              storageService: ref.read(mediaStorageServiceProvider),
            ),
            const SizedBox(height: AppConstants.formSectionSpacing),

            // ---------------------------------------------------------------
            // Tags -- RQ-OBJ-008
            // ---------------------------------------------------------------
            const _SectionHeader(label: _Strings.labelTags),
            const SizedBox(height: AppConstants.formFieldSpacing),
            TagPicker(
              selectedTagIds: formState.tagIds,
              onToggle: (tagId, selected) => selected
                  ? notifier.addTag(tagId)
                  : notifier.removeTag(tagId),
              onTagCreated: (tag) => notifier.addTag(tag.id),
            ),
            const SizedBox(height: AppConstants.formSectionSpacing),

            // ---------------------------------------------------------------
            // Custom properties -- RQ-OBJ-003
            // ---------------------------------------------------------------
            const _SectionHeader(label: _Strings.labelCustomProperties),
            const SizedBox(height: AppConstants.formFieldSpacing),
            _CustomPropertiesSection(
              properties: formState.customProperties,
              onSet: notifier.setCustomProperty,
              onRemove: notifier.removeCustomProperty,
            ),
            const SizedBox(height: AppConstants.formSectionSpacing),

            // ---------------------------------------------------------------
            // Save
            // ---------------------------------------------------------------
            FilledButton(
              onPressed: valid ? () => _onSave(context) : null,
              child: const Text(_Strings.buttonSave),
            ),
          ],
        ),
    );
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> _onSave(BuildContext context) async {
    final notifier = ref.read(_provider.notifier);
    final result = await notifier.save();

    if (!context.mounted) return;

    switch (result) {
      case ItemSaveSuccess():
        Navigator.of(context).pop();
      case ItemSaveFailure(:final errors):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_Strings.saveErrorTitle}: ${errors.values.join(', ')}',
            ),
          ),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

/// Section heading with optional field-level error -- DRY helper.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.errorText});

  final String label;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Date field
// ---------------------------------------------------------------------------

/// Read-only text field that opens a [DatePickerDialog] on tap.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final DateTime value;
  final String label;
  final void Function(DateTime) onChanged;

  @override
  Widget build(BuildContext context) {
    final display =
        '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';

    return TextField(
      controller: TextEditingController(text: display),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () => _pickDate(context),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }
}

// ---------------------------------------------------------------------------
// Main photo section -- D-38
// ---------------------------------------------------------------------------

/// Real photo section using camera/gallery picker -- RQ-MED-001 / D-38.
///
/// Shows a placeholder card when no main photo is set, or a thumbnail
/// of the actual image file with a change icon overlay when one exists.
class _MainPhotoSection extends StatelessWidget {
  const _MainPhotoSection({
    required this.mainPhoto,
    required this.itemId,
    required this.onPhotoPicked,
    required this.onPhotoReplaced,
    required this.pickerService,
    required this.storageService,
  });

  final MediaAttachment? mainPhoto;
  final String itemId;
  final void Function(MediaAttachment) onPhotoPicked;
  final void Function(String oldId, MediaAttachment newAttachment) onPhotoReplaced;
  final MediaPickerService pickerService;
  final MediaStorageService storageService;

  @override
  Widget build(BuildContext context) {
    if (mainPhoto != null) {
      return _buildThumbnail(context);
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return InkWell(
      onTap: () => _pickMainPhoto(context),
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: Container(
        height: AppConstants.photoPlaceholderHeight,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 36),
              SizedBox(height: 8),
              Text(_Strings.photoPlaceholderHint),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final file = File(mainPhoto!.filePath);
    final fileExists = file.existsSync();

    return InkWell(
      onTap: () => _replaceMainPhoto(context),
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: SizedBox(
          height: AppConstants.photoPlaceholderHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (fileExists)
                Image.file(file, fit: BoxFit.cover)
              else
                const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
              Positioned(
                right: 8,
                bottom: 8,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      Theme.of(context).colorScheme.surface.withAlpha(200),
                  child: Icon(
                    Icons.edit,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickMainPhoto(BuildContext context) async {
    final picked = await showPhotoSourceSheet(context, pickerService);
    if (picked == null) return;

    final storedPath =
        await storageService.copyMediaToAppStorage(picked.filePath, itemId);

    onPhotoPicked(
      MediaAttachment(
        id: _uuid.v4(),
        itemId: itemId,
        type: MediaType.photo,
        fileName: picked.fileName,
        filePath: storedPath,
        isMainPhoto: true,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> _replaceMainPhoto(BuildContext context) async {
    final picked = await showPhotoSourceSheet(context, pickerService);
    if (picked == null) return;

    final storedPath =
        await storageService.copyMediaToAppStorage(picked.filePath, itemId);

    onPhotoReplaced(
      mainPhoto!.id,
      MediaAttachment(
        id: _uuid.v4(),
        itemId: itemId,
        type: MediaType.photo,
        fileName: picked.fileName,
        filePath: storedPath,
        isMainPhoto: true,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom properties section
// ---------------------------------------------------------------------------

/// Editable key-value list for per-item custom properties -- RQ-OBJ-003.
class _CustomPropertiesSection extends StatefulWidget {
  const _CustomPropertiesSection({
    required this.properties,
    required this.onSet,
    required this.onRemove,
  });

  final Map<String, String> properties;
  final void Function(String key, String value) onSet;
  final void Function(String key) onRemove;

  @override
  State<_CustomPropertiesSection> createState() =>
      _CustomPropertiesSectionState();
}

class _CustomPropertiesSectionState extends State<_CustomPropertiesSection> {
  final List<_PropertyDraft> _drafts = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.properties.entries.map(
          (entry) => _PropertyRow(
            propKey: entry.key,
            propValue: entry.value,
            isMandatory: false,
            onChanged: (k, v) => widget.onSet(k, v),
            onRemove: () => widget.onRemove(entry.key),
          ),
        ),
        ..._drafts.asMap().entries.map(
              (e) => _DraftPropertyRow(
                draft: e.value,
                onCommit: (k, v) {
                  widget.onSet(k, v);
                  setState(() => _drafts.removeAt(e.key));
                },
                onCancel: () => setState(() => _drafts.removeAt(e.key)),
              ),
            ),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text(_Strings.buttonAddProperty),
          onPressed: () =>
              setState(() => _drafts.add(_PropertyDraft())),
        ),
      ],
    );
  }
}

class _PropertyDraft {
  String key = '';
  String value = '';
}

class _PropertyRow extends StatelessWidget {
  const _PropertyRow({
    required this.propKey,
    required this.propValue,
    required this.isMandatory,
    required this.onChanged,
    required this.onRemove,
  });

  final String propKey;
  final String propValue;
  final bool isMandatory;
  final void Function(String key, String value) onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(propKey)),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: propValue,
            onChanged: (v) => onChanged(propKey, v),
          ),
        ),
        if (!isMandatory)
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onRemove,
          ),
      ],
    );
  }
}

class _DraftPropertyRow extends StatefulWidget {
  const _DraftPropertyRow({
    required this.draft,
    required this.onCommit,
    required this.onCancel,
  });

  final _PropertyDraft draft;
  final void Function(String key, String value) onCommit;
  final VoidCallback onCancel;

  @override
  State<_DraftPropertyRow> createState() => _DraftPropertyRowState();
}

class _DraftPropertyRowState extends State<_DraftPropertyRow> {
  late final TextEditingController _keyController;
  late final TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController();
    _valueController = TextEditingController();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _keyController,
            decoration: const InputDecoration(hintText: _Strings.hintCustomKey),
            onChanged: (v) => widget.draft.key = v,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _valueController,
            decoration:
                const InputDecoration(hintText: _Strings.hintCustomValue),
            onChanged: (v) => widget.draft.value = v,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () {
            if (widget.draft.key.trim().isNotEmpty) {
              widget.onCommit(
                widget.draft.key.trim(),
                widget.draft.value.trim(),
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ],
    );
  }
}
