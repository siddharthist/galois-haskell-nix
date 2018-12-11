{ mkDerivation, ansi-wl-pprint, attoparsec, base, bytestring
, containers, crucible, deepseq, directory, filepath, ghc-prim
, hashable, hashtables, lens, llvm-pretty, llvm-pretty-bc-parser
, mtl, parameterized-utils, process, stdenv, tasty, tasty-golden
, tasty-hunit, template-haskell, text, transformers
, unordered-containers, utf8-string, vector, what4
##################################################### Added
# Generated with cabal2nix and set
# enableLibraryProfiling = false;
# enableExecutableProfiling = false;
# manually
, fetchFromGitHub
}:
let
  fromJson = builtins.fromJSON (builtins.readFile ../json/crucible.json);

  # For some reason, nix-prefetch-git --deepClone doesn't compute the
  # correct SHA256, so we just handle this one manually.
  src = fetchFromGitHub {
    inherit (fromJson) rev sha256;
    owner = "GaloisInc";
    repo = "crucible";
  };
in mkDerivation {
  inherit src;
  enableLibraryProfiling = false;
  enableExecutableProfiling = false;
  doCheck = false;

##################################################### Generated

  pname = "crucible-llvm";
  version = "0.2";
  postUnpack = "sourceRoot+=/crucible-llvm; echo source root reset to $sourceRoot";
  configureFlags = [ "--disable-profiling" ];
  libraryHaskellDepends = [
    ansi-wl-pprint attoparsec base bytestring containers crucible
    deepseq directory ghc-prim hashable hashtables lens llvm-pretty mtl
    parameterized-utils template-haskell text transformers
    unordered-containers utf8-string vector what4
  ];
  testHaskellDepends = [
    base containers crucible directory filepath llvm-pretty
    llvm-pretty-bc-parser mtl parameterized-utils process tasty
    tasty-golden tasty-hunit
  ];
  description = "Support for translating and executing LLVM code in Crucible";
  license = stdenv.lib.licenses.bsd3;
}