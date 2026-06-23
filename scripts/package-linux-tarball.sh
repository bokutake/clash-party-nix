#!/usr/bin/env bash
set -euo pipefail

repo_dir="${1:?upstream repo path required}"
arch="${2:?target arch required}"
target="${3:?target name required}"
tag="${4:?upstream tag required}"

cd "$repo_dir"

version="${tag#v}"
dist_dir="$repo_dir/dist"
pkg_name="clash-party-linux-${version}-${target}"
stage_root="$dist_dir/${pkg_name}"
archive_path="$dist_dir/${pkg_name}.tar.xz"
checksum_path="${archive_path}.sha256"

unpacked_dir="$(
  find "$dist_dir" -mindepth 1 -maxdepth 1 -type d \
    \( -name '*linux*-unpacked' -o -name '*-unpacked' \) \
    | head -n 1
)"

if [ -z "$unpacked_dir" ]; then
  echo "unable to find linux unpacked build output under $dist_dir" >&2
  exit 1
fi

rm -rf "$stage_root" "$archive_path" "$checksum_path"

mkdir -p \
  "$stage_root/bin" \
  "$stage_root/lib/clash-party" \
  "$stage_root/share/applications" \
  "$stage_root/share/icons/hicolor/512x512/apps"

cp -a "$unpacked_dir"/. "$stage_root/lib/clash-party/"

cat > "$stage_root/bin/clash-party" <<'EOF'
#!/usr/bin/env sh
set -eu
exec "$(dirname "$0")/../lib/clash-party/mihomo-party" "$@"
EOF
chmod 0755 "$stage_root/bin/clash-party"

ln -s clash-party "$stage_root/bin/mihomo-party"

cat > "$stage_root/share/applications/mihomo-party.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Version=1.0
Name=Clash Party
GenericName=Proxy Client
Comment=A GUI client based on Mihomo
Exec=clash-party %U
Icon=mihomo-party
Terminal=false
Categories=Utility;
MimeType=x-scheme-handler/clash;x-scheme-handler/mihomo;
Keywords=proxy;clash;mihomo;vpn;
StartupWMClass=mihomo-party
EOF

if [ -f "$repo_dir/build/icon.png" ]; then
  install -m 0644 "$repo_dir/build/icon.png" \
    "$stage_root/share/icons/hicolor/512x512/apps/mihomo-party.png"
fi

tar -C "$dist_dir" -cJf "$archive_path" "$pkg_name"
sha256sum "$(basename "$archive_path")" > "$checksum_path"

echo "packaged tarball: $archive_path"
echo "packaged checksum: $checksum_path"
echo "source unpacked dir: $unpacked_dir"
echo "arch=${arch} target=${target}"
