import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('version drift', () {
    String pubspecVersion() => RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1)!;

    test('package.json declares the same version as the pubspec', () {
      // conventional-changelog reads the version from package.json, not the
      // pubspec, and writes a section for whatever it finds. Left behind at a
      // previous version the command still succeeds — it silently rewrites
      // the released section instead of opening a new one. Nothing else
      // catches that, so it is asserted here.
      final packageJson =
          jsonDecode(File('package.json').readAsStringSync())
              as Map<String, dynamic>;

      expect(packageJson['version'], pubspecVersion());
    });

    test('the README install snippet names the same version', () {
      // The README's `showcaser: ^X.Y.Z` is a version spot nothing in the
      // tooling reads, so only an assertion keeps it honest.
      final readme = File('README.md').readAsStringSync();
      final snippet = RegExp(
        r'showcaser:\s*\^(\S+)',
      ).firstMatch(readme)?.group(1);

      expect(
        snippet,
        isNotNull,
        reason: 'no `showcaser: ^X.Y.Z` snippet found in README.md',
      );
      expect(
        snippet,
        pubspecVersion(),
        reason:
            'README.md is stale: the install snippet says ^$snippet but the '
            'package declares ${pubspecVersion()}.',
      );
    });
  });
}
