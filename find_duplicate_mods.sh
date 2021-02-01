#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function find_duplicate_mods () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local MODS_DIR="${1:-"$HOME"/.minetest/mods}"
  cd -- "$MODS_DIR/" || return $?
  local -A MODS_WHERE=()
  exec < <(find -L [0-9A-Za-z]* -type f -name mod.conf | sort --version-sort)
  local KEY= VAL=
  while IFS= read -r VAL; do
    VAL="${VAL%/*}"
    KEY="${VAL##*/}"
    VAL="${VAL%/*}"
    MODS_WHERE["$KEY"]+="$VAL"$'\n'
  done
  exec < <(printf '%s\n' "${!MODS_WHERE[@]}")
  while IFS= read -r KEY; do
    [ -n "$KEY" ] || continue
    VAL="${MODS_WHERE["$KEY"]}"
    VAL="${VAL%$'\n'}"
    printf '%s\t' "$(<<<"$VAL" wc --lines)"
    VAL="${VAL//$'\n'/ }"
    printf '%s\t%s\n'  "$KEY" "$VAL"
  done | sort --version-sort
}


find_duplicate_mods "$@"; exit $?
