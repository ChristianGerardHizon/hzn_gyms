#!/usr/bin/env bash
# Patch gym collection list/view rules to require branch.organization =
# @request.auth.organization (no users.superAdmin bypass).
# Usage: ./scripts/patch-gym-org-list-rules.sh [local|staging|prod]

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"
TARGET="${1:-local}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing .env" >&2
  exit 1
fi

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
  -d "{\"identity\":\"$EMAIL\",\"password\":\"$PASS\"}" \
  | python -c "import sys,json; print(json.load(sys.stdin).get('token',''))")

[[ -n "$TOKEN" ]] || { echo "Auth failed" >&2; exit 1; }

STRICT='@request.auth.id != "" && @request.auth.organization != "" && branch.organization = @request.auth.organization'
SALE='@request.auth.id != "" && @request.auth.organization != "" && sale.branch.organization = @request.auth.organization'
PROD='@request.auth.id != "" && @request.auth.organization != "" && branch.organization = @request.auth.organization && (@request.auth.branch.id = branch.id || @request.auth.allowedBranches.id ?= branch.id || @request.auth.superAdmin = true)'

patch() {
  local name="$1" rule="$2"
  curl -s -X PATCH "$API_URL/api/collections/$name" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"listRule\":$(python -c "import json,sys; print(json.dumps(sys.argv[1]))" "$rule"),\"viewRule\":$(python -c "import json,sys; print(json.dumps(sys.argv[1]))" "$rule")}" \
    >/dev/null
  echo "patched $name"
}

for c in members sales checkIns memberships memberMemberships; do
  patch "$c" "$STRICT"
done
patch payments "$SALE"
patch saleItems "$SALE"
patch products "$PROD"
echo "Done ($TARGET)."
