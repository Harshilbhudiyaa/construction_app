import 'package:flutter_test/flutter_test.dart';
import 'package:construction_app/app/app.dart';

void main() {
  testWidgets('App boots and shows role selection screen', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());

    // Splash renders first
    expect(find.text('Smart Construction'), findsOneWidget);

    // Wait for Splash delay + navigation to Role Select
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Role select screen should appear
    expect(find.text('Select Role'), findsOneWidget);
    expect(find.text('Worker'), findsOneWidget);
    expect(find.text('Site Engineer'), findsOneWidget);
    expect(find.text('Contractor'), findsOneWidget);
  });
}
