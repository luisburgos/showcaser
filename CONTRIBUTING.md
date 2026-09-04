# Contributing to showcaser

## What this is

Showcaser is a Flutter package: the gallery shell of a component showcase — a
responsive grid of entry tiles routing to the pages they document.

It is intended for pub.dev, so its public API is a commitment: a breaking
change costs everyone who has adopted it. Treat additions as cheap and
removals as expensive.

---

## Making a change

### Branch from `main`

Name the branch for the kind of change, matching the commit type:
`feat/…`, `fix/…`, `chore/…`, `refactor/…`, `docs/…`.

### Write Conventional Commit subjects

[Conventional Commits][conventional_commits_link] are **required, not
preferred**: `CHANGELOG.md` is generated from commit subjects, so a vague or
malformed subject becomes a vague or malformed release note that cannot be
edited afterwards without rewriting history.

```
feat(list): add a maxColumns override
fix(tile): keep cover art from stretching in a short row
```

Use `!` or a `BREAKING CHANGE:` footer for anything that breaks the public
API.

### Open a pull request

This repository **squash-merges only**, so the **PR title becomes the commit
subject on `main`** — it is permanent history, not a label. It must be a
valid Conventional Commit subject; CI enforces this with
`semantic_pull_request`, and a merge is blocked until it passes.

---

## Setup

This project pins its Flutter SDK with [FVM][fvm_link] (`.fvmrc`). **Run
every Flutter and Dart command through `fvm`** — for example
`fvm flutter test` — so you use the pinned SDK rather than whatever is first
on your `PATH`.

```sh
fvm install        # fetch the pinned Flutter SDK declared in .fvmrc
lefthook install   # wire the git hooks (see https://lefthook.dev for the binary)
npm install        # changelog tooling, needed only when cutting a release
```

---

## Checks

Four gates guard every change, run by both the pre-push hook
([lefthook][lefthook_link]) and CI:

| Gate | Command |
|---|---|
| Format | `fvm dart format .` |
| Analyze | `fvm flutter analyze` |
| Test, with 100% coverage | `fvm exec very_good test --coverage --min-coverage 100` |
| Spell-check (Markdown) | `npx cspell --config .github/cspell.json "**/*.md" --exclude CHANGELOG.md` |

`CHANGELOG.md` is excluded from spell-check deliberately: it holds verbatim
commit subjects, so a historical typo would fail the build on a word nobody
can edit.

Install [very_good_cli][very_good_cli_link] once for the coverage gate:

```sh
dart pub global activate very_good_cli
```

---

## Releasing

The version lives in three files and the changelog is generated from
commits, so the order matters. **Bump first, generate second** — the
generator writes a section for whatever version it finds, so running it
early files new work under the release already published.

### 0. The bump is a PR of its own

A release PR carries the bump and nothing else. Feature work lands first, on
its own; the bump follows in a separate `chore(release): bump to X.Y.Z` PR.

This is not bookkeeping preference. The repository squash-merges, so a bump
committed on a feature branch is destroyed with the rest of that branch's
history the moment the PR merges. What survives on `main` is a single `feat:`
commit, and the release leaves no trace in the log. This bit lowframer once,
whose 0.3.0 shipped with no `chore(release)` commit and had to be recovered by
rewriting `main`.

This is enforced by `tool/check_version_bump_is_alone.sh`, which the
`version_bump_is_alone` CI job runs. A PR that changes the version in
`pubspec.yaml` or `package.json` fails unless every file it touches is one of

```
pubspec.yaml package.json package-lock.json README.md CHANGELOG.md
```

The pre-push hook runs it too, so a piggy-backed bump is refused before the
branch reaches the remote and no CI run is spent saying so. To check by hand:

```sh
tool/check_version_bump_is_alone.sh
```

The guard has its own tests, run by both the hook and CI. Run them after
changing it:

```sh
tool/check_version_bump_is_alone_test.sh
```

It compares the *parsed* version on either side rather than pattern-matching
the diff, so how `pubspec.yaml` or `package.json` happens to be formatted
cannot decide whether a bump is noticed.

If it fails, the fix is never to widen the allowlist. Drop the bump from the
branch, land the feature, then open the release PR.

### 1. Bump the version in all three places, to the same value

| File | Read by |
|---|---|
| `pubspec.yaml` | pub.dev and the published package |
| `package.json` | conventional-changelog |
| the `showcaser: ^X.Y.Z` install snippet in `README.md` | everyone reading the package's front page |

`test/version_drift_test.dart` fails if any of them drift apart.

> **`package.json` is the one to remember.** Being a Node tool, the
> generator reads the version from `package.json` — *not* `pubspec.yaml`.
> Left behind, the command still succeeds: it silently rewrites the previous
> version's section instead of opening a new one.

### 2. Regenerate the changelog

```sh
npm run changelog
```

It *prepends* rather than merges, so running it twice for one version
produces two headings. To rewrite a section, delete the old heading and
regenerate.

### 3. Merge, then tag the merge commit

```sh
git tag <version> && git push origin <version>
```

Nothing lands on `main` between the bump and the tag. The tag bounds the
next release's commit range, so it has to exist before the next changelog
run.

### 4. Publish — only after an explicit go

Publishing is the release's one irreversible step, so it has a human gate:
run the dry-run, show its output, and **wait for an explicit approval of the
publish itself** — approval of the release *process* ("cut the release") is
not approval of the upload. This applies doubly to agents driving the
runbook: steps 1–3 are theirs to execute, step 4 is not, however clean the
dry-run looks.

```sh
fvm dart pub publish --dry-run   # review this together first
fvm dart pub publish             # only after the explicit go
```

**Read the dry-run's file tree, not just its warning count.** `.pubignore`
*replaces* `.gitignore` for publishing rather than merging with it, so once it
exists it owns the entire exclusion list: any directory added to the repo since
it was last edited ships unless it is listed there. `pub publish` reports no
warning for this, so the file tree it prints is the only place it shows up.

This has bitten twice, both times a directory added for a good reason and never
listed: `doc/api/` (generated docs) and `tool/` (release scripts). Scan the tree
for anything that is not `lib/`, `example/`, the README, the changelog, the
license and the pubspec.

Published versions are **immutable**: a version can never be replaced or
deleted, only followed by a newer one.

[conventional_commits_link]: https://www.conventionalcommits.org/en/v1.0.0/
[fvm_link]: https://fvm.app
[lefthook_link]: https://lefthook.dev
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
