{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.vex.shell;
in
{
  options.vex.shell = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the Vex default shell (Fish + Starship + Zoxide + CLI tools). Set to false to manage your own shell.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      fish = {
        enable = true;
        shellAliases = {
          cd = "z";
          cat = "bat";
          ls = "eza";
        };
        shellInit = ''
          set -gx CGO_ENABLED 1
        '';
        functions = {
          just = ''
            if test -f justfile; or test -f .justfile; or test -f Justfile
              command just $argv
            end
          '';
        };
      };
      starship = {
        enable = true;
        enableFishIntegration = true;
      };
      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };

    home.packages = with pkgs; [
      bat
      eza
      btop
      ripgrep
      fd
      carapace
      just
      direnv
    ];
  };
}
