// RQ-OBJ-005 / RQ-OBJ-006 / RQ-OBJ-008 / RQ-OBJ-009 / D-22 / D-24
// Unit tests for ItemFormController: verifies draft mutations, live validation,
// save result types, and edit-mode loading.
// Model: Claude Opus 4.6

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutins/data/database/app_database.dart';
import 'package:flutins/data/providers/database_providers.dart';
import 'package:flutins/data/providers/repository_providers.dart';
import 'package:flutins/domain/entities/item.dart';
import 'package:flutins/domain/entities/media_attachment.dart';
import 'package:flutins/domain/repositories/media_repository.dart';
import 'package:flutins/domain/validation/item_validation.dart';
import 'package:flutins/presentation/item_form/item_form_controller.dart';

import '../../helpers/test_database.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Provider instance for create mode (itemId: null) -- D-24.
final _createProvider = itemFormControllerProvider();

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer(AppDatabase db) {
  return ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
  );
}

/// Reads the current [ItemFormState] from [_createProvider], unwrapping the
/// [AsyncValue] produced by the AsyncNotifier family.
ItemFormState _readState(ProviderContainer container) =>
    container.read(_createProvider).requireValue;

MediaAttachment _makeMainPhoto(String itemId) {
  return MediaAttachment(
    id: 'photo-001',
    itemId: itemId,
    type: MediaType.photo,
    fileName: 'main.jpg',
    filePath: 'stub/main.jpg',
    isMainPhoto: true,
    createdAt: DateTime.utc(2024),
  );
  // Note: avoid_redundant_argument_values -- use minimal constructor args  
  // for clarity without IDE noise.
  // ignore: avoid_redundant_argument_values
  // (already using minimum args above)
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ItemFormController --', () {
    late AppDatabase db;
    late ProviderContainer container;
    late ItemFormController notifier;

    setUp(() async {
      db = createTestDatabase();
      container = _makeContainer(db);
      // Keep alive so auto-dispose does not fire mid-test.
      container.listen(_createProvider, (_, next) {});
      // Await the async build (create mode completes immediately).
      await container.read(_createProvider.future);
      notifier = container.read(_createProvider.notifier);
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    // -----------------------------------------------------------------------
    // RQ-OBJ-005: draft mutations
    // -----------------------------------------------------------------------

    group('RQ-OBJ-005 -- draft mutations', () {
      test(
        'Given a fresh controller, '
        'When setName is called, '
        'Then state.name reflects the new value',
        () {
          // When
          notifier.setName('Camera');

          // Then
          expect(
            _readState(container).name,
            'Camera',
          );
        },
      );

      test(
        'Given a fresh controller, '
        'When setCategory is called, '
        'Then state.category reflects the new value',
        () {
          // When
          notifier.setCategory('Electronics');

          // Then
          expect(
            _readState(container).category,
            'Electronics',
          );
        },
      );

      test(
        'Given a fresh controller, '
        'When setAcquisitionDate is called, '
        'Then state.acquisitionDate reflects the new date',
        () {
          // Given
          final date = DateTime(2023, 6, 15);

          // When
          notifier.setAcquisitionDate(date);

          // Then
          expect(
            _readState(container).acquisitionDate,
            date,
          );
        },
      );

      test(
        'Given a fresh controller, '
        'When setSerialNumber is called with a non-null value, '
        'Then state.serialNumber is updated',
        () {
          // When
          notifier.setSerialNumber('SN-123');

          // Then
          expect(
            _readState(container).serialNumber,
            'SN-123',
          );
        },
      );

      test(
        'Given a serial number already set, '
        'When setSerialNumber is called with null, '
        'Then state.serialNumber is cleared',
        () {
          // Given
          notifier.setSerialNumber('SN-123');

          // When
          notifier.setSerialNumber(null);

          // Then
          expect(
            _readState(container).serialNumber,
            isNull,
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-OBJ-008: tag mutations
    // -----------------------------------------------------------------------

    group('RQ-OBJ-008 -- tag management', () {
      test(
        'Given a fresh controller, '
        'When addTag is called with a tag id, '
        'Then state.tagIds contains that id',
        () {
          // When
          notifier.addTag('tag-001');

          // Then
          expect(
            _readState(container).tagIds,
            contains('tag-001'),
          );
        },
      );

      test(
        'Given a tag already added, '
        'When addTag is called again with the same id, '
        'Then tagIds still contains exactly one occurrence',
        () {
          // Given
          notifier.addTag('tag-001');

          // When
          notifier.addTag('tag-001');

          // Then
          expect(
            _readState(container).tagIds.length,
            1,
          );
        },
      );

      test(
        'Given a tag in the list, '
        'When removeTag is called with that id, '
        'Then state.tagIds no longer contains the id',
        () {
          // Given
          notifier.addTag('tag-001');

          // When
          notifier.removeTag('tag-001');

          // Then
          expect(
            _readState(container).tagIds,
            isNot(contains('tag-001')),
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-OBJ-003: custom property mutations
    // -----------------------------------------------------------------------

    group('RQ-OBJ-003 -- custom properties', () {
      test(
        'Given a fresh controller, '
        'When setCustomProperty is called, '
        'Then the property appears in state.customProperties',
        () {
          // When
          notifier.setCustomProperty('Color', 'Black');

          // Then
          expect(
            _readState(container).customProperties,
            containsPair('Color', 'Black'),
          );
        },
      );

      test(
        'Given a custom property already set, '
        'When removeCustomProperty is called, '
        'Then the property is absent from state.customProperties',
        () {
          // Given
          notifier.setCustomProperty('Color', 'Black');

          // When
          notifier.removeCustomProperty('Color');

          // Then
          expect(
            _readState(container).customProperties,
            isNot(contains('Color')),
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-OBJ-006: validation
    // -----------------------------------------------------------------------

    group('RQ-OBJ-006 -- live validation', () {
      test(
        'Given blank name in draft, '
        'When errors is accessed, '
        'Then it contains an error for the name field',
        () {
          // When / Then (initial state has blank name)
          expect(notifier.errors, contains(ItemMandatoryFields.name));
        },
      );

      test(
        'Given blank category in draft, '
        'When errors is accessed, '
        'Then it contains an error for the category field',
        () {
          // When / Then (initial state has blank category)
          expect(notifier.errors, contains(ItemMandatoryFields.category));
        },
      );

      test(
        'Given no media attachments, '
        'When errors is accessed, '
        'Then it contains an error for the mainPhoto field',
        () {
          // When / Then
          expect(
            notifier.errors,
            contains(ItemMandatoryFields.mainPhoto),
          );
        },
      );

      test(
        'Given only name and category filled but no main photo, '
        'When isValid is checked, '
        'Then it is false',
        () {
          // Given
          notifier.setName('Camera');
          notifier.setCategory('Electronics');

          // When / Then
          expect(notifier.isValid, isFalse);
        },
      );

      test(
        'Given name, category, and a main photo attachment all set, '
        'When isValid is checked, '
        'Then it is true',
        () {
          // Given
          notifier.setName('Camera');
          notifier.setCategory('Electronics');
          final itemId = _readState(container).id;
          notifier.addMediaAttachment(_makeMainPhoto(itemId));

          // When / Then
          expect(notifier.isValid, isTrue);
          expect(notifier.errors, isEmpty);
        },
      );
    });

    // -----------------------------------------------------------------------
    // RQ-OBJ-005 / RQ-OBJ-006: save results
    // -----------------------------------------------------------------------

    group('RQ-OBJ-005 / RQ-OBJ-006 -- save', () {
      test(
        'Given mandatory fields not satisfied, '
        'When save is called, '
        'Then it returns ItemSaveFailure with validation errors',
        () async {
          // When
          final result = await notifier.save();

          // Then
          expect(result, isA<ItemSaveFailure>());
          final failure = result as ItemSaveFailure;
          expect(failure.errors, isNotEmpty);
        },
      );

      test(
        'Given all mandatory fields are satisfied, '
        'When save is called, '
        'Then it returns ItemSaveSuccess with the persisted item',
        () async {
          // Given
          notifier.setName('Camera');
          notifier.setCategory('Electronics');
          final itemId = _readState(container).id;
          notifier.addMediaAttachment(_makeMainPhoto(itemId));

          // When
          final result = await notifier.save();

          // Then
          expect(result, isA<ItemSaveSuccess>());
          final success = result as ItemSaveSuccess;
          expect(success.savedItem.name, 'Camera');
          expect(success.savedItem.category, 'Electronics');
        },
      );
    });
  });

  // -------------------------------------------------------------------------
  // RQ-OBJ-009: edit mode (D-24 / D-25)
  // -------------------------------------------------------------------------

  group('ItemFormController -- edit mode (RQ-OBJ-009)', () {
    late AppDatabase db;

    setUp(() {
      db = createTestDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    /// Persists a sample item and its media attachment directly via the
    /// repository providers and returns the item for use in edit-mode tests.
    Future<Item> persistSampleItem(ProviderContainer container) async {
      final mainPhoto = MediaAttachment(
        id: 'media-edit-001',
        itemId: 'edit-item-001',
        type: MediaType.photo,
        fileName: 'laptop.jpg',
        filePath: 'stub/laptop.jpg',
        isMainPhoto: true,
        createdAt: DateTime.utc(2025, 1, 15),
      );

      final item = Item(
        id: 'edit-item-001',
        name: 'Laptop',
        category: 'Electronics',
        acquisitionDate: DateTime.utc(2025, 1, 15),
        serialNumber: 'SN-EDIT-001',
        tagIds: const [],
        customProperties: const {'Color': 'Silver'},
        mediaAttachments: [mainPhoto],
        createdAt: DateTime.utc(2025, 1, 15),
        updatedAt: DateTime.utc(2025, 1, 15),
      );

      final repo = container.read(itemRepositoryProvider);
      await repo.saveItem(item);

      // Media attachments are persisted separately (MediaRepository).
      final MediaRepository mediaRepo =
          container.read(mediaRepositoryProvider);
      await mediaRepo.saveAttachment(mainPhoto);

      return item;
    }

    test(
      'Given an existing item in the database, '
      'When the controller is built with that item id, '
      'Then the form state is pre-populated from the item',
      () async {
        // Given
        final container = _makeContainer(db);
        final item = await persistSampleItem(container);

        final editProvider = itemFormControllerProvider(itemId: item.id);
        container.listen(editProvider, (_, next) {});

        // When
        final formState = await container.read(editProvider.future);

        // Then
        expect(formState.id, item.id);
        expect(formState.name, 'Laptop');
        expect(formState.category, 'Electronics');
        expect(formState.serialNumber, 'SN-EDIT-001');
        expect(formState.customProperties, containsPair('Color', 'Silver'));
        expect(formState.createdAt, item.createdAt);

        container.dispose();
      },
    );

    test(
      'Given an existing item loaded in edit mode, '
      'When a field is modified and save is called, '
      'Then it returns ItemSaveSuccess with the original createdAt preserved',
      () async {
        // Given
        final container = _makeContainer(db);
        final item = await persistSampleItem(container);

        final editProvider = itemFormControllerProvider(itemId: item.id);
        container.listen(editProvider, (_, next) {});
        await container.read(editProvider.future);
        final notifier = container.read(editProvider.notifier);

        // When
        notifier.setName('Gaming Laptop');
        final result = await notifier.save();

        // Then
        expect(result, isA<ItemSaveSuccess>());
        final success = result as ItemSaveSuccess;
        expect(success.savedItem.name, 'Gaming Laptop');
        expect(success.savedItem.createdAt, item.createdAt);

        container.dispose();
      },
    );

    test(
      'Given a non-existent item id, '
      'When the controller is built, '
      'Then it throws a StateError',
      () async {
        // Given
        final container = _makeContainer(db);
        final editProvider =
            itemFormControllerProvider(itemId: 'non-existent-id');
        container.listen(editProvider, (_, next) {});

        // When / Then
        expect(
          container.read(editProvider.future),
          throwsStateError,
        );

        container.dispose();
      },
    );
  });
}
