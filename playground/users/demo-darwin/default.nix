_: {
  home = {
    username = "demo";
    homeDirectory = "/Users/demo";
    stateVersion = "25.05";
  };

  vex = {
    shell.enable = true;
    devenv.enable = true;
    neovim.enable = true;
    git = {
      userName = "Test User";
      userEmail = "test@example.com";
    };
  };

  programs.nvf.settings.vim.languages = {
    typescript.enable = true;
    go.enable = true;
  };
}
