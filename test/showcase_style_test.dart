import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaser/showcaser.dart';

/// A style overriding the single seam, to prove injection reaches the tile.
class _RedTileStyle extends ShowcaseStyle {
  const _RedTileStyle();

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

  group('ShowcaseStyleScope.of', () {
    testWidgets('returns the default style with no scope in the tree', (
      tester,
    ) async {
      late ShowcaseStyle resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = ShowcaseStyleScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, isA<ShowcaseStyle>());
      expect(resolved, isNot(isA<_RedTileStyle>()));
    });

    testWidgets('returns the injected style when wrapped', (tester) async {
      late ShowcaseStyle resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: ShowcaseStyleScope(
            style: const _RedTileStyle(),
            child: Builder(
              builder: (context) {
                resolved = ShowcaseStyleScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(resolved, isA<_RedTileStyle>());
    });

    testWidgets('notifies dependents only when the style changes', (
      tester,
    ) async {
      var builds = 0;
      final dependent = Builder(
        builder: (context) {
          ShowcaseStyleScope.of(context);
          builds++;
          return const SizedBox.shrink();
        },
      );
      Widget build(ShowcaseStyle style) => Directionality(
        textDirection: TextDirection.ltr,
        child: ShowcaseStyleScope(style: style, child: dependent),
      );

      await tester.pumpWidget(build(const ShowcaseStyle()));
      expect(builds, 1);

      // A const-equal style is the same value, so nothing rebuilds.
      await tester.pumpWidget(build(const ShowcaseStyle()));
      expect(builds, 1);

      await tester.pumpWidget(build(const _RedTileStyle()));
      expect(builds, 2);
    });
  });

  group('ShowcaseStyle default', () {
    testWidgets('renders a tappable Material card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ShowcaseEntryTile(entry))),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.text('Buttons'), findsOneWidget);
    });
  });

  group('an injected style', () {
    testWidgets('replaces the tile chrome but keeps the content', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShowcaseStyleScope(
            style: const _RedTileStyle(),
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
