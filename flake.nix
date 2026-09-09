{
  description = "Vex — an opinionated, declarative developer environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      import-tree,
      flake-utils,
      ...
    }@inputs:
    let
      optionalImportTree = path: if builtins.pathExists path then [ (import-tree path) ] else [ ];

      lib = import ./lib/home { inherit inputs import-tree optionalImportTree; };
      osLib = import ./lib/os { inherit inputs import-tree optionalImportTree; };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.callPackage ./cli { inherit pkgs; };
      }
    )
    // {
      inherit lib osLib;

      templates = {
        typescript = {
          path = ./templates/typescript;
          description = "A devenv-based TypeScript project (pnpm workspace, catalog-pinned)";
        };
        go = {
          path = ./templates/go;
          description = "A devenv-based Go project";
        };
      };

      templates.default = self.templates.typescript;
    };
}
