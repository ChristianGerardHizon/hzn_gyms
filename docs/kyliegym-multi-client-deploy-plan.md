# Multi-Client Deploy Plan — kylie-gym

Status as of 2026-08-23: **server provisioned**. Prod and staging PocketBase instances run on `sannjosevet-cicd`.

**Update 2026-09-07:** This repo’s [`scripts/deploy.sh`](../scripts/deploy.sh) now defaults to **HZN Gyms** paths (`/opt/pocketbase/hzn_gyms*`). Legacy kyliegym instances below remain on the server untouched. See [`hzngyms-provision.md`](hzngyms-provision.md).

## Background

kylie-gym is a separate PocketBase instance per client (own data dir / DB), not shared multi-tenancy. Domains:

| Env | URL | Server root | Service | Port |
|-----|-----|-------------|---------|------|
| prod | https://kyliegym.hznsystems.com | `/opt/pocketbase/kyliegym` | `pocketbase_kyliegym.service` | 8102 |
| staging | https://staging.kyliegym.hznsystems.com | `/opt/pocketbase/kyliegym-staging` | `pocketbase_kyliegym-staging.service` | 8103 |

## What's done

- PocketBase dirs + binary (0.39.6), seeded from local `server/pb_data`, hooks, migrations
- systemd units + Caddy reverse proxy for both hosts
- DNS A records → `157.245.154.214`
- `/etc/sudoers.d/deploy-kyliegym` for `deploy-imbak` restarts
- Legacy kyliegym roots remain on disk; **this repo no longer deploys to them**

## Status (2026-09)

HZN Gyms CI deploys to `/opt/pocketbase/hzn_gyms*` via `deploy-hzngyms`. See [hzngyms-provision.md](hzngyms-provision.md) and [hzngyms-initial-setup.md](hzngyms-initial-setup.md).

To touch **legacy kyliegym** only (not the default for this repo):

```bash
SSH_HOST=157.245.154.214 SSH_USER=deploy-imbak \
  DEPLOY_SERVER_ROOT=/opt/pocketbase/kyliegym-staging \
  DEPLOY_SERVICE_NAME=pocketbase_kyliegym-staging.service \
  ./scripts/deploy.sh staging
```

## Reference

See [`docs/deployment.md`](deployment.md) and [`docs/hzngyms-initial-setup.md`](hzngyms-initial-setup.md).
