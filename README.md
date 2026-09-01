# showcaser

**A gallery shell for component showcases.**

The index page of a design system's demo app: a responsive grid of entry tiles,
each with a cover art, a title and a subtitle, routing to the page it documents.
It uses Material by default, or a `ShowcaseTheme` to match your own design
system.

Built to sit alongside [`playgrounder`](https://pub.dev/packages/playgrounder)
(the playground affordance a showcase page uses) and
[`lowframer`](https://pub.dev/packages/lowframer) (the wireframe kit a cover art
is drawn with). Each is independent; showcaser depends on neither.

## Features ✨

- **A catalogue, not a layout:** describe entries as data, and the gallery lays
  them out
- **Responsive by the width it is given:** one column on a phone, up to four on
  a desktop, measured from the space the list actually has rather than the
  window's
- **Free-height rows:** a two-line subtitle costs height only in the row that
  has one, which a `GridView` cannot do
- **Bring your own design system:** a `ShowcaseTileBuilder` in the theme
  restyles the tile; Material until you do
- **Themed, not configured:** spacing and column rules are stated once in a
  `ShowcaseTheme` above the app, not repeated at every list

## Installation 💻

```yaml
dependencies:
  showcaser: ^0.1.0
```

## Usage 🚀

Describe the catalogue as a list of entries, then hand it to the gallery:

```dart
import 'package:showcaser/showcaser.dart';

final entries = <ShowcaseEntry>[
  ShowcaseEntry(
    title: 'Buttons',
    subtitle: 'Labelled actions across every variant, size and state',
    icon: const Icon(Icons.check),
    builder: (_) => const ButtonsPage(),
  ),
];

ShowcaseEntryList(entries: entries);
```

Tapping a tile pushes its `builder` onto the nearest `Navigator`. Pass
`onEntryPressed` to route differently — a nested navigator, a declarative
router, or a detail pane beside the list.

### Cover art

An entry may lead with an illustration instead of an icon. The art is drawn as
given, so it carries its own framing — showcaser supplies no panel of its own
and depends on no illustration package:

```dart
ShowcaseEntry(
  title: 'Chips',
  subtitle: 'Selectable labels across every variant and state',
  coverArt: (_) => const LowframerCover(child: ChipsCoverArt()),
  builder: (_) => const ChipsPage(),
);
```

With cover art present the `icon` is ignored: an illustration and a pictogram
on the same tile is redundant weight.

### Matching your design system

The tile is the one point a design system substitutes. Implement a
`ShowcaseTileBuilder`, put it in a `ShowcaseThemeData`, and scope it once above
your app:

```dart
class MyTileBuilder extends ShowcaseTileBuilder {
  const MyTileBuilder();

  @override
  Widget buildTile(
    BuildContext context, {
    required ShowcaseEntry entry,
    required Widget content,
    required VoidCallback onPressed,
  }) {
    return MyCard(onPressed: onPressed, child: content);
  }
}

ShowcaseTheme(
  data: const ShowcaseThemeData(
    tileBuilder: MyTileBuilder(),
    gap: 12,
  ),
  child: child,
);
```

The content — cover art, title, subtitle — is composed for you and passed in,
so a builder supplies the surface around it rather than rebuilding the layout.
That is what keeps every gallery reading the same while the chrome changes.

`ShowcaseThemeData` also carries the layout: `minTileWidth`, `maxColumns`,
`gap`, `padding` and `coverSpacing`. Stating them once in the theme is what
lets every `ShowcaseEntryList` in the app be written as
`ShowcaseEntryList(entries: ...)`; pass the same values on a single list to
override the theme there.

## License 📄

MIT — see [LICENSE](LICENSE).
