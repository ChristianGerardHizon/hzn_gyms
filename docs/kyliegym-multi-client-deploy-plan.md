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
- `scripts/deploy.sh` defaults to kyliegym staging/prod roots and services

## Remaining (CI activation)

1. Add/confirm GitHub Actions secrets for kyliegym URLs and SSH (`POCKETBASE_URL_STAGING` / `POCKETBASE_URL_PROD` or dedicated kyliegym secrets as used by the workflow).
2. Point CI `SSH_HOST` / `SSH_USER` / `SSH_PRIVATE_KEY` at deploy-imbak on this server (same host as other hznsystems apps).
3. Configure Backblaze/S3 filesystem in prod admin (manual; not done at provision time).
4. Optional: enable any kyliegym-specific deploy job / `KYLIEGYM_DEPLOY_ENABLED` if still present in workflows.

## Deploy usage

```bash
SSH_HOST=157.245.154.214 SSH_USER=deploy-imbak ./scripts/deploy.sh staging
SSH_HOST=157.245.154.214 SSH_USER=deploy-imbak ./scripts/deploy.sh prod --hooks-only
```

Overrides still work: `DEPLOY_SERVER_ROOT`, `DEPLOY_SERVICE_NAME`.

## Reference

See [`docs/deployment.md`](deployment.md) for the full deploy pipeline and sudoers/path tables.
