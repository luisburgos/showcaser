import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaser/showcaser.dart';

void main() {
  group('ShowcaseEntry', () {
    test('keeps the values it is given', () {
      Widget page(BuildContext context) => const SizedBox.shrink();
      const icon = Icon(Icons.star);

      final entry = ShowcaseEntry(
        title: 'Buttons',
        subtitle: 'Labelled actions',
        builder: page,
        icon: icon,
      );

      expect(entry.title, 'Buttons');
      expect(entry.subtitle, 'Labelled actions');
      expect(entry.builder, page);
      expect(entry.icon, icon);
      expect(entry.coverArt, isNull);
    });

    test('icon and coverArt are optional', () {
      final entry = ShowcaseEntry(
        title: 'Colors',
        subtitle: 'The palette',
        builder: (_) => const SizedBox.shrink(),
      );

      expect(entry.icon, isNull);
      expect(entry.coverArt, isNull);
    });
  });
}
