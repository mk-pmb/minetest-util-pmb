#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function denoise_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  cd /

  local DENOISE='
    s~^(\S+ \S+: )VERBOSE(\[)~\1VRBS\2~
    s~^(\S+ \S+: [A-Z]+\[Main\]:) ~\1\f ~

    s~\f ClientEnvironment::processActiveObjectMessage(): got message for($\
      |) id=¹, which doesn\x27t exist~\r~

    s~^Loaded mesh: \S+\.(obj|b3d)$~\r~

    s~\f Adding "\S+" to combined ~\r~
    s~\f Audio: Error opening /~\r~
    s~\f Client: Detached inventory update: ~\r~
    s~\f Client: Loaded cached media: ~\r~
    s~\f Client: Storing model into memory: ~\r~
    s~\f Client::ActiveObjectMgr::(register|remove)Object~\r~
    s~\f Client::ReceiveAll(): Packet processing budget exceeded\.$~\r~
    s~\f Compiling high level shaders for ~\r~
    s~\f GenericCAO:[ :]~\r~
    s~\f getShaderIdDirect(): Returning id=¹ for name "~\r~
    s~\f Irrlicht: Loaded mesh: ~\r~
    s~\f Lazily creating item texture and mesh for "~\r~
    s~\f OpenALSoundManager: "\S+" not found\.$~\r~
    s~\f OpenALSoundManager: Creating positional playing sound$~\r~
    s~\f OpenALSoundManager::maintain(): ~\r~
    s~\f serialized form: ~\r~
    s~\f SourceImageCache::getOrLoad(): Loading path "/~\r~
    s~\f SourceShaderCache::getOrLoad(): Loading path ~\r~
    s~\f SourceShaderCache::getOrLoad(): No path found for "~\r~
    s~\f textures: ¹$~\r~
    s~\f textures\[¹\]: ~\r~

    /\r/d
    s~\f~~g
    '
  DENOISE="${DENOISE//\(\):/\\(\\):}"
  DENOISE="${DENOISE//¹/[0-9]+}"

  exec < <(sed -urf <(echo "$DENOISE"))
  local ORIG= DATE= TIME= MSG= PREV= REPEATS=0
  while read -r ORIG; do
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
