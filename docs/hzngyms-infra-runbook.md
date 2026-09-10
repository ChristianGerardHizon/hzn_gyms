# HZN Gyms — Staging / Production Runbook

Post-merge checklist for organizations multi-tenancy and subdomain branding.

## 1. Staging deploy verification

After the feature PR merges to `staging`:

1. Confirm GitHub Actions deploy job succeeded (web build + PocketBase migrations/hooks).
2. Open staging app URL and confirm login page loads with **HZN Gyms** branding (or org branding if subdomain is live).

## 2. PocketBase schema (staging)

Migrations ship in `server/pb_migrations/` via deploy. Confirm in Admin UI:

- `organizations` collection exists
- `branches.organization` is required (relation to organizations)
- `users.organization` exists (optional relation)
- API rules scope branches by organization

**Never hand-edit** files under `server/pb_migrations/`.

## 3. Backfill first tenant (staging)

Repeat [backfill-organizations.md](backfill-organizations.md) against **staging** Admin API (`PB_STAGING_*` in `.env`):

1. Auth superuser → get token
2. `GET organizations?filter=slug='kyliegym'` — skip create if exists
3. `POST organizations` with name/slug `Kylie Gym` / `kyliegym` (fires Porkbun hook)
4. `PATCH` each branch without `organization` → set org id
5. `PATCH` each user without `organization` → set org id
6. Ensure `branches.organization` is required in schema

## 4. Grant platform access (`users.superAdmin`)

Platform org create/manage is **not** a role permission (roles differ per organization). Do **not** create a “Platform Admin” role.

**First operator** (bootstrap) — in PocketBase Admin → **users** collection:

1. Open the platform operator user record
2. Set `superAdmin` = `true`
3. Assign the org **Admin** role if they will Enter Tenant (gym powers come from that role / membership, not from the flag alone)
4. Verify app nav shows **Platform** link and `/platform` is accessible

**Additional operators** — once at least one platform admin exists, use **Platform → Users** (`/platform/users`) to grant or revoke `superAdmin` on any user. The signed-in operator cannot change their own flag. Hooks still strip `superAdmin` writes from non–platform-admin clients.

See [organization-onboarding.md](organization-onboarding.md) for the two admin layers, setup wizard, and schema patch details. Leftover Platform Admin cleanup: `.\scripts\cleanup-platform-admin-role.ps1`.

## 5. Staging QA

| Area | Steps |
|------|--------|
| Auth | Login with email; wrong password → "email or password" |
| Branding | Org splash → themed UI; drawer title matches org |
| Branches | List scoped to org; new branch gets current org |
| Platform UI | `/platform` dashboard; org list; create/edit; DNS badge |
| Setup wizard | Create org → wizard; branch + admin required; optional steps skippable; mark complete |
| Org switcher | Switch tenant; branches/branding update; Enter tenant opens gym app |
| Rename | App title "HZN Gyms"; local DB migrates from `kylie_gym.sqlite` |

## 6. hzngyms.com infrastructure

Required for `<slug>.hzngyms.com` pre-auth branding.

| Step | Action |
|------|--------|
| DNS delegation | Register **`hzngyms.com`** on Porkbun (available as of Sep 2026) or point NS to Porkbun |
| Wildcard DNS | `*.hzngyms.com` → reverse-proxy server IP |
| Reverse proxy | Caddy/nginx: route `*.hzngyms.com` + apex to Flutter web + PocketBase API |
| Wildcard TLS | Certificate for `*.hzngyms.com` (Caddy on-demand or pre-provisioned) |
| Porkbun env | On PocketBase systemd unit (configured): `/etc/pocketbase/kyliegym-porkbun.env` with `PORKBUN_API_KEY`, `PORKBUN_API_SECRET`, `PORKBUN_DNS_TARGET`, `PORKBUN_BASE_DOMAIN` |
| Sentry | Flutter project `hzn-gyms` (see `pubspec.yaml` sentry.project) |

Caddy example: [caddy-hzngyms.com.example.caddy](caddy-hzngyms.com.example.caddy)

### Example Caddy snippet (adjust paths/hosts)

```caddy
*.hzngyms.com, hzngyms.com {
    tls {
        dns porkbun {env.PORKBUN_API_KEY} {env.PORKBUN_API_SECRET}
    }
    handle /api/* {
        reverse_proxy 127.0.0.1:8090
    }
    handle {
        root * /opt/pocketbase/hzn_gyms_staging/pb_public
        try_files {path} /index.html
        file_server
    }
}
```

## 7. Production

After staging sign-off:

1. Repeat backfill (section 3) on **production** if not already done
2. Set `users.superAdmin = true` on prod platform operator accounts
3. Merge `staging` → `main` with `version:minor` label
4. Verify production deploy + smoke test
5. Validate `kyliegym.hzngyms.com` (or prod subdomain) resolves with correct branding

## 8. PocketBase stuck in `activating` / HTTP 502

**Symptom:** `systemctl is-active` stays `activating`; app/API return 502. Journal shows:

`failed to apply migration … Duplicated or invalid field name …`

**Cause:** Schema was already applied on that host under a different migration filename (Admin API / seed), then deploy rsync'd a repo migration that tries the same change again.

**Fix (do not hand-edit migration `.js` files):** mark the conflicting file(s) as applied, then restart:

```bash
# applied = integer timestamp (match existing _migrations.applied scale)
sqlite3 /opt/pocketbase/hzn_gyms_staging/pb_data/data.db \
  "INSERT OR IGNORE INTO _migrations (file, applied) VALUES ('1788912755_updated_branches.js', 1788912755000001);"
# repeat for each conflicting file / for prod DB path
sudo systemctl restart pocketbase_hzn_gyms_staging.service   # or pocketbase_hzn_gyms.service
```

Confirm with `systemctl is-active` and `curl …/api/health`.

**Sep 9 2026:** staging + prod crash-looped on `1788912755_updated_branches.js` (slug already present via `1788913508*` / `1788913799*`). Marked `1788912755` / `2778` / `2809` applied on both; also marked `1788935261` on prod (orgs rules already applied as `1788935161` / `5260`).

## 9. Optional later

- Sunsetting legacy `/opt/pocketbase/kyliegym*` (new stack live — see [`hzngyms-provision.md`](hzngyms-provision.md))
- Rebrand `icon_pack/` assets
- Backblaze bucket / email alias updates
