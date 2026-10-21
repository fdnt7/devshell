# Reject non-ASCII characters in the given files, except the ones the
# config opts in. Without a config, every file must be ASCII.
#
# Usage: ascii-only [--config <path>] <file>...

config=ascii-only.toml
if [ "${1-}" = --config ]; then
  config=$2
  shift 2
fi

# The config shows the characters it allows, so it is exempt.
for file; do
  shift
  [ "$file" = "$config" ] || set -- "$@" "$file"
done
[ $# -gt 0 ] || exit 0

export LC_ALL=C.UTF-8

class=
if [ -e "$config" ]; then
  # taplo parses the TOML and prints the list one character per line,
  # with escapes resolved. The x keeps the substitution from dropping
  # an empty last entry along with the trailing newline.
  chars=$(taplo get -f "$config" -o value 'allowed[*]' && echo x) || exit 2
  chars=${chars%x}

  class=$(printf '%s' "$chars" | awk -v file="$config" '
        function bad(why) {
            printf "%s: %s: \"%s\"\n", file, why, $0 > "/dev/stderr"
            exit 2
        }
        length($0) != 1 { bad("not a single character") }
        /^[\001-\177]$/ { bad("already ASCII") }
        # Inside a bracket expression only ASCII is special, so the
        # characters go in as they are.
        { printf "%s", $0 }
    ') || exit 2
fi

# grep finding a match is the failure here, and finding none the success
status=0
grep -nHP "[^\x00-\x7F$class]" "$@" || status=$?
case $status in
0)
  echo "non-ASCII characters above; opt one in by pasting it in $config"
  exit 1
  ;;
1) exit 0 ;;
*) exit 2 ;;
esac
