; For use with ARMIPS v0.7d
; ------------------------------------------------------------------------------
; Copyright © 2016 Guillaume Lavoie-Drapeau <psycommando@gmail.com>
; Copyright © 2020 Marco Köpcke <parakoopa@live.de>
; This work is free. You can redistribute it and/or modify it under the
; terms of the Do What The Fuck You Want To Public License, Version 2,
; as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
; ------------------------------------------------------------------------------


; Overlays load offsets
;.definelabel Overlay_0010_offset, ???
.definelabel Overlay_0011_offset, 0x22DCB80
;.definelabel Overlay_0013_offset, ???

; Known function offsets from the game's binaries:
.definelabel LoadFileFromRom, 0x2008C3C
.definelabel HandleSIR0,      0x201F550
.definelabel DebugPrint,      0x200C2C8

; Alloc
.definelabel MemAlloc,        0x2001170     ;(r0 = SzAlloc, r1 = Align?) Returns r0 = PtrAllocated
.definelabel MemFree,         0x2001188     ;(r0 = BufToFree)
.definelabel MemAlloc2,       0x2001390     ;(r0 = unknown, r1 = SzAlloc, r1 = Align?) Returns r0 = PtrAllocated

.definelabel MemZeroFill,     0x2003250     ;(r0 = PtrBuf, r1 = LengthBuffer)

; file streams
;.definelabel FStreamAlloc,    ???
;.definelabel FStreamCtor,     ???
;.definelabel FStreamFOpen,    ???
;.definelabel FStreamSeek,     ???

;.definelabel FStreamRead,     ???
;.definelabel FStreamClose,    ???
;.definelabel FStreamDealloc,  ???

; Actor list patch offsets
.definelabel ActNpcTable,     0x20A71B0
.definelabel ActFn20240B0,    0x2024310
.definelabel ActFn2024114,    0x2024374
.definelabel ActFn2024184,    0x20243E4
.definelabel ActFn20650C0,    0x206543C
.definelabel ActFn20654D0,    0x206584C
.definelabel ActFn2065B14,    0x2065E90
.definelabel ActFn22F7F04,    0x22F88A4
.definelabel Act22F8CD0,      0x22F9670

; Level list patch offsets
.definelabel LvlListTable,    0x20A4CEC
.definelabel LvlFn2065014,    0x2065390
.definelabel LvlFn2064FFC,    0x2065378
.definelabel LvlFn2025AD8,    0x2025DA4
.definelabel LvlFn22DE56C,    0x22DEEAC
.definelabel LvlFn22F134C,    0x22F1CF0
.definelabel LvlFn22F1600,    0x22F1FA4
.definelabel LvlFn22F1758,    0x22F20FC
.definelabel LvlFn22F17B4,    0x22F2158
.definelabel LvlFn22F1F68,    0x22F290C
.definelabel LvlFn22FF9FC,    0x2300398
.definelabel LvlFn2310108,    0x2310AA4
.definelabel LvlFn2310E1C,    0x23117B8
.definelabel LvlFn231110C,    0x2311AA8
.definelabel LvlFn23125D4,    0x2312FB4
