@echo off

tasm avvlib.asm
tasm pcidev.asm
tasm speedsys.asm

tlink /3 speedsys.obj pcidev.obj avvlib.obj, speedsys.exe

pause 0

putwin32.exe

upx -9 -ospeedsys.pac speedsys.exe

del speedsy_.exe
del speedsys.map

ren speedsys.exe speedsy_.exe
ren speedsys.pac speedsys.exe


speedin1.exe

del speedsys.obj
del pcidev.obj
del avvlib.obj
rem del null
