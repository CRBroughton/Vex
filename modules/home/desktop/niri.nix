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
          "Mod+T" = {
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

          # Focus
          "Mod+Left".focus-column-left = { };
          "Mod+Right".focus-column-right = { };
          "Mod+Down".focus-window-down = { };
          "Mod+Up".focus-window-up = { };
          "Mod+H".focus-column-left = { };
          "Mod+L".focus-column-right = { };
          "Mod+J".focus-window-down = { };
          "Mod+K".focus-window-up = { };
          "Mod+Page_Down".focus-workspace-down = { };
          "Mod+Page_Up".focus-workspace-up = { };

          # Move
          "Mod+Ctrl+Left".move-column-left = { };
          "Mod+Ctrl+Right".move-column-right = { };
          "Mod+Ctrl+Down".move-window-down = { };
          "Mod+Ctrl+Up".move-window-up = { };
          "Mod+Ctrl+Page_Down".move-column-to-workspace-down = { };
          "Mod+Ctrl+Page_Up".move-column-to-workspace-up = { };

          # Sizing
          "Mod+R".switch-preset-column-width = { };
          "Mod+Ctrl+Shift+R".switch-preset-window-height = { };
          "Mod+Minus".set-column-width = {
            _args = [ "-10%" ];
          };
          "Mod+Equal".set-column-width = {
            _args = [ "+10%" ];
          };
          "Mod+Shift+Minus".set-window-height = {
            _args = [ "-10%" ];
          };
          "Mod+Shift+Equal".set-window-height = {
            _args = [ "+10%" ];
          };

          # Window state
          "Mod+V".toggle-window-floating = { };
          "Mod+Shift+V".switch-focus-between-floating-and-tiling = { };
          "Mod+Shift+F".fullscreen-window = { };
          "Mod+F".maximize-column = { };
          "Mod+O".toggle-overview = { };

          # Screenshots
          "Print".screenshot = { };
          "Ctrl+Print".screenshot-screen = { };
          "Alt+Print".screenshot-window = { };

          # Session
          "Mod+Q".close-window = { };
          "Mod+Shift+E".quit = { };
        };
      };
    };
  };
}
