_: {
  home = {
    username = "demo";
    homeDirectory = "/home/demo";
    stateVersion = "25.05";
  };

  vex = {
    shell.enable = true;
    devenv.enable = true;
    desktop.niri.enable = true;
    ai.enable = true;
    git = {
      userName = "Test User";
      userEmail = "test@example.com";
    };
  };
}
