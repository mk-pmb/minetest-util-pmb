#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function texcmp_sshot () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  local DEST="${1:-minetest}"; shift
  DEST+='.%y%m%d-%H%M%S'
  local SC_CMD=(
    scrot
    --focused
    --silent
    )
  add_cfg_hints || return $?
  DEST+='.png'
  "${SC_CMD[@]}" -- "$DEST" || return $?
}


function add_cfg_hints () {
  local MT_CFG_FILE="$HOME"/.minetest/minetest.conf
  local CFG_SED="$SELFPATH/src/texcmp_sshot.cfg_hints.sed"
  local CFG_HINTS="$(LANG=C sed -nrf "$CFG_SED" -- "$MT_CFG_FILE" \
    | LANG=C tr -sc 'A-Za-z0-9_=\+\. \n\-' _ \
    | LANG=C sort --version-sort | LANG=C sed -re 's!^[a-z] !!')"
  if [ -z "$CFG_HINTS" ]; then
    echo "W: No interesting config data found in $MT_CFG_FILE" >&2
    return 0
  fi
  # nl -ba <<<"$CFG_HINTS"
  CFG_HINTS="${CFG_HINTS//[$'\n ']/}"
  DEST+="$CFG_HINTS"

  local NOTE="-x 2 -y 2"
  NOTE+=" -c 128,128,128,128"
  NOTE+=" -f 'monospace/8'"
  NOTE+=" -t '${CFG_HINT#\.}'"
  # SC_CMD+=( --note "$NOTE" )
}




texcmp_sshot "$@"; exit $?
