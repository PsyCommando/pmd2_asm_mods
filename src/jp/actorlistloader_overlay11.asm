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
;Meant to be included inside the overlay_0011.bin file!
.relativeinclude on
.nds
.arm

;-------------------------------------
; 0x22F94FC Hook
;-------------------------------------
.org 0x22F9588 ; OK
.area 28
  ;ldr     r7,=20A7FF0h
  ;mov     r12,0Ch
  ldr     r1,=2322ED8h        ;Don't Change this! ;"GroundLives Locate id %3d  kind %3d  index %3d" ; OK
  mov     r2,r9               ;Don't Change this!
  str     r4,[r13]            ;Don't Change this!
  ;smlabb  r4,r3,r12,r7
  mov     r0,r3
  bl      ActorAccessor
  mov     r4,r0
  mov     r0,1h               ;Don't Change this!
.endarea
.org 0x22F9A64      ;Can replace address to actor table in datapool
.area 4
  .pool
    .fill (0x22F9A64 + 4) - .,0
.endarea

;-------------------------------------
; 0x22FA29C Hook
;-------------------------------------
.org 0x22FA2EC ; OK
.area 4
  nop       ;022FA2EC E59FB1F4 ldr     r11,=20A7FF0h
.endarea
.org 0x22FA354 ; OK
.area 12
  mov     r0,r1           ;022FA354 E3A0000C mov     r0,0Ch
  bl      ActorAccessor   ;022FA358 E1600081 smulbb  r0,r1,r0
  ldrsh   r0,[r0]         ;022FA35C E19B00F0 ldrsh   r0,[r11,r0]
.endarea
.org 0x22FA4E8    ;Can replace address to actor table in datapool ; OK
.area 4
  .pool
  .fill (0x22FA4E8 + 4) - .,0 ; OK
.endarea
