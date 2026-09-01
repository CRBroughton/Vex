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

  pre-commit.hooks = {
    gofmt.enable = true;
    govet.enable = true;
  };
}
