import 'package:flutter/material.dart';
import 'package:showcaser/src/showcase_entry.dart';
import 'package:showcaser/src/showcase_style.dart';

/// One [ShowcaseEntry] as a tappable tile, routing to its page.
///
/// Composes the content — cover art or icon, title, subtitle — and hands it to
/// the ambient [ShowcaseStyle] to be dressed. The layout lives here so every
/// design system's gallery reads the same; only the surface is substituted.
class ShowcaseEntryTile extends StatelessWidget {
  /// Creates a tile for [entry].
  const ShowcaseEntryTile(this.entry, {this.onPressed, super.key});

  /// The entry to render.
  final ShowcaseEntry entry;

  /// Overrides what a tap does.
  ///
  /// Defaults to pushing `entry.builder` onto the nearest [Navigator], which
  /// is what a gallery wants. Pass a callback to route differently — a nested
  /// navigator, a declarative router, or a detail pane beside the list.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final coverArt = entry.coverArt;
    final icon = entry.icon;
    final theme = Theme.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // The art replaces the icon rather than joining it: with an
        // illustration on the tile a second pictogram is redundant weight.
        if (coverArt != null) ...[
          coverArt(context),
          const SizedBox(height: 8),
        ] else if (icon != null) ...[
          icon,
          const SizedBox(height: 8),
        ],
        Text(entry.title, style: theme.textTheme.titleSmall),
        Text(
          entry.subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    return ShowcaseStyleScope.of(context).buildTile(
      context,
      entry: entry,
      content: content,
      onPressed:
          onPressed ??
          () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: entry.builder)),
    );
  }
}
