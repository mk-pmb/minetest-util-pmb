#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function parse_cli () {
  local ARG=
  while [ "$#" -ge 1 ]; do
    ARG="$1"; shift
    case "$ARG" in
      -- ) break;;
      --noisy ) CFG[de-noise]=;;
      --cfg:* ) CFG["${ARG#*:}"]="$1"; shift;;
      -* ) echo "E: unsupported CLI argument: $ARG" >&2; return 3;;
      *.rc )
        source -- "$ARG" || return $?$(
          echo "E: failed to source config file '$ARG'" >&2)
        ;;
      * ) echo "E: unsupported CLI argument: $ARG" >&2; return 3;;
    esac
  done
  MT_EXTRA_ARGS+=( "$@" )
}

return 0
