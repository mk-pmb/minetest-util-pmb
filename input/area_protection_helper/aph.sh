#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function aph_cli () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local -A AREA=()
  load_area_config__outer "$@" || return $?
  remove_areas || return $?
  register_area || return $?
}


function load_area_config__outer () {
  # Run config file in a subprocess so it doesn't need to care about
  # name conflicts for variables and functions.
  local DATA=()
  readarray -t DATA < <(load_area_config__inner "$@")
  local KEY= VAL=
  for VAL in "${DATA[@]}"; do
    KEY="${VAL%%=*}"
    [ "$KEY" == "$VAL" ] && continue
    VAL="${VAL#*=}"
    [ -n "$KEY" ] || continue
    AREA["$KEY"]="$VAL"
  done
}


function load_area_config__inner () {
  local -A AREA=()
  source -- "$@"
  local KEY=
  for KEY in "${!AREA[@]}"; do
    echo "$KEY=${AREA[$KEY]}"
  done
}


function remove_areas () {
  local LIST=()
  readarray -t LIST <<<"${AREA[remove]//[^0-9]/$'\n'}"
  local A_ID=
  for A_ID in "${LIST[@]}"; do
    [ "${A_ID:-0}" -ge 1 ] || continue
    chat_send_cmd remove_area "$A_ID" || return $?
  done
}


function chat_send_cmd () {
  echo "$FUNCNAME: $*"
  xdotool type /
  sleep 0.1s
  xdotool type "$*"
  sleep 0.4s
  xdotool key Return
  sleep 0.1s
}


function register_area () {
  [ -n "${AREA[name]}" ] || return 0
  chat_send_cmd area_pos1 "${AREA[x1]},${AREA[y1]},${AREA[z1]}" || return $?
  chat_send_cmd area_pos2 "${AREA[x2]},${AREA[y2]},${AREA[z2]}" || return $?
  chat_send_cmd protect "${AREA[name]}" || return $?
  # Don't spam chat log even more with:
  #     chat_send_cmd area_pos1 0,0,0 || return $?
  #     chat_send_cmd area_pos2 0,0,0 || return $?
  # Instead, you can get rid of the block markers by just smashing them.
}








aph_cli "$@"; exit $?
