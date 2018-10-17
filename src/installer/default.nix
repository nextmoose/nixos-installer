{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
let
  script = "doit" ''
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
    make install DESTDIR=$out
  '';
}
