; For use with ARMIPS v0.7d
; By: psycommando@gmail.com
; 2016/08/16
; For Explorers of Sky North American ONLY!
; ------------------------------------------------------------------------------
; Copyright © 2016 Guillaume Lavoie-Drapeau <psycommando@gmail.com>
; This work is free. You can redistribute it and/or modify it under the
; terms of the Do What The Fuck You Want To Public License, Version 2,
; as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
; ------------------------------------------------------------------------------
.relativeinclude on
.nds
.arm
.include "cmn_eos.asm"

.definelabel PPMD_GameVer,    0  ;Symbol for telling the library we're compiled for EoS North America "0"

;.definelabel LoadFileFromRom, 0x2008C3C
;.definelabel HandleSIR0,      0x201F4B4
;.definelabel DebugPrint,      0x200C240

;First do am9.bin
.open "../bin_src/arm9.bin", "../bin_out/arm9.bin", 0x02000000
    ;Implement our own file loading function to load the list as a sir0!
    .org 0x020A46EC ;write over the actual table
    ;.area 0x20A6910 - .;0x2224 ;We got at most 8,740 bytes to write stuff here, so there's plenty of room!
    .area 0x20A68BC - .
;Check if we need to load the level list for this entry! (r0 = level id, r1=nothing) Return in r0, 1 if should load, 0 if not
    CheckIfShouldGetLvlEntryFromFile:
      ldr r1,=LevelEntryBuffer_lastlvlid
      ldr r1,[r1]
      cmp r0,r1
      bne @@NeedToLoad
      mov r0,0h
      bx r14
      @@NeedToLoad:
      mov r0,1h
      bx r14
      .pool
      .align 4
    ;END

;LoadLvlEntryFromFileOrCache (r0 = levelid) return in r0 the address of the entry in memory
    LevelListAccessor:
      push r1,r4,r14
      mov r4,r0
      bl CheckIfShouldGetLvlEntryFromFile

      cmp r0,0h

      ;If we don't need to load the file, load from cache and return!
      ldreq r0,=LevelEntryBuffer_lastentry
      beq @@End

      ;Else if we need to load the file do it!
      mov r0,r4                         ;Put level id back in r0!
      bl GetLevelEntryDirectlyFromFile  ;The entry's address will be in r0 already

      @@End:
      pop r1,r4,r15
      .pool
      .align 4
    ;END

;Seek within level list instead of loading it! (r0 = level id!) Returns r0 with a pointer to the entry in the entry buffer.
      GetLevelEntryDirectlyFromFile:
        push r1,r2,r4,r5,r14
        mov r4,r0         ;free up r0 to pass some parameters
        ldr r0,=LevelEntryBuffer_lastlvlid
        str r4,[r0]       ;Save the level id to the cache!
        ;sub r13,r13,48h   ;we'll alloc the file stream on the stack
        bl FStreamAlloc

        ;Construct file stream
        ;add r0,r13,0h
        ldr r0,=LevelList_FileStream  ;Set r0 to filestream object
        bl FStreamCtor

        ;Open filestream
        ;add r0,r13,0h          ;Set r0 to filestream object
        ldr r0,=LevelList_FileStream  ;Set r0 to filestream object
        ldr r1,=LevelListFPath ;level_list.bin
        add r1,5h              ;Add 5 bytes to skip the "rom0:" part
        bl FStreamFOpen

        ;Seek to table ptr offset
        ;add r0,r13,0h   ;Set r0 to filestream object
        ldr r0,=LevelList_FileStream  ;Set r0 to filestream object
        mov r1,4h
        mov r2,0h
        bl FStreamSeek

        ;Read Pointer
        ;add r0,r13,0h   ;Set r0 to filestream object
        ;sub r13,r13,4h  ;Alloc 4 bytes on stack
        ;add r1,r13,0h   ;Set allocated stack as dest buffer
        ldr r0,=LevelList_FileStream  ;Set r0 to filestream object
        ldr r1,=LevelList_PointerBuffer
        mov r2,4h       ;Set nb bytes to read to 4
        bl FStreamRead
        ldr r1,=LevelList_PointerBuffer
        ldr r1,[r1]     ;Load the 4bytes buffer into r1!
        mov r5,r1       ;copy the value into r5 so we can use it later
        ;add r13,r13,4h  ;Dealloc Alloc 4 bytes on stack

        ;Seek to pointer
        ;add r0,r13,0h   ;Set r0 to filestream object
        ldr r0,=LevelList_FileStream  ;Set r0 to filestream object
        ;r1 is already set!
        mov r2,0h
        bl FStreamSeek

        ;Seek to the correct entry!
        mov r0,12      ;An entry is 12 bytes
        mla r1,r4,r0,r5 ;set position to seek to: (levelid * 12) + tablebeg
        ;add r0,r13,0h   ;Set r0
        ldr r0,=LevelList_FileStream  ;Set r0 to filestream object
        mov r2,0h
        bl FStreamSeek  ;Seeke to the entry

        ;Read entry to buffer!
        ;add r0,r13,0h   ;Set r0 to filestream object
        ldr r0,=LevelList_FileStream  ;Set r0 to filestream object
        ldr r1,=LevelEntryBuffer_lastentry ;Set target buffer
        mov r2,12       ;Set nb bytes to read to 12
        bl FStreamRead

        ;Copy string!
        ;add r0,r13,0h   ;Set r0 to filestream object
        ldr r0,=LevelList_FileStream  ;Set r0 to filestream object
        ldr r1,=LevelEntryBuffer_lastentry
        ldr r1,[r1,8h] ;The string ptr is at 8 bytes in the entry
        mov r2,0h
        bl FStreamSeek  ;Seeke to the string
        ;add r0,r13,0h   ;Set r0 to filestream object
        ldr r0,=LevelList_FileStream  ;Set r0 to filestream object
        ldr r1,=LevelEntryBuffer_lastname ;Set string buffer as target buffer
        mov r2,10h      ;Set nb of bytes to read to 16!
        bl FStreamRead  ;Read filestream

        ;Replace string pointer!
        ldr r0,=LevelEntryBuffer_lastname   ;Address of the string buffer
        ldr r1,=LevelEntryBuffer_lastentry
        str r0,[r1,8h] ;The string ptr is at 8 bytes in the entry

        ;Close and Dealloc stream
        ;add r0,r13,0h   ;Set r0 to filestream object
        ldr r0,=LevelList_FileStream  ;Set r0 to filestream object
        bl FStreamClose
        bl FStreamDealloc

        ;Return
        ldr r0,=LevelEntryBuffer_lastentry
        ;add r13, r13, 48h ;dealloc filestream
        pop r1,r2,r4,r5,r15

        .pool
        LevelEntryBuffer_lastlvlid:
          dcd 0 ;holds the last levelid so we can cache calls to this and not reload the file all the time
          ;.align 4
        LevelEntryBuffer_lastentry:
          dcd 0,0,0 ;an entry is 12 bytes
        .align 4
        LevelEntryBuffer_lastname:
          dcb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;reserve 16bytes string for writing the last string for the last entry here!
          ;.align 4
        LevelList_PointerBuffer:
          dcd 0
          ;.align 4
        LevelList_FileStream: ;Put the file stream struct here!
          defs 0x48,0
        .align 4
      ;END

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
        LevelListCustomHook022F1F68:
          push r0,r1,r2,r3,r14
          mov r0,r4
          bl  LevelListAccessor
          mov r4,r0
          pop r0,r1,r2,r3,r15
          .pool
          .align 4
        ;END


        LevelListFPath:
            .ascii "rom0:BALANCE/level_list.bin"      ;This is the name of SIR0 file that'll contain our level table!
            dcb 0 ;Put ending 0
        .align 4 ;align the string on 4bytes
;Fill up the rest with junk so we know if something went wrong
        .fill  (0x20A68BC - .), 255 ;Null out the rest of the table
    .endarea

;===============================================================================
; Replace all instances of the table address with our hacked functions
;===============================================================================

;-------------------------------------
; Level Getter2 Hook
;-------------------------------------
    .org 0x2065014
    .area 0x2065050 - 0x2065014
      push r1,r14
      mvn     r1,0h
      cmp     r0,r1
      beq     @@Abort
      ;mov     r1,0Ch
      ;smulbb  r1,r0,r1
      ;ldr     r0,=20A5488h
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
    .org 0x02064FFC
    .area 0x18 ; we got 24 bytes max here
        push r14
        ;Call our modified routine
        bl LevelListStringAccessor ;We want only the string!!
        pop r15
        .pool
        ;.fill (0x02064FFC + 0x18) - .,0
    .endarea
    ;END

;-------------------------------------
; FontLoader Hook (For loading as SIR0 only)
;-------------------------------------
    ;.org 0x2025AD8
    ;.area (0x2025B7C - 0x2025AD8)
      ;push r14
      ;bl ReplacedFontLoader
      ;pop r15
      ;.pool
      ;.fill (0x2025B7C - .),0
    ;.endarea
    ;END


.close ;Close arm9.bin

.include "levellistloader_overlay11.asm"
