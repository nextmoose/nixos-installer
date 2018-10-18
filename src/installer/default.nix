{ pkgs ? import <nixpkgs> {} }:
let
  properties=pkgs.writeText "properties.txt" ''
    GNUPG=${pkgs.gnupg}
  '';
  script=pkgs.writeShellScriptBin "xxx" ''
    source properties.env
    echo XXX
  '';
in
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
