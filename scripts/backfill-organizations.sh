#!/usr/bin/env bash# Idempotent organizations backfill — see docs/backfill-organizations.md
set -euo pipefail

API_URL="${API_URL:?Set API_URL (e.g. https://staging.hzngyms.hznsystems.com)}"
ADMIN_EMAIL="${ADMIN_EMAIL:?Set ADMIN_EMAIL}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:?Set ADMIN_PASSWORD}"
ORG_SLUG="${ORG_SLUG:-kyliegym}"
ORG_NAME="${ORG_NAME:-Kylie Gym}"
GRANT_SUPER_ADMIN="${GRANT_SUPER_ADMIN:-false}"
SUPER_ADMIN_EMAIL="${SUPER_ADMIN_EMAIL:-}"
ROLE_NAME="${ROLE_NAME:-Admin}"

json_get() {
  python3 -c "import json,sys; d=json.load(sys.stdin); print($1)" 2>/dev/null || true
}

echo "==> Authenticating at ${API_URL}"
AUTH_JSON=$(curl -s -X POST "${API_URL}/api/collections/_superusers/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASSWORD}\"}")

TOKEN=$(echo "$AUTH_JSON" | json_get "d.get('token','')")
if [[ -z "$TOKEN" ]]; then
  echo "error: superuser auth failed: $(echo "$AUTH_JSON" | json_get "d.get('message','unknown')")" >&2
  exit 1
fi
AUTH_HEADER="Authorization: ${TOKEN}"

echo "==> Checking for existing org slug=${ORG_SLUG}"
EXISTING=$(curl -s "${API_URL}/api/collections/organizations/records?filter=slug%3D%27${ORG_SLUG}%27&perPage=1" \
  -H "$AUTH_HEADER")
ORG_ID=$(echo "$EXISTING" | json_get "d.get('items',[{}])[0].get('id','')")

if [[ -n "$ORG_ID" ]]; then
  echo "    Found org id=${ORG_ID}"
else
  echo "==> Creating organization ${ORG_NAME}"
  CREATE_JSON=$(curl -s -X POST "${API_URL}/api/collections/organizations/records" \
    -H "$AUTH_HEADER" -H "Content-Type: application/json" \
    -d "{\"name\":\"${ORG_NAME}\",\"slug\":\"${ORG_SLUG}\",\"displayName\":\"${ORG_NAME}\",\"isDeleted\":false}")
  ORG_ID=$(echo "$CREATE_JSON" | json_get "d.get('id','')")
  if [[ -z "$ORG_ID" ]]; then
    echo "error: create org failed: $CREATE_JSON" >&2
    exit 1
  fi
  echo "    Created org id=${ORG_ID}"
fi

echo "==> Linking branches without organization"
PAGE=1
while true; do
  BRANCHES=$(curl -s "${API_URL}/api/collections/branches/records?filter=organization%3D%27%27&perPage=100&page=${PAGE}" \
    -H "$AUTH_HEADER")
  COUNT=$(echo "$BRANCHES" | json_get "len(d.get('items',[]))")
  [[ "$COUNT" == "0" ]] && break
  echo "$BRANCHES" | python3 -c "
import json,sys,urllib.request
d=json.load(sys.stdin)
api='${API_URL}'
token='${TOKEN}'
org='${ORG_ID}'
for item in d.get('items',[]):
    bid=item['id']
    req=urllib.request.Request(f'{api}/api/collections/branches/records/{bid}', data=json.dumps({'organization':org}).encode(), method='PATCH', headers={'Authorization':token,'Content-Type':'application/json'})
    with urllib.request.urlopen(req) as r:
        print(f'  branch {bid} -> {org}')
"
  PAGE=$((PAGE + 1))
done

echo "==> Linking users without organization"
PAGE=1
while true; do
  USERS=$(curl -s "${API_URL}/api/collections/users/records?filter=organization%3D%27%27&perPage=100&page=${PAGE}" \
    -H "$AUTH_HEADER")
  COUNT=$(echo "$USERS" | json_get "len(d.get('items',[]))")
  [[ "$COUNT" == "0" ]] && break
  echo "$USERS" | python3 -c "
import json,sys,urllib.request,urllib.error
d=json.load(sys.stdin)
api='${API_URL}'
token='${TOKEN}'
org='${ORG_ID}'
for item in d.get('items',[]):
    uid=item['id']
    body={'organization':org}
    if not item.get('email'):
        print(f'  skip user {uid}: missing email (set email before linking)')
        continue
    req=urllib.request.Request(f'{api}/api/collections/users/records/{uid}', data=json.dumps(body).encode(), method='PATCH', headers={'Authorization':token,'Content-Type':'application/json'})
    try:
        with urllib.request.urlopen(req) as r:
            print(f'  user {uid} -> {org}')
    except urllib.error.HTTPError as e:
        print(f'  user {uid} failed: {e.read().decode()}')
"
  PAGE=$((PAGE + 1))
done

if [[ "$GRANT_SUPER_ADMIN" == "true" ]]; then
  if [[ -z "$SUPER_ADMIN_EMAIL" ]]; then
    echo "warning: GRANT_SUPER_ADMIN=true but SUPER_ADMIN_EMAIL unset — set users.superAdmin manually in PocketBase Admin" >&2
  else
    echo "==> Setting users.superAdmin on ${SUPER_ADMIN_EMAIL}"
    USERS=$(curl -s "${API_URL}/api/collections/users/records?filter=email%3D%27${SUPER_ADMIN_EMAIL// /%20}%27&perPage=1" \
      -H "$AUTH_HEADER")
    USER_ID=$(echo "$USERS" | json_get "d.get('items',[{}])[0].get('id','')")
    if [[ -z "$USER_ID" ]]; then
      echo "warning: user '${SUPER_ADMIN_EMAIL}' not found — set superAdmin manually" >&2
    else
      curl -s -X PATCH "${API_URL}/api/collections/users/records/${USER_ID}" \
        -H "$AUTH_HEADER" -H "Content-Type: application/json" \
        -d '{"superAdmin":true}' >/dev/null
      echo "    Updated user ${USER_ID} superAdmin=true"
    fi
  fi
fi

echo "==> Done. org=${ORG_ID}"
DNS_STATUS=$(curl -s "${API_URL}/api/collections/organizations/records/${ORG_ID}" -H "$AUTH_HEADER" | json_get "d.get('dnsStatus','')")
echo "    dnsStatus=${DNS_STATUS}"
