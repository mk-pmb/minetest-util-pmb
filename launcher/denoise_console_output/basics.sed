#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

s~^(\S+ \S+: )VERBOSE(\[)~\1VRBS\2~

# ===== BEGIN "Main" messages =====
s~^(\S+ \S+: [A-Z]+\[Main\]:) ~\1\f ~

s~\f ClientEnvironment::processActiveObjectMessage\(\): got message for($\
  |) id=[0-9]+, which doesn\x27t exist~\r~
s~\f Source(Image|Shader)Cache::getOrLoad\(\): ($\
  |Loading path|No path found for) "/~\r~

s~^Loaded mesh: \S+\.(obj|b3d)$~\r~

s~\f Adding "\S+" to combined ~\r~
s~\f Audio: Error opening /~\r~
s~\f Client: Detached inventory update: ~\r~
s~\f Client: Loaded (cached|received) media: ~\r~
s~\f Client: Received files: bunch ~\r~
s~\f Client: Storing model into memory: ~\r~
s~\f Client::ActiveObjectMgr::(register|remove)Object~\r~
s~\f Client::ReceiveAll\(\): Packet processing budget exceeded\.$~\r~
s~\f Compiling high level shaders for ~\r~
s~\f FileCache: File not found in cache: ~\r~
s~\f generateImage\(\): Could not load image "[^"]+" while building texture; Creating a dummy image$~\r~
s~\f GenericCAO:[ :]~\r~
s~\f getShaderIdDirect\(\): Returning id=[0-9]+ for name "~\r~
s~\f Irrlicht: Loaded mesh: ~\r~
s~\f Irrlicht: PNG warning: ~\r~
s~\f Lazily creating item texture and mesh for "~\r~
s~\f NodeDefManager: registering content id ~\r~
s~\f OpenALSoundManager: "\S+" not found\.$~\r~
s~\f OpenALSoundManager: Creating positional playing sound$~\r~
s~\f OpenALSoundManager::maintain\(\): ~\r~
s~\f serialized form: ~\r~
s~\f Texture "[^"]+" of \S+ has transparency, assuming use_texture_alpha = ~\r~
s~\f textures: [0-9]+$~\r~
s~\f textures\[[0-9]+\]: ~\r~


s~\f Server: ignoring unsupported file extension: "\S+\.($\
  |blend|$\
  |txt|$\
  )"$~\r~

s~\f Server: [0-9a-f]{40} is \S+\.($\
  |b3d|$\
  |obj|$\
  |ogg|$\
  |png|$\
  |tr|$\
  )$~\r~

s~\f~~g
# ===== ENDOF "Main" messages =====



s~^\S+ \S+: VRBS\[ConnectionSend\]: con\([0-9/]+\)($\
  |)RE-SENDING timed-out RELIABLE to ~\r~


# ===== BEGIN "Server" messages =====
s~^(\S+ \S+: [A-Z]+\[Server\]:) ~\1\f ~

s~\f Server::sendRequestedMedia\(\): bunch ~\r~
s~\f TOSERVER_REQUEST_MEDIA: requested file ~\r~
s~\f Client: Loaded received media: ~\r~

s~\f~~g
# ===== ENDOF "Server" messages =====


/\r/d
