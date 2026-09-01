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

        iso = vex.osLib.mkHost {
          inherit self;
          hostname = "iso";
          users = [ "test" ];
          stateVersion = "25.05";
        };
      };

      homeConfigurations = {
        test = vex.lib.mkUser {
          inherit self;
          user = "test";
          stateVersion = "25.05";
        };
      };
    };
}
