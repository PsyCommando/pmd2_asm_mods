;
; For Explorers of Sky North American ONLY!
.nds
.arm

.definelabel LoadFileFromRom, 0x2008C3C
.definelabel HandleSIR0,      0x201F4B4
.definelabel DebugPrint,      0x200C240

;First do am9.bin
.open "arm9.bin", 0x02000000
    ;Implement our own file loading function to load the list as a sir0!
    .org 0x020A46EC ;write over the actual table
    .area 0x20A6910 - .;0x2224 ;We got at most 8,740 bytes to write stuff here, so there's plenty of room!
        ;.definelabel LevelListFileBufferPtr, 0x020A46EC
        LevelListFileBufferPtr:
            dcd 0
            dcd 0
        ;.definelabel LevelListTablePtr, 0x020A46F4
        LevelListTablePtr:
            dcd 0
        ;.definelabel LevelListFPath, 0x020A46F8
        LevelListFPath:
            .ascii "rom0:BALANCE/level_list.bin"
            dcb 0 ;Put ending 0
        .align  ;align the string on 4bytes
        LevellistError:
            .ascii "Level list file size was 0!!"
            dcb 0 ;Put ending 0
        .align  ;align the string on 4bytes
        RetSzAndFBuff: ; return value for the file loading function on the heap since we messed up the stack otherwise
            dcd 0
            dcd 0
        .align  ;align the string on 4bytes

        ;Loads the Level list file!
        LevelListLoader:
            push    r0,r1,r2,r14
            ;First reserve 8 bytes on the stack
            ;sub     r13,r13,8h

            ;Prepare our parameters and call the file loading function
            ;add     r0,r13,0h             ;Return struct for the loaded file data
            ldr     r0,=RetSzAndFBuff     ;
            ldr     r1,=LevelListFPath    ;Load our custom file path ptr
            mov     r2,1h                 ;Not sure what this does. Its usually 1, 6,or sometimes 0x30F Maybe byte align??
            bl      LoadFileFromRom       ;This will return the loaded file size in bytes!!

            ;Check if filesize non-zero
            cmp     r0, 0h
            bne     @@Continue            ;Branch ahead if there's no problem
            mov     r0,1h
            ldr     r1,=LevellistError
            bl      DebugPrint

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
          push r14
          bl ShouldLoadLevelList
          cmp r0, 0h
            beq @@end           ;If the file is already loaded, just jump out
          bl  LevelListLoader
        @@end:
          pop r15
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

;********************************
; A few customized functions for making a more seamless hooking!
;********************************
;Get Or Load The Level List into R1!
        GetOrLoadLevelList_R1:
          push r0,r14 ;R0 is modified to retur the value!
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

            cmp     r3,0xCF0
              bne @@Continue
            .msg "Well shit"
         @@Continue:
            bl GetOrLoadLevelList ;Get the pointer to the level list, or load the level list! It'll end up in R0!
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

;-------------------------------------
; Specific hooks
;-------------------------------------
; To reduce the risk of errors, we'll just work on our register in tailor made
; hook functions, here

;HOOK for 0x23125D4, 0x231110C, 0x2310108
        HOOK_LVL_List_A:
          push    r1,r2,r3,r4,r5,r14
          mov     r0,r5             ;023125D4 E3A0000C mov     r0,0Ch
          bl      LevelListAccessor ;023125D8 E1610085 smulbb  r1,r5,r0
          mov     r4,r0             ;023125DC E59F3138 ldr     r3,=20A5488h
          ldrsh   r0,[r4]           ;023125E0 E19300F1 ldrsh   r0,[r3,r1]
          ;023125E4 E0834001 add     r4,r3,r1
          pop    r1,r2,r3,r4,r5,r15
          .pool
      ;END

;Fill up the rest with junk so we know if something went wrong
        .fill (0x20A6910 - .), 0xFF ;Null out the rest of the table
    .endarea

;===============================================================================
; Replace all instances of the table address with our hacked functions
;===============================================================================

;Replace the method for accessing the level list here:
;-------------------------------------
; 02064FFC
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

.close ;Close arm9.bin

.include "levellistloader_overlay11.asm"
