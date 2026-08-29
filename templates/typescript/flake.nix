{
  description = "TypeScript development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
            pnpm
            ni
            typescript
            typescript-language-server
            just
            direnv
          ];

          shellHook = ''
            if [ ! -d "node_modules" ]; then
              echo "Installing dependencies..."
              pnpm install
            fi

            echo "TypeScript development environment ready"
            echo "Node $(node --version) | pnpm $(pnpm --version)"
          '';
        };
      }
    );
}
