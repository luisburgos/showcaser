// Changelog preset for showcaser.
//
// The sibling Flutter apps (netto, volleyboard, poolmate) use the stock
// `angular` preset, which renders ONLY feat / fix / perf / revert and silently
// drops everything else. That suits an app, where the changelog is read as
// release notes by people who only care what visibly changed.
//
// This package is different: it is consumed by showcase apps, so tooling,
// documentation and test work is relevant to the people depending on it. A
// release made up entirely of `chore` and `docs` would otherwise generate an
// empty section and read as though nothing happened.
//
// So we extend `conventional-changelog-conventionalcommits`, which takes an
// explicit `types` list, and surface the types the angular preset hides.
// Anything marked `hidden: true` is still parsed but kept out of the output.
module.exports = {
  options: {
    preset: {
      name: 'conventionalcommits',
      types: [
        { type: 'feat', section: 'Features' },
        { type: 'fix', section: 'Bug Fixes' },
        { type: 'perf', section: 'Performance' },
        { type: 'revert', section: 'Reverts' },
        { type: 'docs', section: 'Documentation' },
        { type: 'test', section: 'Tests' },
        { type: 'build', section: 'Build & Dependencies' },
        { type: 'ci', section: 'CI' },
        { type: 'refactor', section: 'Refactors' },
        { type: 'chore', section: 'Chores' },
        // Formatting-only changes carry no information for a consumer.
        { type: 'style', hidden: true },
      ],
    },
  },
};
