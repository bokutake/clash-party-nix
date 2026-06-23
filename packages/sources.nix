{
  # Fill these when the upstream build workflow publishes tarballs.
  # Example:
  # x86_64-linux = {
  #   version = "1.9.6";
  #   url = "https://github.com/<owner>/<repo>/releases/download/v1.9.6/clash-party-linux-1.9.6-amd64.tar.xz";
  #   hash = "sha256-...";
  # };
  #
  # For local testing you can also point directly at a local tarball:
  # x86_64-linux = {
  #   version = "1.9.6";
  #   path = /absolute/path/to/clash-party-linux-1.9.6-amd64.tar.xz;
  # };
  x86_64-linux = {
    version = "1.9.6";
    url = "https://github.com/bokutake/clash-party-nix/releases/download/v1.9.6/clash-party-linux-1.9.6-amd64.tar.xz";
    hash = "sha256-7ZkWsl60iB9T5IuhT9ROZ/azk/oF7mmnt0BkCt8ME70=";
  };

  aarch64-linux = {
    version = "1.9.6";
    url = "https://github.com/bokutake/clash-party-nix/releases/download/v1.9.6/clash-party-linux-1.9.6-arm64.tar.xz";
    hash = "sha256-R2PRvu0kGioACmlwzvvuZ/kQt8axQPre694tNyLowXs=";
  };
}
