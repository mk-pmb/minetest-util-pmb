#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function maybe_homesym () {
  local LINK="$1"; shift
  [ -d "$HOME/$LINK" ] && return 0
  local DEST=
  for DEST in "$@" ''; do
    [ -n "$DEST" -a -d "$HOME/$DEST" ] && break
  done
  [ -n "$DEST" ] || return 3$(echo "E: not a directory: ~/$LINK," \
    "and neither are any of$(printf ' ~/%s' "$@")" >&2)

  local UP="${LINK//[^\/]/}"
  UP="${UP//\//../}"
  DEST="$UP$DEST"
  ln --verbose --symbolic --no-target-directory \
    -- "$DEST" "$HOME/$LINK" || return $?$(
    echo "E: failed to create symlink ~/$LINK -> $DEST" >&2)
  [ -d "$HOME/$LINK" ] && return 0

  echo -n "E: symlink was created but seems to not point to a directory: " >&2
  ls --color=always -dFl -- "$HOME/$LINK"
  return 4
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
