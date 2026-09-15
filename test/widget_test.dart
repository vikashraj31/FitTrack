import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/main.dart';

void main() {
  testWidgets('FitTrack app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const HomeScreen());

    expect(find.text('Overview'), findsOneWidget);
  });
}