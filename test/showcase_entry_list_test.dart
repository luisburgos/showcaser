import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaser/showcaser.dart';

List<ShowcaseEntry> entries(int count) => [
  for (var i = 0; i < count; i++)
    ShowcaseEntry(
      title: 'Entry $i',
      subtitle: 'Subtitle $i',
      builder: (_) => Scaffold(body: Text('page $i')),
    ),
];

/// Pumps [list] at an exact viewport size, so the column math is exercised at
/// a width the test controls rather than the harness default.
Future<void> pumpAt(
  WidgetTester tester,
  Widget list, {
  required Size size,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: list)));
}

void main() {
  group('columnsFor', () {
    int columns(
      double width, {
      double gap = 8,
      double minTileWidth = kShowcaseMinTileWidth,
      int maxColumns = kShowcaseMaxColumns,
    }) => ShowcaseEntryList.columnsFor(
      width,
      gap: gap,
      minTileWidth: minTileWidth,
      maxColumns: maxColumns,
    );

    test('never returns fewer than one column', () {
      expect(columns(0), 1);
      expect(columns(100), 1);
    });

    test('counts the gaps between columns, not just the tiles', () {
      // Two 280 tiles plus one 8 gap is 568; a width one pixel short of that
      // must still report a single column.
      expect(columns(567), 1);
      expect(columns(568), 2);
    });

    test('caps at maxColumns however wide the space is', () {
      expect(columns(100000), kShowcaseMaxColumns);
    });

    test('honours an overridden minTileWidth and maxColumns', () {
      expect(columns(208, minTileWidth: 100, maxColumns: 2), 2);
      expect(columns(100000, minTileWidth: 100, maxColumns: 2), 2);
    });
  });

  group('theme fallback', () {
    testWidgets('takes its layout from the ambient theme', (tester) async {
      // A theme narrow enough to fit four columns where the default fits two.
      await pumpAt(
        tester,
        const ShowcaseTheme(
          data: ShowcaseThemeData(minTileWidth: 100, padding: EdgeInsets.zero),
          child: _Entries(count: 4),
        ),
        size: const Size(600, 900),
      );

      // 600 / 100 caps at the theme's default 4 columns: one row.
      expect(find.byType(IntrinsicHeight), findsOneWidget);
      expect(find.byType(ShowcaseEntryTile), findsNWidgets(4));
    });

    testWidgets('a constructor argument overrides the theme', (tester) async {
      await pumpAt(
        tester,
        const ShowcaseTheme(
          data: ShowcaseThemeData(minTileWidth: 100, padding: EdgeInsets.zero),
          child: _Entries(count: 4, maxColumns: 2),
        ),
        size: const Size(600, 900),
      );

      // Two columns over four entries: two rows.
      expect(find.byType(IntrinsicHeight), findsNWidgets(2));
    });

    testWidgets('the tile spacing comes from the theme', (tester) async {
      await pumpAt(
        tester,
        ShowcaseTheme(
          data: const ShowcaseThemeData(coverSpacing: 40),
          child: ShowcaseEntryList(
            entries: [
              ShowcaseEntry(
                title: 'A',
                subtitle: 's',
                icon: const Icon(Icons.star),
                builder: (_) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        size: const Size(400, 900),
      );

      final gap = tester.widgetList<SizedBox>(
        find.descendant(
          of: find.byType(ShowcaseEntryTile),
          matching: find.byType(SizedBox),
        ),
      );
      expect(gap.any((b) => b.height == 40), isTrue);
    });
  });

  group('ShowcaseEntryList layout', () {
    testWidgets('lays out one column on a narrow viewport', (tester) async {
      await pumpAt(
        tester,
        ShowcaseEntryList(entries: entries(3)),
        size: const Size(400, 900),
      );

      expect(find.byType(IntrinsicHeight), findsNothing);
      expect(find.byType(ShowcaseEntryTile), findsNWidgets(3));
    });

    testWidgets('lays out rows of tiles on a wide viewport', (tester) async {
      await pumpAt(
        tester,
        ShowcaseEntryList(entries: entries(4)),
        size: const Size(1400, 900),
      );

      // 1400 - 32 padding fits four 280 tiles plus their gaps.
      expect(find.byType(IntrinsicHeight), findsOneWidget);
      expect(find.byType(ShowcaseEntryTile), findsNWidgets(4));
    });

    testWidgets('pads a short final row so its tiles keep column width', (
      tester,
    ) async {
      await pumpAt(
        tester,
        ShowcaseEntryList(entries: entries(5)),
        size: const Size(1400, 900),
      );

      // Five entries over four columns: one full row plus a row of one, whose
      // three missing cells are filled so the real tile is not stretched.
      expect(find.byType(IntrinsicHeight), findsNWidgets(2));
      expect(find.byType(ShowcaseEntryTile), findsNWidgets(5));

      final first = tester.getSize(find.byType(ShowcaseEntryTile).first);
      final last = tester.getSize(find.byType(ShowcaseEntryTile).last);
      expect(last.width, first.width);
    });

    testWidgets('renders nothing for an empty catalogue', (tester) async {
      await pumpAt(
        tester,
        const ShowcaseEntryList(entries: []),
        size: const Size(1400, 900),
      );

      expect(find.byType(ShowcaseEntryTile), findsNothing);
    });

    testWidgets('nests inside another scroll view when shrink-wrapped', (
      tester,
    ) async {
      // The unbounded-height case: a gallery used as one section of a page
      // that already scrolls. Without shrinkWrap this throws "Vertical
      // viewport was given unbounded height".
      await pumpAt(
        tester,
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              ShowcaseEntryList(
                entries: entries(6),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        ),
        size: const Size(1400, 900),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ShowcaseEntryTile), findsNWidgets(6));
    });

    testWidgets('shrink-wraps a single column too', (tester) async {
      await pumpAt(
        tester,
        SingleChildScrollView(
          child: ShowcaseEntryList(
            entries: entries(3),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
        size: const Size(400, 900),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ShowcaseEntryTile), findsNWidgets(3));
    });

    testWidgets('an onEntryPressed override receives the tapped entry', (
      tester,
    ) async {
      final tapped = <String>[];
      await pumpAt(
        tester,
        ShowcaseEntryList(
          entries: entries(2),
          onEntryPressed: (_, entry) => tapped.add(entry.title),
        ),
        size: const Size(400, 900),
      );

      await tester.tap(find.text('Entry 1'));
      await tester.pumpAndSettle();

      expect(tapped, ['Entry 1']);
      expect(find.text('page 1'), findsNothing);
    });

    testWidgets('routes to the entry page with no override', (tester) async {
      await pumpAt(
        tester,
        ShowcaseEntryList(entries: entries(2)),
        size: const Size(400, 900),
      );

      await tester.tap(find.text('Entry 1'));
      await tester.pumpAndSettle();

      expect(find.text('page 1'), findsOneWidget);
    });
  });
}

/// A list of [count] entries, for the theme-fallback group.
class _Entries extends StatelessWidget {
  const _Entries({required this.count, this.maxColumns});

  final int count;
  final int? maxColumns;

  @override
  Widget build(BuildContext context) =>
      ShowcaseEntryList(entries: entries(count), maxColumns: maxColumns);
}
