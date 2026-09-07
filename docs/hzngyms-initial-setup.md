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

### 6. Staging released as `staging-0.0.1` / `0.0.2`

**Symptom:** Staging tags like `staging-0.0.1` after deploys.

**Cause:** Version-manager record `r2yh4ny7e34182b` started at `0.0.0` and only patch-bumps.

**Fix (manual):** PATCH that record to the intended baseline (e.g. `2.0.0`). Still outstanding as of Sep 2026 (record was at `0.0.1` after early deploys).

### 7. Auto Promote to Main failed (Actions cannot create PRs)

**Symptom:** [Auto Promote run](https://github.com/ChristianGerardHizon/hzn_gyms/actions/runs/34057431107) —  
`GitHub Actions is not permitted to create or approve pull requests`.

**Cause:** Repo setting does not allow `GITHUB_TOKEN` to open PRs (even with `pull-requests: write` in the workflow).

**Fix (manual):**  
**Settings → Actions → General → Workflow permissions** → enable **Allow GitHub Actions to create and approve pull requests** (and Read and write permissions).  
Optional: add a classic/fine-grained PAT as secret `GH_PAT` and use it in `auto-promote.yml` (workflow supports `GH_PAT` when set).

### 8. Missing keystore secrets on non-`web-only` deploy

**Symptom:** Staging deploy fails at “Verify deploy secrets exist” with `KEYSTORE_*` missing ([example](https://github.com/ChristianGerardHizon/hzn_gyms/actions/runs/34060109389)).

**Cause:** After removing forced `DEPLOY_WEB_ONLY`, APK builds require keystore secrets whenever the PR lacks `web-only`.

**Fix:** Generate an upload keystore locally, store passwords in gitignored `keystore-secrets.txt` / `.env` / `android/key.properties`, and set GitHub secrets `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`. **Done** for this repo (Sep 2026).

### 9. Invalid `auto-promote.yml` after heredoc edit

**Symptom:** [Workflow file invalid on line 114](https://github.com/ChristianGerardHizon/hzn_gyms/actions/runs/34060109267).

**Cause:** Unindented `##` lines inside a `run: |` block terminated the YAML scalar early.

**Fix:** Keep heredoc body indented under the block, then `sed` strip indent (PR #9).

### 10. `web-only` is label-gated (not global)

`DEPLOY_WEB_ONLY=true` was removed. Web-only mode runs **only** when the PR has `web-only` (or manual dispatch `web_only=true`). Auto-promote forwards `web-only` and `deploy` from feature→staging onto staging→main, and refreshes an existing promote PR’s title/body/labels.

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
| `KEYSTORE_BASE64` | Android upload keystore (required for non-`web-only` deploys) |
| `KEYSTORE_PASSWORD` | Keystore store password |
| `KEY_ALIAS` | Key alias (e.g. `hzngyms`) |
| `KEY_PASSWORD` | Key password |
| `PLAYSTORE_SERVICE_ACCOUNT_JSON` | **Optional** — Play Console service-account JSON for Internal testing AAB upload; if unset, Play step is skipped |
| `GH_PAT` | **Optional** — PAT that can create PRs (auto-promote); only needed if Actions setting stays off |

Local `.env` should mirror the URLs (`STAGING_URL` / `PROD_URL` / `VERSION_MANAGER_*`) and may include `KEYSTORE_*` plus `PLAYSTORE_SERVICE_ACCOUNT_JSON_PATH` for reference. Never commit `.env`, `pb_token.txt`, `*.jks`, `key.properties`, `keystore-secrets.txt`, or `android/keystore/`.

---

## Manual checklist — finish initial setup

Do these once; CI cannot finish them alone.

### A. Version manager baseline

- [ ] Confirm `VERSION_COLLECTION_ID` is the HZN Gyms row (not another product’s id).
- [ ] Set `major` / `minor` / `patch` to the intended baseline (recommended if continuing the old line: `2.0.0` so the next patch deploy is `2.0.1`). **Still on `0.0.x` as of Sep 2026.**
- [ ] Optionally set `minimumMajor` / `minimumMinor` / `minimumPatch` for force-update policy.
- [ ] Re-run or merge a `version:patch` staging deploy and confirm the release tag is **not** `staging-0.0.x` unless intentional.

### B. Auto-promote / production PR path

- [x] Auto-promote can open/update `staging` → `main` (e.g. [PR #10](https://github.com/ChristianGerardHizon/hzn_gyms/pull/10)) — ensure Actions “create and approve pull requests” stays enabled, or keep `GH_PAT`
- [x] Auto-promote refreshes an existing promote PR (title/body/labels) on later `deploy` merges
- [x] `web-only` / `deploy` labels forward from feature→staging → staging→main

### C. Android signing

- [x] Upload keystore generated; GitHub `KEYSTORE_*` secrets set; local `keystore-secrets.txt` + `android/key.properties` gitignored
- [ ] Keep a secure offline backup of the `.jks` + passwords (losing them blocks Play Store updates for that signing key)

### C2. Google Play Internal testing

- [x] Repo secret `PLAYSTORE_SERVICE_ACCOUNT_JSON` set (from HZN service account JSON)
- [ ] Add the same secret on the **Production** environment if env-scoped secrets are required (PAT may lack env secret write)
- [ ] Grant the Play service account access to the **HZN Gyms** app (`com.hznsystems.hzngyms`) with release-to-testing
- [ ] First AAB uploaded manually in Play Console if the API rejects an empty Internal track
- [ ] Local `.env` has `PLAYSTORE_SERVICE_ACCOUNT_JSON_PATH`; JSON lives under gitignored `android/keystore/`

### C3. Google web login (OAuth)

Existing-staff only: Google email must match an admin-created `users` record. Server hook `onRecordAuthWithOAuth2Request` rejects unknown Google emails.

- [ ] Google Cloud → OAuth consent screen + **Web** OAuth client
- [ ] Authorized redirect URIs (PocketBase, not the Flutter app):
  - Local: `http://127.0.0.1:8090/api/oauth2-redirect`
  - Staging: `{PB_STAGING_URL}/api/oauth2-redirect`
  - Prod: `{PB_PROD_URL}/api/oauth2-redirect`
- [ ] PocketBase Admin → **users** → Options → OAuth2 → enable + add Google (Client ID / Secret)
- [ ] Keep password auth enabled
- [ ] Confirm `pb_hooks` (users OAuth reject) deployed on staging/prod
- [ ] Smoke: staff with matching Google email can sign in on web; unknown Google email is denied

### D. App / PocketBase smoke (new hosts)

- [ ] https://staging.hzngyms.hznsystems.com — login, org branding, branch list.
- [ ] PocketBase Admin on staging (superuser from seeded DB / reset if needed).
- [ ] Confirm migrations/hooks landed after CI deploy.
- [ ] Same smoke on https://hzngyms.hznsystems.com **only after** a deliberate prod promote (do not treat seeded laptop DB as final prod forever).

### E. Data / ops (optional but recommended)

- [ ] Decide whether prod should keep the laptop seed or be re-seeded / restored from a known backup.
- [ ] Configure Backblaze/S3 filesystem in **prod** admin if file uploads must persist off-box.
- [ ] Rotate or document `deploy-hzngyms` SSH key backup location.
- [ ] Confirm kyliegym still healthy if tenants still use `*.kyliegym.hznsystems.com`; plan sunset separately.

### F. Later product work (not blocking CI)

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
