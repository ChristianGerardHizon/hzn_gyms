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

## 4. Grant `organizations.manage`

`system.admin` does **not** include `organizations.manage`.

In PocketBase Admin → user roles:

1. Edit the platform super-admin role (or create `Platform Admin`)
2. Enable `organizations.manage` (and `organizations.view` if listed separately)
3. Assign role to test user
4. Verify app nav shows **Organizations** and `/organizations` is accessible

## 5. Staging QA

| Area | Steps |
|------|--------|
| Auth | Login with email; wrong password → "email or password" |
| Branding | Org splash → themed UI; drawer title matches org |
| Branches | List scoped to org; new branch gets current org |
| Organizations UI | List, create/edit, DNS badge, retry DNS |
| Org switcher | Switch tenant; branches/branding update |
| Rename | App title "HZN Gyms"; local DB migrates from `kylie_gym.sqlite` |

## 6. hzngyms.com infrastructure

Required for `<slug>.hzngyms.com` pre-auth branding.

| Step | Action |
|------|--------|
| DNS delegation | Point `hzngyms.com` NS to Porkbun (or manage records at Porkbun) |
| Wildcard DNS | `*.hzngyms.com` → reverse-proxy server IP |
| Reverse proxy | Caddy/nginx: route `*.hzngyms.com` + apex to Flutter web + PocketBase API |
| Wildcard TLS | Certificate for `*.hzngyms.com` (Caddy on-demand or pre-provisioned) |
| Porkbun env | On PocketBase systemd unit: `PORKBUN_API_KEY`, `PORKBUN_API_SECRET`, `PORKBUN_DNS_TARGET`, `PORKBUN_BASE_DOMAIN` |
| Sentry | Create/migrate project `hzngyms` (see `pubspec.yaml` sentry.project) |

Hook reference: `server/pb_hooks/organizations.pb.js` — `POST /api/organizations/:id/retry-dns`

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
        root * /opt/pocketbase/kyliegym-staging/pb_public
        try_files {path} /index.html
        file_server
    }
}
```

## 7. Production

After staging sign-off:

1. Repeat backfill (section 3) on **production** if not already done
2. Grant `organizations.manage` on prod admin role
3. Merge `staging` → `main` with `version:minor` label
4. Verify production deploy + smoke test
5. Validate `kyliegym.hzngyms.com` (or prod subdomain) resolves with correct branding

## 8. Optional later

- Rename server paths `/opt/pocketbase/kyliegym*` → `hzngyms` (coordinate with `scripts/deploy.sh`)
- Rebrand `icon_pack/` assets
- Backblaze bucket / email alias updates
