{
  description = "spelling-beetle";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = inputs:
    let
      overlay = final: prev: {
        haskell = prev.haskell // {
          packageOverrides = hfinal: hprev:
            prev.haskell.packageOverrides hfinal hprev // {
              spelling-beetle = hfinal.callCabal2nix "spelling-beetle" ./. { };
            };
        };

        spelling-beetle = final.haskell.lib.compose.justStaticExecutables final.haskellPackages.spelling-beetle;

        spelling-beetle-shell = final.haskellPackages.shellFor {
          withHoogle = false;
          packages = hpkgs: [ hpkgs.spelling-beetle ];
          nativeBuildInputs = [
            final.cabal-install
            final.ghcid
            final.haskellPackages.haskell-language-server
            final.hlint
            final.ormolu
            final.bashInteractive # see: https://discourse.nixos.org/t/interactive-bash-with-nix-develop-flake/15486
          ];
        };
      };

      perSystem = system:
        let
          pkgs = import inputs.nixpkgs { inherit system; overlays = [ overlay ]; };
        in
        {
          defaultPackage = pkgs.spelling-beetle;
          packages.spelling-beetle = pkgs.spelling-beetle;
          devShell = pkgs.spelling-beetle-shell;
          checks.integration-tests = import ./test pkgs;
        };
    in
    { inherit overlay; } // inputs.flake-utils.lib.eachDefaultSystem perSystem;
}
