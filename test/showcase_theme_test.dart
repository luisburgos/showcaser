import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaser/showcaser.dart';

/// A builder overriding the seam, to prove injection reaches the tile.
class _RedTileBuilder extends ShowcaseTileBuilder {
  const _RedTileBuilder();

  @override
  Widget buildTile(
    BuildContext context, {
    required ShowcaseEntry entry,
    required Widget content,
    required VoidCallback onPressed,
  }) {
    return ColoredBox(
      color: const Color(0xFFFF0000),
      child: GestureDetector(onTap: onPressed, child: content),
    );
  }
}

void main() {
  final entry = ShowcaseEntry(
    title: 'Buttons',
    subtitle: 'Labelled actions',
    builder: (_) => const Scaffold(body: Text('destination')),
  );

  group('ShowcaseThemeData', () {
    test('defaults to the Material tile builder', () {
      expect(
        const ShowcaseThemeData().tileBuilder,
        isA<MaterialShowcaseTileBuilder>(),
      );
    });

    test('has value equality over every field', () {
      expect(const ShowcaseThemeData(), const ShowcaseThemeData());
      expect(
        const ShowcaseThemeData().hashCode,
        const ShowcaseThemeData().hashCode,
      );
      expect(
        const ShowcaseThemeData(),
        isNot(const ShowcaseThemeData(gap: 12)),
      );
      expect(
        const ShowcaseThemeData(),
        isNot(const ShowcaseThemeData(maxColumns: 2)),
      );
      expect(
        const ShowcaseThemeData(),
        isNot(const ShowcaseThemeData(minTileWidth: 200)),
      );
      expect(
        const ShowcaseThemeData(),
        isNot(const ShowcaseThemeData(coverSpacing: 4)),
      );
      expect(
        const ShowcaseThemeData(),
        isNot(const ShowcaseThemeData(padding: EdgeInsets.zero)),
      );
      expect(
        const ShowcaseThemeData(),
        isNot(const ShowcaseThemeData(tileBuilder: _RedTileBuilder())),
      );
    });

    test('copyWith replaces only what it is given', () {
      const base = ShowcaseThemeData();
      final copy = base.copyWith(gap: 20);

      expect(copy.gap, 20);
      expect(copy.padding, base.padding);
      expect(copy.maxColumns, base.maxColumns);
      expect(copy.minTileWidth, base.minTileWidth);
      expect(copy.coverSpacing, base.coverSpacing);
      expect(copy.tileBuilder, base.tileBuilder);
    });

    test('copyWith with no arguments equals the original', () {
      const base = ShowcaseThemeData(gap: 20, maxColumns: 3);
      expect(base.copyWith(), base);
    });
  });

  group('ShowcaseTheme.of', () {
    testWidgets('returns the default data with no theme in the tree', (
      tester,
    ) async {
      late ShowcaseThemeData resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = ShowcaseTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, const ShowcaseThemeData());
    });

    testWidgets('returns the injected data when wrapped', (tester) async {
      late ShowcaseThemeData resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: ShowcaseTheme(
            data: const ShowcaseThemeData(gap: 24),
            child: Builder(
              builder: (context) {
                resolved = ShowcaseTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(resolved.gap, 24);
    });

    testWidgets('notifies dependents only when the data changes', (
      tester,
    ) async {
      var builds = 0;
      final dependent = Builder(
        builder: (context) {
          ShowcaseTheme.of(context);
          builds++;
          return const SizedBox.shrink();
        },
      );
      Widget build(ShowcaseThemeData data) => Directionality(
        textDirection: TextDirection.ltr,
        child: ShowcaseTheme(data: data, child: dependent),
      );

      await tester.pumpWidget(build(const ShowcaseThemeData()));
      expect(builds, 1);

      // Equal data is the same value, so nothing rebuilds.
      await tester.pumpWidget(build(const ShowcaseThemeData()));
      expect(builds, 1);

      await tester.pumpWidget(build(const ShowcaseThemeData(gap: 24)));
      expect(builds, 2);
    });
  });

  group('the tile builder seam', () {
    testWidgets('the default renders a tappable Material card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ShowcaseEntryTile(entry))),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.text('Buttons'), findsOneWidget);
    });

    testWidgets('an injected builder replaces the chrome, keeps the content', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShowcaseTheme(
            data: const ShowcaseThemeData(tileBuilder: _RedTileBuilder()),
            child: Scaffold(body: ShowcaseEntryTile(entry)),
          ),
        ),
      );

      expect(find.byType(Card), findsNothing);
      // By color, not by type: Scaffold paints a ColoredBox of its own.
      expect(
        find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == const Color(0xFFFF0000),
        ),
        findsOneWidget,
      );
      expect(find.text('Buttons'), findsOneWidget);
      expect(find.text('Labelled actions'), findsOneWidget);
    });
  });
}
