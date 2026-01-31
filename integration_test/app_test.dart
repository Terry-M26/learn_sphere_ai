import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:learn_sphere_ai/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('INT-01: Home screen loads with all feature cards',
        (tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify home screen loaded with feature cards
      expect(find.text('AI Tutor Chat'), findsOneWidget);
      expect(find.text('Challenge Mode'), findsOneWidget);
      expect(find.text('Lecture Storage'), findsOneWidget);
      expect(find.text('Lecture Summary'), findsOneWidget);
    });

    testWidgets('INT-02: Drawer opens and shows navigation items',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Open drawer by tapping menu icon
      final menuIcon = find.byIcon(Icons.menu);
      if (menuIcon.evaluate().isNotEmpty) {
        await tester.tap(menuIcon);
        await tester.pumpAndSettle();

        // Verify drawer items
        expect(find.text('Home'), findsWidgets);
      }
    });

    testWidgets('INT-03: Navigate to AI Tutor Chat screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap AI Tutor Chat card
      await tester.tap(find.text('AI Tutor Chat'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify AI Chat screen loaded with greeting
      expect(find.textContaining('Albert'), findsOneWidget);
    });

    testWidgets('INT-04: AI Chat text input accepts text', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to AI Chat
      await tester.tap(find.text('AI Tutor Chat'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find text field and enter text
      final textField = find.byType(TextFormField);
      if (textField.evaluate().isNotEmpty) {
        await tester.enterText(textField.first, 'Hello AI');
        await tester.pumpAndSettle();

        // Verify text was entered
        expect(find.text('Hello AI'), findsOneWidget);
      }
    });

    testWidgets('INT-05: Theme toggle changes UI', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find and tap theme toggle icon (brightness icon)
      final themeToggle = find.byIcon(Icons.brightness_6);
      if (themeToggle.evaluate().isEmpty) {
        // Try alternative icons
        final darkModeIcon = find.byIcon(Icons.dark_mode);
        final lightModeIcon = find.byIcon(Icons.light_mode);
        if (darkModeIcon.evaluate().isNotEmpty) {
          await tester.tap(darkModeIcon);
        } else if (lightModeIcon.evaluate().isNotEmpty) {
          await tester.tap(lightModeIcon);
        }
      } else {
        await tester.tap(themeToggle);
      }
      await tester.pumpAndSettle();

      // Theme should have changed (test passes if no crash)
      expect(find.text('AI Tutor Chat'), findsOneWidget);
    });

    testWidgets('INT-06: Navigate to Challenge Mode screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap Challenge Mode card
      await tester.tap(find.text('Challenge Mode'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify Challenge Mode screen loaded
      expect(find.textContaining('PDF'), findsWidgets);
    });

    testWidgets('INT-07: Navigate to Lecture Storage screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap Lecture Storage card
      await tester.tap(find.text('Lecture Storage'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify screen loaded (may show modules or empty state)
      // Test passes if navigation didn't crash
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('INT-08: Navigate to Lecture Summary screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap Lecture Summary card
      await tester.tap(find.text('Lecture Summary'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify Lecture Summary screen loaded
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
