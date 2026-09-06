# HZN Gyms PocketBase provision (2026-09-07)

New PocketBase instances provisioned on `sannjosevet-cicd` (`157.245.154.214`) from local `server/` seed. **Kylie Gym paths were not modified.**

## Targets

| Env | URL | Server root | Service | Port |
|-----|-----|-------------|---------|------|
| prod | https://hzngyms.hznsystems.com | `/opt/pocketbase/hzn_gyms` | `pocketbase_hzn_gyms.service` | 8106 |
| staging | https://staging.hzngyms.hznsystems.com | `/opt/pocketbase/hzn_gyms_staging` | `pocketbase_hzn_gyms_staging.service` | 8107 |

Ports **8106/8107** (not 8104/8105 — those belong to HZN Laundry).

## Deploy user

- User: `deploy-hzngyms`
- Sudoers: `/etc/sudoers.d/deploy-hzn-gyms` (restart of the two HZN Gyms units only)
- CI: `SSH_USER=deploy-hzngyms` + matching `SSH_PRIVATE_KEY`

## Seed notes

- Seeded from local `server/pb_data`, `pb_migrations`, `pb_hooks`, `pb_public`
- Excluded local `pb_data/backups/` and `data.db.pre-*` bak files (legacy ebegym zip backups)
- PocketBase binary **0.39.6** (copied into each root; kyliegym binary left in place)

## Untouched (legacy)

| Path / service | Status |
|----------------|--------|
| `/opt/pocketbase/kyliegym*` | Unchanged |
| `pocketbase_kyliegym*.service` | Still active |
| `*.kyliegym.hznsystems.com` Caddy blocks | Unchanged |
| `/etc/sudoers.d/deploy-kyliegym` | Unchanged |

## Related

- **Initial setup / pitfalls / manual checklist:** [`hzngyms-initial-setup.md`](hzngyms-initial-setup.md)
- Deploy script defaults: [`scripts/deploy.sh`](../scripts/deploy.sh)
- Full deploy pipeline: [`deployment.md`](deployment.md)
