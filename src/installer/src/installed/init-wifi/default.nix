{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "init-wifi";
  src = ./src;
  buildInputs = [ makeWrapper ];
  buildPhase = ''
  '';
  installPhase = ''
    mkdir $out &&
      mkdir $out/scripts &&
      cp init-wifi.sh $out/scripts &&
      chmod 0500 $out/scripts/init-wifi.sh &&
      makeWrapper $out/scripts/init-wifi.sh $out/bin/init-wifi --set PATH ${lib.makeBinPath [ networkmanager ]}  --set STORE_DIR $out &&
      true
  '';
}
