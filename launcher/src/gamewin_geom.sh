#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function gamewin_geom__detect () {
  local VAR_TPL="$1"; shift
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  local PARSE="$SELFPATH"/gamewin_geom.parse_wmctrl.sed
  local GEOM="$(wmctrl -Gpxl | "$PARSE")"
  case "$GEOM" in
    *$'\npid\t'*$'\npid\t'* )
      echo "E: $FUNCNAME: Found too many MineTest windows." >&2
      return 3;;
    *$'\npid\t'* ) ;;
    * )
      echo "E: $FUNCNAME: Cannot find MineTest version in window title!" >&2
      return 3;;
  esac
  case "$VAR_TPL" in
    '' ) echo "$GEOM";;
    *'?'* | \
    *'&'* | \
    *'$'* | \
    *'^'* | \
    *'\'* )
      echo "E: $FUNCNAME: VAR_TPL contains unsupported characters." >&2
      return 3;;
    *'§'* ) <<<"$GEOM" sed -re "s?^(\S+)\t?${VAR_TPL//§/\\1}?";;
    * ) <<<"$GEOM" sed -re "s?^(\S+)\t?$VAR_TPL[\\1]=?";;
  esac
}


[ "$1" == --lib ] && return 0; gamewin_geom__"$@"; exit $?
