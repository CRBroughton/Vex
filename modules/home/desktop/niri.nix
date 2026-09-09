{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.vex.desktop.niri;
  wallpaper = ./niri-assets/wallpaper.jpg;

  # Always derived from the actual wallpaper file, not hardcoded — picks the
  # lightest color in its (reduced) palette, so a wallpaper change on rebuild
  # automatically re-derives the accent.
  wallpaperAccentColor = lib.removeSuffix "\n" (
    builtins.readFile (
      pkgs.runCommand "wallpaper-accent-color"
        {
          nativeBuildInputs = [
            pkgs.imagemagick
            pkgs.gawk
          ];
        }
        ''
          magick ${wallpaper} -resize 256x256 -colors 16 -unique-colors txt:- | \
            awk '
              match($0, /#([0-9A-Fa-f]{6})/, m) {
                hex = m[1];
                r = strtonum("0x" substr(hex,1,2));
                g = strtonum("0x" substr(hex,3,2));
                b = strtonum("0x" substr(hex,5,2));
                lum = 0.299*r + 0.587*g + 0.114*b;
                if (lum > maxlum) { maxlum = lum; best = "#" hex; }
              }
              END { print best }
            ' > $out
        ''
    )
  );
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
        layout = {
          gaps = 12;

          focus-ring = {
            width = 3;
            active-color = wallpaperAccentColor;
            inactive-color = "#3c3c3c";
          };

          shadow = {
            on = { };
            softness = 30;
            spread = 5;
            offset._props = {
              x = 0;
              y = 5;
            };
            color = "#0000007f";
          };
        };

        prefer-no-csd = { };

        window-rule = {
          geometry-corner-radius._args = [ 10 ];
          clip-to-geometry = true;
        };

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
