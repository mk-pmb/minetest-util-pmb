#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function init_logfiles () {
  local LOGS_DIR='client/logs/'
  local SUB_BFN=
  printf -v SUB_BFN '%(%y%m%d/%H%M%S)T.%s.%s' -1 $$ "${CFG[user]}@${CFG[host]}"
  local LINK_BFN="$LOGS_DIR"latest.

  LOG_FN="$LOGS_DIR$SUB_BFN.log"
  init_one_logfile "$LOG_FN" || return $?

  TRACE_LOG="${CFG[tracelog]}"
  [ "$TRACE_LOG" == + ] && TRACE_LOG="$LOGS_DIR$SUB_BFN.trc"
  [ -z "$TRACE_LOG" ] || init_one_logfile "$TRACE_LOG" || return $?
}


function init_one_logfile () {
  local DEST="$1"; shift
  FEXT="${DEST##*.}"
  local LOG_LINK="${LOGS_DIR}latest.$FEXT"
  [ -L "$LOG_LINK" ] && rm -- "$LOG_LINK"
  local REL_SUB="${DEST:${#LOGS_DIR}}"
  REL_SUB="${REL_SUB%/}"
  ln --symbolic --no-target-directory -- "$REL_SUB" "$LOG_LINK" || return $?
  mkdir --parents -- "$(dirname -- "$DEST")"
  >>"$DEST" || return $?
  chmod a=,ug+rw -- "$DEST" || return $?
}


return 0
