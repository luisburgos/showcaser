# Agent instructions for showcaser

Read CONTRIBUTING.md first — it is the authoritative process document. The
rules below are the hard gates an agent must not cross on its own judgment.

## Hard gates

- **Never run `dart pub publish` (or any publish/upload) without an explicit,
  separate approval of that exact step.** "Cut the release" authorizes the
  runbook's preparatory steps (bump, changelog, PR, tag) — it does NOT
  authorize the upload. Run the dry-run, present its output, then stop and
  ask. Publishing is immutable; a wrong upload cannot be replaced.
- **Do not push branches or open PRs before the user validates the change**
  and approves, unless they explicitly ask for the push/PR. Commit locally
  and report "committed, not pushed".

## Release checklist pointers

- The version lives in **three** places (see CONTRIBUTING's table, including
  the README install snippet); `test/version_drift_test.dart` is the drift
  guard — run it after any bump.
- Bump first, changelog second; tag the merge commit; nothing lands on main
  between bump and tag.

## API invariants

- `ShowcaseStyle` is the single seam through which a consuming design system
  dresses the gallery. New chrome that a consumer might want to substitute
  belongs on `ShowcaseStyle`, not hardcoded into the tile.
- **The package depends on no design system and no illustration kit.** It
  imports Material only for raw primitives (`Card`, `InkWell`, `ListView`,
  `Text`) used as neutral scaffolding for the default style. In particular it
  must never depend on `lowframer`: cover art is supplied by the caller,
  already framed, which is what keeps the gallery usable with any art source.
- **The gallery is content, not chrome.** Page scaffolding — app bars, theme
  toggles, tab shells, version labels — belongs to a consumer's app, not here.
  `ShowcaseEntryList` renders a catalogue; it does not own the screen.
