# devshell

My dev shell for every project, with my git hooks, packaged as a Nix flake. A
project takes it as an input instead of spelling the setup out, and gets:

- a dev shell with interactive bash, the commands behind the hooks below, prek
  and treefmt, plus its own tools;
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

Pick the hooks in `prek.toml`:

```toml
default_install_hook_types = ["pre-commit", "commit-msg"]
default_stages = ["pre-commit"]

# Their commands come from the dev shell.
[[repos]]
repo = "https://github.com/fdnt7/devshell"
rev = "<commit>"
hooks = [
  { id = "ascii-only" },
  { id = "cog-verify" },
  { id = "commit-msg-length" },
  { id = "no-co-authors" },
  { id = "treefmt" },
  { id = "typos" },
  { id = "typos-commit-msg" },
]
```

Add `.envrc` (`use flake`), and `typos.toml` or `ascii-only.toml` when the
project needs exceptions. Then, once: `direnv allow` and `prek install`.

The flake input decides which version of the commands runs, and `rev` only which
hooks are listed. `nix flake update devshell` brings in changes made here;
`prek autoupdate` is needed only when a hook is added or renamed.

## Hooks

| Hook                | Stage      | What it checks                                                                      |
| ------------------- | ---------- | ----------------------------------------------------------------------------------- |
| `ascii-only`        | pre-commit | No non-ASCII characters, except those an allowlist opts in                          |
| `cog-verify`        | commit-msg | A Conventional Commits message, by `cog.toml` if there is one                       |
| `commit-msg-length` | commit-msg | A subject of at most 50 characters, a blank line after it, and a body wrapped at 72 |
| `no-co-authors`     | commit-msg | No `Co-authored-by` trailers, for repositories with one author                      |
| `treefmt`           | pre-commit | No file that the repository's treefmt would change                                  |
| `typos`             | pre-commit | No spelling mistakes, by `typos.toml`, reported but not fixed                       |
| `typos-commit-msg`  | commit-msg | The same, for the commit message                                                    |

### `ascii-only`

Opt characters in with an `ascii-only.toml` at the repository root, pasting each
one as it is:

```toml
allowed = [
  "•", # bullet: in a tool's output quoted somewhere
  "\u00A0", # a character that does not show can be an escape
]
```

Each entry must be a single non-ASCII character. The config itself is exempt
from the check. To keep it elsewhere, pass its path:

```toml
hooks = [{ id = "ascii-only", args = ["--config", "path/to/ascii-only.toml"] }]
```

### `cog-verify`

cocogitto reads its configuration, such as extra commit types, from `cog.toml`,
so this flake packages it as nixpkgs has it. cocogitto has no official hook to
use instead.

### `commit-msg-length`

A body line may run past 72 characters when it can't be wrapped:

- a single word, such as a URL or a store path
- a trailer in the last paragraph, such as `Refs: <url>`

Comments and anything below the scissors line of `git commit --verbose` are not
checked, since git strips them.

### `treefmt`

The command is the repository's own treefmt wrapper, which [treefmt-nix] builds
from the default formatters in `lib/treefmt.nix` and the repository's own
additions. treefmt has no official hook to use instead.

### `typos`

typos reads all its configuration from `typos.toml`, so this flake packages it
as nixpkgs has it. The official hooks install typos with Python, Docker or Cargo
and fix mistakes in place; this one uses the typos on `PATH` and only reports
them. It checks the whole repository rather than the staged files, so the
excludes in `typos.toml` apply.

### `typos-commit-msg`

The same typos, on the message git passes the hook. That file sits under
`.git/`, so typos still finds the repository's `typos.toml`, but only its
`[default]` rules apply: the message has no file type. Commit messages tend to
quote hashes, which typos reads as words; ignore them there, for example:

```toml
[default]
extend-ignore-re = [
  # Short and full commit hashes, like "ba2846c"
  '\b[0-9a-f]{7,40}\b',
]
```

[treefmt-nix]: https://github.com/numtide/treefmt-nix
