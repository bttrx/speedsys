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
PASS       DB 0

TestMes01  DB 000h,'MCP _PIB',13,10
TestMes02  DB 000h,'MIS-E _PIB',13,10
TestMes03  DB 000h,'SMC',13,10
TestMes04  DB 'SiS85C503/5513/5595B_6_b (LPC_b)',0

TestMes05  DB 'DB 000h,008h,000h,''SiS85C503/5513/5595B PCI to ISA Bridge (LPC Bridge)''',13,10


DeCompressedListOfs DW offset DeCompressedMes00
                    DW offset DeCompressedMes01
                    DW offset DeCompressedMes02
                    DW offset DeCompressedMes03
                    DW offset DeCompressedMes04
                    DW offset DeCompressedMes05
                    DW offset DeCompressedMes06
                    DW offset DeCompressedMes07
                    DW offset DeCompressedMes08
                    DW offset DeCompressedMes09
                    DW offset DeCompressedMes10
                    DW offset DeCompressedMes11
                    DW offset DeCompressedMes12
                    DW offset DeCompressedMes13
                    DW offset DeCompressedMes14
                    DW offset DeCompressedMes15
                    DW offset DeCompressedMes16
                    DW offset DeCompressedMes17
                    DW offset DeCompressedMes18
                    DW offset DeCompressedMes19
                    DW offset DeCompressedMes20
                    DW offset DeCompressedMes21
                    DW offset DeCompressedMes22
                    DW offset DeCompressedMes23
                    DW offset DeCompressedMes24
                    DW offset DeCompressedMes25
                    DW offset DeCompressedMes26
                    DW offset DeCompressedMes27
                    DW offset DeCompressedMes28
                    DW offset DeCompressedMes29
                    DW offset DeCompressedMes30
                    DW offset DeCompressedMes31
                    DW offset DeCompressedMes32
                    DW offset DeCompressedMes33
                    DW offset DeCompressedMes34
                    DW offset DeCompressedMes35
                    DW offset DeCompressedMes36
                    DW offset DeCompressedMes37
                    DW offset DeCompressedMes38
                    DW offset DeCompressedMes39
                    DW offset DeCompressedMes40
                    DW offset DeCompressedMes41
                    DW offset DeCompressedMes42
                    DW offset DeCompressedMes43
                    DW offset DeCompressedMes44
                    DW offset DeCompressedMes45
                    DW offset DeCompressedMes46
                    DW offset DeCompressedMes47
                    DW offset DeCompressedMes48
                    DW offset DeCompressedMes49
                    DW offset DeCompressedMes50
                    DW offset DeCompressedMes51
                    DW offset DeCompressedMes52
                    DW offset DeCompressedMes53
                    DW offset DeCompressedMes54
                    DW offset DeCompressedMes55
                    DW offset DeCompressedMes56
                    DW offset DeCompressedMes57
                    DW offset DeCompressedMes58
                    DW offset DeCompressedMes59
                    DW offset DeCompressedMes60
                    DW offset DeCompressedMes61
                    DW offset DeCompressedMes62
                    DW offset DeCompressedMes63
                    DW offset DeCompressedMes64
                    DW offset DeCompressedMes65
                    DW offset DeCompressedMes66
                    DW offset DeCompressedMes67
                    DW offset DeCompressedMes68
                    DW offset DeCompressedMes69
                    DW offset DeCompressedMes70
                    DW offset DeCompressedMes71
                    DW offset DeCompressedMes72
                    DW offset DeCompressedMes73
                    DW offset DeCompressedMes74
                    DW offset DeCompressedMes75
                    DW offset DeCompressedMes76
                    DW offset DeCompressedMes77
                    DW offset DeCompressedMes78
                    DW offset DeCompressedMes79
                    DW offset DeCompressedMes80
                    DW offset DeCompressedMes81
                    DW 0


CompressedList      DB '_0'
                    DB '_1'
                    DB '_2'
                    DB '_3'
                    DB '_4'
                    DB '_5'
                    DB '_6'
                    DB '_7'
                    DB '_8'
                    DB '_9'
                    DB '_A'
                    DB '_B'
                    DB '_C'
                    DB '_D'
                    DB '_E'
                    DB '_F'
                    DB '_G'
                    DB '_H'
                    DB '_I'
                    DB '_J'
                    DB '_K'
                    DB '_L'
                    DB '_M'
                    DB '_N'
                    DB '_O'
                    DB '_P'
                    DB '_Q'
                    DB '_S'
                    DB '_T'
                    DB '_U'
                    DB '_V'
                    DB '_W'
                    DB '_X'
                    DB '_Y'
                    DB '_Z'
                    DB '_a'
                    DB '_b'
                    DB '_c'
                    DB '_d'
                    DB '_e'
                    DB '_f'
                    DB '_g'
                    DB '_h'
                    DB '_i'
                    DB '_j'
                    DB '_k'
                    DB '_l'
                    DB '_m'
                    DB '_n'
                    DB '_o'
                    DB '_p'
                    DB '_q'
                    DB '_s'
                    DB '_t'
                    DB '_u'
                    DB '_v'
                    DB '_w'
                    DB '_x'
                    DB '_y'
                    DB '_z'
                    DB '_А'
                    DB '_Б'
                    DB '_В'
                    DB '_Г'
                    DB '_Д'
                    DB '_Е'
                    DB '_Ж'
                    DB '_З'
                    DB '_И'
                    DB '_Й'
                    DB '_К'
                    DB '_Л'
                    DB '_М'
                    DB '_Н'
                    DB '_О'
                    DB '_П'
                    DB '_Р'
                    DB '_С'
                    DB '_У'
                    DB '_Ф'
                    DB '_Х'
                    DB '_Ц'
                    DB 0,0

DeCompressedMes00   DB ' GUI+3D Accelerator',0
DeCompressedMes01   DB ' GUI Accelerator',0
DeCompressedMes02   DB ' Accelerator',0
DeCompressedMes03   DB ' PCI to SCSI',0
DeCompressedMes04   DB ' CPU to PCI',0
DeCompressedMes05   DB ' PCI to PCI',0
DeCompressedMes06   DB ' PCI to ISA',0
DeCompressedMes07   DB ' PCI to USB',0
DeCompressedMes08   DB ' CPU to AGP',0
DeCompressedMes09   DB ' Millennium',0
DeCompressedMes10   DB ' Multimedia',0
DeCompressedMes11   DB ' Management',0
DeCompressedMes12   DB ' Controller',0
DeCompressedMes13   DB ' Compressor',0
DeCompressedMes14   DB ' Integrated',0
DeCompressedMes15   DB ' Token Ring',0
DeCompressedMes16   DB ' Compatible',0
DeCompressedMes17   DB ' BusMaster',0
DeCompressedMes18   DB ' Processor',0
DeCompressedMes19   DB ' Interface',0
DeCompressedMes20   DB ' Ethernet',0
DeCompressedMes21   DB ' Mystique',0
DeCompressedMes22   DB ' Graphics',0
DeCompressedMes23   DB ' FireWire',0
DeCompressedMes24   DB ' Parallel',0
DeCompressedMes25   DB ' Aladdin',0
DeCompressedMes26   DB ' GeForce',0
DeCompressedMes27   DB ' Digital',0
DeCompressedMes28   DB ' Adapter',0
DeCompressedMes29   DB ' Capture',0
DeCompressedMes30   DB ' Channel',0
DeCompressedMes31   DB ' Cardbus',0
DeCompressedMes32   DB ' Chipset',0
DeCompressedMes33   DB ' Display',0
DeCompressedMes34   DB ' Decoder',0
DeCompressedMes35   DB ' 10/100',0
DeCompressedMes36   DB ' Bridge',0
DeCompressedMes37   DB ' Device',0
DeCompressedMes38   DB ' Serial',0
DeCompressedMes39   DB ' System',0
DeCompressedMes40   DB ' Memory',0
DeCompressedMes41   DB ' VooDoo',0
DeCompressedMes42   DB ' Output',0
DeCompressedMes43   DB ' SDRAM',0
DeCompressedMes44   DB ' SGRAM',0
DeCompressedMes45   DB ' Turbo',0
DeCompressedMes46   DB ' Sound',0
DeCompressedMes47   DB ' Power',0
DeCompressedMes48   DB ' Board',0
DeCompressedMes49   DB ' Modem',0
DeCompressedMes50   DB ' Audio',0
DeCompressedMes51   DB ' Video',0
DeCompressedMes52   DB ' North',0
DeCompressedMes53   DB ' South',0
DeCompressedMes54   DB ' Array',0
DeCompressedMes55   DB ' Fibre',0
DeCompressedMes56   DB ' Frame',0
DeCompressedMes57   DB ' Card',0
DeCompressedMes58   DB ' Riva',0
DeCompressedMes59   DB ' Open',0
DeCompressedMes60   DB ' Rage',0
DeCompressedMes61   DB ' Fire',0
DeCompressedMes62   DB ' Data',0
DeCompressedMes63   DB ' Chip',0
DeCompressedMes64   DB ' Port',0
DeCompressedMes65   DB ' Fast',0
DeCompressedMes66   DB ' SCSI',0
DeCompressedMes67   DB ' EIDE',0
DeCompressedMes68   DB ' Host',0
DeCompressedMes69   DB ' RAID',0
DeCompressedMes70   DB ' UDMA',0
DeCompressedMes71   DB ' USB',0
DeCompressedMes72   DB ' Pro',0
DeCompressedMes73   DB ' Bus',0
DeCompressedMes74   DB ' I/O',0
DeCompressedMes75   DB ' Ultra',0
DeCompressedMes76   DB ' PCI to',0
DeCompressedMes77   DB ' CPU to',0
DeCompressedMes78   DB ' Wide',0
DeCompressedMes79   DB ' Dual',0
DeCompressedMes80   DB ' PCI',0
DeCompressedMes81   DB ' AGP',0

TestBuff            DB 254 DUP(0)
                    DB '**********************'

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

          mov dx, offset TestMes01
          mov ah,9
          int 21h


          mov si,offset TestMes04
          mov di,offset TestBuff
          mov cx,36;120
          cld
          rep movsb
int 3

          mov si,offset TestBuff
          call UnpackPCIString
          mov si,offset TestMes05
          call PackingPCIString




Exit:     mov      ah, 04Ch         ;Выход из программы
          mov      al, 0;[exCode]     ;Возврат значения кода выхода
          int      21h

PROC PackingPCIString; si - stroka
          push ax
          push bx
          push cx
          push dx
          push si
          push di
          push bp
          mov  cx,128
          mov  al,''''
          mov  di,si
          repne scasb

          push  di
          mov   dx,di
Fain2Apostrofa:
          mov  cx,128
          repne scasb
          cmp  [byte ds:di],''''
          jnz  short Not2Apostrofa
          inc  di
          jmp  short Fain2Apostrofa
Not2Apostrofa:

          sub  di,dx
          mov  dx,di
          pop  si

          mov  bp,offset CompressedList
          mov  bx,offset DeCompressedListOfs

NextTestCompresedListString:
          mov  di,[word ds:bx]
          or   di,di
          jz   short EndOfDeCompressedList
          cmp  [Pass],0
          jz   short FirstPassDetected
          inc  di
FirstPassDetected:
          call GetSTRSize
          dec  cx
          push si
          push dx
NextTestStringOffset:
          push cx
          push si
          push di
          cld
          repe cmpsb
          pop  di
          pop  si
          pop  cx
          jnz  short NotFaundPackingString

          push si
          push di
          push cx
          push dx

          mov  di,si ;Start non compressed string
          mov  ax,[word ds:bp]
          cmp  [Pass],0
          jz   short FirstPassDetected1
          dec  ax
FirstPassDetected1:
          mov  [word ds:si],ax
          add  di,cx
          inc  si
          inc  si
          xchg di,si

          push di
          mov  di,si
Fain2Apostrofa1:
          mov  al,''''
          mov  cx,128
          repne scasb
          cmp  [byte ds:di],''''
          jnz  short Not2Apostrofa1
          inc  di
          jmp  short Fain2Apostrofa1
Not2Apostrofa1:
          sub  di,si
          mov  cx,di
          pop  di
          rep movsb
          mov  [byte ds:di],59
          pop  dx
          pop  cx
          pop  di
          pop  si

NotFaundPackingString:
          inc  si
          dec  dx
          jnz  short NextTestStringOffset
          pop  dx
          pop  si
          inc  bx
          inc  bx
          inc  bp
          inc  bp
          jmp  short NextTestCompresedListString

EndOfDeCompressedList:
          pop  bp
          pop  di
          pop  si
          pop  dx
          pop  cx
          pop  bx
          pop  ax
          ret
ENDP PackingPCIString

PROC UnpackPCIString ; si - stroka
          push ax
          push bx
          push cx
          push si
          push di
          push bp
          mov  bp,si
          mov  si,offset CompressedList
          mov  bx,offset DeCompressedListOfs
          cld
NextCompressedDword:
          lodsw
          or   ax,ax
          jz   short EndOffPCICompresList

          mov  di,bp
          call GetSTRSize
NextDwordCheckInPCIStr:
          scasw
          jnz  short CompressedWordNotFound
          mov  [Pass],0
          call ExtractCompressedWord
          call GetSTRSize
          jmp  short ExtractPass0OK
CompressedWordNotFound:
          dec  di
          dec  di
          dec  al
          scasw
          jnz  short CompressedWordNotFoundInPass1
          mov  [Pass],1
          call ExtractCompressedWord
          call GetSTRSize
          jmp  short ExtractPass1OK
CompressedWordNotFoundInPass1:
          dec  di
ExtractPass1OK:
          inc  al
ExtractPass0OK:
          loop short NextDwordCheckInPCIStr
          inc  bx
          inc  bx
          jmp  short NextCompressedDword
EndOffPCICompresList:
          pop  bp
          pop  di
          pop  si
          pop  cx
          pop  bx
          pop  ax
          ret
ENDP UnpackPCIString

PROC ExtractCompressedWord
          push ax
          push cx
          push bx
          push si
;          push di
          call GetSTRSize
          mov  si,[word ds:bx]
int 3
          cmp  [Pass],0
          jz   short DetectFirstPass
          inc  si
DetectFirstPass:
          push si
          push di
          push cx
          xchg di,si
          call GetSTRSize
          dec  cx
          mov  bx,cx
          mov  di,si
          add  di,cx
          dec  di
          dec  di
          pop  cx
          add  si,cx
          dec  si
          add  di,cx
          dec  di
          std
          rep  movsb
          pop  di
          pop  si
          dec  di
          dec  di
          mov  cx,bx
          cld
          rep  movsb
;          pop  di
          pop  si
          pop  bx
          pop  cx
          pop  ax
          ret
ENDP ExtractCompressedWord

PROC GetSTRSize
          push di
          push ax
          sub  al,al
          mov  cx,255
          push cx
          repnz scasb
          pop  ax
          sub  ax,cx
          mov  cx,ax     ;Длинна строки
          pop  ax
          pop  di
          ret
ENDP GetSTRSize

PROC ErrorDiv
          ret
ENDP ErrorDiv



          ENDS Cseg

          SEGMENT EndPrgSeg Page Public 'CODE'
          DB 'EndPrgSeg'
          ENDS EndPrgSeg


          END      Start
