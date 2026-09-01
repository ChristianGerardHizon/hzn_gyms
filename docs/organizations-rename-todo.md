# Organizations + HZN Gyms Rename — Status

Branch: `feat/organizations-and-hzn-gyms-rename` (off `staging`).

## Code complete (committed)

- PocketBase `organizations` collection + Porkbun DNS hook (`server/pb_hooks/`)
- Email-based login (`users.passwordAuth.identityFields = ["email"]`)
- Organization domain/data layer + `CurrentOrganizationController` + branch scoping
- Dynamic branding (theme, logo, app title, org splash)
- Super-admin `/organizations` page + `OrganizationSwitcher`
- Package rename `kylie_gym` → `hzn_gyms` + platform IDs + SQLite legacy shim
- Local "Kylie Gym" org backfill documented in [backfill-organizations.md](backfill-organizations.md)

## Remaining (manual / post-merge)

See [hzngyms-infra-runbook.md](hzngyms-infra-runbook.md) for staging/prod PocketBase setup, DNS, and promotion checklist.

### Quick checklist

- [ ] PR merged to `staging` and deploy succeeded
- [ ] Staging PocketBase: migrations applied, backfill run, `organizations.manage` on platform admin role
- [ ] Staging QA (auth, branding, branch scoping, `/organizations`, org switcher, rename)
- [ ] `hzngyms.com` DNS + wildcard TLS + reverse proxy
- [ ] `PORKBUN_*` env vars on staging/prod PocketBase systemd units
- [ ] Production backfill + permissions
- [ ] `staging` → `main` with `version:minor` after sign-off

### Toolchain note

- **i18n:** use `dart run slang` after editing `assets/i18n/**/*.i18n.json`
- **Codegen:** `dart run build_runner build --delete-conflicting-outputs` may fail on `strings.g.dart` (`Asset already exists`); run slang separately for i18n-only changes

### Intentional `kylie` references (do not rename)

- `kyliegym` org slug in backfill docs (live tenant data)
- `legacyDriftDatabaseName = 'kylie_gym'` in `app_database_name.dart`
- `kylieGymSwCleanupDone` in `web/flutter_bootstrap.js`
- Server deploy paths `/opt/pocketbase/kyliegym*` until infra rename
