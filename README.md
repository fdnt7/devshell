# devshell

One dev shell definition for every project, so no project's `flake.nix` spells
it out. A project gets:

- a dev shell with interactive bash, the commands behind
  [fdnt7/git-hooks](https://github.com/fdnt7/git-hooks), prek and treefmt, plus
  its own tools;
- `nix fmt` and a formatting check in `nix flake check`, through treefmt-nix:
  mdformat, nixfmt, taplo, and shfmt for `.envrc`.

## Use

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devshell = {
      url = "github:fdnt7/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, devshell }:
    devshell.lib.mkOutputs { inherit self nixpkgs; } (pkgs: {
      packages = [ pkgs.cargo pkgs.rustc ];
    });
}
```

The function's result may also set `treefmt`, a treefmt-nix module added to the
defaults, and anything `mkShell` takes, such as `env`. Pass `systems` beside
`self` and `nixpkgs` for more than `x86_64-linux`.

Next to it, the project keeps what its tools read from the repository:
`prek.toml` (copy this repository's), `.envrc` (`use flake`), and `typos.toml`
or `ascii-only.toml` when it needs exceptions. Then, once: `direnv allow` and
`prek install`.

`nix flake update devshell` brings in changes made here.
