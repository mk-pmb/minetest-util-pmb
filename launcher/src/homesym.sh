#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


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


function default_homesyms () {
  maybe_homesym .minetest \
    .config/minetest/userpath \
    || return $?
  maybe_homesym .cache/minetest \
    .config/minetest/cache \
    || return $?
}


return 0
