cmd_s() {
  [[ $# -eq 0 ]] && die "Usage: $PROGRAM $COMMAND match"

  local terms="$(printf '%s.*?' "$@")"

  local result=$(
    find "$PREFIX" -name '*.gpg' -type f \
    | sed -r "s#^$PREFIX/##" \
    | sed -r "s#\.gpg\$##" \
    | sort \
    | grep -Pi "$terms" \
    | head -n 1
  )

  if [ -z $result ]; then
    exit -1
  fi

  local passfile="$PREFIX/$result.gpg"

  $GPG -d "${GPG_OPTS[@]}" "$passfile"
}

cmd_s "$@"
exit $?
