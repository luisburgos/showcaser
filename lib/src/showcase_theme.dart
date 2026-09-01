import 'package:flutter/material.dart';
import 'package:showcaser/src/showcase_tile_builder.dart';

/// The default narrowest a tile may be laid out at.
///
/// Below this a subtitle starts wrapping past two lines and the column stops
/// reading as a scannable list, so the grid drops a column rather than
/// squeezing one further.
const double kShowcaseMinTileWidth = 280;

/// The default ceiling on how many columns the grid will use.
///
/// Capped rather than left to divide the available width: without a ceiling an
/// ultrawide window would spread the catalogue into one thin line of tiles, and
/// a row scanned by title stops being scannable once it reads as a paragraph.
const int kShowcaseMaxColumns = 4;

/// How a design system dresses the gallery.
///
/// Holds the [tileBuilder] that draws a tile's surface, plus the layout values
/// the gallery lays entries out with. Stated once here rather than repeated at
/// every call site: a design system's spacing is a fact about the system, not
/// about any one list.
///
/// Value semantics are a requirement, not a convenience — [ShowcaseTheme]
/// decides whether to rebuild its dependents by comparing two of these.
@immutable
class ShowcaseThemeData {
  /// Creates a theme. Every value defaults to the stock Material gallery.
  const ShowcaseThemeData({
    this.tileBuilder = const MaterialShowcaseTileBuilder(),
    this.minTileWidth = kShowcaseMinTileWidth,
    this.maxColumns = kShowcaseMaxColumns,
    this.gap = 8,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 48),
    this.coverSpacing = 8,
  });

  /// Draws the surface around each tile's content.
  final ShowcaseTileBuilder tileBuilder;

  /// The narrowest a tile may be laid out at before a column is dropped.
  final double minTileWidth;

  /// The most columns the grid will use.
  final int maxColumns;

  /// The space between tiles, both between columns and between rows.
  final double gap;

  /// Inset around the grid.
  ///
  /// Asymmetric by default: tighter on top, because whatever sits above a
  /// gallery — a tab bar, a chip row — usually supplies its own gap, and
  /// looser on the bottom so the last row can scroll clear of a fixed footer.
  final EdgeInsets padding;

  /// The gap between a tile's cover art (or icon) and its title.
  final double coverSpacing;

  /// A copy with the given values replaced.
  ShowcaseThemeData copyWith({
    ShowcaseTileBuilder? tileBuilder,
    double? minTileWidth,
    int? maxColumns,
    double? gap,
    EdgeInsets? padding,
    double? coverSpacing,
  }) {
    return ShowcaseThemeData(
      tileBuilder: tileBuilder ?? this.tileBuilder,
      minTileWidth: minTileWidth ?? this.minTileWidth,
      maxColumns: maxColumns ?? this.maxColumns,
      gap: gap ?? this.gap,
      padding: padding ?? this.padding,
      coverSpacing: coverSpacing ?? this.coverSpacing,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ShowcaseThemeData &&
      other.tileBuilder == tileBuilder &&
      other.minTileWidth == minTileWidth &&
      other.maxColumns == maxColumns &&
      other.gap == gap &&
      other.padding == padding &&
      other.coverSpacing == coverSpacing;

  @override
  int get hashCode => Object.hash(
    tileBuilder,
    minTileWidth,
    maxColumns,
    gap,
    padding,
    coverSpacing,
  );
}

/// Provides a [ShowcaseThemeData] to the gallery below it.
///
/// A gallery reads the ambient theme with [of]. With no theme in the tree the
/// data is a default [ShowcaseThemeData] — stock Material chrome — so bare
/// usage needs no wrapper.
///
/// Named for what it is rather than how it works, following Material's own
/// `DividerTheme` / `ChipTheme`: [of] returns the *data*, not the widget.
///
/// An [InheritedWidget] rather than an `InheritedTheme`: the latter exists so
/// a theme can be re-wrapped across a route boundary into an overlay or
/// dialog, and a gallery is not shown in one.
class ShowcaseTheme extends InheritedWidget {
  /// Scopes [data] over [child].
  const ShowcaseTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The values provided to the subtree.
  final ShowcaseThemeData data;

  /// The ambient theme's data, or a default when none is in scope.
  static ShowcaseThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<ShowcaseTheme>();
    return theme?.data ?? const ShowcaseThemeData();
  }

  @override
  bool updateShouldNotify(ShowcaseTheme oldWidget) => data != oldWidget.data;
}
