%TITLE    "PCI List Compressor Ver 2.01 Coded by Vladimir Afanasiev 25-Oct-2001"
          IDEAL
          MODEL small
          P386
          STACK 256
LenBuffer EQU 16384   ; Размер буффера для работы
          DATASEG
welcome     DB 'PCI .ASM List Compressor Ver 2.01 25-Oct-2001',13,10,10,'Working... $'
filename    DB 'PCIDEV_.ASM',0,'$'
nofile      DB 'File Not Faund ','$'
readonly    DB 'Can Not Get Access',13,10,'$'
MesOK       DB 'Compression Finished',13,10,'$'
meserror    DB 'Erorr',13,10,'$'
hiword      DW ?
loword      DW ?
Deskriptor  DW 0
BytesReaded DW 0
EndWork     DB 0
Pass        DB 0
strpath     DB LenBuffer DUP(?)
      DB LenBuffer DUP(?)

ALIGN 2

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
                    DW offset DeCompressedMes01+1  ;- 0829               - 0780
                    DW offset DeCompressedMes03+1  ;- 0021               - 0003
                    DW offset DeCompressedMes04+1  ;- 0042               - 0037
                    DW offset DeCompressedMes05+1  ;- 0060               - 0000
                    DW offset DeCompressedMes06+1  ;- 0030               - 0007
                    DW offset DeCompressedMes07+1  ;- 0013               - 0002
                    DW offset DeCompressedMes08+1  ;- 0101               - 0095
                    DW offset DeCompressedMes10+1  ;- 0015               - 0010
                    DW offset DeCompressedMes13+1  ;- 0074               - 0065
                    DW offset DeCompressedMes15+1  ;- 0031               - 0026
                    DW offset DeCompressedMes20+1  ;- 0234               - 0226
                    DW offset DeCompressedMes22+1  ;- 0035               - 0025
                    DW offset DeCompressedMes24+1  ;- 0023               - 0018
                    DW offset DeCompressedMes26+1  ;- 0078               - 0012
                    DW offset DeCompressedMes30+1  ;- 0070               - 0065
                    DW offset DeCompressedMes31+1  ;- 0080               - 0073
                    DW offset DeCompressedMes35+1  ;- 0085               - 0072
                    DW offset DeCompressedMes38+1  ;- 0057               - 0040
                    DW offset DeCompressedMes41+1  ;- 0032               - 0013
                    DW offset DeCompressedMes42+1  ;- 0057               - 0020
                    DW offset DeCompressedMes43+1  ;- 0024               - 0019
                    DW offset DeCompressedMes44+1  ;- 0052               - 0036
                    DW offset DeCompressedMes46+1  ;- 0030               - 0015
                    DW offset DeCompressedMes47+1  ;- 0064               - 0039
                    DW offset DeCompressedMes49+1  ;- 0149               - 0077
                    DW offset DeCompressedMes51+1  ;- 0067               - 0050
                    DW offset DeCompressedMes53+1  ;- 0043               - 0025
                    DW offset DeCompressedMes54+1  ;- 0111               - 0098
                    DW offset DeCompressedMes57+1  ;- 0186               - 0162
                    DW offset DeCompressedMes58+1  ;- 0114               - 0015
                    DW offset DeCompressedMes59+1  ;- 0188               - 0083
                    DW offset DeCompressedMes60+1  ;- 0091               - 0022
                    DW offset DeCompressedMes61+1  ;- 0069               - 0043
                    DW offset DeCompressedMes62+1  ;- 0036               - 0013
                    DW offset DeCompressedMes63+1  ;- 0140               - 0133
                    DW offset DeCompressedMes64+1  ;- 0145               - 0104
                    DW offset DeCompressedMes65+1  ;- 0183               - 0170
                    DW offset DeCompressedMes66+1  ;- 0227               - 0207
                    DW offset DeCompressedMes67+1  ;- 0107               - 0089
                    DW offset DeCompressedMes69+1  ;- 0067               - 0043
                    DW offset DeCompressedMes70+1  ;- 0051               - 0034
                    DW offset DeCompressedMes71+1  ;- 0052               - 0041
                    DW offset DeCompressedMes72+1  ;- 0217               - 0187
                    DW offset DeCompressedMes73+1  ;- 0066               - 0048
                    DW offset DeCompressedMes75+1  ;- 0126               - 0113
                    DW offset DeCompressedMes76+1  ;- 0207               - 0163
                    DW offset DeCompressedMes77+1  ;- 0127               - 0117
                    DW offset DeCompressedMes78+1  ;- 0851               - 0541
                    DW offset DeCompressedMes80+1  ;- 0851               - 0541
                    DW offset DeCompressedMes81+1
                    DW 0

DeCompressedMes00   DB ' GUI+3D Accelerator',0
DeCompressedMes01   DB ' GUI',0
DeCompressedMes02   DB ' Accelerator',0
DeCompressedMes03   DB ' Ethernet',0
DeCompressedMes04   DB ' LAN',0
DeCompressedMes05   DB ' Creative',0
DeCompressedMes06   DB ' DMA',0
DeCompressedMes07   DB ' Netelligent',0
DeCompressedMes08   DB ' AGP',0
DeCompressedMes09   DB ' Millennium',0
DeCompressedMes10   DB ' Multimedia',0
DeCompressedMes11   DB ' Management',0
DeCompressedMes12   DB ' Controller',0
DeCompressedMes13   DB ' Wide',0
DeCompressedMes14   DB ' Integrated',0
DeCompressedMes15   DB ' Token Ring',0
DeCompressedMes16   DB ' Compatible',0
DeCompressedMes17   DB ' BusMaster',0
DeCompressedMes18   DB ' Processor',0
DeCompressedMes19   DB ' Interface',0
DeCompressedMes20   DB ' Ether',0
DeCompressedMes21   DB ' Internal',0
DeCompressedMes22   DB ' Graphics',0
DeCompressedMes23   DB ' FireWire',0
DeCompressedMes24   DB ' Parallel',0
DeCompressedMes25   DB ' Aladdin',0
DeCompressedMes26   DB ' GeForce',0
DeCompressedMes27   DB ' Digital',0
DeCompressedMes28   DB ' Adapter',0
DeCompressedMes29   DB ' with',0
DeCompressedMes30   DB ' Channel',0
DeCompressedMes31   DB ' Cardbus',0
DeCompressedMes32   DB ' Chipset',0
DeCompressedMes33   DB ' ISDN',0
DeCompressedMes34   DB ' Decoder',0
DeCompressedMes35   DB ' 10/100',0
DeCompressedMes36   DB ' Bridge',0
DeCompressedMes37   DB ' Device',0
DeCompressedMes38   DB ' Serial',0
DeCompressedMes39   DB ' System',0
DeCompressedMes40   DB ' Memory',0
DeCompressedMes41   DB ' VooDoo',0
DeCompressedMes42   DB ' Savage',0
DeCompressedMes43   DB ' SDRAM',0
DeCompressedMes44   DB ' Dual',0
DeCompressedMes45   DB ' Speed',0
DeCompressedMes46   DB ' Sound',0
DeCompressedMes47   DB ' Power',0
DeCompressedMes48   DB ' Board',0
DeCompressedMes49   DB ' Modem',0
DeCompressedMes50   DB ' Audio',0
DeCompressedMes51   DB ' Video',0
DeCompressedMes52   DB ' North',0
DeCompressedMes53   DB ' Multi',0
DeCompressedMes54   DB ' ISA',0
DeCompressedMes55   DB ' Fibre',0
DeCompressedMes56   DB ' Frame',0
DeCompressedMes57   DB ' Card',0
DeCompressedMes58   DB ' Riva',0
DeCompressedMes59   DB ' Mode',0
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
DeCompressedMes70   DB ' ATM',0
DeCompressedMes71   DB ' USB',0
DeCompressedMes72   DB ' Pro',0
DeCompressedMes73   DB ' Bus',0
DeCompressedMes74   DB ' I/O',0
DeCompressedMes75   DB ' Ultra',0
DeCompressedMes76   DB ' PCI to',0
DeCompressedMes77   DB ' CPU to',0
DeCompressedMes78   DB ' PCI',0
DeCompressedMes79   DB ' TNT',0
DeCompressedMes80   DB ' 256',0;' Smart',0
DeCompressedMes81   DB ' 128',0

          CODESEG

Start:

          mov      ax, @data       ;Установка в DS адреса
          mov      ds, ax          ;сегмента данных
          mov      es, ax          ;ES=DS
          mov      dx,offset welcome
          call     PrnMes
          mov      dx,offset filename  ; Попытка
          mov      ax,3D02h            ; открыть файл
          int      21h                 ; для чтения / записи
          jnc      dalee           ; Переход если нет ошибок

ErrorReading:
error:    cmp      al,2                   ;
          jnz      @@20                   ;  Обработка
          mov      dx,offset nofile       ;  возможных
          call     PrnMes
          mov      dx,offset filename
          jmp      short mesexit          ;  ошибок
@@20:     cmp      al,5                   ;  и выход из программы
          jnz      @@50                   ;
          mov      dx,offset readonly     ;
          jmp      short mesexit          ;
@@50:     mov      dx,offset meserror     ;
mesexit:  call     PrnMes                 ;
Exiterr:  mov      ax, 04C00h          ;Закрыть файл и выйти из программы
          int      21h
dalee:
          mov      [Deskriptor],ax     ;Загрузить дескриптор файла
longloop: call     NahFilePos          ; Установить указатель файла на начало

GetStartString:
          call     ReadFile          ; файла равный размеру буфера
          jc       error
          mov      si,offset strpath
          mov      cx,LenBuffer
NextByteToTest:
          cmp      [dword ds:si],'BD 1'
          jz       short FaindStartString
          inc      si
          loop     NextByteToTest
          jmp      short GetStartString
FaindStartString:

          jmp      short GoToCompressedStrings


FaindToNextBufferFrame:
          mov      si,offset strpath
          mov      cx,LenBuffer
GoToCompressedStrings:
ALIGN 2

NextByteToTestInWorkBuf:
          cmp      cx,256
          jb       short EndBufferDetected
          cmp      [word ds:si],'BD'
          jnz      short NotFaindEndString
          cmp      [word ds:si+5],'h0'
          jnz      short NotFaindEndString
          call     PackingPCIString
NotFaindEndString:
          inc      si
          loop     NextByteToTestInWorkBuf
EndBufferDetected:
          call     GetFilePos
          mov      ax,[BytesReaded]
          sub      [loword],ax
          sbb      [hiword],0
          call     NewFilePos
          call     WriteFile                 ;
          cmp      [EndWork],1
          jz       short EndOfFile
          call     GetFilePos
          sub      [loword],512
          sbb      [hiword],0
          call     NewFilePos

          call     ReadFile            ; файла равный размеру буфера
          jc       ErrorReading
          cmp      ax,LenBuffer        ; Переход если
          jz       short NotEndOfFile  ; конец файла
          mov      [EndWork],1

NotEndOfFile:
          jmp      short FaindToNextBufferFrame

EndOfFile:
          mov      dx,offset MesOK
          call     PrnMes
          mov      ax, 04C00h ;Закрыть файл и выйти из программы
          int      21h

PROC NahFilePos               ;Подпрограмма для установки в начало файла
          xor    ax,ax
          mov    [hiword],ax
          mov    [loword],ax
PROC NewFilePos             ; Подпрограмма для установки позиции в файле
          push     bx
          push     cx
          push     dx
          push     si
          push     di
          mov    cx,[hiword]
          mov    dx,[loword]
          mov    bx,[Deskriptor]
          mov    ax,4200h
          int    21h
          pop      di
          pop      si
          pop      dx
          pop      cx
          pop      bx
          ret
ENDP NewFilePos
ENDP NahFilePos

PROC GetFilePos
          push     bx
          push     cx
          push     dx
          push     si
          push     di
          xor      cx,cx             ;  Получить
          xor      dx,dx             ;  позицию
          mov      ax,04201h         ;  указателя
          mov      bx,[Deskriptor]
          int      21h               ;  и
          mov      [hiword],dx       ;  запомнить
          mov      [loword],ax       ;  ее
          pop      di
          pop      si
          pop      dx
          pop      cx
          pop      bx
          ret
ENDP GetFilePos


PROC WriteFile               ; Подпрограмма для чтения или записи файла
          push     bx
          push     cx
          push     dx
          mov    bx,[Deskriptor]
          mov    ah,40h
          mov    cx,[BytesReaded]
          mov    dx,offset strpath
          int    21h
          pop      dx
          pop      cx
          pop      bx
          ret
ENDP WriteFile

PROC ReadFile
          push     bx
          push     cx
          push     dx
          mov    bx,[Deskriptor]
          mov    ah,3Fh              ; В  ВХ помещен дескриптор файла
          mov    cx,LenBuffer
          mov    dx,offset strpath
          int    21h
          pop      dx
          pop      cx
          pop      bx
          mov      [BytesReaded],ax
          ret
ENDP ReadFile

PROC PrnMes
          mov    ah,09h
          int    21h
          ret
ENDP PrnMes

ALIGN 2
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

          mov  bp,123
          mov  bx,offset DeCompressedListOfs
ALIGN 2
NextTestCompresedListString:
          mov  di,[word ds:bx]
          or   di,di
          jz   short EndOfDeCompressedList
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
          mov  ax,bp
          mov  [byte ds:si],al
          add  di,cx
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
ALIGN 2
NotFaundPackingString:
          inc  si
          dec  dx
          jnz  short NextTestStringOffset
          pop  dx
          pop  si
          inc  bx
          inc  bx
          inc  bp
          jmp  short NextTestCompresedListString

EndOfDeCompressedList:
int 3
          pop  bp
          pop  di
          pop  si
          pop  dx
          pop  cx
          pop  bx
          pop  ax
          ret
ENDP PackingPCIString

ALIGN 2
PROC UnpackPCIString ; si - stroka
          push ax
          push bx
          push cx
          push si
          push di
          push bp
          mov  bp,si
          mov  ax,123
          mov  bx,offset DeCompressedListOfs
          cld
NextCompressedDword:
          cmp  [word ds:bx],0
          jz   short EndOffPCICompresList

          mov  di,bp
          call GetSTRSize
NextInStringCheck:
          repnz scasb
          jnz  short CompressedByteNotFound
          call ExtractCompressedByte
          call GetSTRSize
          jmp  short NextInStringCheck
CompressedByteNotFound:
          inc  bx
          inc  bx
          inc  al
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

ALIGN 2
PROC ExtractCompressedByte
          push ax
          push cx
          push bx
          push si
          call GetSTRSize
          mov  si,[word ds:bx]
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
          mov  cx,bx
          cld
          rep  movsb
          pop  si
          pop  bx
          pop  cx
          pop  ax
          ret
ENDP ExtractCompressedByte

ALIGN 2
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

          END      Start