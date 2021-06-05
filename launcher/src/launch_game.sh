#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function launch_game () {
  # cd only after parse_cli because parse_cli might need to read
  # files relative to the original cwd
  cd -- "$HOME/.minetest" || return $?

  reghelper_pswd1 || return $?
  local LOG_FN= TRACE_LOG=
  init_logfiles || return $?
  local MT_CMD=()
  decide_minetest_invocation || return $?
  cfg_memlimit || return $?

  ( sleep 2s; wmctrl -xFa Minetest.Minetest ) & disown $!
  exec &> >($UNBUFFERED tee -- "$LOG_FN")
  if [ "${CFG[de-noise]}" == + ]; then
    exec &> >("$SELFPATH"/denoise_console_output/denoise.sh)
  fi
  exec "${MT_CMD[@]}" || return $?
}


return 0
