{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.vex.desktop.noctalia;
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  options.vex.desktop.noctalia = {
    enable = lib.mkEnableOption "Noctalia, an all-in-one Wayland shell (bar, launcher, control center, lock screen, wallpaper theming)";
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      settings.wallpaper.default.path = "${./niri-assets/wallpaper.jpg}";
    };
  };
}
