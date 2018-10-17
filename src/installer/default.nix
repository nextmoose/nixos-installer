{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "installer";
  src = ./src;
  buildIncludes = [
    pkgs.coreutils pkgs.mktemp pkgs.gnupg
  ];
  installPhase = ''
    make install DESTDIR=$out
  '';
}
