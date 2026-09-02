#!/usr/bin/env bash
#
# A version bump must arrive as its own PR.
#
# This repository squash-merges, so a bump committed on a feature branch is
# destroyed along with the rest of that branch's history when the PR lands.
# What survives on main is a single feat: commit, and the release leaves no
# trace in the log. This bit lowframer once, whose 0.3.0 shipped with no
# chore(release) commit of its own and had to be rebuilt by rewriting main.
#
# Usage:
#   tool/check_version_bump_is_alone.sh [base-ref]
#
# base-ref defaults to origin/main. Exits 0 when the PR changes no version, or
# when it changes only release files; exits 1 otherwise, naming the offenders.
#
# Run it locally before pushing:
#   tool/check_version_bump_is_alone.sh
set -euo pipefail

base="${1:-origin/main}"

# The files a release moves together, plus the two the bump regenerates.
ALLOWED="pubspec.yaml package.json package-lock.json README.md CHANGELOG.md"

if ! git rev-parse --verify --quiet "$base" >/dev/null; then
  echo "error: base ref '$base' not found. Fetch it first, or pass one explicitly." >&2
  exit 2
fi

# Read the declared version out of a ref rather than pattern-matching the
# diff. Matching diff text asks "does a line starting +version: exist?", which
# is a question about formatting: a package.json indented with four spaces, or
# minified onto one line, carries a real bump the pattern never sees, and
# reordering the keys without touching the version makes it fire on a PR that
# bumps nothing. Comparing the values asks the actual question.
#
# A missing file yields an empty string, so a repo without a package.json
# compares "" against "" and simply contributes nothing.
pubspec_version_at() {
  git show "$1:pubspec.yaml" 2>/dev/null |
    sed -n 's/^version:[[:space:]]*\([^[:space:]#]*\).*/\1/p' | head -1
}

package_json_version_at() {
  git show "$1:package.json" 2>/dev/null | python3 -c '
import json, sys
try:
    print(json.load(sys.stdin).get("version", ""))
except Exception:
    print("")
' 2>/dev/null
}

version_touched=false
if [ "$(pubspec_version_at "$base")" != "$(pubspec_version_at HEAD)" ]; then
  version_touched=true
fi
if [ "$(package_json_version_at "$base")" != "$(package_json_version_at HEAD)" ]; then
  version_touched=true
fi

if [ "$version_touched" = false ]; then
  echo "No version change in this PR. Nothing to check."
  exit 0
fi

echo "This PR changes the package version. Checking it changes nothing else."

# Read line by line: paths may contain spaces, so splitting the whole list on
# whitespace is not safe.
offending=""
while IFS= read -r file; do
  [ -z "$file" ] && continue
  case " $ALLOWED " in
    *" $file "*) ;;
    *) offending="$offending $file" ;;
  esac
done < <(git diff --name-only "$base"...HEAD)

if [ -n "$offending" ]; then
  echo "A version bump must be its own PR. This one also changes:$offending" >&2
  echo "" >&2
  echo "Land the other work first, then open a separate" >&2
  echo "'chore(release): bump to X.Y.Z' PR touching only:" >&2
  echo "  $ALLOWED" >&2
  exit 1
fi

echo "Version bump is alone. OK."
