{ pkgs, ... }:

{
  packages = with pkgs; [
    just
  ];

  languages.go.enable = true;

  scripts = {
    dev.exec = "go run .";
    build.exec = "go build -o bin/app .";
    test.exec = "go test ./...";
    check.exec = "go vet ./...";
  };

  enterShell = ''
    echo "Go development environment ready"
    echo "Go $(go version)"
  '';

  # VEX:PRECOMMIT-START
  git-hooks.hooks = {
    gofmt.enable = true;
    govet.enable = true;
  };
  # VEX:PRECOMMIT-END

  # VEX:EXTRA-SERVICES
}
