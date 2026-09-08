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

Platform org create/manage is **not** a role permission (roles differ per organization).

In PocketBase Admin → **users** collection:

1. Open the platform operator user record
2. Set `superAdmin` = `true`
3. Verify app nav shows **Platform** link and `/platform` is accessible

Only PocketBase `_superusers` may change `superAdmin` (app hooks strip client attempts).

See [organization-onboarding.md](organization-onboarding.md) for setup wizard and schema patch details.

## 5. Staging QA

| Area | Steps |
|------|--------|
| Auth | Login with email; wrong password → "email or password" |
| Branding | Org splash → themed UI; drawer title matches org |
| Branches | List scoped to org; new branch gets current org |
| Platform UI | `/platform` dashboard; org list; create/edit; DNS badge; retry DNS |
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

Hook reference: `server/pb_hooks/organizations.pb.js` — `POST /api/organizations/:id/retry-dns`

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

## 8. Optional later

- Sunsetting legacy `/opt/pocketbase/kyliegym*` (new stack live — see [`hzngyms-provision.md`](hzngyms-provision.md))
- Rebrand `icon_pack/` assets
- Backblaze bucket / email alias updates
