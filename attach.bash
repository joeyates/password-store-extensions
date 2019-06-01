#!/usr/bin/env bash
# pass import - Password Store Extension (https://www.passwordstore.org/)
# Copyright (C) 2018 Joe Yates.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

cmd_attachment_insert() {
  if [[ $# -ne 2 ]]; then
    die "supply a password path and filename"
  fi

  local password_path="$1"
  local file_path="$2"

  check_sneaky_paths "$password_path"

  [[ -e $file_path ]] || die "Error: file '$file_path' does not exist."

  local passfile="$PREFIX/$password_path.gpg"

  [[ -e $passfile ]] && die "Error: '$password_path' already exists."

  local dirpath="$PREFIX/$(dirname "$password_path")"

  mkdir -p -v "$dirpath"
  set_gpg_recipients "$(dirname "$password_path")"

  base64 "$file_path" | $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile" "${GPG_OPTS[@]}" \
    || die "Attachment encryption aborted."

  cd "$dirpath"
  git add "$passfile"
  git commit --message "Attach $password_path"
  cd -

  return 0
}

cmd_attachment_export() {
  if [[ $# -ne 2 ]]; then
    die "supply a password path and filename"
  fi

  local password_path="$1"
  local file_path="$2"

  check_sneaky_paths "$password_path"

  [[ -e $file_path ]] && die "Error: file '$file_path' exists."

  local passfile="$PREFIX/$password_path.gpg"

  [[ -e $passfile ]] || die "Error: '$password_path' doesn't exist."

  $GPG -d "${GPG_OPTS[@]}" "$passfile" \
    | base64 -d \
    > "$file_path"
}

# List all files that are Base64 encoded
# N.B. This is **slow** - it decodes every file
# Also it gives false positives:
# 1. empty files
# 2. simple Base64-encoded strings
cmd_attachment_list() {
  local path="$1"

  find "$PREFIX/$path" -name '*.gpg' -type f -print0 \
    | while IFS= read -r -d '' file; do
        # GPG decode...
        # Try to Base64 decode
        # If that works, it **may** be an attachment
        $GPG -d "${GPG_OPTS[@]}" "$file" 2>/dev/null \
          | base64 -d >/dev/null 2>&1 \
          && echo $file
      done \
    | sed -r "s#^$PREFIX/##" \
    | sed -r "s#\.gpg\$##" \
    | sort
}

case "$1" in
  insert|add)     shift; cmd_attachment_insert "$@" ;;
  export)         shift; cmd_attachment_export "$@" ;;
  list)           shift; cmd_attachment_list "$@" ;;
esac
exit 0
