// RQ-NFR-001 / RQ-NFR-002 / D-07 / D-08 / D-09 / D-11 / D-15 / D-58 / D-59 / D-60 / D-61
// Application entry point.
//
// Initialisation order (D-15):
//   1. WidgetsFlutterBinding -- required before any platform channel call.
//   2. KeystoreService -- retrieves or generates the 256-bit encryption key
//      from the OS keystore (RQ-SEC-001).
//   3. createEncryptedDatabase -- opens the SQLCipher-encrypted SQLite file
//      (RQ-DAT-001 / RQ-DAT-002).
//   4. ProviderScope override -- injects the ready database into Riverpod (D-07).
//   5. runApp -- first frame rendered only after DB is available.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/router.dart';
import 'data/database/database_factory.dart';
import 'data/keystore/keystore_service.dart';
import 'data/providers/database_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // RQ-SEC-001 / D-14: obtain the device-specific encryption key.
  final encryptionKey = await KeystoreService().getOrCreateEncryptionKey();

  // RQ-DAT-001 / RQ-DAT-002 / D-13: open the SQLCipher-encrypted database.
  final database = await createEncryptedDatabase(encryptionKey);

  runApp(
    ProviderScope(
      overrides: [
        // D-07 / D-15: inject the pre-opened database before any widget renders.
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const FlutinsApp(),
    ),
  );
}

/// Root application widget -- RQ-NFR-001 / RQ-NFR-002 / D-08 / D-58 / D-61.
class FlutinsApp extends StatelessWidget {
  const FlutinsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      // D-58: Professional blue-grey seed color for light mode (RQ-NFR-002).
      theme: _buildLightTheme(),
      // D-61: Dark mode with adapted seed color; follows OS preference.
      darkTheme: _buildDarkTheme(),
      // D-08: go_router provides the routing delegate and information parser.
      routerConfig: appRouter,
    );
  }
}

// ---------------------------------------------------------------------------
// Theme definitions -- D-58 / D-59 / D-60 / D-61 / RQ-NFR-002
// ---------------------------------------------------------------------------

/// Deep professional blue -- evokes trust and stability (D-58).
const _lightSeedColor = Color(0xFF1A5276);

/// Lighter blue for dark surfaces -- ensures readability (D-61).
const _darkSeedColor = Color(0xFF5DADE2);

/// Standard border radius for component styling (D-60).
const _componentRadius = 12.0;

ThemeData _buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _lightSeedColor,
  );
  return _applyComponentStyling(
    ThemeData(
      colorScheme: colorScheme,
    ),
    colorScheme,
  );
}

ThemeData _buildDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _darkSeedColor,
    brightness: Brightness.dark,
  );
  return _applyComponentStyling(
    ThemeData(
      colorScheme: colorScheme,
    ),
    colorScheme,
  );
}

/// Applies consistent component styling across light and dark themes (D-60).
ThemeData _applyComponentStyling(ThemeData base, ColorScheme colorScheme) {
  return base.copyWith(
    // D-60: Elevated buttons -- rounded with consistent padding.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_componentRadius),
        ),
      ),
    ),
    // D-60: Filled buttons -- rounded.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_componentRadius),
        ),
      ),
    ),
    // D-60: Outlined buttons -- rounded.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_componentRadius),
        ),
      ),
    ),
    // D-60: Text buttons -- rounded.
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_componentRadius),
        ),
      ),
    ),
    // D-60: Input fields -- outlined with rounded corners.
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_componentRadius),
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
    ),
    // D-60: Cards -- rounded corners with subtle elevation.
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_componentRadius),
      ),
    ),
    // D-60: Dialogs -- rounded corners.
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_componentRadius),
      ),
    ),
    // D-60: Floating action button -- rounded.
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_componentRadius),
      ),
    ),
    // D-60: Snackbar -- rounded.
    snackBarTheme: SnackBarThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_componentRadius),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    // D-60: AppBar -- surface container styling for depth.
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
  );
}
