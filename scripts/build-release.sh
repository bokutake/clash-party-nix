#!/usr/bin/env bash
set -euo pipefail

repo_dir="${1:?upstream repo path required}"
arch="${2:?target arch required}"
target="${3:?target name required}"

cd "$repo_dir"

corepack enable

pnpm install --frozen-lockfile

# Upstream smart_core Linux workflow patches the product name before building.
sed -i "s/productName: Clash Party/productName: clash-party/" electron-builder.yml

pnpm "prepare" "--${arch}"
pnpm "build:linux" "--${arch}"

if pnpm run | grep -q '^.*checksum'; then
  pnpm checksum .deb .rpm
fi

echo "built Linux artifacts for arch=${arch} target=${target}"
