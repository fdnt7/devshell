# Reject a commit message that credits a co-author, for repositories
# with a single author.
#
# Usage: no-co-authors <message file>

status=0
grep -inH '^co-authored-by:' "$1" || status=$?
case $status in
0)
  echo "co-author trailers above; this repository has a single author"
  exit 1
  ;;
1) exit 0 ;;
*) exit 2 ;;
esac
