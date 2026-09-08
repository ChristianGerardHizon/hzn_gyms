#!/usr/bin/env bash
# Applies organization onboarding schema fields and API rule patches via PocketBase Admin API.
# Never hand-edit server/pb_migrations/ — PocketBase auto-generates migrations from these changes.
#
# Usage (local): source .env && ./scripts/patch-organization-onboarding-schema.sh local
# Usage (staging): source .env && ./scripts/patch-organization-onboarding-schema.sh staging

set -euo pipefail

TARGET="${1:-local}"

if [[ "$TARGET" == "staging" ]]; then
  API_URL="${PB_STAGING_URL:?PB_STAGING_URL required}"
  EMAIL="${PB_STAGING_EMAIL:?PB_STAGING_EMAIL required}"
  PASSWORD="${PB_STAGING_PASSWORD:?PB_STAGING_PASSWORD required}"
else
  API_URL="${PB_LOCAL_URL:?PB_LOCAL_URL required}"
  EMAIL="${PB_LOCAL_EMAIL:?PB_LOCAL_EMAIL required}"
  PASSWORD="${PB_LOCAL_PASSWORD:?PB_LOCAL_PASSWORD required}"
fi

TOKEN=$(curl -s -X POST "$API_URL/api/collections/_superusers/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" \
  | python -c "import json,sys; print(json.load(sys.stdin)['token'])")

echo "Authenticated against $API_URL"

# Fetch current organizations collection and merge fields.
ORG_JSON=$(curl -s "$API_URL/api/collections/organizations" -H "Authorization: $TOKEN")

python <<'PY' "$ORG_JSON" | curl -s -X PATCH "$API_URL/api/collections/organizations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d @-
import json, sys
col = json.loads(sys.argv[1])
fields = col.get("fields", [])
names = {f.get("name") for f in fields}
if "setupStatus" not in names:
    fields.append({
        "name": "setupStatus",
        "type": "select",
        "required": False,
        "presentable": True,
        "values": ["pending_setup", "ready"],
    })
if "setupCompletedAt" not in names:
    fields.append({
        "name": "setupCompletedAt",
        "type": "date",
        "required": False,
        "presentable": False,
    })
col["fields"] = fields
print(json.dumps(col))
PY

echo "Patched organizations collection (setupStatus, setupCompletedAt)"

# Patch users list/view/create/update rules for org scoping.
USERS_JSON=$(curl -s "$API_URL/api/collections/users" -H "Authorization: $TOKEN")

python <<'PY' "$USERS_JSON" | curl -s -X PATCH "$API_URL/api/collections/users" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d @-
import json, sys
col = json.loads(sys.argv[1])
org_scope = '@request.auth.id != "" && (organization = @request.auth.organization || @request.auth.superAdmin = true)'
perm_create = '@request.auth.id != "" && @request.auth.role.permissions ?~ "users.create" && (organization = @request.auth.organization || @request.auth.superAdmin = true)'
perm_update = '@request.auth.id != "" && @request.auth.role.permissions ?~ "users.edit" && (organization = @request.auth.organization || @request.auth.superAdmin = true)'
col["listRule"] = org_scope
col["viewRule"] = org_scope
col["createRule"] = perm_create
col["updateRule"] = perm_update
print(json.dumps(col))
PY

echo "Patched users collection API rules"

# Patch branches create/update rules.
BRANCHES_JSON=$(curl -s "$API_URL/api/collections/branches" -H "Authorization: $TOKEN")

python <<'PY' "$BRANCHES_JSON" | curl -s -X PATCH "$API_URL/api/collections/branches" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d @-
import json, sys
col = json.loads(sys.argv[1])
org_branch = '@request.auth.id != "" && (organization = @request.auth.organization || @request.auth.superAdmin = true)'
perm_branch = '@request.auth.id != "" && @request.auth.role.permissions ?~ "branches.create" && (organization = @request.auth.organization || @request.auth.superAdmin = true)'
perm_branch_edit = '@request.auth.id != "" && @request.auth.role.permissions ?~ "branches.edit" && (organization = @request.auth.organization || @request.auth.superAdmin = true)'
col["createRule"] = perm_branch
col["updateRule"] = perm_branch_edit
if not col.get("listRule"):
    col["listRule"] = org_branch
if not col.get("viewRule"):
    col["viewRule"] = org_branch
print(json.dumps(col))
PY

echo "Patched branches collection API rules"

# Ensure users.superAdmin exists and organizations rules use it.
USERS_FOR_FLAG=$(curl -s "$API_URL/api/collections/users" -H "Authorization: $TOKEN")

python <<'PY' "$USERS_FOR_FLAG" | curl -s -X PATCH "$API_URL/api/collections/users" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d @-
import json, sys
col = json.loads(sys.argv[1])
fields = col.get("fields", [])
names = {f.get("name") for f in fields}
if "superAdmin" not in names:
    fields.append({
        "name": "superAdmin",
        "type": "bool",
        "required": False,
        "presentable": True,
        "onCreate": {"value": False, "override": False},
    })
    col["fields"] = fields
print(json.dumps(col))
PY

echo "Ensured users.superAdmin field"

ORG_RULES=$(curl -s "$API_URL/api/collections/organizations" -H "Authorization: $TOKEN")

python <<'PY' "$ORG_RULES" | curl -s -X PATCH "$API_URL/api/collections/organizations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d @-
import json, sys
col = json.loads(sys.argv[1])
rule = '@request.auth.superAdmin = true'
for key in ("listRule", "viewRule", "createRule", "updateRule", "deleteRule"):
    col[key] = rule
print(json.dumps(col))
PY

echo "Patched organizations collection API rules to users.superAdmin"
echo "Done. Restart PocketBase if needed and verify migrations were auto-generated."
