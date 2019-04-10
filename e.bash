# In part copyright (C) 2012 - 2018 Jason A. Donenfeld <Jason@zx2c4.com>.
# This file is licensed under the GPLv2+. Please see LICENSE for more information.

# Adapted from https://git.zx2c4.com/password-store/tree/src/password-store.sh
cmd_e() {
  [[ $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND pass-name"

  local path="${1%/}"
  check_sneaky_paths "$path"
  mkdir -p -v "$PREFIX/$(dirname -- "$path")"
  set_gpg_recipients "$(dirname -- "$path")"
  local passfile="$PREFIX/$path.gpg"
  set_git "$passfile"

  tmpdir #Defines $SECURE_TMPDIR
  local tmp_file="$(mktemp -u "$SECURE_TMPDIR/XXXXXX")-${path//\//-}.txt"

  local action="Add"
  if [[ -f $passfile ]]; then
    $GPG -d -o "$tmp_file" "${GPG_OPTS[@]}" "$passfile" || exit 1
    action="Edit"
  fi
  ${EDITOR:-vi} "$tmp_file"
  [[ -f $tmp_file ]] || die "New password not saved."
  $GPG -d -o - "${GPG_OPTS[@]}" "$passfile" 2>/dev/null | diff - "$tmp_file" &>/dev/null && die "Password unchanged."
  while ! $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile" "${GPG_OPTS[@]}" "$tmp_file"; do
    yesno "GPG encryption failed. Would you like to try again?"
  done
  git_add_file "$passfile" "$action password for $path"
}

cmd_e "$@"

exit 0
