@echo off

copy pcidev.asm pcidev_.asm

pcicomp.exe

tasm avvlib.asm /m2
tasm pcidev_.asm /m2
tasm speedsys.asm

tlink /3 speedsys.obj pcidev_.obj avvlib.obj, speedsys.exe

pause 0

putwin32.exe

upx -9 -ospeedsys.pac speedsys.exe

del speedsy_.exe
del pcidev_.obj
del speedsys.map

ren speedsys.exe speedsy_.exe
ren speedsys.pac speedsys.exe


speedin1.exe

del speedsys.obj
del avvlib.obj
rem del null
