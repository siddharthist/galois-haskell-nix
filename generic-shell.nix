{ pkgs  ? import ./pinned-pkgs.nix { }
, hpkgs ? import ./local.nix { }
, name
, additionalInputs ? pkgs: []
, additionalHaskellInputs ? pkgs: []
}:

let this  = hpkgs.haskellPackages.${name};
    unstable =
      import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz) { };
in with pkgs; pkgs.mkShell {
  shellHook = ''
    # 4mil KB = 4GB mem
    echo "try:"
    echo "ulimit -v 4000000"
  '';
  buildInputs = [
    (hpkgs.haskellPackages.ghcWithPackages (hpkgs': with hpkgs'; [
    ] ++ this.buildInputs
      ++ this.propagatedBuildInputs
      ++ additionalHaskellInputs hpkgs'))

    # https://github.com/ndmitchell/ghcid/pull/236
    unstable.haskellPackages.ghcid
    unstable.haskellPackages.hlint
    unstable.haskellPackages.apply-refact
    haskellPackages.cabal-install
    # haskellPackages.importify

    firejail
    git
    which
    zsh
  ] ++ additionalInputs hpkgs;
}
