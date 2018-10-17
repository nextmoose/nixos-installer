{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};
let script = pkgs.writeShellScriptBin "installer" ''
  echo hello
'';
in
stdenv.mkDerivation rec {
  name = "installer";
  buildInputs = [ script ];
  src = ./src;
  
}
