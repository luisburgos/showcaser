import 'package:flutter/material.dart';
import 'package:showcaser/src/showcase_entry.dart';
import 'package:showcaser/src/showcase_entry_tile.dart';

/// The default narrowest a tile may be laid out at.
///
/// Below this a subtitle starts wrapping past two lines and the column stops
/// reading as a scannable list, so the grid drops a column rather than
/// squeezing one further. Override with `ShowcaseEntryList.minTileWidth`.
const double kShowcaseMinTileWidth = 280;

/// The default ceiling on how many columns the grid will use.
///
/// Capped rather than left to divide the available width: without a ceiling an
/// ultrawide window would spread the catalogue into one thin line of tiles, and
/// a row scanned by title stops being scannable once it reads as a paragraph.
/// Override with `ShowcaseEntryList.maxColumns`.
const int kShowcaseMaxColumns = 4;

/// A responsive gallery of showcase entries, each routing to its page.
///
/// One column on a phone, up to [maxColumns] on a desktop. The layout is
/// driven by the width the list is actually given rather than the window's, so
/// it still lays out correctly inside a padded or inset parent.
class ShowcaseEntryList extends StatelessWidget {
  /// Creates a gallery over [entries], in order.
  const ShowcaseEntryList({
    required this.entries,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 48),
    this.gap = 8,
    this.minTileWidth = kShowcaseMinTileWidth,
    this.maxColumns = kShowcaseMaxColumns,
    this.onEntryPressed,
    this.shrinkWrap = false,
    this.physics,
    super.key,
  });

  /// The entries to list, in order.
  final List<ShowcaseEntry> entries;

  /// Inset around the grid.
  ///
  /// The default is asymmetric on purpose: tighter on top, because whatever
  /// sits above a gallery — a tab bar, a chip row — usually supplies its own
  /// gap, and looser on the bottom so the last row can scroll clear of any
  /// fixed footer.
  final EdgeInsets padding;

  /// The space between tiles, both between columns and between rows.
  final double gap;

  /// The narrowest a tile may be laid out at before a column is dropped.
  final double minTileWidth;

  /// The most columns the grid will use.
  final int maxColumns;

  /// Overrides what tapping an entry does.
  ///
  /// Defaults to the tile's own behavior: pushing the entry's page onto the
  /// nearest [Navigator].
  final void Function(BuildContext context, ShowcaseEntry entry)?
  onEntryPressed;

  /// Whether the list sizes itself to its content rather than to the space it
  /// is given.
  ///
  /// False by default: a gallery is normally the scrolling body of a page, and
  /// building every row up front costs the laziness that makes a long
  /// catalogue cheap. Set it true — with [physics] of
  /// [NeverScrollableScrollPhysics] — to nest the gallery inside another
  /// scroll view, which is the only way it can be given unbounded height
  /// without overflowing.
  final bool shrinkWrap;

  /// The scroll physics of the underlying list.
  ///
  /// Pass [NeverScrollableScrollPhysics] alongside [shrinkWrap] when the
  /// gallery is nested in a parent that already scrolls, so the two do not
  /// compete for the same drag.
  final ScrollPhysics? physics;

  /// How many columns fit in [availableWidth], between one and [maxColumns].
  ///
  /// Counts the gaps as well as the tiles: n columns carry n - 1 gaps between
  /// them, and ignoring those overestimates what fits by a whole gap per
  /// column, which is what pushes the last tile of a row under its minimum.
  @visibleForTesting
  int columnsFor(double availableWidth, double gap) {
    final fitting = (availableWidth + gap) ~/ (minTileWidth + gap);
    return fitting.clamp(1, maxColumns);
  }

  Widget _tile(BuildContext context, ShowcaseEntry entry) {
    final handler = onEntryPressed;
    return ShowcaseEntryTile(
      entry,
      onPressed: handler == null ? null : () => handler(context, entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsFor(
          constraints.maxWidth - padding.horizontal,
          gap,
        );

        // One column is a plain list. Kept as a ListView rather than a
        // one-column grid so the phone case stays lazily built and
        // free-height, which is what lets a tile grow to its own content.
        if (columns == 1) {
          return ListView.separated(
            padding: padding,
            shrinkWrap: shrinkWrap,
            physics: physics,
            itemCount: entries.length,
            separatorBuilder: (_, _) => SizedBox(height: gap),
            itemBuilder: (context, index) => _tile(context, entries[index]),
          );
        }

        // Rows rather than a GridView: a grid wants a fixed extent or aspect
        // ratio for every cell, which would either clip the longest subtitle
        // or pad out every other tile to match it. A Row of Expanded tiles in
        // an IntrinsicHeight lets each row size to its own tallest tile, so a
        // two-line subtitle costs height only in the row that has one.
        return ListView.separated(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: (entries.length / columns).ceil(),
          separatorBuilder: (_, _) => SizedBox(height: gap),
          itemBuilder: (context, rowIndex) {
            final start = rowIndex * columns;
            final rowEntries = entries.skip(start).take(columns).toList();

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: gap,
                children: [
                  for (final entry in rowEntries)
                    Expanded(child: _tile(context, entry)),
                  // A short final row keeps its tiles at column width instead
                  // of stretching them across the gap the missing ones left.
                  for (var i = rowEntries.length; i < columns; i++)
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
