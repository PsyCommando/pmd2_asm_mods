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
.relativeinclude on
.nds
.arm

;-------------------------------------
; Hook 022DFC0C
;-------------------------------------
  .org 0x22DFC0C ; OK
  .area 24  ;We have 24 bytes here
    ldrsh   r3,[r0,8h]
    mov     r0,r3
    bl LevelListSecondHWORDGet;ldr     r2,=20A6896h ; OK
    mov     r2,r0
    mov     r0,0h ;smulbb  r1,r3,r1
    nop ;ldrsh   r2,[r2,r1]
  .endarea

;-------------------------------------
; Hook 022F2998
;-------------------------------------
  .org 0x22F2998 ; OK
  .area 0x14  ;We have 20 bytes here
    ;Prepare the parameter for the accessor
    mov     r0,r5               ;022F2998 E3A0000C mov     r0,0Ch
    bl      LevelListAccessor   ;022F299C E1630085 smulbb  r3,r5,r0
    mov     r4,r0               ;022F29A0 E59F41E4 ldr     r4,=20A6894h
    ldrsh   r0,[r4]             ;022F29A4 E19400F3 ldrsh   r0,[r4,r3]
    nop                         ;022F29A8 E0844003 add     r4,r4,r3
  .endarea
  .org 0x22F2B8C         ;We need to modify the address here, to use it for our bl above! ; OK
  .area 4
    .pool
  .endarea

;-------------------------------------
; Hook 022F2C4C
;-------------------------------------
  .org 0x22F2C4C ; OK
  .area 0x14
    ;Prepare the parameter for the accessor
    mov     r0,r8                 ;022F2C4C E3A0000C mov     r0,0Ch
    bl      LevelListAccessor     ;022F2C50 E1610088 smulbb  r1,r8,r0
    mov     r4,r0                 ;022F2C54 E59F20EC ldr     r2,=20A6894h
    ldrsh   r0,[r4]               ;022F2C58 E19200F1 ldrsh   r0,[r2,r1]
    nop                           ;022F2C5C E0824001 add     r4,r2,r1
  .endarea
  .org 0x22F2D48 ; OK
  .area 4
    .pool
  .endarea

  ;-------------------------------------
  ; Hook 022F2DA4
  ;-------------------------------------
  .org 0x22F2DA4 ; OK
  .area 24
    mov     r0,r4               ;022F2DA4 E59F1034 ldr     r1,=20A6894h   //<-change       //Level list beg
    ldr     r3,[r2,4h]          ;!! Don't touch !!
    bl      LevelListAccessor   ;022F2DAC E3A0000C mov     r0,0Ch
    strh    r4,[r3]             ;!! Don't touch !!
    ldrsh   r1,[r0,4h]          ;022F2DB4 E1001084 smlabb  r0,r4,r0,r1
    nop                         ;022F2DB8 E1D010F4 ldrsh   r1,[r0,4h]
  .endarea
  .org 0x22F2DE0
  .area 4
    .pool
  .endarea

  ;-------------------------------------
  ; Hook 0x22F2E00 - This one caused misalignment in the stack!!
  ;-------------------------------------
  .org 0x22F2E00 ; OK
  .area (0x22F2E30 - 0x22F2E00) ; OK
    push r14                  ;022F2E00 E59F0024 ldr     r0,=2326220h
    ldr     r0,=2326220h       ;022F2E04 E5900004 ldr     r0,[r0,4h] ; OK
    ldr     r0,[r0,4h]         ;022F2E08 E3500000 cmp     r0,0h
    cmp     r0,0h              ;022F2E0C 03E00000 mvneq   r0,0h
    mvneq   r0,0h              ;022F2E10 012FFF1E bxeq    r14
    popeq   r15                ;022F2E14 E1D020F0 ldrsh   r2,[r0]

    ldrsh   r0,[r0]           ;022F2E18 E3A0000C mov     r0,0Ch
    bl      LevelListAccessor ;022F2E1C E59F100C ldr     r1,=20A6894h
    ldrsh   r0,[r0]           ;022F2E20 E1600082 smulbb  r0,r2,r0
    pop     r15               ;022F2E24 E19100F0 ldrsh   r0,[r1,r0]
    .pool                     ;022F2E28 E12FFF1E bx      r14
    ;.fill   (0x22F2E00 + 0x22F2E30) - . ;022F17E0 02326220 eoreqs  r4,r2,0C000h
    ;022F2E30 020A5488 andeq   r5,r10,88000000h
  .endarea

  ;-------------------------------------
  ; Hook 022F35B4
  ;-------------------------------------
  .org 0x22F35B4 ; OK
  .area 20
    nop ;mov     r0,r4             ;022F35B4 E3A0300C mov     r3,0Ch
    mov     r1,r7             ;!! Don't Touch !!
    mov     r2,r6             ;!! Don't Touch !!
    bl      LevelListCustomHook022F35B4 ;022F35C0 E1640384 smulbb  r4,r4,r3 ;;<== Custom hook for this one since we don't have much space, and a lot of registers are in use!
    nop ;022F35C4 E59F50C8 ldr     r5,=20A6894h ;;;Put the result into r4 since r0 gets overwritten several times after, not r4 and r5
  .endarea
  .org 0x22F3624 ; OK
  .area 4
    ldrsh   r0,[r4]           ;022F3624 E19500F4 ldrsh   r0,[r5,r4]
  .endarea
  .org 0x22F3694 ; OK
  .area 4
    .pool
  .endarea

  ;-------------------------------------
  ; Hook 0230105C
  ;-------------------------------------
  .org 0x230105C ; OK
  .area 24
    push r14
    mov     r0,r1                 ;0230105C E59F200C ldr     r2,=20A6894h
    bl      LevelListAccessor     ;02301060 E3A0000C mov     r0,0Ch
    ldr     r0,[r0,8h]            ;02301064 E0202091 mla     r0,r1,r0,r2
    ;bx      r14                   ;02301068 E5900008 ldr     r0,[r0,8h]
    pop r15
    .pool                         ;0230106C E12FFF1E bx      r14
    ;02301070 020A5488 andeq   r5,r10,88000000h
  .endarea

  ;-------------------------------------
  ; Hook 0x23116B4
  ;-------------------------------------
  .org 0x23116B4 ; OK
  .area 20
    mov     r0,r5             ;023116B4 E3A0000C mov     r0,0Ch
    bl      LevelListAccessor ;023116B8 E1610085 smulbb  r1,r5,r0
    mov     r4,r0             ;023116BC E59F3210 ldr     r3,=20A6894h
    ldrsh   r0,[r4]           ;023116C0 E19300F1 ldrsh   r0,[r3,r1]
    nop                       ;023116C4 E0834001 add     r4,r3,r1
  .endarea
  .org 0x23118D4 ; OK
  .area 4
    .pool
  .endarea

  ;-------------------------------------
  ; Hook 0x23123C8
  ;-------------------------------------
  .org 0x23123C8 ; OK
  .area 4
    nop     ;023123C8 E3A0000C mov     r0,0Ch        //<-change
  .endarea
  ;023123CC E2811902 add     r1,r1,8000h
  ;023123D0 E5861000 str     r1,[r6]
  ;023123D4 E5962004 ldr     r2,[r6,4h]
  .org 0x23123D8 ; OK
  .area 4
    nop     ;023123D8 E1610084 smulbb  r1,r4,r0      //<-change
  .endarea
  ;023123DC E2820A06 add     r0,r2,6000h
  ;023123E0 E5860004 str     r0,[r6,4h]
  ;023123E4 E5952000 ldr     r2,[r5]
  .org 0x23123E8 ; OK
  .area 4
    mov     r0,r4  ;023123E8 E59F0080 ldr     r0,=20A6894h  //<-change
  .endarea
  ;023123EC E2422902 sub     r2,r2,8000h
  ;023123F0 E5852000 str     r2,[r5]
  ;023123F4 E5952004 ldr     r2,[r5,4h]
  .org 0x23123F8
  .area 4
    bl    LevelListFirstHWORDGet ;023123F8 E19000F1 ldrsh   r0,[r0,r1]    //<-change
  .endarea
  .org 0x2312470
  .area 4
    .pool
  .endarea

  ;-------------------------------------
  ; Hook 0x23126B8
  ;-------------------------------------
  .org 0x23126B8 ; OK
  .area 20
    mov     r0,r5             ;023126B8 E3A0000C mov     r0,0Ch
    bl      LevelListAccessor ;023126BC E1610085 smulbb  r1,r5,r0
    mov     r4,r0             ;023126C0 E59F315C ldr     r3,=20A6894h
    ldrsh   r0,[r4]           ;023126C4 E19300F1 ldrsh   r0,[r3,r1]
    nop                       ;023126C8 E0834001 add     r4,r3,r1
  .endarea
  .org 0x02312824 ; OK
  .area 4
    .pool
  .endarea

  ;-------------------------------------
  ; Hook 0x2313B54
  ;-------------------------------------
  .org 0x2313B54 ; OK
  .area 20
    mov     r0,r5             ;02313B54 E3A0000C mov     r0,0Ch
    bl      LevelListAccessor ;02313B58 E1610085 smulbb  r1,r5,r0
    mov     r4,r0             ;02313B5C E59F3138 ldr     r3,=20A6894h
    ldrsh   r0,[r4]           ;02313B60 E19300F1 ldrsh   r0,[r3,r1]
    nop                       ;02313B64 E0834001 add     r4,r3,r1
  .endarea
  .org 0x02313C9C ; OK
  .area 4
    .pool
  .endarea
