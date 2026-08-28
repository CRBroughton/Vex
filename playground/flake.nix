{
  description = "Vex playground — for development testing only";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    vex = {
      url = "path:../";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { vex, self, ... }:
    {
      nixosConfigurations = {
        test = vex.osLib.mkHost {
          inherit self;
          hostname = "test";
          users = [ "test" ];
          stateVersion = "25.05";
        };
      };
    };
}
