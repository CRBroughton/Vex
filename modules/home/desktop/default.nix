{ config, lib, ... }:

let
  cfg = config.vex.desktop;
in
{
  options.vex.desktop = {
    enable = lib.mkEnableOption "the Vex desktop session (niri + noctalia)";

    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = ./niri-assets/wallpaper.jpg;
      description = "Wallpaper used by both niri (for its derived accent color) and Noctalia.";
    };
  };

  config = lib.mkIf cfg.enable {
    vex.desktop.niri.enable = true;
    vex.desktop.noctalia.enable = true;
  };
}
