{ pkgs, ... }:
{
  users.users.demo = {
    isNormalUser = true;
    home = "/home/demo";
    shell = pkgs.fish;
    initialPassword = "demo";
  };
}
