{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.programs.niri;
  niriDir = "${config.xdg.configHome}/niri";
in
{
  # Fichiers écrits à chaud par quickshell, inclus après la config Nix (niri les recharge tout seul) :
  # - theme.kdl    : couleurs des bordures/ombres du thème courant
  # - bar-mode.kdl : mode compact quand la barre est en bas (0 gap, 0 bordure, 0 arrondi)
  # finalConfig est en lecture seule, donc on remplace le fichier généré (toujours validé par `niri validate`).
  xdg.configFile.niri-config.source = lib.mkForce (
    inputs.niri.lib.internal.validated-config-for pkgs cfg.package (
      cfg.finalConfig
      + ''

        include optional=true "${niriDir}/theme.kdl"
        include optional=true "${niriDir}/bar-mode.kdl"
      ''
    )
  );
}
