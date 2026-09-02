#!/usr/bin/env bash
#
# Tests for check_version_bump_is_alone.sh.
#
# Each case builds a throwaway git repository, commits a branch shaped like a
# real PR, and asserts the check's exit code. Exit codes are the contract:
#   0 = allowed   1 = blocked   2 = could not run
#
# Usage:
#   tool/check_version_bump_is_alone_test.sh
set -euo pipefail

CHECK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/check_version_bump_is_alone.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

passed=0
failed=0

# Builds a fresh repo whose main holds a 0.3.0 release, then leaves a branch
# checked out for the case to modify.
new_repo() {
  local dir="$WORK/$1"
  mkdir -p "$dir"
  git -C "$dir" init -q .
  git -C "$dir" config user.email test@example.com
  git -C "$dir" config user.name test
  git -C "$dir" config commit.gpgsign false
  printf 'name: showcaser\nversion: 0.3.0\ndescription: kit\n' > "$dir/pubspec.yaml"
  printf '{\n  "name": "showcaser",\n  "version": "0.3.0"\n}\n' > "$dir/package.json"
  printf 'dependencies: showcaser ^0.3.0\n' > "$dir/README.md"
  printf '# Changelog\n' > "$dir/CHANGELOG.md"
  printf 'code\n' > "$dir/lib.dart"
  git -C "$dir" add -A
  git -C "$dir" commit -qm "chore: base"
  git -C "$dir" branch -M main
  git -C "$dir" checkout -q -b pr
  echo "$dir"
}

commit_all() { git -C "$1" add -A && git -C "$1" commit -qm "${2:-wip}"; }

# assert <name> <expected-exit> <repo-dir> [base-ref]
assert() {
  local name="$1" want="$2" dir="$3" base="${4:-main}"
  local got=0
  ( cd "$dir" && bash "$CHECK" "$base" ) >/dev/null 2>&1 || got=$?
  if [ "$got" = "$want" ]; then
    printf '  ok    %s\n' "$name"
    passed=$((passed + 1))
  else
    printf '  FAIL  %s (expected exit %s, got %s)\n' "$name" "$want" "$got"
    failed=$((failed + 1))
  fi
}

echo "check_version_bump_is_alone.sh"

# --- the three shapes a PR can take ------------------------------------------

d=$(new_repo bump_alone)
sed -i.bak 's/^version: 0.3.0/version: 0.4.0/' "$d/pubspec.yaml"
sed -i.bak 's/"version": "0.3.0"/"version": "0.4.0"/' "$d/package.json"
sed -i.bak 's/\^0.3.0/^0.4.0/' "$d/README.md"
rm -f "$d"/*.bak
commit_all "$d" "chore(release): bump to 0.4.0"
assert "a bump touching only release files is allowed" 0 "$d"

d=$(new_repo piggyback)
sed -i.bak 's/^version: 0.3.0/version: 0.4.0/' "$d/pubspec.yaml"
rm -f "$d"/*.bak
printf 'code\nfeature\n' > "$d/lib.dart"
commit_all "$d" "feat: piggybacked bump"
assert "a bump alongside source changes is blocked" 1 "$d"

d=$(new_repo feature_only)
printf 'code\nfeature\n' > "$d/lib.dart"
commit_all "$d" "feat: no bump here"
assert "a PR with no version change is allowed" 0 "$d"

# --- formatting must not decide the outcome ----------------------------------
#
# These are why the check compares parsed values rather than diff text. Under
# the earlier grep-based detection the first and third of these passed: a real
# bump went unnoticed because the line did not match the expected shape.

d=$(new_repo json_4_space)
printf '{\n    "name": "showcaser",\n    "version": "0.4.0"\n}\n' > "$d/package.json"
printf 'code\nfeature\n' > "$d/lib.dart"
commit_all "$d" "feat: piggyback with 4-space json"
assert "a bump in 4-space-indented package.json is blocked" 1 "$d"

d=$(new_repo json_minified)
printf '{"name":"lowframer","version":"0.4.0"}\n' > "$d/package.json"
printf 'code\nfeature\n' > "$d/lib.dart"
commit_all "$d" "feat: piggyback with minified json"
assert "a bump in minified package.json is blocked" 1 "$d"

d=$(new_repo pubspec_no_space)
sed -i.bak 's/^version: 0.3.0/version:0.4.0/' "$d/pubspec.yaml"
rm -f "$d"/*.bak
printf 'code\nfeature\n' > "$d/lib.dart"
commit_all "$d" "feat: piggyback, no space after colon"
assert "a bump written 'version:0.4.0' is blocked" 1 "$d"

d=$(new_repo json_reorder)
printf '{\n  "version": "0.3.0",\n  "name": "showcaser"\n}\n' > "$d/package.json"
printf 'code\nfeature\n' > "$d/lib.dart"
commit_all "$d" "chore: reorder json keys, same version"
assert "reordering keys without bumping is allowed" 0 "$d"

d=$(new_repo pubspec_comment)
sed -i.bak 's/^version: 0.3.0/version: 0.3.0 # pinned/' "$d/pubspec.yaml"
rm -f "$d"/*.bak
printf 'code\nfeature\n' > "$d/lib.dart"
commit_all "$d" "chore: annotate the version line"
assert "a trailing comment is not a version change" 0 "$d"

# --- the rest of the allowlist -----------------------------------------------

d=$(new_repo changelog_readme)
sed -i.bak 's/^version: 0.3.0/version: 0.4.0/' "$d/pubspec.yaml"
rm -f "$d"/*.bak
printf '# Changelog\n\n## 0.4.0\n' > "$d/CHANGELOG.md"
sed -i.bak 's/\^0.3.0/^0.4.0/' "$d/README.md"
rm -f "$d"/*.bak
printf '{"lockfileVersion":3}\n' > "$d/package-lock.json"
commit_all "$d" "chore(release): bump to 0.4.0"
assert "changelog, readme and lockfile ride with a bump" 0 "$d"

# --- operational failure is distinguishable from a rejection -----------------

d=$(new_repo bad_base)
printf 'code\nedit\n' > "$d/lib.dart"
commit_all "$d" "chore: noop"
assert "an unresolvable base ref exits 2, not 1" 2 "$d" "no/such/ref"

echo ""
if [ "$failed" -gt 0 ]; then
  echo "$failed failed, $passed passed"
  exit 1
fi
echo "$passed passed"
