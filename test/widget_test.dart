// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_holy_bible/main.dart';

void main() {
  testWidgets('App launches and shows HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Expect to find a widget with 'Welcome' text (replace with something you know is in your UI)
    expect(find.text('The Holy Bible'), findsOneWidget);
  });
}
