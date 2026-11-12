import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ridlers/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app boots to the Ridlers splash screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Ridlers'), findsOneWidget);
    expect(find.text('Pocket money, sorted.'), findsOneWidget);

    // Let the splash navigation timer resolve before the test ends.
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('fresh install lands on the phone login screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    // Let the splash finish its delayed navigation.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
  });
}
