#!/usr/bin/env bash
# Backfill organizationMemberships from users.organization + users.role.
# Usage: ./scripts/backfill-organization-memberships.sh [local|staging|prod]
# Credentials from .env (LOCAL_* / STAGING_* / PROD_* or PB_*).

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"
TARGET="${1:-local}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing .env at $ENV_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a
# load KEY=VALUE lines
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%$'\r'}"
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${line// }" ]] && continue
  [[ "$line" != *=* ]] && continue
  key="${line%%=*}"
  val="${line#*=}"
  key="${key%"${key##*[![:space:]]}"}"
  [[ -z "$key" || "$key" =~ [^A-Za-z0-9_] ]] && continue
  export "$key=$val"
done < "$ENV_FILE"
set +a

if [[ "$TARGET" == "staging" ]]; then
  API_URL="${PB_STAGING_URL:-$STAGING_URL}"
  EMAIL="${PB_STAGING_EMAIL:-$STAGING_EMAIL}"
  PASS="${PB_STAGING_PASSWORD:-$STAGING_PASSWORD}"
elif [[ "$TARGET" == "prod" ]]; then
  API_URL="${PB_PROD_URL:-$PROD_URL}"
  EMAIL="${PB_PROD_EMAIL:-$PROD_EMAIL}"
  PASS="${PB_PROD_PASSWORD:-$PROD_PASSWORD}"
else
  API_URL="${PB_LOCAL_URL:-$LOCAL_API_URL}"
  EMAIL="${PB_LOCAL_EMAIL:-$LOCAL_EMAIL}"
  PASS="${PB_LOCAL_PASSWORD:-$LOCAL_PASSWORD}"
fi

API_URL="${API_URL%/}"
TOKEN=$(curl -s -X POST "$API_URL/api/collections/_superusers/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$EMAIL\",\"password\":\"$PASS\"}" | python -c "import sys,json; print(json.load(sys.stdin).get('token',''))")

if [[ -z "$TOKEN" ]]; then
  echo "Auth failed" >&2
  exit 1
fi

python - "$API_URL" "$TOKEN" <<'PY'
import json, sys, urllib.parse, urllib.request

api, token = sys.argv[1], sys.argv[2]
headers = {"Authorization": token, "Content-Type": "application/json"}

def get(path):
    req = urllib.request.Request(api + path, headers=headers)
    with urllib.request.urlopen(req) as r:
        return json.load(r)

def post(path, body):
    data = json.dumps(body).encode()
    req = urllib.request.Request(api + path, data=data, headers=headers, method="POST")
    with urllib.request.urlopen(req) as r:
        return json.load(r)

page = 1
created = 0
skipped = 0
while True:
    users = get(f"/api/collections/users/records?page={page}&perPage=100&filter=organization!=''&&role!=''")
    for u in users.get("items", []):
        org = u.get("organization") or ""
        role = u.get("role") or ""
        uid = u["id"]
        if not org or not role:
            continue
        filt = urllib.parse.quote(f'user="{uid}" && organization="{org}"')
        existing = get(f"/api/collections/organizationMemberships/records?filter={filt}&perPage=1")
        if existing.get("totalItems", 0) > 0:
            skipped += 1
            continue
        post("/api/collections/organizationMemberships/records", {
            "user": uid,
            "organization": org,
            "role": role,
            "status": "active",
            "joinedAt": u.get("created") or "2024-01-01 00:00:00.000Z",
        })
        created += 1
    if page >= users.get("totalPages", 1):
        break
    page += 1

print(f"created={created} skipped={skipped}")
PY
