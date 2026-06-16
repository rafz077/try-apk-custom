import 'package:flutter_test/flutter_test.dart';

import 'package:body_fit_app/main.dart';

void main() {
  testWidgets('App should launch', (WidgetTester tester) async {
    await tester.pumpWidget(const BodyFitApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('BodyFit Market'), findsOneWidget);
  });
}
