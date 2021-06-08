#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function parse_cli () {
  local ARG=
  while [ "$#" -ge 1 ]; do
    ARG="$1"; shift
    case "$ARG" in
      -- ) break;;
      --noisy ) CFG[de-noise]=;;

      --gamewin-geom ) CFG[task]='gamewin_geom__detect';;
      -n | --no-launch ) CFG[task]='true';;

      -Q | --digmode=quick  ) set_mt_ini_opt safe_dig_and_place=false;;
      -1 | --digmode=one    ) set_mt_ini_opt safe_dig_and_place=true;;

      --host | \
      --port | \
      --user | \
      --cfg:* )
        ARG="${ARG#--}"
        ARG="${ARG#*:}"
        CFG["$ARG"]="$1"
        shift;;

      -* ) echo "E: unsupported CLI argument: $ARG" >&2; return 3;;
      *.rc )
        cli_source_config "$ARG" || return $?$(
          echo "E: failed to source config file '$ARG'" >&2)
        ;;
      * ) echo "E: unsupported CLI argument: $ARG" >&2; return 3;;
    esac
  done
  CLI_EXTRA_ARGS+=( "$@" )
}


function cli_source_config () {
  local CFG_FN="$1"; shift
  local CFG_DIR="$(readlink -m -- "$CFG_FN"/..)"
  source -- "$CFG_FN" || return $?
}


function set_mt_ini_opt () {
  local CFG="$HOME"/.minetest/minetest.conf
  local UPD="$HOME"/.minetest/tmp.upd-$$.minetest.conf
  local SED= KEY= VAL=
  for VAL in "$@"; do
    KEY="${VAL%%=*}"
    VAL="${VAL#*=}"
    SED+="/^$KEY *=/d"$'\n'
  done
  SED+='s~\s+$~~'
  VAL="$(sed -rf <(echo "$SED") -- "$CFG")" || return $?
  VAL+="$(printf '\n%s' "${@/=/ = }")"
  <<<"$VAL" sort --version-sort >"$UPD" || return $?
  mv --no-target-directory -- "$UPD" "$CFG" || return $?
}


return 0
