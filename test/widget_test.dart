// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:diamondcityradio/main.dart';
import 'package:diamondcityradio/data/song_repository.dart';
import 'package:diamondcityradio/data/report_repository.dart';

void main() {
  testWidgets('App launches with Pip-Boy theme', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      DiamondCityRadioApp(
        initialSets: [[], [], []],
        songRepo: SongRepository([]),
        reportRepo: ReportRepository([]),
        buildNextSet: () => [],
      ),
    );

    // Verify the app renders without crashing
    expect(find.byType(DiamondCityRadioApp), findsOneWidget);
  });
}
