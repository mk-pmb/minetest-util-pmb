#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function denoise_main () {
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly

  exec < <("$SELFPATH"/basics.sed -- "$@")
  local ORIG= DATE= TIME= MSG= PREV= REPEATS=0
  while IFS= read -r ORIG; do
    [ -n "$ORIG" ] || continue
    MSG="$ORIG"
    DATE="${MSG%% *}"; MSG="${MSG#* }"
    TIME="${MSG%%: *}"; MSG="${MSG#*: }"
    if [ "$MSG" == "$PREV" ]; then
      (( REPEATS += 1 ))
      continue
    fi

    [ "$REPEATS" -ge 2 ] && echo "    ^ × $REPEATS"
    REPEATS=0
    PREV=

    echo "$ORIG"
    PREV="$MSG"
  done
}


denoise_main "$@"; exit $?
