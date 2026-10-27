import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_bucket/app.dart';
import 'package:news_bucket/data/models/news_category.dart';

void main() {
  testWidgets('shows three tabs and switches between them', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NewsBucketApp()));
    await tester.pumpAndSettle();

    expect(find.text('News Bucket'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));

    await tester.tap(find.text('Saved').last);
    await tester.pumpAndSettle();
    expect(find.text('Saved articles will appear here.'), findsOneWidget);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
  });

  testWidgets('switching to dark mode applies the dark theme', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NewsBucketApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(SegmentedButton<ThemeMode>));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  test('sources.json is valid and uses known categories', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final raw = await rootBundle.loadString('assets/sources.json');
    final sources =
        (jsonDecode(raw) as Map<String, dynamic>)['sources'] as List;

    expect(sources, isNotEmpty);
    final ids = <String>{};
    for (final source in sources.cast<Map<String, dynamic>>()) {
      expect(ids.add(source['id'] as String), isTrue, reason: 'duplicate id');
      expect(
        () => NewsCategory.fromId(source['category'] as String),
        returnsNormally,
      );
      expect(Uri.parse(source['url'] as String).scheme, 'https');
    }
  });
}
