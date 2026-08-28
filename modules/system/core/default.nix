{ pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./shell.nix
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
