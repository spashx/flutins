// RQ-NFR-001 / D-07 / D-08 / D-09 / D-11 / D-15
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

/// Root application widget -- RQ-NFR-001 / D-08.
class FlutinsApp extends StatelessWidget {
  const FlutinsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // D-08: go_router provides the routing delegate and information parser.
      routerConfig: appRouter,
    );
  }
}
