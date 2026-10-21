{
  description = "One dev shell definition for every project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    git-hooks = {
      url = "github:fdnt7/git-hooks";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      git-hooks,
      treefmt-nix,
    }:
    let
      lib = import ./lib.nix { inherit git-hooks treefmt-nix; };
    in
    lib.mkOutputs { inherit self nixpkgs; } (_: { }) // { inherit lib; };
}
