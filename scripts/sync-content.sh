#!/usr/bin/env bash
set -euo pipefail

WP_PATH="${WP_PATH:-/var/www/html}"
WP_SOURCE_ROOT="${WP_SOURCE_ROOT:-/workspace}"
SOURCE_CONTENT_DIR="${WP_SOURCE_ROOT}/wp-content"
TARGET_CONTENT_DIR="${WP_PATH}/wp-content"

copy_dir_contents() {
  local source_dir="$1"
  local target_dir="$2"

  mkdir -p "$target_dir"

  if [ ! -d "$source_dir" ]; then
    return
  fi

  cp -a "${source_dir}/." "$target_dir/"
}

mkdir -p \
  "${TARGET_CONTENT_DIR}/plugins" \
  "${TARGET_CONTENT_DIR}/mu-plugins" \
  "${TARGET_CONTENT_DIR}/themes" \
  "${TARGET_CONTENT_DIR}/uploads"

for content_dir in mu-plugins themes plugins; do
  copy_dir_contents "${SOURCE_CONTENT_DIR}/${content_dir}" "${TARGET_CONTENT_DIR}/${content_dir}"
done
