#!/usr/bin/env bash
set -euo pipefail

repo_dir="${1:?upstream repo path required}"
arch="${2:?target arch required}"
target="${3:?target name required}"
tag="${4:?upstream tag required}"

cd "$repo_dir"

test -d dist

version="${tag#v}"
archive_path="dist/clash-party-linux-${version}-${target}.tar.xz"
checksum_path="${archive_path}.sha256"

test -f "$archive_path"
test -f "$checksum_path"

tar -tf "$archive_path" | grep -F "/bin/clash-party" >/dev/null
tar -tf "$archive_path" | grep -F "/bin/mihomo-party" >/dev/null
tar -tf "$archive_path" | grep -F "/lib/clash-party/resources/app.asar" >/dev/null
tar -tf "$archive_path" | grep -F "/share/applications/mihomo-party.desktop" >/dev/null

# Assert the source tree still contains the native sysproxy module source.
test -e src/native/sysproxy || {
  echo "missing src/native/sysproxy in upstream tree" >&2
  exit 1
}

case "$arch" in
  x64)
    find dist -type f | grep -E 'amd64|x64' >/dev/null || {
      echo "no x64/amd64 artifact detected in dist/" >&2
      exit 1
    }
    ;;
  arm64)
    find dist -type f | grep -E 'arm64|aarch64' >/dev/null || {
      echo "no arm64/aarch64 artifact detected in dist/" >&2
      exit 1
    }
    ;;
esac

echo "basic smoke test passed for arch=${arch} target=${target} tag=${tag}"
