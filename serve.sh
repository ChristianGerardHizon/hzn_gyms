#!/bin/bash
# Cross-platform PocketBase server launcher
# Works on Linux and macOS

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/server"

# Find pocketbase binary
if command -v pocketbase &>/dev/null; then
  PB_BIN="pocketbase"
elif [ -f "$SCRIPT_DIR/server/pocketbase" ]; then
  PB_BIN="$SCRIPT_DIR/server/pocketbase"
else
  echo "Error: pocketbase binary not found in PATH or server/"
  exit 1
fi

echo "Starting PocketBase server (dev mode)..."
echo "Data dir:    $SERVER_DIR/pb_data"
echo "Hooks dir:   $SERVER_DIR/pb_hooks"
echo "Public dir:  $SERVER_DIR/pb_public"
exec "$PB_BIN" serve \
  --dir "$SERVER_DIR/pb_data" \
  --hooksDir "$SERVER_DIR/pb_hooks" \
  --publicDir "$SERVER_DIR/pb_public" \
  --dev
