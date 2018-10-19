{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "init-read-only-pass";
  src = ./src;
  buildInputs = [ makeWrapper ];
  buildPhase = ''
  '';
  installPhase = ''
    mkdir $out &&
      makeWrapper $out/scripts/secret.sh $out/bin/secret --set STORE_DIR $out &&
      true
  '';
}
