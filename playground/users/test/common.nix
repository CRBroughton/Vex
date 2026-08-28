{ pkgs, ... }:
{
  users.users.test = {
    isNormalUser = true;
    home = "/home/test";
    shell = pkgs.fish;
    initialPassword = "test";
  };
}
