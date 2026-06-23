{
  lib,
  stdenvNoCC,
  makeWrapper,
  wrapGAppsHook3,
  autoPatchelfHook,
  perl,
  alsa-lib,
  atk,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libglvnd,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxtst,
  libxcb,
  libxshmfence,
  nspr,
  nss,
  pango,
  stdenv,
  systemd,
  zlib,
  clashPartyUnwrapped,
}:

stdenvNoCC.mkDerivation {
  pname = "clash-party";
  inherit (clashPartyUnwrapped) version;
  src = clashPartyUnwrapped;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    perl
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    atk
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libgbm
    libglvnd
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    libxcb
    libxshmfence
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    zlib
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -a "$src" "$out"
    chmod -R u+w "$out"

    ASAR_PATH="$out/lib/clash-party/resources/app.asar"

    if [ -f "$ASAR_PATH" ]; then
      # Upstream Linux releases may omit the sysproxy-rs native binding while
      # still shipping the JS loader. Replace it with a Linux no-op so the main
      # process can start even when the binding is missing.
      perl - "$ASAR_PATH" <<'PERL'
use strict;
use warnings;

my $path = shift @ARGV;
open my $fh, '+<:raw', $path or die "open $path: $!";

read($fh, my $prefix, 16) == 16 or die "short asar prefix";
my (undef, undef, undef, $header_size) = unpack('V4', $prefix);
read($fh, my $header, $header_size) == $header_size or die "short asar header";

$header =~ /"sysproxy-rs":\{"files":\{"index\.js":\{"size":(\d+),"offset":"(\d+)"/
  or die "sysproxy-rs index.js not found in asar header";

my ($size, $offset) = ($1, $2);
my $content_base = 16 + $header_size;
my $absolute_offset = $content_base + $offset;

my $stub = <<'STUB';
const noop = () => true;
const noopAsync = async () => true;
const emptyProxy = () => ({ enable: false, host: "", bypass: [], mode: "manual", pacScript: "" });

module.exports.triggerManualProxy = noopAsync;
module.exports.triggerAutoProxy = noopAsync;
module.exports.getSystemProxy = emptyProxy;
module.exports.getAutoProxy = emptyProxy;
module.exports.setSystemProxy = noopAsync;
module.exports.setAutoProxy = noopAsync;
module.exports.setProxy = noopAsync;
module.exports.enableProxy = noopAsync;
module.exports.openUWPTool = noop;
STUB

length($stub) <= $size or die "sysproxy-rs stub larger than original index.js";
$stub .= ' ' x ($size - length($stub));

seek($fh, $absolute_offset, 0) or die "seek failed";
print {$fh} $stub or die "write failed";
close $fh or die "close failed";
PERL
    fi

    mkdir -p "$out/lib/clash-party/resources/nix-sidecar-store"
    if [ -d "$out/lib/clash-party/resources/sidecar" ]; then
      for sidecar in mihomo mihomo-alpha mihomo-smart; do
        if [ -f "$out/lib/clash-party/resources/sidecar/$sidecar" ]; then
          mv "$out/lib/clash-party/resources/sidecar/$sidecar" \
            "$out/lib/clash-party/resources/nix-sidecar-store/$sidecar.bin.real"
        fi
      done

      rm -rf "$out/lib/clash-party/resources/sidecar"
      ln -s /var/lib/clash-party/sidecar "$out/lib/clash-party/resources/sidecar"
    fi

    if [ -f "$out/bin/clash-party" ]; then
      mv "$out/bin/clash-party" "$out/bin/.clash-party-real"
      makeWrapper "$out/bin/.clash-party-real" "$out/bin/clash-party" \
        "''${gappsWrapperArgs[@]}" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd ]}" \
        --add-flags "--disable-setuid-sandbox"
    fi

    if [ -L "$out/bin/mihomo-party" ] || [ -f "$out/bin/mihomo-party" ]; then
      rm -f "$out/bin/mihomo-party"
      ln -s "$out/bin/clash-party" "$out/bin/mihomo-party"
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Wrapped Clash Party package for NixOS";
    homepage = "https://github.com/mihomo-party-org/clash-party";
    license = licenses.gpl3Only;
    mainProgram = "clash-party";
    platforms = platforms.linux;
  };
}
