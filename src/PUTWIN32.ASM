%TITLE    "Вставка Win32 модуля в тело SPEEDSYS.EXE Ver 1.24 Sep-05-2001"
          IDEAL
          MODEL   small
          STACK   256
          P386

BufferSize      EQU 7680

          DATASEG
exCode          DB      0
W32Buff         DB 1 DUP(0)
NameSpeedsys    DB 'SPEEDSYS.EXE',0
NameSSTWin32    DB 'SSTWIN32.EXE',0
HandleSPEEDSYS  DW ?
HandleSSTWIN32  DW ?
MesOpenSssWin32 DB 13,10,13,10,'SST '
NumCompiled     DB 'Compiled on '
NumMonth        DB 3 DUP(0),'-'
NumDay          DB 2 DUP(0),'-'
NumYear         DB 4 DUP(0),'. Open SSTWIN32.EXE... $'
MesOpenSpeedsys DB 13,10,'Open SPEEDSYS.EXE... $'
PosError        DB 13,10,'ERROR: Can not faind Win32 buffer in SPEEDSYS.EXE.$'
MesInesrOk      DB 13,10,'Insert SSTWIN32.EXE to SPEEDSYS.EXE ...OK.',13,10,13,10,'$'
MesBigFile      DB 13,10,'ERROR: Resize buffer for SSTWIN32.EXE',13,10,13,10,'$'
MesFailed       DB 'Failed.',13,10,13,10,'$'
MesOK           DB 'OK.$'
SSTWIN32FileSize DW 0
MinusCounter     DB 0
CompiledCounter  DW 0
hiword          DW ?
loword          DW ?
StrMonths       DB 'JanFebMarAprMayJunJulAugSepOctNovDec'

          CODESEG

Start:
          mov      ax, @data       ;Установка в DS адреса
          mov      ds, ax          ;сегмента данных
          mov      es, ax          ;ES=DS

          mov     ah,4
          int     1Ah
          push    cx
          mov     di,offset NumDay
          mov     al,dl
          call    TimePrn
          pop     ax
          mov     di,offset NumYear
          call    YearPrn
          sub     ah,ah
          mov     al,dh
          aam     10h
          aad
          mov     cx,ax
          mov     si,offset StrMonths-3
NextMonth:
          add     si,3
          loop    short NextMonth
          mov     cx,3
          mov     di,offset NumMonth
          cld
          rep movsb

          mov      dx,offset MesOpenSssWin32
          mov      ah,9
          int      21h

          mov      dx,offset NameSSTWin32
          mov      ax,3D00h
          int      21h
          mov      [HandleSSTWIN32],ax
          mov      dx,offset MesFailed
          jc       Error
          mov      dx,offset MesOK
          mov      ah,9
          int      21h

          mov      dx,offset MesOpenSpeedsys
          mov      ah,9
          int      21h
          mov      dx,offset NameSpeedsys
          mov      ax,3D02h
          int      21h
          mov      [HandleSPEEDSYS],ax
          mov      dx,offset MesFailed
          jc       Error
          mov      dx,offset MesOK
          mov      ah,9
          int      21h

          mov      [MinusCounter],0
FainStartAdr:
          mov      ah,3Fh
          mov      bx,[HandleSPEEDSYS]
          mov      cx,1
          mov      dx,offset W32Buff
          int      21h
          cmp      [W32Buff],'-'
          jnz      short MinusNotFound
          inc      [MinusCounter]
          cmp      [MinusCounter],8
          jz       short GetPosInSpeedsysOK
          jmp      short GetNextByteInSpeedsys
MinusNotFound:
          mov      [MinusCounter],0


          mov      si,offset NumCompiled
          add      si,[CompiledCounter]
          mov      bl,[W32Buff]
          cmp      [byte ds:si],bl
          jnz      short CompiledNotFound
          inc      [CompiledCounter]
          cmp      [CompiledCounter],9
          jnz      short GetNextByteInSpeedsys
          push     ax

          mov      ah,40h
          mov      bx,[HandleSPEEDSYS]
          mov      cx,11
          mov      dx,offset NumMonth
          int      21h

          pop      ax
CompiledNotFound:
          mov      [CompiledCounter],0

GetNextByteInSpeedsys:
          or       ax,ax
          jnz      short FainStartAdr
          mov      dx,offset PosError
          jmp      Error
GetPosInSpeedsysOK:
          mov      bx,[HandleSPEEDSYS]
          xor      cx,cx             ;  Получить
          xor      dx,dx             ;  позицию
          mov      ax,04201h         ;  указателя
          int      21h               ;  и
          mov      [hiword],dx       ;  запомнить
          mov      [loword],ax       ;  ее

          mov      [SSTWIN32FileSize],0

PutWin32:
          mov      ah,3Fh
          mov      bx,[HandleSSTWIN32]
          mov      cx,1
          mov      dx,offset W32Buff
          int      21h
          or       ax,ax
          jz       short EndSSTWIN32File
          inc      [SSTWIN32FileSize]
          cmp      [SSTWIN32FileSize],BufferSize
          mov      dx,offset MesBigFile
          ja       short PutMesBigFile
          mov      ah,40h
          mov      bx,[HandleSPEEDSYS]
          mov      cx,1
          mov      dx,offset W32Buff
          cmp      [W32Buff],0
          jz       short CanNotCript
          cmp      [W32Buff],5Ah
          jz       short CanNotCript
          xor      [W32Buff],05Ah
;          rol      [W32Buff],1
CanNotCript:
          int      21h
          jmp      short PutWin32
EndSSTWIN32File:

          mov    bx,[HandleSPEEDSYS]
          mov    cx,[hiword]
          mov    dx,[loword]
          sub    dx,8
          sbb    cx,0
          mov    ax,4200h
          int    21h
          mov    ah,40h
          mov    bx,[HandleSPEEDSYS]
          mov    cx,2
          mov    dx,offset SSTWIN32FileSize
          int    21h
          mov    dx,offset MesInesrOk

PutMesBigFile:
Error:
          mov      ah,9
          int      21h


Exit:     mov      ah, 04Ch         ;Выход из программы
          mov      al, [exCode]     ;Возврат значения кода выхода
          int      21h

PROC TimePrn
          mov     cx,2
          sub     ah,ah
          jmp     short GoToTimePrn
PROC YearPrn
          mov     cx,4
GoToTimePrn:
          call    BinToAscHex
          ret
ENDP YearPrn
ENDP TimePrn

PROC HexDigit
              cmp       dl,10
              jb        short @@10
              add       dl,'A'-10
              ret

@@10:         or        dl,'0'
              ret
ENDP HexDigit

PROC NumToASCII
          push  cx
          push  dx
          push  di
          push  si
          xor   si,si
          jcxz  short @@20
@@10:
          xor   dx,dx
          div   bx
          call  HexDigit
          push  dx
          inc   si
          loop  short @@10
@@20:
          inc   cx
          or    ax,ax
          jnz   short @@10
          mov   cx,si
          jcxz  short @@40
          cld
@@30:
          pop   ax
          stosb
          loop  short @@30
@@40:
          pop   si
          pop   di
          pop   dx
          pop   cx
          ret
ENDP NumToASCII

PROC BinToAscHex ; в шеснадцатиричные ASCII строки
          push   bx
          mov    bx,16
          call   NumToASCII
          pop    bx
          ret
ENDP BinToAscHex

          END      Start