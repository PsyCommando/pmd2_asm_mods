@ECHO OFF
mkdir "../bin_out"
mkdir "../bin_out/overlay"
mkdir "../build"
"../armips/armips.exe" "levellistloader_arm9.asm" -temp "../build/levellist_output.txt" -sym "../build/levellist_symfile.sym" -erroronwarning
pause