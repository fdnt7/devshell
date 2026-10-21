{
  description = "git-hooks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      treefmtEval = forAllSystems (
        system: inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix
      );
    in
    {
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # callPackage adds override functions beside the hooks
          hooks = pkgs.lib.filterAttrs (_: pkgs.lib.isDerivation) (pkgs.callPackage ./hooks { });
        in
        hooks
        // {
          default = pkgs.symlinkJoin {
            name = "git-hooks";
            paths = builtins.attrValues hooks;
          };
        }
      );
      devShells = forAllSystems (
        system:
        let
          inherit (nixpkgs.legacyPackages.${system}) mkShell prek;
        in
        {
          default = mkShell {
            packages = [
              prek
              self.formatter.${system}
              self.packages.${system}.default
            ];
          };
        }
      );
    };
}
