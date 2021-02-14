#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function cph_lurk () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  [ "$#" -ge 1 ] || cd /
  local XC='xsel --clipboard'
  local PREV= CRNT=
  while sleep 0.1s; do
    CRNT="$($XC --output)"
    [ -n "$CRNT" ] || continue
    [ "$CRNT" == "$PREV" ] && continue
    if [ -n "$PREV" ]; then
      PREV="$CRNT"  # now PREV means preview
      PREV="${PREV//$'\n'/¶ }"
      PREV="${PREV//$'\t'/␇$'\t'}"
      PREV="${PREV//$'\x1B'/␛}"
      printf '%(%T)T detected: "%s"\n' -1 "$PREV"
      sleep 1s
      printf '%(%T)T re-clipping.\n'
      $XC --clear
      $XC --input <<<"$CRNT"
      [ -z "$*" ] || "$@" <<<"$CRNT" || return $?$(
        echo "E: failed (rv=$?) to paste into $*" >&2)
    fi
    PREV="$CRNT"  # now PREV means previous
  done
}


function cph_strip_colors () {
  < <(sed -urf <(echo '
    s~\x1B\(c\@\#[0-9a-fA-F]{1,6}\)~~g  # strip color codes
    ')) "$@"; return $?
}


function cph_merge_whitespace () {
  < <(tr -s '\r\n \t' ' ') "$@"; return $?
}










cph_lurk "$@"; exit $?
