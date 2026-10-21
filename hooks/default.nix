# Each hook as a command, with what it needs on its PATH. treefmt is not
# here: each repository's wrapper carries its own treefmt.nix.
{
  gawk,
  gnugrep,
  taplo,
  typos,
  writeShellApplication,
}:
{
  ascii-only = writeShellApplication {
    name = "ascii-only";
    runtimeInputs = [
      gawk
      gnugrep
      taplo
    ];
    text = builtins.readFile ./ascii-only.sh;
  };

  commit-msg-length = writeShellApplication {
    name = "commit-msg-length";
    runtimeInputs = [ gawk ];
    text = ''exec awk -f ${./commit-msg-length.awk} "$@"'';
  };

  no-co-authors = writeShellApplication {
    name = "no-co-authors";
    runtimeInputs = [ gnugrep ];
    text = builtins.readFile ./no-co-authors.sh;
  };

  # As nixpkgs has it: typos.toml is all its configuration.
  inherit typos;
}
