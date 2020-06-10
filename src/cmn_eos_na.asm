; For use with ARMIPS v0.7d
; By: psycommando@gmail.com
; 2016/08/18
; For Explorers of Sky North American ONLY!
; ------------------------------------------------------------------------------
; Copyright © 2016 Guillaume Lavoie-Drapeau <psycommando@gmail.com>
; This work is free. You can redistribute it and/or modify it under the
; terms of the Do What The Fuck You Want To Public License, Version 2,
; as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
; ------------------------------------------------------------------------------


; Overlays load offsets
.definelabel Overlay_0010_offset, 0x22BCA80
.definelabel Overlay_0011_offset, 0x22DC240
.definelabel Overlay_0013_offset, 0x238A140

; Known function offsets from the game's binaries:
.definelabel LoadFileFromRom, 0x2008C3C
.definelabel HandleSIR0,      0x201F4B4
.definelabel DebugPrint,      0x200C240

; Alloc
.definelabel MemAlloc,        0x2001170     ;(r0 = SzAlloc, r1 = Align?) Returns r0 = PtrAllocated
.definelabel MemFree,         0x2001188     ;(r0 = BufToFree)
.definelabel MemAlloc2,       0x2001390     ;(r0 = unknown, r1 = SzAlloc, r1 = Align?) Returns r0 = PtrAllocated

.definelabel MemZeroFill,     0x2003250     ;(r0 = PtrBuf, r1 = LengthBuffer)

; file streams
.definelabel FStreamAlloc,    0x2008168     ;() Is usually done first, before any reading is done. Seems to instantiate the Filestream?
.definelabel FStreamCtor,     0x2008204     ;(r0 = PtrFStreamStruct)  Zeroes the content of the struct
.definelabel FStreamFOpen,    0x2008210     ;(r0 = PtrFStreamStruct, r1 = PtrFPath) Open the file for reading
.definelabel FStreamSeek,     0x20082A8     ;(r0 = PtrFStreamStruct, r1 = OffsetToSeekTo, r2 = unknown?(usually 0) )
;2008244h
.definelabel FStreamRead,     0x2008254     ;(r0 = PtrFStreamStruct, r1 = PtrOutBuffer, r2 = NbBytesToRead ) Read the ammount of bytes specified to the buffer, for the FStream object
.definelabel FStreamClose,    0x20082C4     ;(r0 = PtrFStreamStruct)  Close the filestream
.definelabel FStreamDealloc,  0x2008194     ;() ???

; Actor list patch offsets
.definelabel ActNpcTable,     0x20A6910
.definelabel ActFn20240B0,    0x20240B0
.definelabel ActFn2024114,    0x2024114
.definelabel ActFn2024184,    0x2024184
.definelabel ActFn20650C0,    0x20650C0
.definelabel ActFn20654D0,    0x20654D0
.definelabel ActFn2065B14,    0x2065B14
.definelabel ActFn22F7F04,    0x22F7F04
.definelabel Act22F8CD0,      0x22F8CD0

; Level list patch offsets
.definelabel LvlListTable,    0x20A46EC
.definelabel LvlFn2065014,    0x2065014
.definelabel LvlFn2064FFC,    0x2064FFC
.definelabel LvlFn2025AD8,    0x2025AD8
.definelabel LvlFn22DE56C,    0x22DE56C
.definelabel LvlFn22F134C,    0x22F134C
.definelabel LvlFn22F1600,    0x22F1600
.definelabel LvlFn22F1758,    0x22F1758
.definelabel LvlFn22F17B4,    0x22F17B4
.definelabel LvlFn22F1F68,    0x22F1F68
.definelabel LvlFn22FF9FC,    0x22FF9FC
.definelabel LvlFn2310108,    0x2310108
.definelabel LvlFn2310E1C,    0x2310E1C
.definelabel LvlFn231110C,    0x231110C
.definelabel LvlFn23125D4,    0x23125D4
