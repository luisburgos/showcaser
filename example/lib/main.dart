import 'package:flutter/material.dart';
import 'package:showcaser/showcaser.dart';

void main() => runApp(const ExampleApp());

/// The example catalogue: a handful of entries routing to placeholder pages.
///
/// Deliberately plain — the point is the gallery, not the pages behind it.
final _entries = <ShowcaseEntry>[
  for (final (title, subtitle, icon) in <(String, String, IconData)>[
    ('Buttons', 'Labelled actions across every variant and state', Icons.check),
    ('Chips', 'Selectable labels, single or in a group', Icons.label_outline),
    ('Text fields', 'Typed entry, on its own or under a label', Icons.edit),
    (
      'Cards',
      'Surfaces, and keeping their content readable',
      Icons.crop_square,
    ),
    ('Dividers', 'Rules between stacked or side-by-side content', Icons.remove),
    ('App bars', 'Page chrome, shown in place', Icons.web_asset),
    ('Tabs', 'Switching between peer sections', Icons.tab),
    ('Sheets', 'Modal sheets, headers and footers', Icons.more_horiz),
  ])
    ShowcaseEntry(
      title: title,
      subtitle: subtitle,
      icon: Icon(icon),
      builder: (_) => _PlaceholderPage(title: title),
    ),
];

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'showcaser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      // No ShowcaseStyleScope: this is the zero-config path, where the gallery
      // dresses itself in stock Material.
      home: Scaffold(
        appBar: AppBar(title: const Text('showcaser')),
        body: ShowcaseEntryList(entries: _entries),
      ),
    );
  }
}

/// Where a tapped entry lands.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('The $title page.')),
    );
  }
}
