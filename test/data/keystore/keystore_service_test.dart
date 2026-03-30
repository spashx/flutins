// RQ-SEC-001
// Unit tests for KeystoreService.
// Uses a mock FlutterSecureStorage to avoid OS keystore access in unit tests.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutins/data/keystore/keystore_service.dart';

import 'keystore_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FlutterSecureStorage>()])
void main() {
  group('KeystoreService -- RQ-SEC-001', () {
    late MockFlutterSecureStorage mockStorage;
    late KeystoreService service;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      service = KeystoreService(storage: mockStorage);
    });

    test(
      // Given no key exists in secure storage (first launch)
      // When getOrCreateEncryptionKey is called
      // Then a new 64-character lowercase hex key is stored and returned
      'generates and stores a 256-bit hex key when none exists',
      () async {
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(
          mockStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {});

        final key = await service.getOrCreateEncryptionKey();

        expect(key.length, 64);
        expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(key), isTrue);
        verify(
          mockStorage.write(key: anyNamed('key'), value: key),
        ).called(1);
      },
    );

    test(
      // Given an existing key is present in secure storage (subsequent launches)
      // When getOrCreateEncryptionKey is called
      // Then the existing key is returned without writing a new one
      'returns existing key and does not overwrite it',
      () async {
        // 64-char hex string that simulates a stored key
        final storedKey = 'a1b2c3d4' * 8;
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => storedKey);

        final key = await service.getOrCreateEncryptionKey();

        expect(key, storedKey);
        verifyNever(
          mockStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        );
      },
    );

    test(
      // Given no key exists
      // When getOrCreateEncryptionKey is called twice consecutively (simulated)
      // Then each call produces a valid 64-char hex key
      'each generated key is a valid 64-character hex string',
      () async {
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(
          mockStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {});

        final key1 = await service.getOrCreateEncryptionKey();
        final key2 = await service.getOrCreateEncryptionKey();

        final hexPattern = RegExp(r'^[0-9a-f]{64}$');
        expect(hexPattern.hasMatch(key1), isTrue);
        expect(hexPattern.hasMatch(key2), isTrue);
      },
    );
  });
}
