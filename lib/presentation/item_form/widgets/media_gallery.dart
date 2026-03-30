// RQ-MED-001 / RQ-MED-003 / RQ-MED-004 / D-39 / D-40
// Media gallery section for the item form screen.
// Displays a photo grid and document list with add buttons (D-39),
// and an edit mode toggle with checkboxes for batch deletion (D-40).
// Model: Claude Opus 4.6

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/media_attachment.dart';
import '../../home/widgets/delete_confirmation_dialog.dart';
import '../services/media_picker_service.dart';
import '../services/media_storage_service.dart';
import 'photo_source_sheet.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _uuid = Uuid();

abstract final class _Strings {
  _Strings._();

  static const String photosSubHeading = 'Photos';
  static const String documentsSubHeading = 'Documents';
  static const String addPhoto = 'Add photo';
  static const String addDocument = 'Add document';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String deleteSelected = 'Delete selected';
  static const String noPhotos = 'No additional photos';
  static const String noDocuments = 'No documents';
}

/// Number of columns in the photo thumbnail grid.
const int _photoGridColumns = 3;

/// Spacing between grid cells.
const double _photoGridSpacing = 4.0;

/// Height of a document list tile.
const double _documentTileHeight = 48.0;

// ---------------------------------------------------------------------------
// MediaGallerySection -- D-39 / D-40
// ---------------------------------------------------------------------------

/// Displays additional photos in a grid and documents in a list,
/// with add buttons and an edit mode for batch deletion -- D-39 / D-40.
class MediaGallerySection extends StatefulWidget {
  const MediaGallerySection({
    super.key,
    required this.attachments,
    required this.itemId,
    required this.onAdd,
    required this.onRemove,
    required this.pickerService,
    required this.storageService,
  });

  /// All media attachments for the current item (including main photo).
  final List<MediaAttachment> attachments;

  /// The id of the item being edited.
  final String itemId;

  /// Callback to add a new attachment to the form state.
  final void Function(MediaAttachment) onAdd;

  /// Callback to remove an attachment by id from the form state.
  final void Function(String) onRemove;

  /// The media picker service for selecting files.
  final MediaPickerService pickerService;

  /// The media storage service for copying files to app storage.
  final MediaStorageService storageService;

  @override
  State<MediaGallerySection> createState() => _MediaGallerySectionState();
}

class _MediaGallerySectionState extends State<MediaGallerySection> {
  /// Whether gallery edit mode (D-40) is active.
  bool _isEditMode = false;

  /// Set of attachment IDs selected for deletion in edit mode (D-40).
  final Set<String> _selectedIds = {};

  /// Additional photos (non-main-photo) for the grid -- D-39.
  List<MediaAttachment> get _photos => widget.attachments
      .where((a) => a.type == MediaType.photo && !a.isMainPhoto)
      .toList();

  /// Document attachments for the list -- D-39.
  List<MediaAttachment> get _documents =>
      widget.attachments.where((a) => a.type == MediaType.document).toList();

  @override
  Widget build(BuildContext context) {
    final photos = _photos;
    final documents = _documents;
    final hasAnyMedia = photos.isNotEmpty || documents.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Edit mode toggle header -- D-40
        if (hasAnyMedia) _buildEditToggle(context),

        // Photos sub-section -- D-39
        _buildSubHeading(context, _Strings.photosSubHeading),
        const SizedBox(height: _photoGridSpacing),
        if (photos.isEmpty && !_isEditMode)
          _buildEmptyHint(context, _Strings.noPhotos),
        if (photos.isNotEmpty) _buildPhotoGrid(context, photos),
        if (!_isEditMode) ...[
          const SizedBox(height: AppConstants.formFieldSpacing),
          _AddButton(
            label: _Strings.addPhoto,
            icon: Icons.add_a_photo_outlined,
            onTap: () => _addPhoto(context),
          ),
        ],

        const SizedBox(height: AppConstants.formSectionSpacing),

        // Documents sub-section -- D-39
        _buildSubHeading(context, _Strings.documentsSubHeading),
        const SizedBox(height: _photoGridSpacing),
        if (documents.isEmpty && !_isEditMode)
          _buildEmptyHint(context, _Strings.noDocuments),
        if (documents.isNotEmpty) _buildDocumentList(context, documents),
        if (!_isEditMode) ...[
          const SizedBox(height: AppConstants.formFieldSpacing),
          _AddButton(
            label: _Strings.addDocument,
            icon: Icons.note_add_outlined,
            onTap: _addDocument,
          ),
        ],

        // Delete selected button -- D-40
        if (_isEditMode && _selectedIds.isNotEmpty) ...[
          const SizedBox(height: AppConstants.formFieldSpacing),
          _buildDeleteSelectedButton(context),
        ],
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Sub-widgets
  // -------------------------------------------------------------------------

  Widget _buildEditToggle(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _toggleEditMode,
        child: Text(_isEditMode ? _Strings.done : _Strings.edit),
      ),
    );
  }

  Widget _buildSubHeading(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge);
  }

  Widget _buildEmptyHint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.grey),
      ),
    );
  }

  Widget _buildPhotoGrid(
    BuildContext context,
    List<MediaAttachment> photos,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _photoGridColumns,
        crossAxisSpacing: _photoGridSpacing,
        mainAxisSpacing: _photoGridSpacing,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return _PhotoGridTile(
          attachment: photo,
          isEditMode: _isEditMode,
          isSelected: _selectedIds.contains(photo.id),
          onSelectionChanged: (selected) => _onSelectionChanged(photo.id, selected),
        );
      },
    );
  }

  Widget _buildDocumentList(
    BuildContext context,
    List<MediaAttachment> documents,
  ) {
    return Column(
      children: documents.map((doc) {
        return _DocumentListTile(
          attachment: doc,
          isEditMode: _isEditMode,
          isSelected: _selectedIds.contains(doc.id),
          onSelectionChanged: (selected) =>
              _onSelectionChanged(doc.id, selected),
        );
      }).toList(),
    );
  }

  Widget _buildDeleteSelectedButton(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      icon: const Icon(Icons.delete_outline),
      label: const Text(_Strings.deleteSelected),
      onPressed: () => _deleteSelected(context),
    );
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedIds.clear();
      }
    });
  }

  void _onSelectionChanged(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  Future<void> _addPhoto(BuildContext context) async {
    final picked = await showPhotoSourceSheet(context, widget.pickerService);
    if (picked == null) return;

    final storedPath = await widget.storageService
        .copyMediaToAppStorage(picked.filePath, widget.itemId);

    widget.onAdd(
      MediaAttachment(
        id: _uuid.v4(),
        itemId: widget.itemId,
        type: MediaType.photo,
        fileName: picked.fileName,
        filePath: storedPath,
        isMainPhoto: false,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> _addDocument() async {
    final picked = await widget.pickerService.pickDocument();
    if (picked == null) return;

    final storedPath = await widget.storageService
        .copyMediaToAppStorage(picked.filePath, widget.itemId);

    widget.onAdd(
      MediaAttachment(
        id: _uuid.v4(),
        itemId: widget.itemId,
        type: MediaType.document,
        fileName: picked.fileName,
        filePath: storedPath,
        isMainPhoto: false,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  /// Confirms and deletes all selected attachments -- D-40.
  Future<void> _deleteSelected(BuildContext context) async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      _selectedIds.length,
    );
    if (confirmed != true) return;

    for (final id in _selectedIds.toList()) {
      widget.onRemove(id);
    }
    setState(() {
      _selectedIds.clear();
      _isEditMode = false;
    });
  }
}

// ---------------------------------------------------------------------------
// Photo grid tile
// ---------------------------------------------------------------------------

/// Individual photo thumbnail in the gallery grid -- D-39 / D-40.
class _PhotoGridTile extends StatelessWidget {
  const _PhotoGridTile({
    required this.attachment,
    required this.isEditMode,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  final MediaAttachment attachment;
  final bool isEditMode;
  final bool isSelected;
  final void Function(bool) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final file = File(attachment.filePath);
    final fileExists = file.existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (fileExists)
            Image.file(file, fit: BoxFit.cover)
          else
            Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image_outlined, size: 32),
              ),
            ),
          if (isEditMode)
            Positioned(
              top: 4,
              right: 4,
              child: Checkbox(
                value: isSelected,
                onChanged: (v) => onSelectionChanged(v ?? false),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Document list tile
// ---------------------------------------------------------------------------

/// Individual document row in the gallery document list -- D-39 / D-40.
class _DocumentListTile extends StatelessWidget {
  const _DocumentListTile({
    required this.attachment,
    required this.isEditMode,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  final MediaAttachment attachment;
  final bool isEditMode;
  final bool isSelected;
  final void Function(bool) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _documentTileHeight,
      child: Row(
        children: [
          if (isEditMode)
            Checkbox(
              value: isSelected,
              onChanged: (v) => onSelectionChanged(v ?? false),
            ),
          const Icon(Icons.insert_drive_file_outlined),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              attachment.fileName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add button
// ---------------------------------------------------------------------------

/// Styled "add" button for photos and documents -- D-39.
class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
