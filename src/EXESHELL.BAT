@echo off
tasm avvlib.asm

tasm exeshell.asm

tlink /3 exeshell.obj avvlib.obj, exeshell.exe
