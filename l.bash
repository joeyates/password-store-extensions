#!/usr/bin/env bash
# pass l - Password Store Extension (https://www.passwordstore.org/)
# Similar to pass's `list`, but:
# * lists entries as a flat list,
# * has a shorter command.
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

cmd_l() {
  local path="$1"
  local ret=0
  find "$PREFIX/$path" -name '*.gpg' -type f \
    | sed -r "s#^$PREFIX/##" \
    | sed -r "s#\.gpg\$##" \
    | sort
  ret=$?

  return $ret
}

cmd_l "$@"
exit $?
