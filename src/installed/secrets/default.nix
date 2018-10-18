{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "secrets";
  src = ./src;
  buildInputs = [ makeWrapper ];
  buildPhase = ''
    gunzip --to-stdout secrets.tar.gz > secrets.tar &&
      mkdir secrets &&
      tar --extract --file secrets.tar --directory secrets &&
      true
  '';
  installPhase = ''
    mkdir $out &&
      mkdir $out/etc &&
      cp --recursive secrets $out/etc &&
      mkdir $out/scripts &&
      cp secret.sh $out/scripts &&
      chmod 0500 $out/scripts/secret.sh &&
      mkdir $out/bin &&
      makeWrapper $out/scripts/secret.sh $out/bin/secret --set STORE_DIR $out &&
      true
  '';
}
