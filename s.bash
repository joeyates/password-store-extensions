cmd_s() {
  [[ $# -eq 0 ]] && die "Usage: $PROGRAM $COMMAND match"

  local terms="$(printf '%s.*?' "$1")"

  local result=$(
    find "$PREFIX" -name '*.gpg' -type f \
    | sed -r "s#^$PREFIX/##" \
    | sed -r "s#\.gpg\$##" \
    | sort \
    | grep -Pi "$terms" \
    | head -n 1
  )

  [ -z $result ] && die "'$1' not found"

  local passfile="$PREFIX/$result.gpg"

  echo "$result:"
  $GPG -d "${GPG_OPTS[@]}" "$passfile"
}

cmd_s "$@"
exit $?
