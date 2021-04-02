#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function launch () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFFILE="$(readlink -m -- "$BASH_SOURCE")"
  local SELFPATH="$(dirname -- "$SELFFILE")"
  local SELFNAME="$(basename -- "$SELFFILE" .sh)"
  local INVOKED_AS="$(basename -- "$0" .sh)"
  local UNBUFFERED='stdbuf -i0 -o0 -e0'

  local -A CFG=()
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
  # cd only after parse_cli because parse_cli might need to read
  # files relative to the original cwd
  cd -- "$HOME/.minetest" || return $?

  local LOG_FN= TRACE_LOG=
  init_logfiles || return $?
  local MT_CMD=()
  decide_minetest_invocation || return $?
  cfg_memlimit || return $?

  ( sleep 2s; wmctrl -xFa Minetest.Minetest ) & disown $!
  exec &> >($UNBUFFERED tee -- "$LOG_FN")
  if [ "${CFG[de-noise]}" == + ]; then
    exec &> >("$SELFPATH"/denoise_console_output/denoise.sh)
  fi
  exec "${MT_CMD[@]}" || return $?
}







launch "$@"; exit $?
