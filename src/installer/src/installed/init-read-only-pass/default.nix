{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
let
  precommit = pkgs.writeShellScriptBin "precommit" ''
    echo This is a read only repository.  No commits are allowed. &&
      exit 64
  '';
in
stdenv.mkDerivation rec {
  name = "init-read-only-pass";
  src = ./src;
  buildInputs = [ makeWrapper ];
  buildPhase = ''
  '';
  installPhase = ''
    mkdir $out &&
      mkdir $out/scripts &&
      cp init-read-only-pass.sh $out/scripts &&
      makeWrapper $out/scripts/init-read-only-pass.sh $out/bin/init-read-only-pass --set PATH ${lib.makeBinPath [ mktemp coreutils gzip gnutar gnupg pass precommit ]} --set STORE_DIR $out &&
      true
  '';
}
