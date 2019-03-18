cmd_f() {
  [[ $# -eq 0 ]] && die "Usage: $PROGRAM $COMMAND pass-names..."
  local terms="$(printf '%s.*?' "$@")"
  find "$PREFIX" -name '*.gpg' -type f \
    | sed -r "s#^$PREFIX/##" \
    | sed -r "s#\.gpg\$##" \
    | sort \
    | grep -Pi "$terms"
}

cmd_f "$@"
exit $?
