import 'package:flutter/material.dart';
import 'package:showcaser/src/showcase_entry.dart';

/// Builds the surface around a gallery tile's content.
///
/// The gallery's behavior — the responsive column math, the free-height rows,
/// the routing — is fixed. Its *chrome* is not: the tile a reader taps is the
/// point a consuming design system will want in its own widgets rather than
/// stock Material, so that is the point this seam exposes.
///
/// The gallery composes the content — cover art or icon, title, subtitle —
/// and hands it here already laid out and sized to the tile. An implementation
/// supplies the *surface* around it and wires [buildTile]'s `onPressed`; it
/// does not rebuild the content. That split is what lets a design system
/// restyle the gallery without reimplementing its layout, and what keeps every
/// gallery reading the same while the chrome changes.
///
/// Abstract rather than concrete-with-defaults so an implementation cannot
/// silently inherit Material chrome it meant to replace; the Material tile is
/// [MaterialShowcaseTileBuilder], which is what a theme falls back to.
///
/// Mirrors Flutter's own behavioral seams — `PageTransitionsBuilder`,
/// `SliverChildDelegate` — which are abstract builders carried inside a theme
/// rather than injected in place of one.
///
@immutable
// A one-member abstract class on purpose: it is a subclassing seam carried in
// a theme and compared by value, not a callback. A top-level function could be
// neither const-constructed into ShowcaseThemeData's default nor given the
// value equality updateShouldNotify depends on.
// ignore: one_member_abstracts
abstract class ShowcaseTileBuilder {
  /// Allows subclasses to be const-constructed.
  const ShowcaseTileBuilder();

  /// Builds one tile.
  ///
  /// [content] is the composed cover art, title and subtitle. [entry] is
  /// passed for the rare implementation that varies by entry; most need only
  /// [content] and [onPressed].
  ///
  /// The returned widget should stretch to fill the height its row was given,
  /// so tiles in a row share one height.
  Widget buildTile(
    BuildContext context, {
    required ShowcaseEntry entry,
    required Widget content,
    required VoidCallback onPressed,
  });
}

/// The stock Material tile: a [Card] with an [InkWell].
///
/// What a gallery renders with when no theme is in scope, so bare usage needs
/// no wiring.
///
/// Value equality so two independently constructed defaults compare equal,
/// which is what keeps `ShowcaseThemeData` equality — and therefore
/// `updateShouldNotify` — honest.
@immutable
class MaterialShowcaseTileBuilder extends ShowcaseTileBuilder {
  /// Creates the Material tile builder.
  const MaterialShowcaseTileBuilder();

  @override
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

  @override
  bool operator ==(Object other) => other is MaterialShowcaseTileBuilder;

  @override
  int get hashCode => (MaterialShowcaseTileBuilder).hashCode;
}
