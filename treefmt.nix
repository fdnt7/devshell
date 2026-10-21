{
  # Used to find the project root
  projectRootFile = "flake.nix";

  programs = {
    mdformat = {
      enable = true;
      # Tables and the rest of GitHub's Markdown, which mdformat would mangle
      plugins = ps: [ ps.mdformat-gfm ];
      settings.wrap = 80;
    };
    nixfmt.enable = true;
    shfmt = {
      enable = true;
      includes = [
        ".envrc"
        "*.sh"
      ];
    };
    taplo.enable = true;
    yamlfmt.enable = true;
  };
}
