#!/usr/bin/env bash
# HZN Gyms deploy — web assets to PocketBase via SSH + rsync.
# Designed for GitHub Actions (ubuntu runners). Mirrors sannjose_animal_clinic deploy flow.
#
# Prerequisites (CI):
#   - SSH agent loaded with deploy key (e.g. webfactory/ssh-agent)
#   - known_hosts populated for SSH_HOST
#   - Env: SSH_HOST, SSH_USER
#   - For web deploy: build/web/ already built
#
# Usage (from repo root):
#   ./scripts/deploy.sh staging
#   ./scripts/deploy.sh prod
#   ./scripts/deploy.sh staging --web-only
#   ./scripts/deploy.sh staging --migrations-only
#   ./scripts/deploy.sh staging --hooks-only
#   ./scripts/deploy.sh staging --restart-only
#   ./scripts/deploy.sh staging --skip-web --skip-migrations
#
# Env overrides:
#   SSH_HOST, SSH_USER          (required)
#   DEPLOY_SERVER_ROOT          (optional; defaults per environment)
#   DEPLOY_SERVICE_NAME         (optional; defaults per environment)

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./scripts/deploy.sh <staging|prod> [options]

Options:
  --web-only           Deploy only build/web → pb_public/
  --migrations-only    Deploy only server/pb_migrations/
  --hooks-only         Deploy only server/pb_hooks/
  --restart-only       Only restart the PocketBase service
  --skip-web           Skip web sync
  --skip-migrations    Skip migrations sync
  --skip-hooks         Skip hooks sync
  --skip-restart       Skip systemd restart
  -h, --help           Show this help
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

ENVIRONMENT="$1"
shift

case "$ENVIRONMENT" in
  staging|prod) ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    echo "error: environment must be 'staging' or 'prod' (got: $ENVIRONMENT)" >&2
    usage
    exit 1
    ;;
esac

DO_WEB=1
DO_MIGRATIONS=1
DO_HOOKS=1
DO_RESTART=1
MODE_SET=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --web-only)
      DO_WEB=1; DO_MIGRATIONS=0; DO_HOOKS=0; MODE_SET=1; shift ;;
    --migrations-only)
      DO_WEB=0; DO_MIGRATIONS=1; DO_HOOKS=0; MODE_SET=1; shift ;;
    --hooks-only)
      DO_WEB=0; DO_MIGRATIONS=0; DO_HOOKS=1; MODE_SET=1; shift ;;
    --restart-only)
      DO_WEB=0; DO_MIGRATIONS=0; DO_HOOKS=0; DO_RESTART=1; MODE_SET=1; shift ;;
    --skip-web)
      DO_WEB=0; shift ;;
    --skip-migrations)
      DO_MIGRATIONS=0; shift ;;
    --skip-hooks)
      DO_HOOKS=0; shift ;;
    --skip-restart)
      DO_RESTART=0; shift ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

# Ignore unused when only skip flags used
: "${MODE_SET}"

SSH_HOST="${SSH_HOST:-}"
SSH_USER="${SSH_USER:-}"

if [[ -z "$SSH_HOST" || -z "$SSH_USER" ]]; then
  echo "error: SSH_HOST and SSH_USER must be set" >&2
  exit 1
fi

case "$ENVIRONMENT" in
  staging)
    SERVER_ROOT="${DEPLOY_SERVER_ROOT:-/opt/pocketbase/kyliegym-staging}"
    SERVICE_NAME="${DEPLOY_SERVICE_NAME:-pocketbase_kyliegym-staging.service}"
    ;;
  prod)
    SERVER_ROOT="${DEPLOY_SERVER_ROOT:-/opt/pocketbase/kyliegym}"
    SERVICE_NAME="${DEPLOY_SERVICE_NAME:-pocketbase_kyliegym.service}"
    ;;
esac

REMOTE="${SSH_USER}@${SSH_HOST}"
REMOTE_PUBLIC="${SERVER_ROOT}/pb_public"
REMOTE_MIGRATIONS="${SERVER_ROOT}/pb_migrations"
REMOTE_HOOKS="${SERVER_ROOT}/pb_hooks"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$REPO_ROOT"

echo "========================================"
echo " hzn-gyms deploy"
echo " Environment : ${ENVIRONMENT}"
echo " SSH         : ${REMOTE}"
echo " Server root : ${SERVER_ROOT}"
echo " Service     : ${SERVICE_NAME}"
echo "========================================"

sync_dir() {
  local label="$1"
  local local_path="$2"
  local remote_path="$3"

  if [[ ! -d "$local_path" ]]; then
    echo "error: local path missing for ${label}: ${local_path}" >&2
    exit 1
  fi

  echo "==> Sync ${label} → ${REMOTE}:${remote_path}/"
  rsync -avz --delete \
    "${local_path}/" \
    "${REMOTE}:${remote_path}/"
}

if [[ "$DO_WEB" -eq 1 ]]; then
  sync_dir "web" "build/web" "$REMOTE_PUBLIC"
fi

if [[ "$DO_MIGRATIONS" -eq 1 ]]; then
  sync_dir "migrations" "server/pb_migrations" "$REMOTE_MIGRATIONS"
fi

if [[ "$DO_HOOKS" -eq 1 ]]; then
  sync_dir "hooks" "server/pb_hooks" "$REMOTE_HOOKS"
fi

if [[ "$DO_RESTART" -eq 1 ]]; then
  echo "==> Restart ${SERVICE_NAME}"
  ssh "$REMOTE" "sudo systemctl restart ${SERVICE_NAME}"
  ssh "$REMOTE" "systemctl is-active ${SERVICE_NAME}"
fi

echo "Done."
