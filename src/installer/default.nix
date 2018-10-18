{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "installer";
  src = ./src;
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir $out &&
      mkdir $out/scripts &&
      cp installer.sh $out/scripts &&
      chmod 0500 $out/scripts/installer.sh &&
      mkdir $out/bin &&
      makeWrapper $out/scripts/installer.sh $out/bin/installer &&
      true
  '';
}
