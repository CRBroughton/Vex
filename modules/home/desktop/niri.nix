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
    enable = lib.mkEnableOption "the Niri desktop session (keybinds, autostart, userland tools)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      foot
      rofi
    ];

    wayland.windowManager.niri = {
      enable = true;

      settings = {
        layout.gaps = 8;
        prefer-no-csd = { };

        binds = {
          "Mod+Return" = {
            _props.hotkey-overlay-title = "Open a Terminal";
            spawn = [ "foot" ];
          };
          "Mod+D" = {
            _props.hotkey-overlay-title = "Open the App Launcher";
            spawn = [
              "rofi"
              "-show"
              "drun"
            ];
          };
          "Mod+Q".close-window = { };
          "Mod+Shift+E".quit = { };
          "Mod+F".maximize-column = { };
          "Mod+Shift+Space".toggle-window-floating = { };
          "Mod+Tab".focus-window-down = { };
        };
      };
    };
  };
}
