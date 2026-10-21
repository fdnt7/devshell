# Formatting every project gets; a project adds to it through `treefmt`
# in mkOutputs.
{
  # Used to find the project root
  projectRootFile = "flake.nix";

  programs = {
    mdformat = {
      enable = true;
      settings.wrap = 80;
    };
    nixfmt.enable = true;
    shfmt = {
      enable = true;
      includes = [ ".envrc" ];
    };
    taplo.enable = true;
  };
}
