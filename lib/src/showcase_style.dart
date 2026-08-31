import 'package:flutter/material.dart';
import 'package:showcaser/src/showcase_entry.dart';

/// How a design system dresses the gallery.
///
/// The gallery's behavior — the responsive column math, the free-height rows,
/// the routing — is fixed. Its *chrome* is not: the tile a reader taps is the
/// one point a consuming design system will want in its own widgets rather
/// than stock Material, so that is the point that lives here.
///
/// The base class supplies a Material default, so a consumer that injects
/// nothing gets a usable gallery with no wiring. Subclass it, override
/// [buildTile], and provide it through a [ShowcaseStyleScope].
///
/// This mirrors `PlaygroundStyle` from the sibling `playgrounder` package on
/// purpose: an app consuming both dresses them the same way, and a reader who
/// has learned one seam already knows the other.
class ShowcaseStyle {
  /// Creates a style. The base builds stock Material chrome.
  const ShowcaseStyle();

  /// Builds one tile in the gallery.
  ///
  /// [content] is the composed title, subtitle and cover art, already laid out
  /// and sized to the tile — an override supplies the *surface* around it and
  /// wires [onPressed], rather than rebuilding the content itself. That split
  /// is what lets a design system restyle the gallery without reimplementing
  /// its layout.
  ///
  /// [entry] is passed for the rare override that needs to vary by entry; most
  /// implementations only need [content] and [onPressed].
  ///
  /// The default is a Material [Card] with an [InkWell]. It stretches to fill
  /// the height its row was given, so tiles in a row share one height.
  Widget buildTile(
    BuildContext context, {
    required ShowcaseEntry entry,
    required Widget content,
    required VoidCallback onPressed,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: content,
        ),
      ),
    );
  }
}

/// Provides a [ShowcaseStyle] to the gallery below it.
///
/// A gallery reads the ambient style with [of]. With no scope in the tree the
/// style is a plain [ShowcaseStyle] — stock Material chrome — so bare usage
/// needs no wrapper.
class ShowcaseStyleScope extends InheritedWidget {
  /// Scopes [style] over [child].
  const ShowcaseStyleScope({
    required this.style,
    required super.child,
    super.key,
  });

  /// The style provided to the subtree.
  final ShowcaseStyle style;

  /// The ambient style, or a default [ShowcaseStyle] when none is in scope.
  static ShowcaseStyle of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ShowcaseStyleScope>();
    return scope?.style ?? const ShowcaseStyle();
  }

  @override
  bool updateShouldNotify(ShowcaseStyleScope oldWidget) =>
      style != oldWidget.style;
}
