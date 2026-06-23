#!/usr/bin/env bash
set -euo pipefail

repo_dir="${1:?upstream repo path required}"
arch="${2:?target arch required}"
target="${3:?target name required}"
tag="${4:?upstream tag required}"

repo_dir="$(realpath "$repo_dir")"

cd "$repo_dir"

find_dist_dir() {
  local root="$1"

  local archive_parent
  archive_parent="$(
    find "$root" -maxdepth 4 -type f -name 'clash-party-linux-*.tar.xz' \
      -printf '%h\n' \
      | sort \
      | head -n 1
  )"
  if [ -n "$archive_parent" ]; then
    printf '%s\n' "$archive_parent"
    return 0
  fi

  local unpacked_parent
  unpacked_parent="$(
    find "$root" -maxdepth 4 -type d \
      \( -name '*linux*-unpacked' -o -name '*-unpacked' \) \
      -printf '%h\n' \
      | sort \
      | head -n 1
  )"
  if [ -n "$unpacked_parent" ]; then
    printf '%s\n' "$unpacked_parent"
    return 0
  fi

  local named_dir
  named_dir="$(
    find "$root" -maxdepth 3 -type d \
      \( -name dist -o -name release -o -name out \) \
      | sort \
      | head -n 1
  )"
  if [ -n "$named_dir" ]; then
    printf '%s\n' "$named_dir"
    return 0
  fi

  return 1
}

dist_dir="$(find_dist_dir "$repo_dir" || true)"
if [ -z "$dist_dir" ]; then
  echo "unable to locate build output directory under $repo_dir" >&2
  find "$repo_dir" -maxdepth 4 -type d | sort >&2
  exit 1
fi

version="${tag#v}"
archive_path="${dist_dir}/clash-party-linux-${version}-${target}.tar.xz"
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
    find "$dist_dir" -type f | grep -E 'amd64|x64' >/dev/null || {
      echo "no x64/amd64 artifact detected in $dist_dir" >&2
      exit 1
    }
    ;;
  arm64)
    find "$dist_dir" -type f | grep -E 'arm64|aarch64' >/dev/null || {
      echo "no arm64/aarch64 artifact detected in $dist_dir" >&2
      exit 1
    }
    ;;
esac

echo "basic smoke test passed for arch=${arch} target=${target} tag=${tag} dist_dir=${dist_dir}"
