; For use with ARMIPS v0.7d
; By: psycommando@gmail.com
; 2016/08/16 - Updated 2023/09/11
; For Explorers of Sky Japan ONLY!
; ------------------------------------------------------------------------------
; Copyright © 2016 Guillaume Lavoie-Drapeau <psycommando@gmail.com>
; This work is free. You can redistribute it and/or modify it under the
; terms of the Do What The Fuck You Want To Public License, Version 2,
; as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
; ------------------------------------------------------------------------------
; All mods are in this!
.relativeinclude on
.nds
.arm
.definelabel PPMD_GameVer,    2       ;Symbol for telling the library we're compiled for EoS Japan "2"
.include "../cmn_eos.asm"

; ================
; === arm9.bin ===
; ================
.open "../../bin_src/arm9.bin", "../../bin_out/arm9.bin", 0x02000000 ;Always loaded at this offset
  ;--- Level list loader ---
  .include "levellistloader_arm9.asm"

  ;--- Actor list loader ---
  .include "actorlistloader_arm9.asm"
.close ;Close arm9.bin

; ========================
; === overlay_0010.bin ===
; ========================
.open "../../bin_src/overlay_0010.bin", "../../bin_out/overlay/overlay_0010.bin", 0x022BE220 ;EoS JP because can't replace at compilation!
.close ;Close overlay_0010.bin

; ========================
; === overlay_0011.bin ===
; ========================
.open "../../bin_src/overlay_0011.bin", "../../bin_out/overlay/overlay_0011.bin", 0x022DD8E0 ;EoS JP because can't replace at compilation!
  ; --- Level list loader ---
  .include "levellistloader_overlay11.asm"

  ;--- Actor list loader ---
  .include "actorlistloader_overlay11.asm"
.close ;Close overlay_0011.bin

; ========================
; === overlay_0013.bin ===
; ========================
.open "../../bin_src/overlay_0013.bin", "../../bin_out/overlay/overlay_0013.bin", 0x0238B6A0 ;EoS JP because can't replace at compilation!
.close ;Close overlay_0013.bin
