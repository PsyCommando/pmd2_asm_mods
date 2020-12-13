; For use with ARMIPS v0.7d
; By: psycommando@gmail.com
; 2020/11/17
; For Explorers of Sky All Versions
; ------------------------------------------------------------------------------
; Copyright © 2016 Guillaume Lavoie-Drapeau <psycommando@gmail.com>
; This work is free. You can redistribute it and/or modify it under the
; terms of the Do What The Fuck You Want To Public License, Version 2,
; as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
; ------------------------------------------------------------------------------

.relativeinclude on

; Selects the correct region to apply the patch
.if PPMD_GameVer == GameVer_EoS_NA
	.include "na/levellistloader_overlay11.asm"
	.include "na/actorlistloader_overlay11.asm"
.elseif PPMD_GameVer == GameVer_EoS_EU
	.include "eu/levellistloader_overlay11.asm"
	.include "eu/actorlistloader_overlay11.asm"
.endif

.relativeinclude off
