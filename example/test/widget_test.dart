import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('App loads and shows QR scan button', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Expect to find a button with text or icon
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    expect(find.textContaining('Scan'), findsOneWidget);
  });
}
