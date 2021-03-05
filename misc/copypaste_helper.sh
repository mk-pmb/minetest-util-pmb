#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
__DOC__="

When copying text to clipboard in MineTest 5.4.0 on Ubuntu bionic,
that text is available only for a very short timespan (MT issue 7830).
This script tries to catch this brief moment of opportunity, get the
clipped text, and then seize responsibility for maintaining the
clipboard content.

However, this comes at a heavy price: Each time the clipboard
responsibility is seized, the MineTest client may freeze for up to
several seconds. Avoid accidential copying when monsters are nearby.

If you provide command line arguments, they will be interpreted as a
shell command for notification. The notification command will be run
each time new text was acquired, and the new text will be sent to the
notification command's standard input. (Curious? Try with `nl -ba`)
One use case for this could be text-to-speech.

There might be a slight delay between invocation of the notification
command, and the text being available for pasting. If your notification
command wants to use the clipboard in any way, I suggest it delays all
such action to about 0.2s after invocation.

"


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


function cph_merge_whitespace () { < <(tr -s '\r\n \t' ' ') "$@"; return $?; }

function cph_envtext () { eval "$1"'="$INPUT" "${@:1}"'; return $?; }

function cph_nonfatal () {
  "$@" || echo "W: failed (rv=$?) to paste into $*" >&2
  return 0
}











cph_lurk "$@"; exit $?
