{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
let
  precommit = pkgs.writeShellScriptBin "pre-commit" ''
    echo This is a read only repository.  No commits are allowed. &&
      exit 64
  '';
  prepush = pkgs.writeShellScriptBin "pre-push" ''
    echo This is a read only repository.  No pushes are allowed. &&
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
      mkdir $out/etc &&
      cp secrets.tar.gz $out/etc &&
      mkdir $out/scripts &&
      cp init-read-only-pass.sh $out/scripts &&
      chmod 0500 $out/scripts/init-read-only-pass.sh &&
      makeWrapper $out/scripts/init-read-only-pass.sh $out/bin/init-read-only-pass --set PATH ${lib.makeBinPath [ mktemp coreutils gzip gnutar gnupg pass precommit prepush which ]} --set STORE_DIR $out &&
      true
  '';
}
