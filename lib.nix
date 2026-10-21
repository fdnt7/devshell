{ git-hooks, treefmt-nix }:
{
  # A project's flake outputs: a dev shell, `nix fmt` and a formatting
  # check, set up the same way in every project. The project passes its
  # own flake and nixpkgs, and a function from its packages to what it
  # adds:
  #
  #   packages  tools for its dev shell
  #   treefmt   a treefmt-nix module merged into ./treefmt.nix
  #   ...       anything else goes to mkShell as it is (env, shellHook)
  mkOutputs =
    {
      self,
      nixpkgs,
      systems ? [ "x86_64-linux" ],
    }:
    project:
    let
      forAllSystems = nixpkgs.lib.genAttrs systems;
      perSystem = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          args = project pkgs;
          treefmt = treefmt-nix.lib.evalModule pkgs {
            imports = [
              ./treefmt.nix
              (args.treefmt or { })
            ];
          };
        in
        {
          formatter = treefmt.config.build.wrapper;
          check = treefmt.config.build.check self;
          shell = pkgs.mkShell (
            removeAttrs args [ "treefmt" ]
            // {
              packages = [
                # The build environment puts its own bash on PATH, one
                # without line editing; this one comes first, so `bash`
                # typed inside the shell is usable.
                pkgs.bashInteractive

                # The hooks in the project's prek.toml run these.
                git-hooks.packages.${system}.default
                pkgs.prek
                treefmt.config.build.wrapper
              ]
              ++ args.packages or [ ];
            }
          );
        }
      );
    in
    {
      # `nix fmt`
      formatter = forAllSystems (system: perSystem.${system}.formatter);

      # `nix flake check`
      checks = forAllSystems (system: {
        formatting = perSystem.${system}.check;
      });

      devShells = forAllSystems (system: {
        default = perSystem.${system}.shell;
      });
    };
}
