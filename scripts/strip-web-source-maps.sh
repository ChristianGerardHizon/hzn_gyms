#!/usr/bin/env bash
# Remove *.map from build/web after sentry_dart_plugin has uploaded them.
# Keeps pb_public from serving unminified sources.
set -euo pipefail

WEB_DIR="${1:-build/web}"

if [[ ! -d "$WEB_DIR" ]]; then
  echo "error: web build directory missing: ${WEB_DIR}" >&2
  exit 1
fi

echo "==> Strip source maps from ${WEB_DIR}"
find "$WEB_DIR" -type f -name '*.map' -print -delete
echo "Done."
