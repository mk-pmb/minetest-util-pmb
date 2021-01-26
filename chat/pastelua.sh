#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function pastelua () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local LUA_CODE=
  case "$1" in
    =* ) LUA_CODE="${1:1} "; shift;;
  esac

  LUA_CODE+="$(sed -re '/^\s*(-{2}|$)/d' -- "$@" | tr '\n' '\r' | sed -re '
    s~\s*\r\s*~ ~g
    s~^ ~~
    s~ $~~
    ')"

  if [ -n "$LUA_CODE" ]; then
    echo -n "$LUA_CODE" | clipsave || return $?
    echo "D: saved ${#LUA_CODE} characters to clipboard"
  fi

  local XDO_KEYS=(
    # Maybe open chat:
    t

    # Bug in 5.3.0: First attempt pastes old content or fails.
    Ctrl+v

    # Thus, remove the failed paste. (And the "t" if chat was open already.)
    Ctrl+a Delete

    # Paste and send actual text
    Ctrl+v Return
    )
  xdotool key "${XDO_KEYS[@]}" || return $?
}










[ "$1" == --lib ] && return 0; pastelua "$@"; exit $?
