import 'package:flutter_test/flutter_test.dart';

import 'package:nexcarg/main.dart';

void main() {
  testWidgets('NexCarg shows the auth screen on cold start', (WidgetTester tester) async {
    await tester.pumpWidget(const NexCargApp());
    await tester.pump();

    expect(find.text('NexCarg'), findsWidgets);
    expect(find.text('Iniciar sesión'), findsWidgets);
  });
}
