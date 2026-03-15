#!/usr/bin/env bash
set -euo pipefail

PRESSYARD_RUNTIME_UID="${PRESSYARD_RUNTIME_UID:-33}"
PRESSYARD_RUNTIME_GID="${PRESSYARD_RUNTIME_GID:-33}"
PRESSYARD_FILE_UMASK="${PRESSYARD_FILE_UMASK:-0002}"

is_numeric() {
  [[ "${1:-}" =~ ^[0-9]+$ ]]
}

prepare_runtime_permissions() {
  local runtime_dir

  for runtime_dir in \
    /var/www/html/wp-content/upgrade \
    /var/www/html/wp-content/languages \
    /var/www/html/wp-content/cache \
    /var/www/html/wp-content/uploads
  do
    mkdir -p "$runtime_dir"
    chown "${PRESSYARD_RUNTIME_UID}:${PRESSYARD_RUNTIME_GID}" "$runtime_dir" 2>/dev/null || true
    chmod 775 "$runtime_dir" 2>/dev/null || true
  done
}

umask "$PRESSYARD_FILE_UMASK"

if [ "$(id -u)" = "0" ] && is_numeric "$PRESSYARD_RUNTIME_UID" && is_numeric "$PRESSYARD_RUNTIME_GID"; then
  export APACHE_RUN_USER="#${PRESSYARD_RUNTIME_UID}"
  export APACHE_RUN_GROUP="#${PRESSYARD_RUNTIME_GID}"
  prepare_runtime_permissions
fi

exec docker-entrypoint.sh "$@"
