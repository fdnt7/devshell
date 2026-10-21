# git-hooks

Git hooks for [prek] and [pre-commit], packaged with Nix.

| Hook                | Stage      | What it checks                                                                      |
| ------------------- | ---------- | ----------------------------------------------------------------------------------- |
| `ascii-only`        | pre-commit | No non-ASCII characters, except those an allowlist opts in                          |
| `cog-verify`        | commit-msg | A Conventional Commits message, by `cog.toml` if there is one                       |
| `commit-msg-length` | commit-msg | A subject of at most 50 characters, a blank line after it, and a body wrapped at 72 |
| `no-co-authors`     | commit-msg | No `Co-authored-by` trailers, for repositories with one author                      |
| `treefmt`           | pre-commit | No file that the repository's treefmt would change                                  |
| `typos`             | pre-commit | No spelling mistakes, by `typos.toml`, reported but not fixed                       |
| `typos-commit-msg`  | commit-msg | The same, for the commit message                                                    |

## Use

The hooks run commands that this flake packages, so a repository needs two
things: the hooks in its prek config, and the commands on its `PATH`. The one
exception is treefmt, which the repository brings itself.

Pick the hooks in `prek.toml`:

```toml
default_install_hook_types = ["pre-commit", "commit-msg"]

[[repos]]
repo = "https://github.com/fdnt7/git-hooks"
rev = "<tag or commit>"
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

Add the commands to the dev shell:

```nix
{
  inputs.git-hooks.url = "github:fdnt7/git-hooks";

  # in the dev shell
  packages = [
    inputs.git-hooks.packages.${system}.default
    # treefmt, built from the repository's own treefmt.nix
    self.formatter.${system}
  ];
}
```

The flake input decides which version of the commands runs; `rev` only decides
which hooks are listed, so the two can move separately.

## Hooks

### `ascii-only`

Opt characters in with an `ascii-allowlist.toml` at the repository root, pasting
each one as it is:

```toml
allowed = [
  "•", # bullet: `nix flake update` output
  "\u00A0", # a character that does not show can be an escape
]
```

Each entry must be a single non-ASCII character. The allowlist itself is exempt
from the check. To keep it elsewhere, pass its path:

```toml
hooks = [{ id = "ascii-only", args = ["--allowlist", "path/to/allowlist.toml"] }]
```

### `cog-verify`

cocogitto reads its configuration, such as extra commit types, from `cog.toml`,
so this flake packages it as nixpkgs has it. cocogitto has no official hook to
use instead.

### `commit-msg-length`

A body line may run past 72 characters when it can't be wrapped:

- a single word, such as a URL or a store path
- a trailer in the last paragraph, such as `Refs: <url>`
- `nix flake update` output: its input lines and their locked refs
- `nvd` output: the store paths it compares and its package lines

Comments and anything below the scissors line of `git commit --verbose` are not
checked, since git strips them.

### `treefmt`

This flake doesn't package treefmt: the command is the repository's own wrapper,
which [treefmt-nix] builds with the formatters and settings of its
`treefmt.nix`. treefmt has no official hook to use instead.

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
quote hashes and tool output, which typos reads as words; ignore them there, for
example:

```toml
[default]
extend-ignore-re = [
  # Short and full commit hashes, like "ba2846c"
  '\b[0-9a-f]{7,40}\b',
  # nvd's package lines, like "[U.] firefox 140.0"
  '(?m)^\[[A-Z][.+*-]\] .*$',
]
```

[pre-commit]: https://pre-commit.com
[prek]: https://github.com/j178/prek
[treefmt-nix]: https://github.com/numtide/treefmt-nix
