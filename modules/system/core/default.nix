{ pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./shell.nix
    ./networking.nix
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nvd
    nix-output-monitor
    nixd
    nixfmt
    nh
  ];
}
