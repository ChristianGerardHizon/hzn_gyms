---
name: create-pr
description: Version label semantics, deploy/minimum-version labels, release tag naming, and the QA Notes template for pull requests in this repo. Use when creating a PR with gh pr create.
---

# Creating a Pull Request

Core rules live in `CLAUDE.md` (target `staging`, ask for a version label, always include QA Notes). This skill has the detail.

## Version labels

- `version:patch` — Bug fixes, small tweaks (e.g., `1.2.3` → `1.2.4`)
- `version:minor` — New features, enhancements (e.g., `1.2.3` → `1.3.0`)
- `version:major` — Breaking changes, major releases (e.g., `1.2.3` → `2.0.0`)
- **No label** — Skip deploy; the PR will merge without triggering a build (staging only)
- For PRs targeting `main`, a version label is **required** — the deploy will fail without one.
- Add the label using: `gh pr edit <number> --add-label "version:patch"`

## Other labels

- **Optionally add the `deploy` label** on a staging PR to auto-open a staging→main production PR after merge (same as hizone_laundry)
- **For PRs from `staging` to `main`, ask if this should be the new minimum required version:**
  - If yes, add `minimum version`: `gh pr edit <number> --add-label "minimum version"`
  - Deploy then also updates `minimumMajor` / `minimumMinor` / `minimumPatch` on the version manager
- **Release tags (created by deploy):** staging → `staging-X.Y.Z` (prerelease); production → `vX.Y.Z`

## QA Notes

When creating a PR, always include a **QA Notes** section in the PR description that tells testers what to verify. Generate these notes based on the actual changes in the PR:

1. **Analyze the diff** — look at every file changed in the PR
2. **Identify user-facing changes** — UI updates, new screens, changed behavior, updated URLs/configs
3. **List specific test steps** — concrete actions a QA tester should perform, not vague descriptions
4. **Include environment details** — if configs/URLs changed, note what the expected values should be
5. **Call out regressions to watch for** — areas that might break due to the changes

**Format:**
```markdown
## QA Notes
### What changed
- Brief summary of each change

### Test steps
- [ ] Step-by-step actions to verify each change
- [ ] Include expected results for each step

### Regression risks
- Areas that could be affected by these changes
```
