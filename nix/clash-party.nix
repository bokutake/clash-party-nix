{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs,
  pnpm,
  rustPlatform,
  pkg-config,
  makeWrapper,
  copyDesktopItems,
  gtk3,
  libayatana-appindicator,
  webkitgtk_4_1,
  glib,
  cairo,
  pango,
  gdk-pixbuf,
  libGL,
}:

buildNpmPackage rec {
  pname = "clash-party";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "mihomo-party-org";
    repo = "clash-party";
    rev = "v1.9.6";
    hash = lib.fakeHash;
  };

  npmDepsHash = lib.fakeHash;

  nativeBuildInputs = [
    nodejs
    pnpm
    pkg-config
    makeWrapper
    copyDesktopItems
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
  ];

  buildInputs = [
    gtk3
    libayatana-appindicator
    webkitgtk_4_1
    glib
    cairo
    pango
    gdk-pixbuf
    libGL
  ];

  # This is intentionally a draft. It encodes the desired shape:
  # build from source, keep native module generation inside the normal build.
  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"

    pnpm install --frozen-lockfile

    if pnpm run | grep -q 'build:linux'; then
      pnpm build:linux
    elif pnpm run | grep -q 'dist'; then
      pnpm dist
    else
      echo "No upstream Linux packaging script found" >&2
      exit 1
    fi

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r dist "$out/"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Draft nixpkgs-style upstream Clash Party source build";
    homepage = "https://github.com/mihomo-party-org/clash-party";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
