{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
}:

buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "0.84.4";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha512-jmOlrqUmvhh/siNWFRXjYLJzhKFIHNsAQaysRwzQPQFnPAaV/vhqHsLH/MBsIISA1Rjj7WTUFR3nJrpXoLx39w==";
  };

  # The published tarball ships its own npm-shrinkwrap.json, but it's
  # incomplete (missing `integrity` on several nested @earendil-works/*
  # entries, and missing @types/cross-spawn entirely). Use a freshly
  # generated, complete package-lock.json instead.
  postPatch = ''
    rm -f npm-shrinkwrap.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-RPYwzb+pD7BMlwjaaTZzaVMje51cusr6GnCApFBEAc0=";

  # Published tarball ships a prebuilt dist/, no build step needed.
  dontNpmBuild = true;

  inherit nodejs;

  meta = {
    description = "Minimal agent harness for AI-assisted software development";
    homepage = "https://pi.dev";
    license = lib.licenses.mit;
    mainProgram = "pi";
  };
}
