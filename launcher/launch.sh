#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function launch () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFFILE="$(readlink -m -- "$BASH_SOURCE")"
  local SELFPATH="$(dirname -- "$SELFFILE")"
  local SELFNAME="$(basename -- "$SELFFILE" .sh)"
  local INVOKED_AS="$(basename -- "$0" .sh)"

  # cd -- "$SELFPATH" || return $?
  cd -- "$HOME/.minetest" || return $?

  local -A CFG=( [cfg_file]="$1" ); shift
  [ -z "${CFG[cfg_file]}" ] \
    || source -- "${CFG[cfg_file]}" || return $?$(
    echo "E: failed to source config file '${CFG[cfg_file]}'" >&2)

  local MT_HOST="${CFG[host]}"
  local MT_PORT="${CFG[port]:-30000}"
  local MT_USER="${CFG[user]:-Guest}"
  local MT_OPTS=(
    # --info
    --verbose
    )
  local MT_WORLD_NAME=
  if [ -n "$MT_HOST" ]; then
    MT_WORLD_NAME="$MT_HOST,$MT_PORT"
    mkdir --parents -- "worlds/$MT_WORLD_NAME"
    MT_OPTS+=(
      --worldname "$MT_WORLD_NAME"
      --address "$MT_HOST"
      --port "$MT_PORT"
      --name "$MT_USER"
      )
  fi

  local MT_PSWD="${CFG[pswd]}"
  if [ -n "$MT_PSWD" ]; then
    exec 17< <(echo -n "$MT_PSWD")
    MT_OPTS+=( --password-file /dev/fd/17 --go )
  fi

  local LOG_FN=
  printf -v LOG_FN 'client/logs/%(%y%m%d/%H%M%S)T.%s.%s.log' \
    -1 $$ "$MT_USER@$MT_HOST"
  mkdir --parents -- "$(dirname -- "$LOG_FN")"
  >>"$LOG_FN" || return $?
  chmod a=,ug+rw -- "$LOG_FN" || return $?
  exec &> >("$SELFPATH"/denoise_console_output/denoise.sh \
    | stdbuf -i0 -o0 -e0 tee -- "$LOG_FN")

  exec minetest "${MT_OPTS[@]}" || return $?
}






launch "$@"; exit $?
