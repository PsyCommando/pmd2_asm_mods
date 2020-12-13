; For use with ARMIPS v0.7d
; By: psycommando@gmail.com
; 2020/11/17
; For Explorers of Sky Europe ONLY!
; ------------------------------------------------------------------------------
; Copyright © 2016 Guillaume Lavoie-Drapeau <psycommando@gmail.com>
; This work is free. You can redistribute it and/or modify it under the
; terms of the Do What The Fuck You Want To Public License, Version 2,
; as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
; ------------------------------------------------------------------------------


; Overlays load offsets
.definelabel Overlay_0010_offset, 0x022BD3C0 ;OK
.definelabel Overlay_0011_offset, 0x022DCB80 ;OK
.definelabel Overlay_0013_offset, 0x0238A880 ;OK

; Known function offsets from the game's binaries:
.definelabel LoadFileFromRom, 0x2008C3C ;OK
.definelabel HandleSIR0,      0x201F550 ;OK
.definelabel DebugPrint,      0x200C2C8 ;OK

; Alloc
.definelabel MemAlloc,        0x2001170     ;(r0 = SzAlloc, r1 = Align?) OK Returns r0 = PtrAllocated
.definelabel MemFree,         0x2001188     ;(r0 = BufToFree) OK
.definelabel MemAlloc2,       0x2001390     ;(r0 = unknown, r1 = SzAlloc, r1 = Align?) Returns r0 = PtrAllocated OK

.definelabel MemZeroFill,     0x2003250     ;(r0 = PtrBuf, r1 = LengthBuffer) OK

; file streams
.definelabel FStreamAlloc,    0x2008168     ;() Is usually done first, before any reading is done. Seems to instantiate the Filestream? OK
.definelabel FStreamCtor,     0x2008204     ;(r0 = PtrFStreamStruct)  Zeroes the content of the struct OK
.definelabel FStreamFOpen,    0x2008210     ;(r0 = PtrFStreamStruct, r1 = PtrFPath) Open the file for reading OK
.definelabel FStreamSeek,     0x20082A8     ;(r0 = PtrFStreamStruct, r1 = OffsetToSeekTo, r2 = unknown?(usually 0) ) OK
;2008244h
.definelabel FStreamRead,     0x2008254     ;(r0 = PtrFStreamStruct, r1 = PtrOutBuffer, r2 = NbBytesToRead ) Read the ammount of bytes specified to the buffer, for the FStream object OK
.definelabel FStreamClose,    0x20082C4     ;(r0 = PtrFStreamStruct)  Close the filestream OK
.definelabel FStreamDealloc,  0x2008194     ;() ??? OK
