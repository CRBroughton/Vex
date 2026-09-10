{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.vex.devenv;
in
{
  options.vex.devenv = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install devenv for declarative, per-project development environments.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      devenv
    ];
  };
}
