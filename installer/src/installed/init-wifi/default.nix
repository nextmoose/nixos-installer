{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "init-wifi";
  src = ./src;
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir $out &&
      mkdir $out/etc &&
      cp secrets.tar.gz $out/etc &&
      mkdir $out/scripts &&
      cp init-wifi.sh $out/scripts &&
      chmod 0500 $out/scripts/init-wifi.sh &&
      makeWrapper $out/scripts/init-wifi.sh $out/bin/init-wifi --set PATH ${lib.makeBinPath [ mktemp coreutils gzip gnutar networkmanager ]}  --set STORE_DIR $out &&
      true
  '';
}
