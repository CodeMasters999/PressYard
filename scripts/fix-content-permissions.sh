#!/usr/bin/env bash
set -euo pipefail

WP_PATH="${WP_PATH:-/var/www/html}"
PRESSYARD_RUNTIME_UID="${PRESSYARD_RUNTIME_UID:-33}"
PRESSYARD_RUNTIME_GID="${PRESSYARD_RUNTIME_GID:-33}"

is_numeric() {
  [[ "${1:-}" =~ ^[0-9]+$ ]]
}

if [ "$(id -u)" != "0" ]; then
  exit 0
fi

if ! is_numeric "$PRESSYARD_RUNTIME_UID" || ! is_numeric "$PRESSYARD_RUNTIME_GID"; then
  exit 0
fi

for content_dir in \
  "$WP_PATH/wp-content/plugins" \
  "$WP_PATH/wp-content/mu-plugins" \
  "$WP_PATH/wp-content/themes" \
  "$WP_PATH/wp-content/uploads"
do
  [ -e "$content_dir" ] || continue
  chown -R "${PRESSYARD_RUNTIME_UID}:${PRESSYARD_RUNTIME_GID}" "$content_dir" 2>/dev/null || true
done
