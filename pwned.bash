#!/usr/bin/env bash

# Copyright (C) 2025 Zane Zakraisek <zz@eng.utah.edu>
# SPDX-License-Identifier: BSD-2-Clause

cmd_pwned_usage() {
  echo "Usage: pass pwned [--line,-l] pass-name"
  echo "   Check HIBP to see if the password has been exposed in a breach"
  echo "   using SHA-1 and k-anonymity. Only the first five characters of"
  echo "   the password's SHA1 hash ever get sent from your computer.    "
  exit 0
}

cmd_pwned_version() {
  local version="v0.0.1"
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

  [[ -z "$count" ]] && die "Good news — no pwnage found!"
  echo "Oh no - pwned!"
  echo "This password has been seen $count times before."
}

cmd_pwned() {
  local opts line=1
  opts="$($GETOPT -o l: -l line: -n "$PROGRAM" -- "$@")" || exit $?
  eval set -- "$opts"
  while true; do case $1 in
    -l|--line) line="$2"; shift 2 ;;
    --) shift; break ;;
  esac done
  [[ $line =~ ^[0-9]+$ ]] || die "line must be a number"
  
  local path="$1"
  [[ -z "$path" ]] && cmd_pwned_usage

  local passfile="$PREFIX/$path.gpg"
  check_sneaky_paths "$path"
  
  pass="$($GPG -d "${GPG_OPTS[@]}" "$passfile" | tail -n +"${line}" | head -n 1)" || exit $?
  [[ -z $pass ]] && die "Empty file or line"
  cmd_check_hibp
}

case "$1" in
  help|--help)       shift; cmd_pwned_usage "$@" ;;
  version|--version) shift; cmd_pwned_version "$@" ;;
  *)                        cmd_pwned "$@" ;;
esac
exit 0
