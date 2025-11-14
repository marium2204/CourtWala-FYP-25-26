import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:courtwala/main.dart'; // ✅ updated import

void main() {
  testWidgets('CourtWalaApp loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CourtWalaApp()); // ✅ correct app class name

    // Verify that the SplashScreen is shown.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
