import 'package:flutter_test/flutter_test.dart';
import 'package:snake_xtreme/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SnakeXtremeApp());

    // Verify that the splash screen loads with the title
    expect(find.text('SNAKE'), findsOneWidget);
    expect(find.text('XTREME'), findsOneWidget);
  });
}
