# List password store entries sorted by last modification
# Oldest entries come last.
# Adapted in part from https://gist.github.com/mixu/dbca40ec642ee652136e
cmd_oldest() {
  local path="$1"

  git --git-dir=$PREFIX/.git ls-tree -r --name-only -z HEAD -- $path \
    | grep -zE "\.gpg$" \
    | while IFS= read -r -d '' filename; do
        local date=$(git --git-dir=$PREFIX/.git log -1 --format="%at|%ad|" -- "$filename")
        echo "$date$filename"
      done \
    | sed -r "s#\.gpg\$##" \
    | sort -rn \
    | cut -d '|' --output-delimiter=' ' -f 2,3
}

cmd_oldest $@

exit $?
