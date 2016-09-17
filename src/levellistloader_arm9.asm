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
    .area 0x20A6910 - .;0x2224 ;We got at most 8,740 bytes to write stuff here, so there's plenty of room!
        ;Loads the Level list file!
        LevelListLoader:
            push    r0,r1,r2,r14
            ;First reserve 8 bytes on the stack
            ;sub     r13,r13,8h

            ;Prepare our parameters and call the file loading function
            ;add     r0,r13,0h             ;Return struct for the loaded file data
            ldr     r0,=RetSzAndFBuff     ;
            ldr     r1,=LevelListFPath    ;Load our custom file path ptr
            ldr     r2,=0h                ;Not sure what this does. Its usually 1, 6,or sometimes 0x30F Maybe byte align??
            bl      LoadFileFromRom       ;This will return the loaded file size in bytes!!

            ;Check if filesize non-zero
          ;  cmp     r0, 0h
          ;    bne     @@Continue            ;Branch ahead if there's no problem
            ;mov     r0,1h
            ;ldr     r1,=LevellistError
            ;bl      DebugPrint

        @@Continue:
            ;Copy the 2 dwords returned on the stack earlier to our dedicated variables
            ldr     r0,=LevelListFileBufferPtr
            ;ldr     r1,[r13]
            ldr     r1,=RetSzAndFBuff
            ldr     r1,[r1]
            str     r1,[r0],4h
            ;ldr     r1,[r13,4h]
            ldr     r1,=RetSzAndFBuff
            ldr     r1,[r1,4h]
            str     r1,[r0],4h

            ;Prepare the SIR0
            ldr     r0,=LevelListTablePtr   ;This is where the pointer to the data from the SIR0 will be placed!
            ;ldr     r1,[r13]                ;This is the pointer to the filebuffer we just put on the stack
            ldr     r1,=RetSzAndFBuff
            ldr     r1,[r1]
            bl      HandleSIR0              ;This converts the offset to be memory relative, when needed

            ;Finally, dealloc the 8 bytes on the stack
            ;add     r13,r13,8h
            pop     r0,r1,r2,r15
            ;Pool constants here
            .pool
        ;END LevelListLoader

;Run a check to see if the pointer to the buffer is null.
        ShouldLoadLevelList:
            push    r1,r2,r3,r14
            ldr     r0,=LevelListFileBufferPtr
            ldr     r1,=LevelListTablePtr
            ldr     r0,[r0]
            ldr     r1,[r1]
            cmp r0,0h
                moveq r0,1h
                popeq r1,r2,r3,r15
            ;cmpne r1,0h
                ;moveq r0,1h
                ;popeq r1-r3,r15
        @@ReturnFalse:
            mov r0,0h
            pop r1,r2,r3,r15
            ;Pool constants here
            .pool
        ;END ShouldLoadLevelList

;TryLoadLevelList: Load the level list if needed!
        TryLoadLevelList:
          push r0,r14
          bl ShouldLoadLevelList
          cmp r0, 0h
            beq @@end           ;If the file is already loaded, just jump out
          bl  LevelListLoader
        @@end:
          pop r0,r15
        ;END

;For directly getting the level list address with no fuss involved
        GetLevelListAddress:
          ldr r0,=LevelListTablePtr
          ldr r0,[r0]
          bx r14
        ;END

;Get Or Load The Level List into R0!
        GetOrLoadLevelList:
          push r14
          bl ShouldLoadLevelList
          cmp r0, 0h
              beq @@GetAddress ;If the file is already loaded, just jump to accessing the table
        @@LoadTable:
              bl  LevelListLoader
        @@GetAddress:
          ldr r0,=LevelListTablePtr
          ldr r0,[r0]
          pop r15
          .pool
        ;END

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
    ;END

;LoadLvlEntryFromFileOrCache (r0 = levelid) return in r0 the address of the entry in memory
    LoadLvlEntryFromFileOrCache:
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
        LevelEntryBuffer_lastentry:
          dcd 0,0,0 ;an entry is 12 bytes
        .align 4
        LevelEntryBuffer_lastname:
          dcb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;reserve 16bytes string for writing the last string for the last entry here!
        LevelList_PointerBuffer:
          dcd 0
        LevelList_FileStream: ;Put the file stream struct here!
          defs 0x48,0
        .align 4
      ;END

;********************************
; A few customized functions for making a more seamless hooking!
;********************************
;Get Or Load The Level List into R1!
        GetOrLoadLevelList_R1:
          push r0,r14 ;R0 is modified to return the value!
          bl TryLoadLevelList
          ldr r1,=LevelListTablePtr
          ldr r1,[r1]
          pop r0,r15
          .pool
        ;END

;Get Or Load The Level List into R2!
        GetOrLoadLevelList_R2:
          push r0,r14
          bl TryLoadLevelList
          ldr r2,=LevelListTablePtr
          ldr r2,[r2]
          pop r0,r15
          .pool
        ;END

;Get Or Load The Level List into R4!
        GetOrLoadLevelList_R4:
          push r0,r14
          bl TryLoadLevelList
          ldr r4,=LevelListTablePtr
          ldr r4,[r4]
          pop r0,r15
          .pool
        ;END

;Access the content of the buffer much like the original function!
        LevelListAccessor:
          push r14
          bl LoadLvlEntryFromFileOrCache
          pop  r15
          .pool

;CODE BEFORE DOING TEST WITH LOADING FROM FILE EACH TIMES!
            push r1,r2,r3,r4,r14
            ;First, save the entry index in r0
            mov r3,r0
            ;Check if we must load the file
            ;bl ShouldLoadLevelList
            ;cmp r0, 0h
                ;beq @@GetValue ;If the file is already loaded, just jump to accessing the table
         ;@@LoadTable:
            ;bl  LevelListLoader
         ;@@GetValue:

            ;cmp     r3,0xCF0
            ;  bne @@Continue
            ;.msg "Well shit"
         ;@@Continue:
            ;bl GetOrLoadLevelList ;Get the pointer to the level list, or load the level list! It'll end up in R0!
            ;TEST
            bl      GetLevelListAddress
            mov     r1,0Ch        ;Each entries in the table is 12 bytes long
            smulbb  r1,r3,r1    ;Multiply by the size of a table entry
            ;ldr     r4, =LevelListTablePtr
            ;ldr     r0, [r4]      ;Load our pointer
            add     r0,r0,r1    ;set it to the correct entry
            ;ldr     r0, [r4,r1] ;Load the actual
            pop     r1,r2,r3,r4,r15
            ;Pool constants here
            .pool
        ;END LevelListAccessor

;Same as above, except it returns the pointer to the string of the level, instead of the entry!
        LevelListStringAccessor:
          push r14
          bl LevelListAccessor  ;Get the pointer to the entry
          add r0,r0,8h        ;Increment to get the pointer to the string
          ldr r0,[r0]          ;Read the pointer to the string into r0
          pop r15
          .pool
        ;END LevelListStringAccessor

;Helper for getting the first hword and return it into r0.
        LevelListFirstHWORDGet:
            push  r1,r14
            bl    LevelListAccessor
            ldrsh r0,[r0]
            pop   r1,r15
            .pool
        ;END

;A re-implementation of the font loader so the level table is loaded earlier.
; The fonts are the first thing loaded in memory, so its probably going to be very
; helpful to have this !!
        ReplacedFontLoader:
          push    r3,r14

          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;bl      TryLoadLevelList  ;<=== We added our function to load the level list here

          ;The original code is below:
          sub     r13,r13,8h
          ldr     r1,=209ABF0h
          add     r0,r13,0h
          mov     r2,1h
          bl      LoadFileFromRom                ;LoadFileFromRom(R1=filepath)
          ldr     r0,[r13]
          ldr     r2,=22A7A54h
          add     r3,r0,4h
          str     r0,[r2,10h]
          str     r3,[r2]
          ldr     r1,=209AC04h
          add     r0,r13,0h
          mov     r2,1h
          bl      LoadFileFromRom                ;LoadFileFromRom(R1=filepath)
          ldr     r0,[r13]
          ldr     r2,=22A7A54h
          add     r3,r0,4h
          str     r0,[r2,14h]
          str     r3,[r2,4h]
          ldr     r1,=209AC18h
          add     r0,r13,0h
          mov     r2,1h
          bl      LoadFileFromRom                ;LoadFileFromRom(R1=filepath)
          ldr     r0,[r13]
          ldr     r1,=20AFD04h
          mov     r2,0h
          str     r0,[r1,0Ch]
          str     r2,[r1,8h]
          ldr     r0,=22A7A54h
          mov     r2,0Bh
          str     r2,[r0,8h]
          str     r2,[r0,0Ch]
          mov     r0,1h
          strb    r0,[r1]
          add     r13,r13,8h
          pop     r3,r15
        .pool
        ;END

        ;.definelabel LevelListFileBufferPtr, 0x020A46EC
        LevelListFileBufferPtr:
            dcd 0
            dcd 0
        ;.definelabel LevelListTablePtr, 0x020A46F4
        LevelListTablePtr:
            dcd 0
        ;.definelabel LevelListFPath, 0x020A46F8
        LevelListFPath:
            .ascii "rom0:BALANCE/level_list.bin"      ;This is the name of SIR0 file that'll contain our level table!
            dcb 0 ;Put ending 0
        .align 4 ;align the string on 4bytes
        RetSzAndFBuff: ; return value for the file loading function on the heap since we messed up the stack otherwise
            dcd 0
            dcd 0
        .align 4 ;align the string on 4bytes

;Fill up the rest with junk so we know if something went wrong
        .fill (0x20A690C - .), 0xFF ;Null out the rest of the table
    .endarea

;===============================================================================
; Replace all instances of the table address with our hacked functions
;===============================================================================

;-------------------------------------
; Level String Getter Hook
;-------------------------------------
    .org 0x02064FFC
    .area 0x18 ; we got 24 bytes max here
        push r14
        ;Call our modified routine
        bl LevelListStringAccessor ;We want only the string!!
        ;Must bx back
        ;bx r14
        pop r15
        .pool
        .fill (0x02064FFC + 0x18) - .
    .endarea
    ;END
;-------------------------------------
; FontLoader Hook
;-------------------------------------
    .org 0x2025AD8
    .area (0x2025B7C - 0x2025AD8)
      push r14
      bl ReplacedFontLoader
      pop r15
      .pool
      .fill (0x2025B7C - .)
    .endarea
    ;END

.close ;Close arm9.bin

.include "levellistloader_overlay11.asm"
