# Organizations + HZN Gyms Rename — Progress & Remaining Work

Working notes for `feat/organizations-and-hzn-gyms-rename`. Full plan/context: see the
approved plan this branch is implementing (org > branch multi-tenancy with
Porkbun DNS automation, dynamic branding, then a full kylie→hzn rename).

## Branch / repo state

- Branch: `feat/organizations-and-hzn-gyms-rename` (off `staging`).
- `origin` now points to `git@github.com:ChristianGerardHizon/hzn_gyms.git` (mirrored `main`+`staging`
  there). The old repo is kept as remote `old-origin` →
  `git@github.com:ChristianGerardHizon/kylie-gym.git` (untouched, nothing deleted).
- Local PocketBase dev server: `D:\Tools\pocketbase\pocketbase.exe serve --dir=server/pb_data
  --hooksDir=server/pb_hooks --migrationsDir=server/pb_migrations --publicDir=server/pb_public`
  on `127.0.0.1:8090`. **Currently stopped** (was killed while debugging the test failures below —
  start it again before doing more schema/backfill work).

## Done (committed)

1. **PocketBase schema** — `organizations` collection, optional→required `branches.organization`,
   optional `users.organization`, org-scoped `branches` list/view rules, `organizations.manage`
   permission gating. Migrations auto-generated via Admin API (never hand-edited).
2. **Porkbun DNS hook** — `server/pb_hooks/organizations.pb.js` +
   `server/pb_hooks/lib/organizations_helpers.js`. Tested live against the local server: creates
   `<slug>.hzngyms.com`, sets `dnsStatus`, retry route gated behind `organizations.manage`, skips
   real Porkbun calls when `PORKBUN_API_KEY`/`PORKBUN_API_SECRET` aren't set in the process env.
3. **Email-based login** (separate user request) — PocketBase `users.passwordAuth.identityFields`
   is now `["email"]` (email required), login form/repository/controller switched from
   username→email, `invalidCredentials` i18n string updated.
4. **Organization domain/data layer** — mirrors `Branch`: `Organization`, `OrganizationDto`,
   `OrganizationRepository` (+ `fetchBySlugOrHostname`, `retryDnsProvisioning`).
   `organizations.manage`/`organizations.view` permissions added to `Permissions` (NOT covered by
   the `isAdmin` bypass — see `CurrentUserPermissions.canManageOrganizations`).
5. **Org resolution + branch scoping** — `CurrentOrganizationController` (web: `Uri.base.host` →
   subdomain/slug lookup; else signed-in user's `organization`; else persisted secure-storage
   choice). `BranchesController` now filters by the resolved org and stamps it on newly-created
   branches.
6. **Dynamic branding** — `theme_provider` package removed entirely; `AppThemes.light/dark(Color)`
   + `MaterialApp.router(theme:, darkTheme:, themeMode:)` driven by
   `effectiveSeedColorProvider`/`currentThemeModeProvider.toThemeMode`. New `OrgLogo` widget
   (falls back to bundled icon), `effectiveAppTitleProvider` wired into app title/drawer text.
   `Application` gates its first frame on org resolution via `OrgLoadingSplash`.
7. **Backfill** — "Kylie Gym" org created for real through the Admin API (fired the Porkbun hook
   like any org would), local branch/user linked, `branches.organization` tightened to required.
   Documented as repeatable curl steps in `docs/backfill-organizations.md` (includes the
   `users.email` gotcha from item 3).
8. macOS `GeneratedPluginRegistrant.swift` regenerated (dropped `shared_preferences_foundation`,
   a transitive dep that only came from `theme_provider`).

Commits so far (oldest→newest): schema+hook → email auth → org domain/data → org resolution+branch
scoping → dynamic branding → macOS registrant fix → backfill+docs.

## In progress / uncommitted right now

Working tree has these **uncommitted** changes (not yet safe to commit — see blocker below):

- `assets/i18n/en/failures.i18n.json`, `assets/i18n/tl/failures.i18n.json` — `invalidCredentials`
  text changed from "username or password" → "email or password".
- `lib/src/core/i18n/strings_en.g.dart`, `strings_tl.g.dart` — **hand-patched** (not regenerated —
  see toolchain issue below) to match the JSON source change above.
- `test/features/auth/presentation/pages/login_page_test.dart` — updated to fill an email instead
  of a username, and to expect the new error string. **Passes.**
- `test/features/members/presentation/widgets/member_create_wizard_card_step_test.dart` and
  `test/features/memberships/presentation/widgets/purchase_membership_dialog_test.dart` — added
  `currentOrganizationIdProvider.overrideWithValue(null)` to their `ProviderScope` overrides.
  **Still failing — see blocker.**
- Untracked `kylie-fitness-gym-icon-pack_1.zip` at repo root — flagged in the plan as something to
  ask the user about (likely delete), never touched.

### 🔴 Blocker: 4 widget tests still fail after the org-scoping change

`BranchesController.build()` now reads `currentOrganizationIdProvider`. Two test files that mount
widgets pulling in `branchesControllerProvider` transitively (not directly imported/overridden)
started failing with a `pumpAndSettle` timeout:

- `test/features/members/presentation/widgets/member_create_wizard_card_step_test.dart` (3 tests)
- `test/features/memberships/presentation/widgets/purchase_membership_dialog_test.dart` (1 test)

Overriding `currentOrganizationIdProvider.overrideWithValue(null)` did **not** fix it. The captured
exception shows a real HTTP call reaching `http://127.0.0.1:8090/api/collections/branches/records`
with a **400** response — reproduced both with the local PocketBase server running *and* after
`taskkill`-ing it, which doesn't make sense for a live server and needs more digging (possibly a
stale connection being reused, a different process listening on 8090, or the error is unrelated to
connectivity and PocketBase itself is legitimately rejecting `filter=isDeleted+%3D+false` for some
config reason worth checking directly with curl once the server's back up). Next steps:

1. Confirm nothing is listening on `127.0.0.1:8090` (`netstat`), then re-run just those two test
   files in isolation to rule out state leaking from an earlier test in the same `flutter test`
   process.
2. If it's really a live call reaching PocketBase, that's a **pre-existing** test hygiene problem
   (a widget test should never hit the network) that `BranchesController`'s new org-dependency just
   made newly-visible/newly-triggered — determine why `branchesControllerProvider` builds at all in
   these tests (what widget in `MemberFormDialog`/`PurchaseMembershipDialog` reads it) and either
   override `branchesControllerProvider`/`branchRepositoryProvider` directly (like
   `_FakeMembershipsController` does for memberships) or find/add the override these tests were
   presumably relying on before to short-circuit it.
3. Run the **full** suite again once fixed (`flutter test`) to confirm no other files are affected
   the same way — only these two turned up in the last full run, but worth double-checking.

### Known pre-existing toolchain issue (unrelated to this branch, worth flagging separately)

`dart run build_runner build --delete-conflicting-outputs` fails with
`InvalidOutputException: kylie_gym|lib/src/core/i18n/strings.g.dart — Asset already exists`, even
after `dart run build_runner clean` and even after renaming the file out of the way first. The CLI
also warns `--delete-conflicting-outputs` and `--low-resources-mode` "have been removed and were
ignored" — suggesting a build_runner version bump changed conflict-resolution behavior in a way
that's now broken for this specific slang-generated output. Worked around by hand-editing
`strings_en.g.dart`/`strings_tl.g.dart` directly for the one string that changed; **not a real fix**
— any future i18n string changes will need the same manual patch (or the toolchain issue needs a
real fix: check `build_runner`/`slang_build_runner`/`analyzer` version compatibility, possibly
pin/bump versions) until resolved. CLAUDE.md's `--low-resources-mode` instruction also can't
currently be honored since the flag is ignored by the installed build_runner version.

## Not started

### Phase 4/5 remainder — Organizations UI
- Super-admin-only nav entry for a new `/organizations` route (list/switch/create orgs, view
  `dnsStatus`, retry DNS). Need to locate the nav-item registry consumed by `tablet_nav_rail.dart`/
  `mobile_drawer.dart` first.
- `lib/src/core/routing/routes/organizations.routes.dart` (new, plural — keep the existing
  singular `lib/src/features/organization/` feature as-is per the plan's naming-collision
  resolution).
- `OrganizationSwitcher` widget mirroring `branch_switcher.dart`, gated on
  `CurrentUserPermissions.canManageOrganizations`.
- An actual "Organizations" management page: list, create (name/slug/branding fields), edit,
  dns status badge + retry button (calls `OrganizationRepository.retryDnsProvisioning`).

### Phase 7 — full kylie→hzn rename (not started at all)
Everything in the approved plan's Phase 7: `pubspec.yaml` name, `package_rename_config.yaml` +
running the rename tool, the ~168+ file `package:kylie_gym/` → `package:hzn_gyms/` import rewrite
across `lib/`+`test/`, `lib/main.dart` (`runKylieGymApp` → `runHznGymsApp`), the local SQLite DB
filename compat shim (`app_database.dart`), i18n `appName` fallback strings, `web/manifest.json`+
`index.html`+`flutter_bootstrap.js`, CI comment/default-value updates in `deploy.yml`/
`auto-promote.yml`/`scripts/deploy.sh`, `server/pb_public/index.html` title, `CLAUDE.md`/
`README.md` naming, and deciding what to do with `kylie-fitness-gym-icon-pack_1.zip`/`icon_pack/`.
This is the largest remaining chunk of work and hasn't been touched yet.

### Manual follow-up (infra, explicitly out of code-plan scope — see plan's checklist)
Domain registration/delegation for `hzngyms.com` to Porkbun, wildcard TLS + reverse proxy,
server-side directory/systemd/sudoers renames, Backblaze bucket rename, email alias updates,
provisioning `PORKBUN_API_KEY`/`PORKBUN_API_SECRET`/`PORKBUN_DNS_TARGET`/`PORKBUN_BASE_DOMAIN` as
real server env vars (note: `PORKBUN_API_KEY`/`PORKBUN_API_SECRET` already exist in the repo's
local `.env` — reuse those names, don't rename to `PORKBUN_SECRET_API_KEY` as an earlier plan draft
said).

## Before resuming

- Restart the local PocketBase server (see command above) if doing more schema/API work.
- Resolve the blocker above before committing the currently-uncommitted test files.
- Re-run `flutter analyze` + `flutter test` (full suite) once the blocker's fixed, then commit as
  its own logical commit (email-auth i18n fix + the two test files), separate from Phase 7 rename
  work.
