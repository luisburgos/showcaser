import 'package:flutter/material.dart';

/// A single entry in a showcase gallery.
///
/// Deliberately a plain data class over widgets and strings: an entry is
/// content, not chrome. How it is *drawn* belongs to `ShowcaseStyle`, so the
/// same catalogue can be rendered by two design systems without being
/// rewritten.
///
/// The icon is a [Widget] rather than a design system's icon enum, which is
/// what keeps this package free of any one system's types.
@immutable
class ShowcaseEntry {
  /// Creates an entry pointing at the page it documents.
  const ShowcaseEntry({
    required this.title,
    required this.subtitle,
    required this.builder,
    this.icon,
    this.coverArt,
  });

  /// The entry title, and the tile's primary label.
  final String title;

  /// A one-line description of what the entry covers.
  final String subtitle;

  /// Builds the destination page, pushed when the tile is tapped.
  final WidgetBuilder builder;

  /// The leading glyph, shown when [coverArt] is absent.
  ///
  /// Ignored once an entry has cover art: with an illustration on the tile a
  /// second pictogram is redundant weight.
  final Widget? icon;

  /// Builds an optional illustration rendered across the top of the tile.
  ///
  /// The widget is drawn as given — this package supplies no framing panel of
  /// its own, so a caller using a wireframe kit wraps the art in that kit's
  /// own cover before passing it. That keeps the gallery free of any
  /// illustration dependency while leaving the panel fully themeable.
  ///
  /// A builder rather than a widget so the art resolves against the tile's
  /// own context, which is what lets it read the ambient theme.
  final WidgetBuilder? coverArt;
}
