          IDEAL
          MODEL   small
          P386
          STACK   128
          DATASEG
welcome   DB      13,10,10,'Insert strings "'
sst       DB      'SST" and "'
ver       DB      '4.31"... $'
UpxString DB 4 DUP(' ')
Upx       DB 'UPX '

MesNoFile DB      13,10,10,'Can not found '
filename  DB      'SPEEDSYS.EXE',0,'.',13,10,'$'
meserror  DB      'ERROR.$'
MesErrSST DB      13,10,10,'ERROR: UPX packing not found$'
mesOK     DB      'OK.$'
          CODESEG
Start:
          mov      ax,@data
          mov      ds,ax
          mov      dx,offset Welcome
          mov      ah,9
          int      21h
          mov      dx,offset Filename
          mov      ax,3D02h
          int      21h
          mov      dx,offset MesNoFile
          jc       short Error
          mov      bx,ax
          sub      cx,cx
          mov      dx,055h
          mov      ax,4200h
          int      21h
          mov      dx,offset MesError
          jc       short Error         ; Переход если нет ошибок
          mov     ah,3Fh
          mov     cx,3
          mov     dx,offset UPXstring
          int     21h
          mov     eax,[dword ds:UPX]
          cmp     eax,[dword ds:UPXString]
          mov     dx,offset MesErrSST
          jnz     short Error
          sub      cx,cx
          mov      dx,055h
          mov      ax,4200h
          int      21h
          mov      dx,offset MesError
          jc       short Error         ; Переход если нет ошибок

          mov      ax,4000h
          mov      cx,3
          mov      dx,offset sst
          int      21h
          mov      dx,offset MesError
          jc       short Error         ; Переход если нет ошибок


          sub      cx,cx
          mov      dx,06Bh
          mov      ax,4200h
          int      21h
          mov      dx,offset MesError
          jc       short Error         ; Переход если нет ошибок

          mov      ax,4000h
          mov      cx,4
          mov      dx,offset ver
          int      21h
          mov      dx,offset MesError
          jc       short Error         ; Переход если нет ошибок


          mov      dx,offset MesOk
Error:
          mov      ah,9
          int      21h
          mov      ax, 04C00h         ;Выход из программы
          int      21h
          END      Start