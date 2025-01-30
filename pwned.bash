#!/usr/bin/env bash

# Copyright (C) 2025 Zane Zakraisek <zz@eng.utah.edu>
# SPDX-License-Identifier: BSD-2-Clause

cmd_pwned_usage() {
  echo "Usage: pass pwned [--line,-l] [--all,-a] pass-name"
  echo "   Check HIBP to see if the password has been exposed in a breach"
  echo "   using SHA-1 and k-anonymity. Only the first five characters of"
  echo "   the password's SHA1 hash ever get sent from your computer.    "
  exit 0
}

cmd_pwned_version() {
  local version="v0.1.0"
  echo "pass-pwned $version"
  exit 0
}

cmd_check_hibp() {
  local CURL sha1sum count http_code response
  local endpoint="https://api.pwnedpasswords.com/range"
  local min_tls="v1.2"
  local k=5

  CURL=$(which curl 2> /dev/null)
  [[ -z "$CURL" ]] && die "ERROR: curl must be installed and in the PATH"
  
  sha1sum=$(echo -n "$pass" | sha1sum | head -c 40)
  local prefix=${sha1sum:0:$k}
  local suffix=${sha1sum:$k}

  [[ "${#prefix}" != "$k" ]] && die "ERROR: Incorrect sha1 prefix length generated"
  
  local url="$endpoint/$prefix" 
  response="$($CURL --tls$min_tls --silent "$url" --write-out "\n%{http_code}")" || exit $?
  http_code="$(echo "$response" | tail -n 1)"
  [[ "$http_code" != 200 ]] && die "Error returned from HIBP"

  count="$(echo "$response" | head -n -1 | grep -i "$suffix" | cut -d ':' -f 2 | tr -d '\r')"
  [[ -z "$count" ]] && echo -e "\tGood news — no pwnage found!\n" && return
  echo -e "\tOh no - pwned!"
  echo -e "\tThis password has been seen $count times before.\n"
}

cmd_pwned() {
  local opts line=1 all=0
  opts="$($GETOPT -o al: -l all,line: -n "$PROGRAM" -- "$@")" || exit $?
  eval set -- "$opts"
  while true; do case $1 in
    -l|--line) line="$2"; shift 2 ;;
    -a|--all)  all=1;     shift 1 ;;
    --) shift; break ;;
  esac done
  [[ $line =~ ^[0-9]+$ ]] || die "line must be a number"
  
  local path="$1"
  [[ $all == 1 ]] && [[ -n "$path" ]] && cmd_pwned_usage
  [[ $all == 0 ]] && [[ -z "$path" ]] && cmd_pwned_usage

  [[ -z "$path" ]] && path='*'

  local IFS=$'\n'
  local passfile
  for passfile in $(find "$PREFIX/" -type f -wholename "$PREFIX/$path.gpg"); do
    check_sneaky_paths "$path"
    pass="$($GPG -d "${GPG_OPTS[@]}" "$passfile" | tail -n +"${line}" | head -n 1)" || exit $?
    echo ${passfile#$PREFIX/} 
    [[ -z $pass ]] && echo -e  "\tEmpty file or line\n" && continue
    cmd_check_hibp
  done
}

case "$1" in
  help|--help)       shift; cmd_pwned_usage "$@" ;;
  version|--version) shift; cmd_pwned_version "$@" ;;
  *)                        cmd_pwned "$@" ;;
esac
exit 0
