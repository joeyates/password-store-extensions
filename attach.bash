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

  mkdir -p -v "$PREFIX/$(dirname "$password_path")"
  set_gpg_recipients "$(dirname "$password_path")"

  base64 $file_path | $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile" "${GPG_OPTS[@]}" \
    || die "Attachment encryption aborted."

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
    > $file_path
}

case "$1" in
  insert|add)     shift; cmd_attachment_insert "$@" ;;
  export)         shift; cmd_attachment_export "$@" ;;
esac
exit 0
