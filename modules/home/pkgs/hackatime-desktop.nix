{
  lib,
  rustPlatform,
  fetchgit,
  fetchPnpmDeps,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  cargo-tauri,
  jq,
  moreutils,
  pkg-config,
  wrapGAppsHook3,
  glib-networking,
  libayatana-appindicator,
  libsoup_3,
  openssl,
  webkitgtk_4_1,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hackatime-desktop";
  version = "1.7.5";

  src = fetchgit {
    url = "https://github.com/hackclub/hackatime-desktop.git";
    rev = "832a61069323ef9030e5d0d85cdbd1cae02ebcb3";
    hash = "sha256-iBnt2AyUuC8BpMXHLsbz6k3RzPnGEDNOIol7cOAFZ2c=";
    fetchLFS = true;
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-YllpsiWAWafgy7CeE873fziDkJOgyxvOZE0sZR9ItEU=";
  };

  postPatch = ''
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" \
        "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"

    jq '.bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json \
      | sponge src-tauri/tauri.conf.json
  '';

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoHash = "sha256-dUnnttnpHuSx8wt7rqrD6wt592n7bOblXzZDWhY7p5o=";

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
    cargo-tauri.hook
    jq
    moreutils
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking
    libayatana-appindicator
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  meta = {
    description = "Desktop client for Hackatime";
    homepage = "https://github.com/hackclub/hackatime-desktop";
    license = lib.licenses.mit;
    mainProgram = "desktop";
    platforms = lib.platforms.linux;
  };
})
