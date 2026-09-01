{
  imports = [ ./hardware.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "demo";

  vex = {
    desktop.niri.enable = true;
    ai.enable = true;
    autoUpgrade = {
      enable = true;
      flake = "github:acmecorp/acme-vex";
      allowReboot = false;
    };
  };
}
