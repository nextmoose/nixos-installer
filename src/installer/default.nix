{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
let script = pkgs.writeShellScriptBin "installer" ''
  echo hello
'';
in
stdenv.mkDerivation rec {
  name = "installer";
  src = ./src;
  buildInputs = [ script ];
}
