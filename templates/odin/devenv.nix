{ pkgs, ... }:

{
  packages = with pkgs; [
    just
    raylib
    libGL
    libX11
  ];

  languages.odin = {
    enable = true;
    lsp.enable = true;
  };

  scripts = {
    dev.exec = ''odin run src/ -extra-linker-flags:"-lGL -lm -lpthread -ldl -lrt -lX11"'';
    build.exec = ''mkdir -p bin && odin build src/ -out:bin/app -extra-linker-flags:"-lGL -lm -lpthread -ldl -lrt -lX11"'';
    test.exec = ''odin test src/ -extra-linker-flags:"-lGL -lm -lpthread -ldl -lrt -lX11"'';
    check.exec = "odin check src/";
  };

  enterShell = ''
    echo "Odin development environment ready"
    echo "$(odin version)"
  '';

  # VEX:PRECOMMIT-START
  git-hooks.hooks = {
    odin-check = {
      enable = true;
      name = "odin check";
      entry = "odin check src/";
      files = "\\.odin$";
      pass_filenames = false;
    };
  };
  # VEX:PRECOMMIT-END

  # VEX:EXTRA-SERVICES
}
