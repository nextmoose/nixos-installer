{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
let
  script = writeShellScriptBin "doit" ''
    gpg --help
  '';
in
stdenv.mkDerivation rec {
  name = "installer";
  src = ./src;
  buildInputs = [
    pkgs.coreutils pkgs.mktemp script
  ];
  installPhase = ''
    make install DESTDIR=$out SCRIPT=$script
  '';
}
