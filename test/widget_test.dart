import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Personal Library App', () {
    testWidgets('Material shell renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Personal Library'),
          ),
        ),
      );
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Personal Library'), findsOneWidget);
    });
  });
}
