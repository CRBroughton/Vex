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
        demo = vex.osLib.mkHost {
          inherit self;
          hostname = "demo";
          users = [ "demo" ];
          stateVersion = "25.05";
        };

        vm = vex.osLib.mkHost {
          inherit self;
          hostname = "vm";
          users = [ "demo" ];
          stateVersion = "25.05";
        };

        iso = vex.osLib.mkHost {
          inherit self;
          hostname = "iso";
          users = [ "demo" ];
          stateVersion = "25.05";
        };
      };

      homeConfigurations = {
        demo = vex.lib.mkUser {
          inherit self;
          user = "demo";
          stateVersion = "25.05";
        };
      };
    };
}
