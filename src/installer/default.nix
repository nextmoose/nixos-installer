{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "installer";
  src = ./src;
  buildPhase = ''
    make build GNUPG=${pkgs.gnupg}
  '';
  installPhase = ''
    make install DESTDIR=$out
  '';
}
