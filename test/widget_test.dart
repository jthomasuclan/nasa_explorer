import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasa_explorer/main.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('App loads and shows bottom navigation bar with all tabs',
        (WidgetTester tester) async {
      // Arrange - build the app
      await tester.pumpWidget(const NasaApp());

      // Assert - bottom navigation bar exists with all 3 tabs
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Favourites'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}