{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.vex.desktop.niri;
in
{
  options.vex.desktop.niri = {
    enable = lib.mkEnableOption "Niri, a scrollable-tiling Wayland compositor, as the desktop session";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --cmd niri";
        user = "greeter";
      };
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    security.rtkit.enable = true;
  };
}
