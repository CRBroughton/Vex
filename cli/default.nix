{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "vex";
  text = ''
    echo "vex — an opinionated, declarative developer environment"
  '';
}
