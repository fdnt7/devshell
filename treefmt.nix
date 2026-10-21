# Formatting every project gets; a project adds to it through `treefmt`
# in mkOutputs.
{
  # Used to find the project root
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    shfmt = {
      enable = true;
      includes = [ ".envrc" ];
    };
    taplo.enable = true;
  };
}
