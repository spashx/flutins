// RQ-SEC-001
// OS keystore adapter -- generates, stores, and retrieves the database
// encryption key using the device OS keystore, transparent to the user.
//
// Android: uses Android Keystore via flutter_secure_storage.
// Windows: uses DPAPI (Data Protection API) via flutter_secure_storage.
// The user is never shown or prompted for this key (RQ-SEC-001).

import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the device-specific, OS-protected database encryption key.
///
/// Usage:
///   final key = await KeystoreService().getOrCreateEncryptionKey();
///
/// The returned key is a 64-character hex string representing 256 bits,
/// suitable for use as a SQLCipher PRAGMA key value (D-13).
class KeystoreService {
  KeystoreService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Secure-storage key under which the encryption key is persisted.
  static const String _storageKey = 'flutins_db_encryption_key';

  /// Number of random bytes to generate (256 bits = 32 bytes = 64 hex chars).
  static const int _keyByteLength = 32;

  final FlutterSecureStorage _storage;

  /// Returns the existing encryption key from the OS keystore, or generates,
  /// stores, and returns a new one on first launch -- RQ-SEC-001.
  Future<String> getOrCreateEncryptionKey() async {
    final existing = await _storage.read(key: _storageKey);
    if (existing != null) return existing;

    final newKey = _generateSecureHexKey();
    await _storage.write(key: _storageKey, value: newKey);
    return newKey;
  }

  /// Generates a cryptographically random 256-bit key as a lowercase hex string.
  String _generateSecureHexKey() {
    final rng = Random.secure();
    final bytes = List<int>.generate(_keyByteLength, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
