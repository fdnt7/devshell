{
  description = "My dev shell for every project, with my git hooks";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      lib = import ./lib { inherit treefmt-nix; };
    in
    lib.mkOutputs { inherit self nixpkgs; } (_: {
      treefmt = ./treefmt.nix;
    })
    // {
      inherit lib;

      # The hooks' commands, for `nix build` and anyone wanting them alone
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
        system: lib.hooks nixpkgs.legacyPackages.${system}
      );
    };
}
