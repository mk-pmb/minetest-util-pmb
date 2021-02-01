#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function launch () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFFILE="$(readlink -m -- "$BASH_SOURCE")"
  local SELFPATH="$(dirname -- "$SELFFILE")"
  local SELFNAME="$(basename -- "$SELFFILE" .sh)"
  local INVOKED_AS="$(basename -- "$0" .sh)"

  maybe_homesym .minetest \
    .config/minetest/userpath \
    || return $?
  maybe_homesym .cache/minetest \
    .config/minetest/cache \
    || return $?
  [ "$*" == --symlinks-only ] && return 0

  local -A CFG=(
    [vmemlimit]='100%'
    )
  local MT_EXTRA_ARGS=()
  parse_cli "$@" || return $?

  # cd -- "$SELFPATH" || return $?
  cd -- "$HOME/.minetest" || return $?
  local MT_HOST="${CFG[host]}"
  local MT_PORT="${CFG[port]:-30000}"
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

  local LOG_FN= TRACE_LOG=
  init_logfiles || return $?

  local MT_PROG="$(which {~/.minetest/client/bin/,minetest} \
    |& grep -Pe '^/' -m 1)"
  [ -x "$MT_PROG" ] || return $?$(
    echo "E: unable to find a minetest client executable." >&2)

  cfg_memlimit || return $?

  local UNBUFFERED='stdbuf -i0 -o0 -e0'
  local MT_CMD=(
    nice -n 10
    strace-fyxo "$HOME"/.minetest/trace.txt
    $UNBUFFERED
    "$MT_PROG"
    "${MT_OPT[@]}"
    "${MT_EXTRA_ARGS[@]}"
    )
  echo -n "D: exec:"; printf ' ‹%s›' "${MT_CMD[@]}"; echo
  ( sleep 2s; wmctrl -xFa Minetest.Minetest ) & disown $!
  exec &> >("$SELFPATH"/denoise_console_output/denoise.sh \
    | $UNBUFFERED tee -- "$LOG_FN")
  exec "${MT_CMD[@]}" || return $?
}


function maybe_homesym () {
  local LINK="$1"; shift
  [ -d "$HOME/$LINK" ] && return 0
  local DEST=
  for DEST in "$@" ''; do
    [ -n "$DEST" -a -d "$HOME/$DEST" ] && break
  done
  [ -z "$DEST" ] || ln --verbose --symbolic --no-target-directory \
    -- "$HOME/$DEST" "$HOME/$LINK" || return $?$(
    echo "E: failed to create symlink ~/$LINK -> ~/$DEST" >&2)
  [ -d "$HOME/$LINK" ] && return 0
  DEST=" $*"
  DEST="${DEST// / ~/}"
  echo "E: not a directory: ~/$LINK, and neither are any of$DEST" >&2
  return 3
}


function parse_cli () {
  local ARG=
  while [ "$#" -ge 1 ]; do
    ARG="$1"; shift
    case "$ARG" in
      -- ) break;;
      --cfg ) CFG["$1"]="$2"; shift 2;;
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


function init_logfiles ()
  local LOGS_DIR='client/logs/'
  local SUB_BFN=
  printf -v SUB_BFN '%(%y%m%d/%H%M%S)T.%s.%s' -1 $$ "$MT_USER@$MT_HOST"
  local LINK_BFN="$LOGS_DIR"/latest.

  LOG_FN="$LOGS_DIR/$SUB_BFN.log"
  init_one_logfile "$LOG_FN" || return $?

  TRACE_LOG="${CFG[tracelog]}"
  [ "$TRACE_LOG" == + ] && TRACE_LOG="$LOGS_DIR/$SUB_BFN.trc"
  [ -z "$TRACE_LOG" ] || init_one_logfile "$TRACE_LOG" || return $?
}


function init_one_logfile () {
  local DEST="$1"; shift
  FEXT="${DEST##*.}"
  local LOG_LINK="${LOGS_DIR}latest.$FEXT"
  [ -L "$LOG_LINK" ] && rm -- "$LOG_LINK"
  ln --symbolic --no-target-directory -- "$DEST" "$LOG_LINK" || return $?
  mkdir --parents -- "$(dirname -- "$DEST")"
  >>"$DEST" || return $?
  chmod a=,ug+rw -- "$DEST" || return $?
}















launch "$@"; exit $?
