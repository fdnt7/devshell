# What this repository adds to the formatting devshell gives every project
# (mdformat, nixfmt, shfmt for .envrc, taplo).
{
  programs = {
    # Tables and the rest of GitHub's Markdown, which mdformat would mangle
    mdformat.plugins = ps: [ ps.mdformat-gfm ];
    shfmt.includes = [ "*.sh" ];
    yamlfmt.enable = true;
  };
}
