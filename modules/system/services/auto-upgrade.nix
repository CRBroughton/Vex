{ config, lib, ... }:

let
  cfg = config.vex.autoUpgrade;
in
{
  options.vex.autoUpgrade = {
    enable = lib.mkEnableOption "Automatic system upgrades";

    flake = lib.mkOption {
      type = lib.types.str;
      description = "The flake URL to upgrade from. Set this to your own config repo, not Vex itself.";
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "04:00";
      description = "When to run upgrades (systemd calendar format).";
    };

    allowReboot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to automatically reboot after kernel updates.";
    };

    rebootWindow = {
      lower = lib.mkOption {
        type = lib.types.str;
        default = "03:00";
        description = "Start of the permitted reboot window.";
      };
      upper = lib.mkOption {
        type = lib.types.str;
        default = "05:00";
        description = "End of the permitted reboot window.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    system.autoUpgrade = {
      enable = true;
      inherit (cfg) flake;
      dates = cfg.schedule;
      inherit (cfg) allowReboot;
      rebootWindow = {
        lower = cfg.rebootWindow.lower;
        upper = cfg.rebootWindow.upper;
      };
    };
  };
}
