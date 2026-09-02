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
- **Never put a version bump in a PR that changes anything else.** The bump is
  always its own `chore(release): bump to X.Y.Z` PR, opened only after the
  feature work has already landed on `main`. Squash-merge destroys the branch's
  commits, so a piggy-backed bump erases the release from history entirely.
  If you notice mid-branch that a release is due, finish and land the branch
  first, then start a fresh one for the bump. The pre-push hook and CI both
  run `tool/check_version_bump_is_alone.sh`, so a piggy-backed bump is
  refused before it reaches the remote. Do not rely on either to catch it: a
  branch that should never have existed still costs the time to make it.

## Release checklist pointers

- The version lives in **three** places (see CONTRIBUTING's table, including
  the README install snippet); `test/version_drift_test.dart` is the drift
  guard — run it after any bump.
- Bump first, changelog second; tag the merge commit; nothing lands on main
  between bump and tag.

## API invariants

- `ShowcaseTileBuilder` is the single seam through which a consuming design
  system dresses the gallery, and it is carried in `ShowcaseThemeData` rather
  than injected in its own right — the shape Flutter uses for a behavioral
  seam (`PageTransitionsBuilder` inside `PageTransitionsTheme`). New chrome a
  consumer might substitute becomes another builder field on the theme data,
  never a hardcoded widget in the tile.
- `ShowcaseThemeData` must keep exact `==`/`hashCode` over every field,
  including `tileBuilder`. `ShowcaseTheme.updateShouldNotify` compares two of
  them, so a field left out of equality silently stops propagating.
- Naming follows Material, not implementation: the widget is `ShowcaseTheme`
  (never `*Scope`), its field is `data`, and `of(context)` returns the data
  rather than the widget.
- **The package depends on no design system and no illustration kit.** It
  imports Material only for raw primitives (`Card`, `InkWell`, `ListView`,
  `Text`) used as neutral scaffolding for the default style. In particular it
  must never depend on `lowframer`: cover art is supplied by the caller,
  already framed, which is what keeps the gallery usable with any art source.
- **The gallery is content, not chrome.** Page scaffolding — app bars, theme
  toggles, tab shells, version labels — belongs to a consumer's app, not here.
  `ShowcaseEntryList` renders a catalogue; it does not own the screen.
