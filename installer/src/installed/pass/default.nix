{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "pass";
  src = ./src;
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir $out &&
      cp scripts $out/scripts &&
      chmod 0500 $out/scripts/* &&
      tar --extract --verbose --gunzip --file pass.tar.gz $out &&
      makeWrapper \
        $out/scripts/pass.sh \
        $out/bin/pass \
        --set STORE_DIR $out &&
        --set PATH ${lib.makeBinPath [ pkgs.coreutils ]} &&
      true
  '';
}
