; For use with ARMIPS v0.7d
; By: psycommando@gmail.com
; 2020/11/17 - Updated 2023/9/11
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
	.include "na/levellistloader_arm9.asm"
	.include "na/actorlistloader_arm9.asm"
.elseif PPMD_GameVer == GameVer_EoS_EU
	.include "eu/levellistloader_arm9.asm"
	.include "eu/actorlistloader_arm9.asm"
.elseif PPMD_GameVer == GameVer_EoS_JP
	.include "jp/levellistloader_arm9.asm"
	.include "jp/actorlistloader_arm9.asm"
.endif

.relativeinclude off
