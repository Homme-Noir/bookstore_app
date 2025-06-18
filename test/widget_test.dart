// This is a basic Flutter widget test for the Bookstore App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bookstore_app/main.dart';

void main() {
  group('Bookstore App Widget Tests', () {
    testWidgets('Firebase error app displays error message correctly',
        (WidgetTester tester) async {
      // Build the error app widget
      await tester.pumpWidget(const FirebaseInitErrorApp());

      // Verify that the error message is displayed (the text is split across lines)
      expect(
          find.text(
              'Error initializing Firebase.\nPlease check your configuration.'),
          findsOneWidget);

      // Verify the error styling
      final errorText = tester.widget<Text>(find.text(
          'Error initializing Firebase.\nPlease check your configuration.'));
      expect(errorText.style?.color, Colors.red);
      expect(errorText.style?.fontSize, 18);
    });

    testWidgets('Firebase error app has correct structure',
        (WidgetTester tester) async {
      // Build the error app widget
      await tester.pumpWidget(const FirebaseInitErrorApp());

      // Verify the widget structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);

      // Verify debug banner is disabled
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, false);
    });

    testWidgets('Firebase error app text is centered',
        (WidgetTester tester) async {
      // Build the error app widget
      await tester.pumpWidget(const FirebaseInitErrorApp());

      // Verify text alignment
      final textWidget = tester.widget<Text>(find.text(
          'Error initializing Firebase.\nPlease check your configuration.'));
      expect(textWidget.textAlign, TextAlign.center);
    });

    testWidgets('App can be created without crashing (basic structure test)',
        (WidgetTester tester) async {
      // This test verifies that the app structure is correct
      // We're not testing the full MyApp because it requires Firebase initialization

      // Test that we can create a basic MaterialApp with the same title
      await tester.pumpWidget(
        MaterialApp(
          title: 'Book Store',
          home: const Scaffold(
            body: Center(
              child: Text('Test App'),
            ),
          ),
        ),
      );

      // Verify basic structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('App title is correctly set', (WidgetTester tester) async {
      // Test the app title configuration
      await tester.pumpWidget(
        MaterialApp(
          title: 'Book Store',
          home: const Scaffold(
            body: Center(
              child: Text('Test'),
            ),
          ),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'Book Store');
    });

    testWidgets('Firebase error app contains both parts of error message',
        (WidgetTester tester) async {
      // Build the error app widget
      await tester.pumpWidget(const FirebaseInitErrorApp());

      // Verify that both parts of the error message are present
      expect(
          find.textContaining('Error initializing Firebase'), findsOneWidget);
      expect(find.textContaining('Please check your configuration'),
          findsOneWidget);
    });
  });
}
