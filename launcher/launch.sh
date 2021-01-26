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

  local -A CFG=()
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

  local LOG_FN=
  printf -v LOG_FN 'client/logs/%(%y%m%d/%H%M%S)T.%s.%s.log' \
    -1 $$ "$MT_USER@$MT_HOST"
  mkdir --parents -- "$(dirname -- "$LOG_FN")"
  >>"$LOG_FN" || return $?
  chmod a=,ug+rw -- "$LOG_FN" || return $?

  local MT_PROG="$(which {~/.minetest/client/bin/,minetest} \
    |& grep -Pe '^/' -m 1)"
  [ -x "$MT_PROG" ] || return $?$(
    echo "E: unable to find a minetest client executable." >&2)

  local MT_CMD=(
    stdbuf -i0 -o0 -e0
    "$MT_PROG"
    "${MT_OPT[@]}"
    "${MT_EXTRA_ARGS[@]}"
    )
  echo -n "D: exec:"; printf ' ‹%s›' "${MT_CMD[@]}"; echo
  ( sleep 2s; wmctrl -xFa Minetest.Minetest ) & disown $!
  exec &> >("$SELFPATH"/denoise_console_output/denoise.sh \
    | stdbuf -i0 -o0 -e0 tee -- "$LOG_FN")
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











launch "$@"; exit $?
