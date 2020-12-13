@ECHO OFF
REM cd src
mkdir "bin_out"
mkdir "bin_out/overlay"
mkdir "build"

"armips/armips.exe" "src/eu/all_mods.asm" -temp "build/output.txt" -sym "build/symfile.sym" -erroronwarning
pause
