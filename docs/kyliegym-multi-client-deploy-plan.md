# Multi-Client Deploy Plan — kylie-gym

Status as of 2026-08-19: **implemented but inactive**. kylie-gym's server is not provisioned yet, so nothing in this plan runs until the activation steps below are done.

## Background

New client (kylie-gym) joins the existing ebe-gym client on the same Flutter/PocketBase codebase. Decision: **separate PocketBase instance per client** (own server, own database), not shared multi-tenancy — the app has zero multi-tenancy scaffolding today (no tenant/org field anywhere), and retrofitting it for just 2 clients isn't worth it. Same codebase, different `--dart-define=API_URL` per build, different deploy target per client.

## What's done

- **`scripts/deploy.sh`** — added `--client=NAME` flag (default: `ebegym`, so ebe-gym's behavior is unchanged). Changes the default remote server root / systemd service name:
  - `/opt/pocketbase/<client>[-staging]`
  - `pocketbase_<client>[-staging].service`
  - Still overridable via `DEPLOY_SERVER_ROOT` / `DEPLOY_SERVICE_NAME` if a client's server doesn't follow that convention.

- **`.github/workflows/deploy.yml`** — added job `deploy-web-kyliegym-staging`:
  - Builds `flutter build web --dart-define=API_URL=${{ secrets.POCKETBASE_URL_STAGING_KYLIEGYM }}`
  - Deploys via `./scripts/deploy.sh staging --client=kyliegym --web-only`
  - Gated behind `if: vars.KYLIEGYM_DEPLOY_ENABLED == 'true'` — currently unset, so the job **no-ops** (skips cleanly, doesn't fail) and the existing ebe-gym pipeline is unaffected.
  - Staging only, web-only. No production counterpart yet.

- **`docs/deployment.md`** — documents the new secrets, the `KYLIEGYM_DEPLOY_ENABLED` switch, and a "Multi-Client Web Deploys" section explaining the setup.

## What's NOT done (deliberately out of scope until needed)

- No `deploy-web-kyliegym-prod` job (mirror of `deploy-production`) — nothing to point it at yet.
- No Flutter build flavors / per-client branding/app-icon config — app currently builds identically for both clients aside from the baked-in `API_URL`.
- No automated first-time schema seeding for a new client server (see manual step below).

## Activation checklist (once kylie-gym's server exists)

1. Provision the kylie-gym PocketBase server (systemd service named `pocketbase_kyliegym-staging.service` if following convention, or set `DEPLOY_SERVER_ROOT`/`DEPLOY_SERVICE_NAME` overrides).
2. Add GitHub Actions secrets:
   - `POCKETBASE_URL_STAGING_KYLIEGYM`
   - `SSH_HOST_KYLIEGYM`
   - `SSH_USER_KYLIEGYM`
   - `SSH_PRIVATE_KEY_KYLIEGYM`
3. Add repo variable `KYLIEGYM_DEPLOY_ENABLED = true` (Settings → Secrets and variables → Actions → Variables).
4. Seed the schema once, by hand (CI job only pushes `build/web/`, not migrations/hooks):
   ```bash
   ./scripts/deploy.sh staging --client=kyliegym --migrations-only --hooks-only
   ```
5. Merge/re-run a staging deploy — `deploy-web-kyliegym-staging` should now run and push the web build to kylie-gym's server.
6. Once staging is verified working, copy the job as `deploy-web-kyliegym-prod` (mirror `deploy-production`: prod secrets, `--client=kyliegym` with `deploy.sh prod`) and repeat steps 2–4 for prod secrets/variable.

## Reference

See `docs/deployment.md` → "Multi-Client Web Deploys" and "Per-client secrets" for the full secrets table and script usage.
