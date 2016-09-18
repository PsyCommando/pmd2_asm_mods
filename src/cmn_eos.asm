;; For use with ARMIPS v0.7d
; By: psycommando@gmail.com
; 2016/08/18
; This is meant to be used for writing a set of common routines, at the offset
; the including file is at.
; ------------------------------------------------------------------------------
; Copyright © 2016 Guillaume Lavoie-Drapeau <psycommando@gmail.com>
; This work is free. You can redistribute it and/or modify it under the
; terms of the Do What The Fuck You Want To Public License, Version 2,
; as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
; ------------------------------------------------------------------------------
.ifndef CMN_EOS_ARM
.definelabel CMN_EOS_ARM, 1

.relativeinclude on
.nds
.arm
.notice "Included PPMD common library"

; Use these to define the current game version label "PPMD_GameVer",
;  and have the library setup for that game's offsets!
.definelabel GameVer_EoS_NA, 0
.definelabel GameVer_EoS_EU, 1
.definelabel GameVer_EoS_JP, 2
;#TODO: Add more game versions.

;
; Include the correct file with the correct offsets for the correct game version
;
.if (PPMD_GameVer == GameVer_EoS_NA)
  .include "cmn_eos_na.asm"
.elseif (PPMD_GameVer == GameVer_EoS_EU)
  .include "cmn_eos_eu.asm"
.elseif (PPMD_GameVer == GameVer_EoS_JP)
  .include "cmn_eos_jp.asm"
.else

  .ifndef PPMD_GameVer
    .error "cmn_eos.asm: The label with the current game version, PPMD_GameVer, was not defined!!"
  .else
    .error "cmn_eos.asm: The PPMD_GameVer label was defined, but contains an unknown game version!"
  .endif

.endif

.endif ;CMN_EOS_ARM
