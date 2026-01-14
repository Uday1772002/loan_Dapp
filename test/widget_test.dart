// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:loan_dapp/main.dart';

void main() {
  testWidgets('App should start with Connect Wallet screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LoanDApp());

    // Verify that we see the Connect Wallet button
    expect(find.text('Connect Wallet'), findsOneWidget);
  });
}
