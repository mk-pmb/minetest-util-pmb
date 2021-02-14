#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function copypaste_helper () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  [ "$#" -ge 1 ] || cd /
  local XC='xsel --clipboard'
  local PREV= CRNT=
  while sleep 0.1s; do
    CRNT="$($XC --output)"
    [ -n "$CRNT" ] || continue
    [ "$CRNT" == "$PREV" ] && continue
    if [ -n "$PREV" ]; then
      printf '%(%T)T detected: "%s"\n' -1 "${CRNT//$'\n'/¶ }"
      sleep 1s
      printf '%(%T)T re-clipping.\n'
      $XC --clear
      $XC --input <<<"$CRNT"
      [ -z "$*" ] || "$@" <<<"$CRNT" || return $?$(
        echo "E: failed (rv=$?) to paste into $*" >&2)
    fi
    PREV="$CRNT"
  done
}










copypaste_helper "$@"; exit $?
