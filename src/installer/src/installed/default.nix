{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "installed";
  src = ./src;
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir $out &&
      mkdir $out/etc &&
      cp *.txt $out/etc &&
      chmod 0400 $out/etc/* &&
      mkdir $out/scripts &&
      cp *.sh $out/scripts &&
      chmod 0500 $out/scripts/*.sh &&
      makeWrapper $out/scripts/create-nixos-objects.sh $out/bin/create-nixos-objects --set PATH ${lib.makeBinPath [ coreutils findutils ]} --set STORE_DIR $out &&
      true
  '';
}
