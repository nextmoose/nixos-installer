{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "installer";
  src = ./src;
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir $out &&
      mkdir $out/etc &&
      cp secrets.tar.gpg $out/etc &&
      chmod 0400 $out/etc/secrets.tar.gpg &&
      mkdir $out/scripts &&
      cp installer.sh $out/scripts &&
      chmod 0500 $out/scripts/installer.sh &&
      mkdir $out/bin &&
      makeWrapper $out/scripts/installer.sh $out/bin/installer --set PATH ${lib.makeBinPath [ gnupg mktemp coreutils lvm2 dosfstools cryptsetup e2fsprogs ]} --set STORE_DIR $out &&
      true
  '';
}
