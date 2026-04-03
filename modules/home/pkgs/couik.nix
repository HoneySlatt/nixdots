{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "couik";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "Fadilix";
    repo = "couik";
    rev = "v${version}";
    hash = "sha256-zs6vL1A0WQEucUZJkKZSdhd86MQleai/jpVN7Rkq+ts=";
  };

  vendorHash = "sha256-/zAZuYse+fwqe0GvwfJs8g10ei/IFZ/UE0nu5ski6To=";

  subPackages = [ "cmd/couik" ];

  meta = with lib; {
    description = "Terminal-based typing speed test";
    homepage = "https://github.com/Fadilix/couik";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "couik";
  };
}
