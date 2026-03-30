// Widget smoke test -- RQ-NFR-001
// Given the application is launched
// When the home screen renders
// Then the app bar shows the application name

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutins/main.dart';

void main() {
  testWidgets(
    'Home screen renders app bar title -- RQ-NFR-001',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: FlutinsApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Flutins'), findsOneWidget);
    },
  );
}
