{ config, lib, ... }:

let
  cfg = config.vex.desktop;
in
{
  options.vex.desktop.enable = lib.mkEnableOption "the Vex desktop session (niri + noctalia)";

  config = lib.mkIf cfg.enable {
    vex.desktop.niri.enable = true;
    vex.desktop.noctalia.enable = true;
  };
}
