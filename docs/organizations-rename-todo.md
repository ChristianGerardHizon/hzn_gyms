# Organizations + HZN Gyms Rename — Status

**Shipped:** `staging` and `main` (PR #1 → staging, PR #2 → main).

## Done

- [x] PR #1 merged to `staging` (organizations + HZN Gyms rename)
- [x] PocketBase migrations/hooks deployed to staging + prod servers
- [x] Backfill: `Kylie Gym` org (`slug=kyliegym`) on staging + prod — `scripts/backfill-organizations.sh`
- [x] `organizations.manage` on **Admin** role (staging + prod)
- [x] Web builds deployed to staging + prod (`HZN Gyms` in `index.html`)
- [x] `PORKBUN_*` on PocketBase systemd (`/etc/pocketbase/kyliegym-porkbun.env`)
- [x] GitHub secrets (partial): `POCKETBASE_URL_*`, `SSH_HOST`, `SSH_USER`
- [x] PR #2 merged `staging` → `main` (`version:minor`)

## Remaining (manual)

- [ ] **Register `hzngyms.com`** on Porkbun (~$11/yr — currently available, not in account). Then:
  - Wildcard DNS `*.hzngyms.com` → `157.245.154.214`
  - Append `server/caddy/hzngyms.com.caddy` to `/etc/caddy/Caddyfile` and `systemctl reload caddy`
  - Retry DNS from `/organizations` or `POST /api/organizations/:id/retry-dns`
- [ ] **GitHub CI secrets** (copy from `kylie-gym` repo or regenerate): `SSH_PRIVATE_KEY`, `VERSION_MANAGER_URL`, `VERSION_COLLECTION_ID`, `SENTRY_*` (prod)
- [ ] **Staging credentials in `.env`**: `STAGING_EMAIL`/`STAGING_PASSWORD` are stale; prod superuser creds work for admin API until updated
- [ ] Full UI QA on staging (login, org switcher, branch scoping) — API/back-end verified

See [hzngyms-infra-runbook.md](hzngyms-infra-runbook.md).

### Toolchain note

- **i18n:** `dart run slang`
- **Codegen:** `build_runner` may fail on `strings.g.dart`; use slang for i18n-only changes

### Intentional `kylie` references

- `kyliegym` org slug in backfill docs
- `legacyDriftDatabaseName = 'kylie_gym'`
- `kylieGymSwCleanupDone` in `web/flutter_bootstrap.js`
- Server paths `/opt/pocketbase/kyliegym*`
