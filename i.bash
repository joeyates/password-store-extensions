#!/usr/bin/env bash
# pass insert multiline - Password Store Extension (https://www.passwordstore.org/)
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

cmd_insert_multiline() {
  if [[ $# -ne 1 ]]; then
    die "supply a filename"
  fi

  local password_path="$1"

  check_sneaky_paths "$password_path"

  local passfile="$PREFIX/$password_path.gpg"

  [[ -e $passfile ]] && die "Error: '$password_path' already exists."

  local content=$(</dev/stdin)

  local dirpath="$PREFIX/$(dirname "$password_path")"

  mkdir -p -v "$dirpath"
  set_gpg_recipients "$(dirname "$password_path")"

  echo "$content" | $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile" "${GPG_OPTS[@]}" \
    || die "Attachment encryption aborted."

  cd "$dirpath"
  git add "$passfile"
  git commit --message "Add $password_path"
  cd -

  return 0
}

cmd_insert_multiline "$@"

exit 0
