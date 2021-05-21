#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function parse_cli () {
  local ARG=
  while [ "$#" -ge 1 ]; do
    ARG="$1"; shift
    case "$ARG" in
      -- ) break;;
      --noisy ) CFG[de-noise]=;;

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
  MT_EXTRA_ARGS+=( "$@" )
}


function cli_source_config () {
  local CFG_FN="$1"; shift
  local CFG_DIR="$(readlink -m -- "$CFG_FN"/..)"
  source -- "$CFG_FN" || return $?
}


return 0
