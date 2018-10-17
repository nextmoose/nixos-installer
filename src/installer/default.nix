{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "installer";
  src = ./src;
  buildIncludes = [
    pkgs.coreUtils pkgs.gnupg
  ];
  installPhase = ''
    make install DESTDIR=$out
  '';
}
