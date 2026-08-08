# Update Created Endpoint

Admin utility to backdate the PocketBase system `created` field on **members** and **sales** records.

**Auth required:** PocketBase **superuser** credentials only (`_superusers`). Regular app users (including admins with `users` roles) cannot call this endpoint.

| | |
|---|---|
| Method | `POST` |
| Path | `/api/ebe/update-created` |
| Auth | `Authorization: <superuser_token>` |
| Collections | `members`, `sales` only |
| Hook files | `server/pb_hooks/update_created.pb.js`, `server/pb_hooks/lib/update_created_helpers.js` |

Restart PocketBase after adding or changing these hooks so the route is registered.

---

## Why `setRaw`?

`created` is an autodate field. `record.set("created", …)` is ignored. The hook uses `record.setRaw("created", …)` then `$app.save(record)`. Saving also bumps `updated` (normal autodate behavior).

---

## 1. Get a superuser token

Credentials live in `.env` (`LOCAL_API_URL` / `LOCAL_USER` / `LOCAL_PASSWORD`, or staging/prod equivalents). The identity must be a **`_superusers`** account, not a normal `users` login.

```bash
# PowerShell
$base = "http://127.0.0.1:8090"   # or your PB URL
$auth = Invoke-RestMethod -Method POST `
  -Uri "$base/api/collections/_superusers/auth-with-password" `
  -ContentType "application/json" `
  -Body (@{ identity = "SUPERUSER_EMAIL"; password = "SUPERUSER_PASSWORD" } | ConvertTo-Json)
$token = $auth.token
```

```bash
# curl
TOKEN=$(curl -s -X POST "$PB_URL/api/collections/_superusers/auth-with-password" \
  -H "Content-Type: application/json" \
  -d '{"identity":"SUPERUSER_EMAIL","password":"SUPERUSER_PASSWORD"}' \
  | jq -r '.token')
```

---

## 2. Single update

```json
{
  "collection": "members",
  "id": "RECORD_ID",
  "created": "2024-01-15 08:00:00.000Z"
}
```

`collection` must be `members` or `sales`.  
`created` accepts PocketBase format (`2024-01-15 08:00:00.000Z`) or ISO (`2024-01-15T08:00:00.000Z`).

```bash
curl -s -X POST "$PB_URL/api/ebe/update-created" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"collection":"members","id":"RECORD_ID","created":"2024-01-15 08:00:00.000Z"}'
```

```powershell
Invoke-RestMethod -Method POST -Uri "$base/api/ebe/update-created" `
  -Headers @{ Authorization = $token } `
  -ContentType "application/json" `
  -Body (@{
    collection = "members"
    id = "RECORD_ID"
    created = "2024-01-15 08:00:00.000Z"
  } | ConvertTo-Json)
```

---

## 3. Batch update

```json
{
  "updates": [
    { "collection": "members", "id": "…", "created": "2024-01-15 08:00:00.000Z" },
    { "collection": "sales", "id": "…", "created": "2024-06-01T10:30:00.000Z" }
  ]
}
```

```bash
curl -s -X POST "$PB_URL/api/ebe/update-created" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"updates":[{"collection":"members","id":"…","created":"2024-01-15 08:00:00.000Z"},{"collection":"sales","id":"…","created":"2024-06-01T10:30:00.000Z"}]}'
```

---

## Success response

```json
{
  "success": true,
  "count": 1,
  "results": [
    {
      "collection": "members",
      "id": "RECORD_ID",
      "previousCreated": "2026-02-27 07:19:37.864Z",
      "created": "2024-01-15 08:00:00.000Z"
    }
  ]
}
```

---

## Errors

| Case | Typical result |
|---|---|
| Missing / non-superuser token | `401` / `403` |
| `collection` not `members` or `sales` | `400` — collection not allowed |
| Missing `id` or `created` | `400` |
| Invalid datetime | `400` |
| Unknown record id | `404` / request error |

Check-ins are **not** supported by this endpoint (use `checkInTime` via normal record APIs if needed).

---

## Notes

- Prefer staging/local first; production backdates affect reports and “today” queries that filter on `created`.
- After a successful call, confirm with  
  `GET /api/collections/{collection}/records/{id}?fields=id,created`.
