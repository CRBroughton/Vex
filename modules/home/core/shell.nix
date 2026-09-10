{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.vex.shell;
  vexShell = pkgs.callPackage ../../../shell {
    wrappersLib = inputs.wrappers.lib;
    inherit (cfg) greeting extraPackages;
    zellijThemeName = cfg.zellij.theme.name;
    zellijThemeColors = cfg.zellij.theme.colors;
  };
in
{
  options.vex.shell = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the Vex default shell (Fish + Starship + Zoxide + Zellij + CLI tools), wrapped as a portable, self-contained fish binary. Set to false to manage your own shell.";
    };

    greeting = lib.mkOption {
      type = lib.types.str;
      default = "vex — Mod+/ for the cheatsheet (shortcuts, common commands)";
      description = "Fish greeting message shown in new interactive shells. Set to an empty string to disable it.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages made available on PATH inside the wrapped Vex fish shell.";
    };

    zellij.theme = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "vitesse-dark";
        description = "Name of the Zellij theme (both the selected theme and the block defining it below).";
      };

      colors = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          fg = "#dbd7ca";
          bg = "#121212";
          black = "#121212";
          red = "#cb7676";
          green = "#4d9375";
          yellow = "#e6cc77";
          blue = "#6394bf";
          magenta = "#db889a";
          cyan = "#5eaab5";
          white = "#959da5";
          orange = "#d4976c";
        };
        description = "Zellij theme colors, as `{ fg, bg, black, red, green, yellow, blue, magenta, cyan, white, orange }` hex strings.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      vexShell.vexFish
      vexShell.vexZellij
    ];
  };
}
