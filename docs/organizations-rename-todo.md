# Organizations + HZN Gyms Rename — Status

**Shipped:** `staging` and `main` (PR #1 → staging, PR #2 → main).

## Done

- [x] PR #1 merged to `staging` (organizations + HZN Gyms rename)
- [x] PocketBase migrations/hooks deployed to staging + prod servers
- [x] Backfill: `Kylie Gym` org (`slug=kyliegym`) on staging + prod — `scripts/backfill-organizations.sh`
- [x] `organizations.manage` on **Admin** role (staging + prod)
- [x] Web builds deployed to staging + prod (`HZN Gyms` in `index.html`)
- [x] `PORKBUN_*` on PocketBase systemd (`/etc/pocketbase/kyliegym-porkbun.env`)
- [x] GitHub secrets: `POCKETBASE_URL_*`, `SSH_HOST`, `SSH_USER`, `SSH_PRIVATE_KEY`, `VERSION_MANAGER_URL`, `VERSION_COLLECTION_ID`, `SENTRY_AUTH_TOKEN`, `SENTRY_DSN_PROD`
- [x] PR #2 merged `staging` → `main` (`version:minor`)

## Remaining (manual)

See the full checklist in [hzngyms-initial-setup.md](hzngyms-initial-setup.md). Highlights:

- [ ] **Version manager** record not left at `0.0.0` (staging already tagged `staging-0.0.1` by mistake)
- [ ] **Auto-promote**: enable Actions “create and approve pull requests”, or set `GH_PAT`
- [ ] **Register `hzngyms.com`** on Porkbun for tenant wildcards (later; temporary hosts use `*.hzngyms.hznsystems.com`)
- [ ] Full UI QA on https://staging.hzngyms.hznsystems.com
- [ ] Decide prod data strategy (laptop seed vs clean restore)

See [hzngyms-infra-runbook.md](hzngyms-infra-runbook.md).

### Toolchain note

- **i18n:** `dart run slang`
- **Codegen:** `build_runner` may fail on `strings.g.dart`; use slang for i18n-only changes

### Intentional `kylie` references

- `kyliegym` org slug in backfill docs
- `legacyDriftDatabaseName = 'kylie_gym'`
- `kylieGymSwCleanupDone` in `web/flutter_bootstrap.js`
- Legacy server paths `/opt/pocketbase/kyliegym*` (HZN Gyms now uses `/opt/pocketbase/hzn_gyms*`)
