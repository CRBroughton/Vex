{ modulesPath, ... }:
{
  imports = [
    ./hardware.nix
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "test";

  vex.autoUpgrade = {
    enable = true;
    flake = "github:acmecorp/acme-vex";
    allowReboot = false;
  };

  virtualisation = {
    diskSize = 8192;
    memorySize = 4096;
    cores = 2;
  };
}
