// TubeNix Widget Tests
// Tests for the TubeNix application

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('TubeNix app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TubeNixApp());

    // Verify that TubeNix text appears on splash screen
    expect(find.text('TubeNix'), findsOneWidget);
    expect(find.text('The Creator\'s Challenge'), findsOneWidget);
  });
}
