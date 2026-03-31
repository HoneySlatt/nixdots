{ pkgs }:

let
  wine = pkgs.wineWow64Packages.staging;
in
pkgs.stdenv.mkDerivation {
  pname = "pwasio";
  version = "0.0.2";

  src = pkgs.fetchgit {
    url = "https://github.com/golfiros/pwasio.git";
    rev = "327379b356a372889bc08940dc479d2bbad9508a";
    sha256 = "sha256-r0eXeeTW2o8DC0IkGbE0QdDHcmCIYJFQhA0yqSxsJdE=";
  };

  nativeBuildInputs = with pkgs; [
    clang
    wine
    pipewire
    pkg-config
  ];

  buildInputs = with pkgs; [
    pipewire
  ];

  patchPhase = ''
    substituteInPlace Makefile \
      --replace-warn "WINDOWSINC := /usr/include/wine/windows" "WINDOWSINC := ${wine}/include/wine/windows"
  '';

  buildPhase = ''
    make \
      WINECC=${wine}/bin/winegcc \
      WINERC=${wine}/bin/wrc \
      WINEBUILD=${wine}/bin/winebuild
  '';

  installPhase = ''
    mkdir -p $out/lib/wine/x86_64-unix
    mkdir -p $out/lib/wine/x86_64-windows
    cp lib/wine/x86_64-unix/pwasio.dll.so $out/lib/wine/x86_64-unix/
    cp lib/wine/x86_64-windows/pwasio.dll $out/lib/wine/x86_64-windows/
  '';
}
