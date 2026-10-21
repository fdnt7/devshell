{
  description = "git-hooks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # The dev shell, `nix fmt` and the formatting check, shared with my
    # other projects; ./treefmt.nix adds to its formatters. devshell puts
    # these hooks in every shell, so here it takes them from this
    # repository itself: the shell runs the hooks as they are in the tree.
    devshell = {
      url = "github:fdnt7/devshell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        git-hooks.follows = "";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      devshell,
    }:
    devshell.lib.mkOutputs { inherit self nixpkgs; } (_: {
      treefmt = ./treefmt.nix;
    })
    // {
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
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
    };
}
