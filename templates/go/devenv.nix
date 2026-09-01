{ pkgs, ... }:

{
  packages = with pkgs; [
    just
  ];

  languages.go.enable = true;

  scripts.dev.exec = "go run .";
  scripts.build.exec = "go build -o bin/app .";
  scripts.test.exec = "go test ./...";
  scripts.check.exec = "go vet ./...";

  enterShell = ''
    echo "Go development environment ready"
    echo "Go $(go version)"
  '';

  pre-commit.hooks = {
    gofmt.enable = true;
    govet.enable = true;
  };
}
