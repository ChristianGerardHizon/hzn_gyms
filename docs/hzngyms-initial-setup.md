# HZN Gyms — Initial Setup Guide

Post-rename / new PocketBase stack setup for **hzn_gyms**. Use this when standing up a fresh GitHub repo + server roots, or when verifying the Sep 2026 cutover from legacy `kyliegym*`.

Related docs:

- [hzngyms-provision.md](hzngyms-provision.md) — what was provisioned on the server
- [deployment.md](deployment.md) — CI/CD pipeline details
- [hzngyms-infra-runbook.md](hzngyms-infra-runbook.md) — org multi-tenancy / `hzngyms.com` later work

---

## Current stack (as of 2026-09-07)

| Env | Public URL | Server root | systemd | Port |
|-----|------------|-------------|---------|------|
| staging | https://staging.hzngyms.hznsystems.com | `/opt/pocketbase/hzn_gyms_staging` | `pocketbase_hzn_gyms_staging.service` | 8107 |
| prod | https://hzngyms.hznsystems.com | `/opt/pocketbase/hzn_gyms` | `pocketbase_hzn_gyms.service` | 8106 |

| Item | Value |
|------|--------|
| Server | `157.245.154.214` (`sannjosevet-cicd`) |
| Deploy SSH user | `deploy-hzngyms` |
| Sudoers | `/etc/sudoers.d/deploy-hzn-gyms` (restart of the two HZN Gyms units only) |
| PocketBase | 0.39.6 |
| Deploy script defaults | [`scripts/deploy.sh`](../scripts/deploy.sh) → `hzn_gyms*` |

**Legacy (do not use for this repo’s CI):** `/opt/pocketbase/kyliegym*`, `deploy-imbak`, `*.kyliegym.hznsystems.com`, ports 8102/8103. Left running and untouched.

Ports **8104/8105** belong to HZN Laundry — do not reuse them.

---

## What we already completed

1. **Server roots** created and seeded from local `server/` (`pb_data`, migrations, hooks, public). Large local `pb_data/backups/` zip archives were excluded on purpose.
2. **systemd** units enabled for staging/prod on 8107/8106 as `deploy-hzngyms`.
3. **Caddy** site blocks appended for `hzngyms.hznsystems.com` and `staging.hzngyms.hznsystems.com` (kylie blocks unchanged).
4. **DNS A records** created (Porkbun) → `157.245.154.214`.
5. **GitHub secrets** updated for the new stack (see table below).
6. **`scripts/deploy.sh`** pointed at `hzn_gyms*` (merged via PR #5).
7. **Staging deploy succeeded** to `/opt/pocketbase/hzn_gyms_staging` ([Actions run](https://github.com/ChristianGerardHizon/hzn_gyms/actions/runs/34057431052)).

---

## Problems we hit (and fixes)

### 1. Deploy targeted Kylie Gym paths

**Symptom:** CI log showed `Server root : /opt/pocketbase/kyliegym-staging`.

**Cause:** Repo renamed to hzn_gyms; `deploy.sh` still defaulted to kyliegym. No `/opt/pocketbase/hzngyms*` (or `hzn_gyms*`) existed yet.

**Fix:** Provision new roots; change deploy defaults; leave kyliegym alone.

### 2. `Permission denied (publickey)` on rsync

**Symptom:** rsync exit 255; **0 bytes** transferred (Kylie data was safe).

**Cause:** `SSH_PRIVATE_KEY` was the **root** Codemagic/`sannjosevet-cicd` key, while `SSH_USER` was (or should be) a deploy user whose `authorized_keys` expects a different key. `deploy-imbak` trusts `deploy-imbak@github-actions`, not the root cicd key.

**Fix:** New user `deploy-hzngyms` + dedicated ed25519 key (`~/.ssh/id_ed25519_deploy_hzngyms`). Store that private key as `SSH_PRIVATE_KEY`. Set `SSH_USER=deploy-hzngyms`.

### 3. Ports 8104/8105 already taken

**Symptom:** Plan assumed 8104/8105 free.

**Cause:** HZN Laundry already uses those ports.

**Fix:** Use **8106** (prod) and **8107** (staging).

### 4. Wrong Sentry token type (earlier)

**Symptom:** Sentry upload 401.

**Cause:** Client “Security Token” / hex token is not valid for `sentry_dart_plugin` CI uploads.

**Fix:** Org CI token with `org:ci` / `project:releases` (stored as `SENTRY_AUTH_TOKEN`). Keep DSN separate (`SENTRY_DSN_PROD`).

### 5. Version manager URL 404 (earlier)

**Symptom:** Version fetch failed / 404.

**Cause:** Secret was host-only (`https://version-manager.fly.dev`) without `/api/collections/versions/records`.

**Fix:** Full collection URL + record id (`VERSION_MANAGER_URL` + `VERSION_COLLECTION_ID`).

### 6. Staging released as `staging-0.0.1`

**Symptom:** Staging tag/release `staging-0.0.1` after a successful deploy.

**Cause:** Version-manager record `r2yh4ny7e34182b` is literally `major=0 minor=0 patch=0`. Patch bump → `0.0.1`.

**Fix (manual):** PATCH that record (or point secrets at the correct app’s version row) to the intended baseline (e.g. continue from prior product line `2.0.0`). See checklist below.

### 7. Auto Promote to Main failed

**Symptom:** [Auto Promote run](https://github.com/ChristianGerardHizon/hzn_gyms/actions/runs/34057431107) —  
`GitHub Actions is not permitted to create or approve pull requests`.

**Cause:** Repo setting does not allow `GITHUB_TOKEN` to open PRs (even with `pull-requests: write` in the workflow).

**Fix (manual):**  
**Settings → Actions → General → Workflow permissions** → enable **Allow GitHub Actions to create and approve pull requests** (and Read and write permissions).  
Optional: add a classic/fine-grained PAT as secret `GH_PAT` and use it in `auto-promote.yml` (workflow supports `GH_PAT` when set).

Until fixed, open `staging` → `main` PRs manually after a `deploy`-labeled merge.

---

## GitHub Actions secrets (required)

| Secret | Expected value / notes |
|--------|------------------------|
| `SSH_HOST` | `157.245.154.214` |
| `SSH_USER` | `deploy-hzngyms` |
| `SSH_PRIVATE_KEY` | Private key matching `/home/deploy-hzngyms/.ssh/authorized_keys` (not the root cicd key) |
| `POCKETBASE_URL_STAGING` | `https://staging.hzngyms.hznsystems.com` |
| `POCKETBASE_URL_PROD` | `https://hzngyms.hznsystems.com` |
| `VERSION_MANAGER_URL` | `https://version-manager.fly.dev/api/collections/versions/records` |
| `VERSION_COLLECTION_ID` | Record id for **this** app (today: `r2yh4ny7e34182b` — must not stay at 0.0.0) |
| `SENTRY_AUTH_TOKEN` | Org CI token for release/source-map upload |
| `SENTRY_DSN_PROD` | Prod DSN for in-app SDK (`ENV=prod`) |
| `GH_PAT` | **Optional** — PAT that can create PRs (auto-promote); only needed if Actions setting stays off |

Local `.env` should mirror the URLs (`STAGING_URL` / `PROD_URL` / `VERSION_MANAGER_*`). Never commit `.env` or `pb_token.txt`.

---

## Manual checklist — finish initial setup

Do these once; CI cannot finish them alone.

### A. Version manager baseline

- [ ] Confirm `VERSION_COLLECTION_ID` is the HZN Gyms row (not another product’s id).
- [ ] Set `major` / `minor` / `patch` to the intended baseline (recommended if continuing the old line: `2.0.0` so the next patch deploy is `2.0.1`).
- [ ] Optionally set `minimumMajor` / `minimumMinor` / `minimumPatch` for force-update policy.
- [ ] Re-run or merge a `version:patch` staging deploy and confirm the release tag is **not** `staging-0.0.x` unless intentional.

### B. Auto-promote / production PR path

- [ ] Enable **Allow GitHub Actions to create and approve pull requests** on the repo.
- [ ] Or create secret `GH_PAT` with `repo` (or equivalent) scope and keep `auto-promote.yml` using it.
- [ ] Merge a staging PR labeled `version:patch` + `deploy` and confirm Auto Promote opens `staging` → `main`.

### C. App / PocketBase smoke (new hosts)

- [ ] https://staging.hzngyms.hznsystems.com — login, org branding, branch list.
- [ ] PocketBase Admin on staging (superuser from seeded DB / reset if needed).
- [ ] Confirm migrations/hooks landed after CI deploy.
- [ ] Same smoke on https://hzngyms.hznsystems.com **only after** a deliberate prod promote (do not treat seeded laptop DB as final prod forever).

### D. Data / ops (optional but recommended)

- [ ] Decide whether prod should keep the laptop seed or be re-seeded / restored from a known backup.
- [ ] Configure Backblaze/S3 filesystem in **prod** admin if file uploads must persist off-box.
- [ ] Rotate or document `deploy-hzngyms` SSH key backup location.
- [ ] Confirm kyliegym still healthy if tenants still use `*.kyliegym.hznsystems.com`; plan sunset separately.

### E. Later product work (not blocking CI)

- [ ] Register `hzngyms.com` + wildcard DNS / Caddy for tenant subdomains (see infra runbook).
- [ ] Re-enable Porkbun env on systemd if org DNS automation is required.
- [ ] Full UI QA (org switcher, permissions, POS, check-in) on the new staging host.

---

## Local emergency deploy

```bash
# From repo root (Linux/macOS or Git Bash with rsync)
export SSH_HOST=157.245.154.214
export SSH_USER=deploy-hzngyms
# ssh-agent must load id_ed25519_deploy_hzngyms

./scripts/deploy.sh staging
./scripts/deploy.sh prod --hooks-only
```

Overrides: `DEPLOY_SERVER_ROOT`, `DEPLOY_SERVICE_NAME`.

---

## Verify kyliegym was not touched

After any HZN Gyms change:

```bash
systemctl is-active pocketbase_kyliegym.service pocketbase_kyliegym-staging.service
stat -c '%y %n' /opt/pocketbase/kyliegym/pb_public /opt/pocketbase/kyliegym-staging/pb_public
```

Expected: both **active**; `pb_public` mtimes unchanged unless someone intentionally deploys kylie.
