; For use with ARMIPS v0.7d
; By: psycommando@gmail.com
; 2016/08/16 - Updated 2020/11/17
; For Explorers of Sky Europe ONLY!
; ------------------------------------------------------------------------------
; Copyright © 2016 Guillaume Lavoie-Drapeau <psycommando@gmail.com>
; This work is free. You can redistribute it and/or modify it under the
; terms of the Do What The Fuck You Want To Public License, Version 2,
; as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
; ------------------------------------------------------------------------------
;Meant to be included inside the arm9.bin file!
.relativeinclude on
.nds
.arm

;.definelabel PPMD_GameVer,    1       ;Symbol for telling the library we're compiled for EoS Europe "1"

;First do am9.bin
;.open "../bin_src/arm9.bin", "../bin_out/arm9.bin", 0x02000000
    ;Implement our own file loading function to load the list as a sir0!
    .org 0x020A4CEC ;write over the actual table OK
    ;.area 0x20A71B0 - .;0x24c4 ;We got at most 9,400 bytes to write stuff here, so there's plenty of room! OK
    .area 0x20A715C - . ;OK

    ;Uncomment the desired implementation! Filestreams don't load the entire level list in memory, while the sir0 option loads the whole thing!
    ; Filestreams are slower and takes little memory, while the other consumes more memory but is very quick!
    ;.include "../levellistloader_cachedfstream.asm"
    .include "../levellistloader_assir0.asm"

;********************************
; A few customized functions for making a more seamless hooking!
;********************************
;Same as above, except it returns the pointer to the string of the level, instead of the entry!
        LevelListStringAccessor:
          push r14
          bl LevelListAccessor  ;Get the pointer to the entry
          ;add r0,r0,8h        ;Increment to get the pointer to the string
          ldr r0,[r0,8h]          ;Read the pointer to the string into r0
          pop r15
          .pool
          .align 4
        ;END LevelListStringAccessor

;Helper for getting the first hword and return it into r0.
        LevelListFirstHWORDGet:
            push  r14
            bl    LevelListAccessor
            ldrsh r0,[r0]
            pop   r15
            .pool
            .align 4
        ;END

;Helper for getting the first hword and return it into r0.
        LevelListSecondHWORDGet:
            push  r14
            bl    LevelListAccessor
            ldrsh r0,[r0,2h]
            pop   r15
            .pool
            .align 4
        ;END

;Custom Hook for 022F1F68
        LevelListCustomHook022F290C:
          push r0,r1,r2,r3,r14
          mov r0,r4
          bl  LevelListAccessor
          mov r4,r0
          pop r0,r1,r2,r3,r15
          .pool
          .align 4
        ;END

;********************************
; Fontloader hook
;********************************
;A re-implementation of the font loader so the level table is loaded earlier.
; The fonts are the first thing loaded in memory, so its probably going to be very
; helpful to have this !!
        ReplacedFontLoader:
          push    r3,r14
          bl      TryLoadLevelList  ;<=== We added our function to load the level list here
          bl      TryLoadActorList 

          ;The original code is below:
          sub     r13,r13,8h
          ldr     r1,=209B12Ch ;OK
          add     r0,r13,0h
          mov     r2,1h
          bl      LoadFileFromRom                ;LoadFileFromRom(R1=filepath)
          ldr     r0,[r13]
          ldr     r2,=22A8394h ;OK
          add     r3,r0,4h
          str     r0,[r2,8h]
          str     r3,[r2]
          ldr     r1,=209B140h ;OK
          add     r0,r13,0h
          mov     r2,1h
          bl      LoadFileFromRom                ;LoadFileFromRom(R1=filepath)
          ldr     r0,[r13]
          ldr     r2,=22A8394h ;OK
          add     r3,r0,4h
          str     r0,[r2,0Ch]
          str     r3,[r2,4h]
          ldr     r1,=209B154h ;OK
          add     r0,r13,0h
          mov     r2,1h
          bl      LoadFileFromRom                ;LoadFileFromRom(R1=filepath)
          ldr     r0,[r13]
          ldr     r1,=20B0620h ;OK
          mov     r2,0h
          str     r0,[r1,08h]
          str     r2,[r1,4h]
          ldr     r0,=22A8394h ;OK
          mov     r2,0Bh
          str     r2,[r0,10h]
          str     r2,[r0,14h]
          mov     r0,1h
          strb    r0,[r1]
          add     r13,r13,8h
          pop     r3,r15
        .pool
        ;END


        LevelListFPath:
            .ascii "rom0:BALANCE/level_list.bin"      ;This is the name of SIR0 file that'll contain our level table!
            dcb 0 ;Put ending 0
        .align 4 ;align the string on 4bytes
;Fill up the rest with junk so we know if something went wrong
        .fill  (0x20A715C - .), 255 ;Null out the rest of the table ; OK
    .endarea

;===============================================================================
; Replace all instances of the table address with our hacked functions
;===============================================================================

;-------------------------------------
; Level Getter2 Hook
;-------------------------------------
    .org 0x2065390 ;OK
    .area 0x20653CC - 0x2065390 ;OK
      push r1,r14
      mvn     r1,0h
      cmp     r0,r1
      beq     @@Abort
      ;mov     r1,0Ch
      ;smulbb  r1,r0,r1
      ;ldr     r0,=20A5BD8h ;OK
      ;ldrsh   r0,[r0,r1]
      bl LevelListFirstHWORDGet
      cmp     r0,5h
      cmpne   r0,6h
      cmpne   r0,8h
      moveq   r0,0h
      ;bxeq    r14
      popeq r1,r15
      @@Abort:
      mov     r0,1h
      ;bx      r14
      pop r1,r15
      .pool
    .endarea

;-------------------------------------
; Level String Getter Hook
;-------------------------------------
    .org 0x02065378 ;OK
    .area 0x18 ; we got 24 bytes max here
        push r14
        ;Call our modified routine
        bl LevelListStringAccessor ;We want only the string!!
        pop r15
        .pool
        ;.fill (0x02065378 + 0x18) - .,0 ;OK
    .endarea
    ;END

;-------------------------------------
; FontLoader Hook (For loading as SIR0 only)
;-------------------------------------
    .org 0x2025DA4 ;OK
    .area (0x2025E48 - 0x2025DA4) ;OK
      push r14
      bl ReplacedFontLoader
      pop r15
      .pool
      .fill (0x2025E48 - .),0 ;OK
    .endarea
    ;END


;.close ;Close arm9.bin

;.include "levellistloader_overlay11.asm"
