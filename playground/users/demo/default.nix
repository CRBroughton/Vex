_: {
  home = {
    username = "demo";
    homeDirectory = "/home/demo";
    stateVersion = "25.05";
  };

  vex = {
    shell.enable = true;
    devenv.enable = true;
    neovim.enable = true;
    desktop.enable = true;
    ai.enable = true;
    git = {
      userName = "Test User";
      userEmail = "test@example.com";
    };
  };

  # Extra nvf language support for the playground specifically (typescript's
  # LSP/treesitter covers JS too) — nix is already on by default in vex.neovim.
  programs.nvf.settings.vim.languages = {
    typescript.enable = true;
    go.enable = true;
  };
}
