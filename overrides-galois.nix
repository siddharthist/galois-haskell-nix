# Overrides to the default Haskell package set for most Galois packages
{ pkgsOld ? import ./pinned-pkgs.nix { }
, compiler ? "ghc843"
}:

haskellPackagesNew: haskellPackagesOld:
let
  abc       = pkgsOld.callPackage ./abc.nix { };
  hmk       = haskellPackagesNew.callPackage;
  hlib      = pkgsOld.haskell.lib;
  mkpkg     = import ./mkpkg.nix;
  dontCheck = pkg: pkg.overrideDerivation (_: { doCheck = false; });

  # For packages that have different behavior for different GHC versions
  switchGHC = arg: arg."${compiler}" or arg.otherwise;

  withSubdirs = pname: json: f: suffix:
    hmk (mkpkg {
      inherit json;
      name   = pname + suffix;
      repo   = pname;
      subdir = f suffix;
    }) { };

  maybeSuffix = suffix: if suffix == "" then "" else "-" + suffix;

  crucibleF = withSubdirs "crucible" ./json/crucible.json
                (suffix: "crucible" + maybeSuffix suffix);

  macaw = withSubdirs "macaw" ./json/macaw.json (suffix: suffix);

  # A package in a subdirectory of Crucible
  useCrucible = name: hmk (mkpkg {
      inherit name;
      json   = ./json/crucible.json;
      repo   = "crucible";
      subdir = name;
  }) { };

  # We disable tests because they rely on external SMT solvers
  what4 = suffix:
    let name = "what4" + maybeSuffix suffix;
    in dontCheck (useCrucible name);

in {

  # Need newer version, to override cabal2nix's inputs
  abcBridge = hmk ./abcBridge.nix { };

  # The version on Hackage should work, its just not in nixpkgs yet
  parameterized-utils = hmk (mkpkg {
    name = "parameterized-utils";
    json = ./json/parameterized-utils.json;
  }) { };

  saw-script = switchGHC {
    "ghc843"  = hmk ./ghc843/saw-script.nix { };
    otherwise = hmk (mkpkg {
                  name = "saw-script";
                  json = ./json/saw-script.json;
                }) { };
  };

  saw-core = hmk (mkpkg {
    name = "saw-core";
    json = ./json/saw-core.json;
  }) { };

  saw-core-aig = hmk (mkpkg {
    name = "saw-core-aig";
    json = ./json/saw-core-aig.json;
  }) { };

  # This one takes a long time to build
  saw-core-sbv = hmk (mkpkg {
    name = "saw-core-sbv";
    json = ./json/saw-core-sbv.json;
  }) { };

  saw-core-what4 = hmk (mkpkg {
    name = "saw-core-what4";
    json = ./json/saw-core-what4.json;
  }) { };

  # crucible-server = crucibleF "server";
  crucible      = crucibleF "";
  crucible-c    = crucibleF "c";
  crucible-saw  = crucibleF "saw";
  crux          = useCrucible "crux";
  crucible-jvm  = dontCheck (crucibleF "jvm");
  crucible-llvm = switchGHC {
    "ghc843"  = hmk ./ghc843/crucible-llvm.nix { };
    otherwise = dontCheck (crucibleF "llvm");
  };

  what4     = what4 "";
  what4-sbv = what4 "sbv";
  what4-abc = (what4 "abc").overrideDerivation (oldAttrs: {
      buildPhase = ''
        export NIX_LDFLAGS+=" -L${abc} -L${abc}/lib"
        ${oldAttrs.buildPhase}
      '';
      librarySystemDepends = [ abc ];
  });

  # Cryptol needs base-compat < 0.10, version is 0.10.4
  cryptol = hlib.doJailbreak haskellPackagesOld.cryptol;

  cryptol-verifier = hmk (mkpkg {
    name = "cryptol-verifier";
    json = ./json/cryptol-verifier.json;
  }) { };

  elf-edit = hmk (mkpkg {
    name = "elf-edit";
    json = ./json/elf-edit.json;
  }) { };

  flexdis86 = hmk (mkpkg {
    name = "flexdis86";
    json = ./json/flexdis86.json;
  }) { };

  binary-symbols = hmk (mkpkg {
    name   = "binary-symbols";
    repo   = "flexdis86";
    subdir = "binary-symbols";
    json   = ./json/flexdis86.json;
  }) { };

  galois-dwarf = hmk (mkpkg {
    name = "dwarf";
    json = ./json/dwarf.json;
  }) { };

  # Hackage version broken
  jvm-parser = hmk (mkpkg {
    name = "jvm-parser";
    json = ./json/jvm-parser.json;
  }) { };

  jvm-verifier = dontCheck (hmk (mkpkg {
    name = "jvm-verifier";
    json = ./json/jvm-verifier.json;
  }) { });

  llvm-pretty-bc-parser = hmk (mkpkg {
    name = "llvm-pretty-bc-parser";
    json = ./json/llvm-pretty-bc-parser.json;
  }) { };

  llvm-verifier = (hmk (mkpkg {
    name = "llvm-verifier";
    json = ./json/llvm-verifier.json;
  }) { });

  llvm-pretty = hmk (mkpkg {
    name = "llvm-pretty";
    owner = "elliottt";
    json = ./json/llvm-pretty.json;
  }) { };

  macaw-base         = macaw "base";
  macaw-x86          = macaw "x86";
  macaw-symbolic     = switchGHC {
    "ghc843"  = hmk ./ghc843/macaw-symbolic.nix { };
    otherwise = macaw "symbolic";
  };
  macaw-x86-symbolic = switchGHC {
    "ghc843"  = hmk ./ghc843/macaw-x86-symbolic.nix { };
    otherwise = macaw "x86_symbolic";
  };

  # https://github.com/NixOS/nixpkgs/blob/849b27c62b64384d69c1bec0ef368225192ca096/pkgs/development/haskell-modules/configuration-common.nix#L1080
  hpack     = switchGHC {
    "ghc822"  = hlib.dontCheck haskellPackagesNew.hpack_0_29_6;
    otherwise = haskellPackagesOld.hpack;
  };
  cabal2nix = switchGHC {
    "ghc822"  = hlib.dontCheck haskellPackagesOld.cabal2nix;
    otherwise = haskellPackagesOld.cabal2nix;
  };
}
