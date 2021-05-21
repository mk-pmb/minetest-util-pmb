#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function decide_minetest_invocation () {
  local MT_HOST="${CFG[host]}"
  local MT_PORT="${CFG[port]:-30_000}"
  MT_PORT="${MT_PORT//[,_]/}"
  local MT_USER="${CFG[user]:-Guest}"
  local MT_OPT=(
    # --info
    # --verbose
    )
  local MT_WORLD_NAME=
  if [ -n "$MT_HOST" ]; then
    MT_WORLD_NAME="$MT_HOST,$MT_PORT"
    mkdir --parents -- "worlds/$MT_WORLD_NAME"
    MT_OPT+=(
      --worldname "$MT_WORLD_NAME"
      --address "$MT_HOST"
      --port "$MT_PORT"
      --name "$MT_USER"
      )
  fi

  local MT_PSWD="${CFG[pswd]}"
  if [ -n "$MT_PSWD" ]; then
    exec 17< <(echo -n "$MT_PSWD")
    MT_OPT+=( --password-file /dev/fd/17 --go )
  fi

  local MT_PROG="$(which {~/.minetest/client/bin/,minetest} \
    |& grep -Pe '^/' -m 1)"
  [ -x "$MT_PROG" ] || return $?$(
    echo "E: unable to find a minetest client executable." >&2)

  [ -z "${CFG[nice]}" ] || MT_CMD+=( nice -n "${CFG[nice]}" )
  [ -z "$TRACE_LOG" ] || MT_CMD+=( strace-fyxo "$TRACE_LOG" )
  MT_CMD+=(
    $UNBUFFERED
    "$MT_PROG"
    "${MT_OPT[@]}"
    "${MT_EXTRA_ARGS[@]}"
    )

  echo -n "D: exec:"; printf ' ‹%s›' "${MT_CMD[@]}"; echo
}


function cfg_memlimit () {
  local MAX_MEM="${CFG[vmemlimit]}"
  local TOTAL_RAM="$(
    grep -m 1 -xPe 'MemTotal:\s+\d+ kB' -- /proc/meminfo | tr -cd 0-9)"
  [ -n "$TOTAL_RAM" ] || TOTAL_RAM=0
  case "$MAX_MEM" in
    unlimited | \
    '' ) return;;
    *[kK] ) MAX_MEM="${MAX_MEM%[kK]}";;
    *[mM] ) MAX_MEM="${MAX_MEM%[mM]} * 1024";;
    *% ) MAX_MEM="(${MAX_MEM%\%} * $TOTAL_RAM) / 100";;
  esac

  local MAX_KB=
  let MAX_KB="$MAX_MEM"
  [ "${MAX_KB:-0}" -ge 1 ] || return 4$(
    echo "E: Failed to parse or calculate memory limit" >&2)
  ulimit -v "$MAX_KB" || return $?
}


return 0
