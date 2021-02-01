#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function find_duplicate_mods () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  if [ "$#" == 0 ]; then
    MOD_DIRS=(
      {"$HOME"/.,/usr/share/}minetest/{mods,client-mods,games}/
      )
    "$FUNCNAME" "${MOD_DIRS[@]}"
    return $?
  fi

  local MOD_DIRS=()
  local KEY= VAL=
  for VAL in "$@"; do
    [ -d "$VAL" ] && MOD_DIRS+=( "$VAL" )
  done

  local -A MODS_WHERE=()
  exec < <(find -L "${MOD_DIRS[@]}" \
    -name '.*' -prune , \
    -path '*/games/devtest/mods' -prune , \
    -type f -name mod.conf | sort --version-sort)
  while IFS= read -r VAL; do
    VAL="${VAL%/*}"
    KEY="$(basename -- "$VAL")"
    VAL="$(dirname -- "$VAL")"
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
