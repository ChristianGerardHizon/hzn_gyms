---
name: pocketbase-schema-change
description: Apply PocketBase collection/schema changes (fields, indexes, views, API rules) via the Admin API using curl. Use when adding or modifying PocketBase collections, fields, or indexes.
---

# PocketBase Schema Changes

Reminder of the rule from `CLAUDE.md`: **NEVER create, edit, delete, rename, or rewrite any file under `server/pb_migrations/`.** All schema changes go through the Admin API; PocketBase auto-generates migration files from those changes.

Credentials are in `.env`:
- Local: `PB_LOCAL_URL`, `PB_LOCAL_EMAIL`, `PB_LOCAL_PASSWORD`
- Staging: `PB_STAGING_URL`, `PB_STAGING_EMAIL`, `PB_STAGING_PASSWORD`

```bash
# 1. Authenticate as superuser
TOKEN=$(curl -s -X POST "$PB_LOCAL_URL/api/collections/_superusers/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$PB_LOCAL_EMAIL\",\"password\":\"$PB_LOCAL_PASSWORD\"}" \
  | jq -r '.token')

# 2. Read current collection (check existing indexes first)
curl -s "$PB_LOCAL_URL/api/collections/{collectionName}" -H "Authorization: $TOKEN"

# 3. Patch collection (merge with existing indexes — do not overwrite unrelated ones)
curl -s -X PATCH "$PB_LOCAL_URL/api/collections/{collectionName}" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"indexes":["CREATE INDEX idx_name ON collectionName (field1, field2)"]}'
```

If a migration fails: diagnose the query/schema issue, fix it via the Admin API (e.g. PATCH the collection), and let PocketBase regenerate migrations. Never patch the broken `.js` file yourself.
