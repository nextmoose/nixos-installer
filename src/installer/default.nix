{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "installer";
  src = ./src;
  buildIncludes = [
    pkgs.coreutil pkgs.mktemp pkgs.gnupg
  ];
  installPhase = ''
    make install DESTDIR=$out
  '';
}
