// RQ-DAT-002 / RQ-NFR-001 / ISS-003
// Unit tests for the Android SQLCipher library loader in database_factory.dart.
//
// The tests exercise openSqlcipherLibrary() on the test host (Windows/Linux)
// where libsqlcipher.so is not present, validating the non-Android rethrow
// branch.  The Android success path (try + full-path fallback) is documented
// in Gherkin below and can only be verified on a physical Android device.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutins/data/database/database_factory.dart';

void main() {
  group('openSqlcipherLibrary -- RQ-DAT-002 / ISS-003', () {
    test(
      // Given: the test host is not an Android device (Windows or Linux CI)
      // When:  openSqlcipherLibrary() is called
      // Then:  ArgumentError is rethrown because libsqlcipher.so does not
      //        exist on the host and the non-Android rethrow branch fires.
      //        This confirms the !Platform.isAndroid guard is in place and
      //        that the function does not swallow the error silently.
      'Given non-Android host, '
      'When openSqlcipherLibrary is called, '
      'Then ArgumentError is thrown because libsqlcipher.so is absent',
      () {
        expect(openSqlcipherLibrary, throwsA(isA<ArgumentError>()));
      },
    );

    test(
      // Given: the test host is not an Android device
      // When:  openSqlcipherLibrary() throws
      // Then:  the thrown error is an ArgumentError (not FileSystemException),
      //        proving the /proc/self/cmdline fallback was NOT entered
      //        (that branch is Android-only and would throw FileSystemException
      //        on Windows because /proc does not exist).
      'Given non-Android host, '
      'When openSqlcipherLibrary throws, '
      'Then the error is ArgumentError, not FileSystemException',
      () {
        Object? caught;
        try {
          openSqlcipherLibrary();
        } catch (e) {
          caught = e;
        }
        expect(caught, isA<ArgumentError>());
        expect(caught, isNot(isA<FileSystemException>()));
      },
    );

    // ---------------------------------------------------------------------------
    // Android success path -- documented in Gherkin, requires physical device
    // ---------------------------------------------------------------------------
    //
    // Scenario A -- bare dlopen succeeds (extractNativeLibs=true)
    //   Given: the application runs on Android with extractNativeLibs=true
    //   When:  openSqlcipherLibrary() is called
    //   Then:  DynamicLibrary pointing to libsqlcipher.so is returned
    //          without entering the catch block
    //
    // Scenario B -- bare dlopen fails, full-path fallback resolves (extractNativeLibs=false)
    //   Given: the application runs on Android with extractNativeLibs=false
    //   And:   DynamicLibrary.open('libsqlcipher.so') throws ArgumentError
    //   When:  openSqlcipherLibrary() is called
    //   Then:  /proc/self/cmdline is read to obtain the package ID
    //   And:   DynamicLibrary.open('/data/data/<packageId>/lib/libsqlcipher.so')
    //          succeeds and the DynamicLibrary is returned
  });
}
