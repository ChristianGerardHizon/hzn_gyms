# Organization Onboarding

Super-admins with `users.superAdmin = true` use the **Platform** shell (`/platform`) to create tenants and run the setup wizard. Branch staff continue using the gym app at `/`. Role permissions stay per-organization and do not grant platform access.

## Platform shell routes

| Route | Purpose |
|-------|---------|
| `/platform` | Dashboard — tenant counts, recent orgs, quick links |
| `/platform/organizations` | Organization list (create, edit, continue setup) |
| `/platform/organizations/:orgId/setup` | Guided onboarding wizard |

Legacy `/organizations` redirects to `/platform/organizations`. The old `/organization/*` nested paths still redirect to top-level `/users`, `/roles`, and `/branches`.

## Setup wizard steps

1. **Branding** — review name, slug, colors (edit via org form)
2. **First branch** — required; scoped to the tenant
3. **Org admin** — required user with email, default branch, and Admin role (`system.admin`)
4. **Membership plan** — optional (skippable)
5. **Product** — optional (skippable)
6. **Review & complete** — client checklist mirrors server validation

Creating an organization from the list dialog switches into that tenant and navigates to the setup wizard automatically.

## Completion criteria (server-authoritative)

`POST /api/organizations/{id}/complete-setup` runs the same checks as the wizard review step:

- At least one branch for the organization
- At least one admin user with email, branch, and `system.admin` role

DNS / per-tenant subdomain provisioning is **not** required. Organizations work without a custom hostname; staff sign in on the shared app URL and branding is applied from the user's organization after login.

On success, PocketBase sets `setupStatus = ready` and `setupCompletedAt`.

Hook implementation: `server/pb_hooks/lib/organization_setup_helpers.js`.

## Public branding resolve

Unauthenticated clients resolve tenant branding by hostname:

```
GET /api/public/organizations/resolve?host={hostname}
```

Returns id, name, slug, displayName, seed/splash colors, logo URLs, and subdomain. The endpoint remains available for future use (e.g. marketing landing pages), but the Flutter **login screen is organization-agnostic** — tenant branding is applied only after sign-in based on the user's `organization` field (or a super-admin's persisted org switcher choice).

## PocketBase schema (Admin API only)

Do **not** hand-edit `server/pb_migrations/`. Apply changes via Admin API or admin UI.

Run the patch script against local or staging:

```bash
# Credentials from .env (PB_LOCAL_* or PB_STAGING_*)
./scripts/patch-organization-onboarding-schema.sh
```

The script adds:

- `organizations.setupStatus` (select: `pending_setup`, `ready`)
- `organizations.setupCompletedAt` (date)
- Org-scoped API rules on `users` and `branches` (tenant + `users.superAdmin` bypass)
- `users.superAdmin` bool (default false) for platform operators
- `organizations` CRUD rules require `@request.auth.superAdmin = true`

### Manual curl (if script unavailable)

1. Authenticate: `POST /api/collections/_superusers/auth-with-password`
2. `PATCH /api/collections/organizations` — add `setupStatus`, `setupCompletedAt` fields
3. `PATCH /api/collections/users` and `branches` — update list/view/create/update rules per script

## User org scoping hook

`server/pb_hooks/lib/users_helpers.js` forces `organization` on user create/update for non–platform-admins so staff cannot assign users to other tenants.

## QA checklist

- [ ] Platform admin login lands on `/platform` (not gym dashboard)
- [ ] Create org → redirected to setup wizard
- [ ] Cannot complete setup without branch + admin user
- [ ] Optional membership/product steps can be skipped
- [ ] Complete setup sets badge to **Ready** on org list
- [ ] **Enter tenant** switches org context and opens gym app at `/`
- [ ] Branch staff without `users.superAdmin` cannot open `/platform`
- [ ] Public resolve returns branding for tenant subdomain (optional / legacy)

## Backfill existing data

See [backfill-organizations.md](backfill-organizations.md) for attaching legacy branches/users to a default organization.
