%TITLE    "Оболочка для EXE-файлов"
          IDEAL
          MODEL   small
          STACK   256
          P386
          ;INCLUDE "filename"


                   SEGMENT Sseg Page Stack 'STACK'
                   DB 2048 DUP(0)
                   ENDS Sseg

                   SEGMENT Dseg Page Public 'DATA'
                   PUBLIC FileHandle,EndProgram,MultiTask

FileHandle DW 0
EndProgram DW 0
MultiTask  DB 0


MesErr         DB 13,10,'Error in RND',13,10,'$'
Number         DB 6 DUP(0),13,'$'
          ENDS Dseg

; 0-черный   4-красный
; 1-синий    5-фиолетовый
; 2-зеленый  6-коричневый
; 3-голубой  7-белый

          SEGMENT Cseg Page Public 'CODE'

          PUBLIC ErrorDiv

          EXTRN LongTimerL:word
;          EXTRN TSCTic:dword
          EXTRN AdrScreen:proc,colorframe:proc
          EXTRN BinToAscHex:proc,NzInMes:proc
          EXTRN KeyWaiting:proc,GetCh:proc
          EXTRN ColorVerLine:proc,ColorLine:proc,ColorHorLine:proc
          EXTRN ColorStr6x8:proc,CursorPos:proc
          EXTRN Bintoascdec:proc,BintoascdecH:proc,Rectangle:proc
          EXTRN StartNewTimer:proc,StopNewTimer:proc
          EXTRN SetNewInterrupt:proc,RestoreInterrupt:proc
          EXTRN SetTimerInterrupt:proc,RestoreTimerInterrupt:proc
          EXTRN Rnd:proc,CreatePCXfile:proc
          EXTRN InitXMSAccess:proc,WriteFile:proc

          ASSUME cs:Cseg, ss:Sseg, ds:Dseg, es:Dseg

ALIGN 2
;SegMyProg DW ?

Start:
          mov      ax, @data       ;Установка в DS адреса
          mov      ds, ax          ;сегмента данных
          mov      es, ax          ;ES=DS


int 3
mov       cx,084Ah
mov       bl,5 ; c:
mov       bh,000;4
mov       ax,0440Dh
xor       dx,dx
;mov dx,1
int       021h


          sub ebx,ebx
mm02:
          push ebx

          sub ebx,ebx
          sub edx,edx
          mov ecx,500


          push ecx
mm01:
          mov  eax,500
          call Rnd
          add  ebx,eax
          adc  edx,0
          dec  ecx
          jnz  short mm01
          pop  ecx


          mov  eax,ebx
          shr  ecx,1
          div  ecx
          mov  di,offset Number
          mov cx,6
          call BinToAscDecH
          mov dx, offset Number
          mov ah,9
          int 21h
          call getch

          pop   ebx

          inc ebx
          cmp ebx,400
          jnz mm02


Exit:     mov      ah, 04Ch         ;Выход из программы
          mov      al, 0;[exCode]     ;Возврат значения кода выхода
          int      21h

PROC ErrorDiv
          ret
ENDP ErrorDiv



          ENDS Cseg

          SEGMENT EndPrgSeg Page Public 'CODE'
          DB 'EndPrgSeg'
          ENDS EndPrgSeg


          END      Start

---DOS 2.0+ ---
 00h (0)   no error
 01h (1)   function number invalid
 02h (2)   file not found
 03h (3)   path not found
 04h (4)   too many open files (no handles available)
 05h (5)   access denied
 06h (6)   invalid handle
 07h (7)   memory control block destroyed
 08h (8)   insufficient memory
 09h (9)   memory block address invalid
 0Ah (10)  environment invalid (usually >32K in length)
 0Bh (11)  format invalid
 0Ch (12)  access code invalid
 0Dh (13)  data invalid
 0Eh (14)  reserved
 0Eh (14)  (PTS-DOS 6.51+, S/DOS 1.0+) fixup overflow
 0Fh (15)  invalid drive
 10h (16)  attempted to remove current directory
 11h (17)  not same device
 12h (18)  no more files
---DOS 3.0+ (INT 24 errors)---
 13h (19)  disk write-protected
 14h (20)  unknown unit
 15h (21)  drive not ready
 16h (22)  unknown command
 17h (23)  data error (CRC)
 18h (24)  bad request structure length
 19h (25)  seek error
 1Ah (26)  unknown media type (non-DOS disk)
 1Bh (27)  sector not found
 1Ch (28)  printer out of paper
 1Dh (29)  write fault
 1Eh (30)  read fault
 1Fh (31)  general failure
 20h (32)  sharing violation
 21h (33)  lock violation
 22h (34)  disk change invalid (ES:DI -> media ID structure)(see #01681)
 23h (35)  FCB unavailable
 23h (35)  (PTS-DOS 6.51+, S/DOS 1.0+) bad FAT
 24h (36)  sharing buffer overflow
 25h (37)  (DOS 4.0+) code page mismatch
 26h (38)  (DOS 4.0+) cannot complete file operation (EOF / out of input)
 27h (39)  (DOS 4.0+) insufficient disk space
 28h-31h   reserved



