#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function reghelper_pswd1 () {
  local PW1="${CFG[pswd1]}"
  [ -n "$PW1" ] || return 0
  CFG[pswd]="${CFG[pswd1]}"
  unset CFG[pswd1]
  reghelper_pswd1__loop &
}


function reghelper_pswd1__loop () {
  local BTN='%MEDIA_PLAY:0,%CLOSE:9'
  BTN="${BTN//%/GTK_STOCK_}"
  local MSG=
  printf -v MSG '%s\n' \
    "Type password (length: ${#PW1}) for user '${CFG[user]}'?" \
    ''
    "• It might not be displayed in the password box." \
    "• You'll still need click the confirm button or press enter yourself." \
    ;
  local GX_CMD=(
    gxmessage
    -title 'MineTest password helper'
    -buttons "$BTN"
    -default "${BTN%%[:,]*}"
    -nofocus
    -ontop
    -file -
    )
  echo "${GX_CMD[@]}"
  while <<<"$MSG" "${GX_CMD[@]}"; do
    sleep 1s
    xdotool type "$PW1"
    sleep 2s
  done
}


return 0
