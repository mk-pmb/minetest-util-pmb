#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function launcher_cli () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFFILE="$(readlink -m -- "$BASH_SOURCE")"
  local SELFPATH="$(dirname -- "$SELFFILE")"
  local SELFNAME="$(basename -- "$SELFFILE" .sh)"
  local INVOKED_AS="$(basename -- "$0" .sh)"
  local UNBUFFERED='stdbuf -i0 -o0 -e0'

  local -A CFG=(
    [task]='launch_game'
    )
  local DBGLV="${DEBUGLEVEL:-0}"
  local MT_EXTRA_ARGS=()
  local ITEM=
  for ITEM in "$SELFPATH"/src/*.sh; do
    source -- "$ITEM" || return $?
  done
  source -- "$SELFPATH"/cfg_default.rc || return $?

  default_homesyms || return $?
  [ "$*" == --symlinks-only ] && return 0

  parse_cli "$@" || return $?
  "${CFG[task]}" || return $?
}


launcher_cli "$@"; exit $?
