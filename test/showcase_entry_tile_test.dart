import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaser/showcaser.dart';

void main() {
  group('ShowcaseEntryTile', () {
    testWidgets('renders the title and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShowcaseEntryTile(
              ShowcaseEntry(
                title: 'Chips',
                subtitle: 'Selectable labels',
                builder: (_) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Chips'), findsOneWidget);
      expect(find.text('Selectable labels'), findsOneWidget);
    });

    testWidgets('shows the icon when there is no cover art', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShowcaseEntryTile(
              ShowcaseEntry(
                title: 'Chips',
                subtitle: 'Selectable labels',
                icon: const Icon(Icons.star),
                builder: (_) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('cover art replaces the icon when both are given', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShowcaseEntryTile(
              ShowcaseEntry(
                title: 'Chips',
                subtitle: 'Selectable labels',
                icon: const Icon(Icons.star),
                coverArt: (_) => const Text('art'),
                builder: (_) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('art'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('renders neither when the entry has no icon or art', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShowcaseEntryTile(
              ShowcaseEntry(
                title: 'Chips',
                subtitle: 'Selectable labels',
                builder: (_) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsNothing);
      expect(find.text('Chips'), findsOneWidget);
    });

    testWidgets('a tap pushes the entry page by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShowcaseEntryTile(
              ShowcaseEntry(
                title: 'Chips',
                subtitle: 'Selectable labels',
                builder: (_) => const Scaffold(body: Text('destination')),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Chips'));
      await tester.pumpAndSettle();

      expect(find.text('destination'), findsOneWidget);
    });

    testWidgets('an onPressed override replaces the default routing', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShowcaseEntryTile(
              ShowcaseEntry(
                title: 'Chips',
                subtitle: 'Selectable labels',
                builder: (_) => const Scaffold(body: Text('destination')),
              ),
              onPressed: () => taps++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Chips'));
      await tester.pumpAndSettle();

      expect(taps, 1);
      expect(find.text('destination'), findsNothing);
    });
  });
}
