{
  lib,
  stdenvNoCC,
  fetchurl,
  source,
}:

let
  resolvedSrc =
    if source == null then
      throw "clash-party-unwrapped requires non-null source metadata"
    else if source ? url then
      fetchurl {
        inherit (source) url hash;
      }
    else if source ? path then
      source.path
    else
      throw "clash-party-unwrapped source must define either url/hash or path";
in
stdenvNoCC.mkDerivation {
  pname = "clash-party-unwrapped";
  version = source.version or "unstable";
  src = resolvedSrc;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    tar -xJf "$src" -C "$out" --strip-components=1
    runHook postInstall
  '';

  meta = with lib; {
    description = "Unwrapped Clash Party app tree";
    homepage = "https://github.com/mihomo-party-org/clash-party";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
