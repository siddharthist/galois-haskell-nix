# Generated by cabal2nix, then edited by hand
{ mkDerivation, fetchgit, aig, base, base-compat, c2hs, Cabal
, containers, directory, filemanip, filepath, QuickCheck, stdenv
, tasty, tasty-ant-xml, tasty-hunit, tasty-quickcheck, vector
# , abc
}:
let
  # For some reason, nix-prefetch-git --deepClone doesn't compute the
  # correct SHA256, so we just handle this one manually.
  src = fetchgit {
    url = "https://github.com/GaloisInc/abcBridge.git";
    deepClone = true;
    rev = "a4413485354cb1d3d5f9c3076f06628a7b481968";
    sha256 = "1smfb4nrxl51xfjk7hwyphz2jp8h7m6jhb4ahc991n657gxwwagp";
  };
in mkDerivation {
  inherit src;
  pname = "abcBridge";
  version = "0.17.1";
  isLibrary = true;
  isExecutable = true;
  setupHaskellDepends = [ base Cabal directory filemanip filepath ];
  libraryHaskellDepends = [
    aig base base-compat containers directory vector
  ];
  # librarySystemDepends = [ abc ];
  libraryToolDepends = [ c2hs ];
  testHaskellDepends = [
    aig base base-compat directory QuickCheck tasty tasty-ant-xml
    tasty-hunit tasty-quickcheck vector
  ];
  description = "Bindings for ABC, A System for Sequential Synthesis and Verification";
  license = stdenv.lib.licenses.bsd3;
}
