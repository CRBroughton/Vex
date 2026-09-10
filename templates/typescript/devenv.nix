{ pkgs, ... }:

{
  packages = with pkgs; [
    just
    ni
  ];

  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_22;
    npm.enable = false;
    pnpm = with pkgs; {
      enable = true;
      package = pnpm;
      install.enable = true;
    };

    lsp.enable = false;
  };

  languages.typescript.enable = true;

  scripts = {
    dev.exec = "nr dev";
    build.exec = "nr build";
    test.exec = "nr test";
    check.exec = "pnpm exec tsc --noEmit";
  };

  enterShell = ''
    echo "TypeScript development environment ready"
    echo "Node $(node --version) | pnpm $(pnpm --version)"
  '';

  # VEX:PRECOMMIT-START
  git-hooks.hooks = {
    eslint.enable = true;
  };
  # VEX:PRECOMMIT-END

  # VEX:EXTRA-SERVICES
}
