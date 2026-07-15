import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_waleed_flutter/main.dart';

void main() {
  testWidgets('Login screen shows username and password fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AlWaleedApp());

    expect(find.text('تسجيل الدخول'), findsWidgets);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
