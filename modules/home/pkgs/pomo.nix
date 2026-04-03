{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "pomo";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "Bahaaio";
    repo = "pomo";
    rev = "v${version}";
    hash = "sha256-gQ7bHQGaQPujpOwVdcwKgiYQjUECi/Pjt5LKwa1v1J8=";
  };

  vendorHash = "sha256-kbTYq4Xc86bcmNMhInq1rwYTbGRmu2TEXT2e7bqT5YY=";

  meta = with lib; {
    description = "Terminal Pomodoro timer";
    homepage = "https://github.com/Bahaaio/pomo";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "pomo";
  };
}
