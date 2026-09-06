# Organizations Backfill

One-off, idempotent backfill that creates the "Kylie Gym" organization (the
first tenant) and links existing `branches`/`users` records to it. Run once
per environment (dev/staging/prod) after the `organizations` schema
(`server/pb_migrations/1788295945_created_organizations.js` and related
`updated_branches`/`updated_users` migrations) has been applied.

Uses the PocketBase Admin API only — this is **not** a `pb_migrations` file,
per the rule in `CLAUDE.md` (never hand-write/edit files under
`server/pb_migrations/`). Credentials come from `.env` per the
`pocketbase-schema-change` skill.

## Steps

```bash
# 1. Authenticate as superuser
TOKEN=$(curl -s -X POST "$LOCAL_API_URL/api/collections/_superusers/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$LOCAL_EMAIL\",\"password\":\"$LOCAL_PASSWORD\"}" \
  | python -c "import json,sys;print(json.load(sys.stdin)['token'])")

# 2. Idempotency check — skip creation if it already exists
curl -s "$LOCAL_API_URL/api/collections/organizations/records?filter=slug%3D%27kyliegym%27" \
  -H "Authorization: $TOKEN"

# 3. Create the org (skip if step 2 found one). This fires the Porkbun
#    provisioning hook (server/pb_hooks/organizations.pb.js) exactly like any
#    new org — no special-casing for the first tenant.
curl -s -X POST "$LOCAL_API_URL/api/collections/organizations/records" \
  -H "Authorization: $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"Kylie Gym","slug":"kyliegym","displayName":"Kylie Gym","isDeleted":false}'

# 4. For each existing branch without `organization` set, link it to the new
#    org's id (from step 3's response).
curl -s -X PATCH "$LOCAL_API_URL/api/collections/branches/records/<branchId>" \
  -H "Authorization: $TOKEN" -H "Content-Type: application/json" \
  -d '{"organization":"<orgId>"}'

# 5. Same for users.
curl -s -X PATCH "$LOCAL_API_URL/api/collections/users/records/<userId>" \
  -H "Authorization: $TOKEN" -H "Content-Type: application/json" \
  -d '{"organization":"<orgId>"}'

# 6. Once every branch is linked, tighten branches.organization to required
#    (it starts optional so the backfill above can run against existing
#    rows) via a schema PATCH — see server/pb_migrations for the resulting
#    auto-generated migration.
```

## Gotcha hit during the dev backfill: `users.email` is now required

Login was switched from username-based to email-based auth in the same
work (`passwordAuth.identityFields = ["email"]`, `email` now required).
Any pre-existing `users` record with a blank `email` (common for
early/manually-seeded dev accounts that only had a `username`) will fail
step 5's PATCH with `validation_required` on `email` — set a real email on
that record first:

```bash
curl -s -X PATCH "$LOCAL_API_URL/api/collections/users/records/<userId>" \
  -H "Authorization: $TOKEN" -H "Content-Type: application/json" \
  -d '{"email":"<real-email>"}'
```

## Verifying

```bash
curl -s "$LOCAL_API_URL/api/collections/organizations/records/<orgId>" \
  -H "Authorization: $TOKEN"
```

Check `dnsStatus`:
- `"pending"` — expected in local dev/CI when `PORKBUN_API_KEY`/
  `PORKBUN_API_SECRET` aren't set on the server process; `subdomain` is
  still computed and stored (e.g. `kyliegym.gyms.hznsystems.com`).
- `"created"` — a real Porkbun DNS record was provisioned (staging/prod
  with credentials configured).
- `"failed"` — check `dnsError`; retry via `POST /api/organizations/<id>/retry-dns`
  (super-admin auth, `organizations.manage` permission) or wait for the
  scheduled retry (every 30 minutes).
