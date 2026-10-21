# Check a commit message against 50/72: a subject of at most 50
# characters, a blank line after it, and body lines of at most 72.
#
# A body line may overflow when it can't be wrapped:
# - a single word, such as a URL or a store path, after any indent or
#   list marker
# - a trailer in the last paragraph, such as `Refs: <url>`
# - `nix flake update` output: the input lines and their locked refs
#
# Usage: commit-msg-length <message file>

# Git strips comments after the hook runs, and everything below the
# scissors line with `git commit --verbose`.
/^# -+ >8 -+$/ { exit }
/^#/ { next }

{ line[++n] = $0 }

function trailer(s) {
    return s ~ /^[A-Za-z0-9-]+: / || s ~ /^[ \t]+[^ \t]/
}

function exempt(i, s) {
    s = line[i]
    if (i >= trailers && trailer(s))
        return 1
    # `nix flake update`
    if (s ~ /^• (Updated|Added|Removed) input '/ || s ~ /^    '/ || s ~ /^  → /)
        return 1
    sub(/^[ \t]*(([-*•]|[0-9]+[.)])[ \t]+)?/, "", s)
    return s !~ /[ \t]/
}

function fail(i, msg) {
    printf "line %d: %s\n  %s\n", i, msg, line[i]
    bad = 1
}

END {
    while (n > 0 && line[n] ~ /^[ \t]*$/)
        n--

    # The last paragraph holds trailers only if every line in it is one.
    trailers = n + 1
    for (i = n; i > 2 && line[i] !~ /^[ \t]*$/; i--)
        if (!trailer(line[i])) {
            i = n + 1
            break
        }
    if (i <= n)
        trailers = i + 1

    if (length(line[1]) > 50)
        fail(1, "subject is " length(line[1]) " characters, over 50")
    if (n >= 2 && line[2] !~ /^[ \t]*$/)
        fail(2, "missing a blank line after the subject")
    for (i = 3; i <= n; i++)
        if (length(line[i]) > 72 && !exempt(i))
            fail(i, "body line is " length(line[i]) " characters, over 72; wrap it")

    exit bad
}
