
       %TITLE    " Win32 модуль Ver 1.48 24-Jun-2003"

.586
.model flat, stdcall
option casemap :none   ; case sensitive

      include \masm32\include\windows.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\advapi32.inc

      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\advapi32.lib


        StopTimerGetMBInSec     PROTO :DWORD

.data

ALIGN 16
ClockPerSec     DD ?
NumMsec         DD ?

ALIGN 16
MesSST          DB 'SST_'
Frequency       DD 0
GetVerEAX       DD 0
MemStatus       DD 8 DUP(0)
ComputerName    DB 16 DUP(0)
UserName        DB 16 DUP(0)
MSR0000011E     DD 0
NumDrive        DD 0
DriveBuffer     DD 7*8 DUP(0)
MSRC0000082     DD 0
MSRC0000087     DD 0
MSRC0010015     DD 0
MSR00000017edx  DD 0
MSR0000002A     DD 0
MSR0000002C     DD 0
MicrocodeRev    DD 0
NumDriveName0   DB 40 DUP(0)
AtaAtapiPM      DW 0,8 DUP(0),15 DUP(0),5 DUP(0)
NumDriveName1   DB 40 DUP(0)
AtaAtapiPS      DW 0,8 DUP(0),15 DUP(0),5 DUP(0)
NumDriveName2   DB 40 DUP(0)
AtaAtapiSM      DW 0,8 DUP(0),15 DUP(0),5 DUP(0)
NumDriveName3   DB 40 DUP(0)
AtaAtapiSS      DW 0,8 DUP(0),15 DUP(0),5 DUP(0)
NumDriveName4   DB 40 DUP(0)
AtaAtapiTM      DW 0,8 DUP(0),15 DUP(0),5 DUP(0)
NumDriveName5   DB 40 DUP(0)
AtaAtapiTS      DW 0,8 DUP(0),15 DUP(0),5 DUP(0)
NumDriveName6   DB 40 DUP(0)
AtaAtapiQM      DW 0,8 DUP(0),15 DUP(0),5 DUP(0)
NumDriveName7   DB 40 DUP(0)
AtaAtapiQS      DW 0,8 DUP(0),15 DUP(0),5 DUP(0)
AtaDrive        DB 0
AtapiCDROM      DB 0

MemBand         DD 0

nSize           DD 16
DrvBufSize      DD 0
FileHandle      DD ?
BytesReaded     DD offset nSize-offset MesSST
filename        DB 'C:\SSTRES.TMP',0
PhysDrive       DB '\\.\PHYSICALDRIVE'
NumPhysDrive    DB '0',0

StepCPU         DB 0
CPUmodel        DB 0   ;* не
CPUfamily       DB 0   ;* менять
CPUtype         DB 0   ;* порядок
IntelExtendedFamily DB 0   ; 27-20 8 bit
IntelExtendedModel  DB 0   ; 19-16 4 bit
BrandID         DB 0

AMDProcessor    DB 0
IntelProcessor  DB 0
CyrixProcessor  DB 0
IDTProcessor    DB 0
AuthenticAMD    DB 'AuthenticAMD'
GenuineIntel    DB 'GenuineIntel'
CyrixInstead    DB 'CyrixInstead'
CentaurHauls    DB 'CentaurHauls'

VendorIDstring1 DD 0
VendorIDstring2 DD 0
VendorIDstring3 DD 0

FeatureFlagMSR  DB 0

hMemory         DD ?
WorkBuffer      DD ?
IDE0BaseIO      DW 1F0h
IDE1BaseIO      DW 170h
IDE2BaseIO      DW 0;1E8h
IDE3BaseIO      DW 0;168h

ATAPIPacket     DB 5Ah
                DB 0
ATAPIPage       DB ?
                DB 4 DUP(0)
ATAPIPageLength DW ?
                DB 3 DUP(0)

NumTimerLow     DD ?
NumTimerHigh    DD ?
TSC250ms        DD ?
MemoryBaseAdr   DD ?
hMemoryBaseAdr  DD ?
NumAveraging1   DD 0
NumAveraging2   DD 0
NumAveraging3   DD 0
NumAveraging4   DD 0
NumAveraging5   DD 0

StructRDMSR     DB 12 DUP (0)
ProcRDMSR       DB 00Fh,032h,0CBh,0

.code

Start:


        invoke  GetCurrentProcess
        invoke  SetPriorityClass, eax, REALTIME_PRIORITY_CLASS
        invoke  GetCurrentThread
        invoke  SetThreadPriority, eax, THREAD_PRIORITY_TIME_CRITICAL

        invoke  GetVersion
        mov     [GetVerEAX],eax
        cmp     al,4
        jb      VersionError
        mov     [NumDriveName0],148
        invoke  GetVersionEx, offset NumDriveName0
        cmp     [NumDriveName0+4],5
        jnz     short NotWin2000orXP
        cmp     [NumDriveName0+8],1
        jnz     short NotWinXP
        mov     byte ptr [GetVerEAX],128+6 ;WinXP
NotWinXP:
        cmp     [NumDriveName0+8],2
        jnz     short NotWinNET
        mov     byte ptr [GetVerEAX],128+7 ;WinNET
NotWinNET:


NotWin2000orXP:
        mov     edi,offset NumDriveName0
        mov     ecx,148/4
        sub     eax,eax
        cld
        rep stosd

        invoke CreateFile,offset filename,GENERIC_READ+GENERIC_WRITE,FILE_SHARE_READ+FILE_SHARE_WRITE,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
        cmp     eax,INVALID_HANDLE_VALUE
        jne     FileCreateOK
VersionError:
        ret
FileCreateOK:
        mov     [FileHandle],eax

        invoke  GlobalMemoryStatus, offset MemStatus

        invoke  GlobalAlloc, GHND or GMEM_SHARE, 0FFFFh ; Allocate memory 65536 byte
        mov     [hMemory],eax                        ; Handle to memory
        or      eax,eax
        jz      short VersionError
        invoke  GlobalLock,eax
        mov     [WorkBuffer],eax

        mov     esi,offset DriveBuffer
DetectNextDrive:

        invoke CreateFile,offset PhysDrive,GENERIC_READ+GENERIC_WRITE,FILE_SHARE_READ+FILE_SHARE_WRITE,NULL,OPEN_EXISTING,0,NULL
        cmp      eax,INVALID_HANDLE_VALUE
        jz       FixedDiskNotFound
        invoke DeviceIoControl,eax,70000h ,NULL,0,esi,1Ch,offset DrvBufSize,NULL
        or       eax,eax
        jz       short DriveNotFound
        inc      [NumDrive]
DriveNotFound:
        add      esi,1Ch
        inc      [NumPhysDrive]
        cmp      [NumPhysDrive],8
        jnz      DetectNextDrive
FixedDiskNotFound:


        invoke GetComputerName, offset ComputerName,offset nSize
        invoke GetUserName, offset UserName,offset nSize

        pushfd
        pop     ecx
        mov     eax,ecx
        xor     eax,000200000h
        push    eax
        popfd
        pushfd
        pop     eax
        xor     eax,ecx
        je      NotSupportQueryPerformanceFrequency
        sub     eax,eax
        cpuid
        mov     [VendorIDstring1],ebx
        mov     [VendorIDstring2],edx
        mov     [VendorIDstring3],ecx
        mov     edi,offset AuthenticAMD
        call    CompareVendors
        jnz     short NotAMDprocessor
        mov     [AMDProcessor],1
NotAMDprocessor:
        mov     edi,offset GenuineIntel
        call    CompareVendors
        jnz     short NotIntelprocessor
        mov     [IntelProcessor],1
NotIntelprocessor:
        mov     edi,offset CyrixInstead
        call    CompareVendors
        jnz     short NotCyrixprocessor
        mov     [CyrixProcessor],1
NotCyrixprocessor:
        mov     edi,offset CentaurHauls
        call    CompareVendors
        jnz     short NotIDTprocessor
        mov     [IDTProcessor],1
NotIDTprocessor:

        cmp     al,1
        jb      NotSupportQueryPerformanceFrequency
        mov     eax,1
        sub     ebx,ebx
        cpuid
        mov     [BrandID],bl
        push    eax
        and     al,0Fh
        mov     [StepCPU],al
        pop     eax
        shr     eax,4
        push    eax
        and     al,0Fh
        mov     [CPUmodel],al
        pop     eax
        shr     eax,4
        push    eax
        and     al,0Fh
        mov     [CPUfamily],al
        pop     eax
        shr     eax,4
        push    eax
        and     al,03h
        mov     [CPUtype],al
        pop     eax
        shr     eax,4
        push    eax
        and     al,0Fh
        mov     [IntelExtendedModel],al
        pop     eax
        shr     eax,4
        mov     [IntelExtendedFamily],al

        test    edx,20h
        jz      short NotSupportMSRinstr
        mov     [FeatureFlagMSR],1
NotSupportMSRinstr:

        test    edx,10h ;TSC support ?
        jz      NotSupportQueryPerformanceFrequency
        invoke  QueryPerformanceFrequency, offset ClockPerSec
        or      eax,eax
        jz      NotDetectFrequency

        shr      [ClockPerSec],2
        invoke   QueryPerformanceCounter, offset NumMsec
        mov      ebx,[NumMsec]
WaitPerformanceCounter:
        invoke   QueryPerformanceCounter, offset NumMsec
        rdtsc
        mov      ecx,[NumMsec]
        cmp      ecx,ebx
        jz       short WaitPerformanceCounter

        push     eax
        push     edx

        add      ecx,[ClockPerSec]
        mov      ebx,ecx
Wait250ms:
        invoke   QueryPerformanceCounter, offset NumMsec
        rdtsc
        mov      ecx,[NumMsec]
        cmp      ecx,ebx
        jb       short Wait250ms

        pop     ecx
        pop     ebx

        sub     eax,ebx
        sbb     edx,ecx

        push    eax
        push    edx
        shrd    eax,edx,2
        mov     TSC250ms,eax
        pop     edx
        pop     eax

        mov     ebx,2500
        div     ebx
        mov     [Frequency],eax

        invoke  GlobalAlloc, GPTR,16*1024*1024+128*1024
        mov     hMemoryBaseAdr,eax
        invoke  GlobalLock,hMemoryBaseAdr

        add     eax,0FFFFh
        sub     ax,ax

        mov     MemoryBaseAdr,eax

        call    DetectMemBand

        invoke  GlobalUnlock,hMemoryBaseAdr
        invoke  GlobalFree,hMemoryBaseAdr

NotDetectFrequency:

        test    [GetVerEAX],80000000h
        jz      NotSupportQueryPerformanceFrequency
        mov       edx,offset ProcRDMSR
        mov       eax,offset StructRDMSR
        mov       ecx,eax
        sgdt      [ecx]
        mov       edi,[ecx+2]
        sldt      ax
        and       eax,0FFF8h
        add       edi,eax
        mov       eax,[edi+2]
        mov       [ecx],eax
        mov       al,[edi+7]
        mov       [ecx+3],al
        mov       ax,[edi]
        and       al,0F8h
        movzx     eax,ax
        mov       [ecx+4],eax
        mov       edi,[ecx]
m3:
        cmp       dword ptr [eax+edi],0
        jne       m1
        cmp       dword ptr [eax+edi+4],0
        je        m2
m1:
        sub       eax,8
        jns       m3
        jmp  NotSupportQueryPerformanceFrequency

m2:     add       edi,eax
        add       al,7
        mov       [ecx+4],ax
        mov       [edi],edx
        mov       eax,0EC000028h
        xchg      eax,[edi+2]
        mov       [edi+6],ax
        mov       [ecx+6],edi

        call      DetectIDEDriveName

        cmp     [FeatureFlagMSR],1
        jnz     NotSupportQueryPerformanceFrequency

        call      GetCPUMSRs


NotSupportQueryPerformanceFrequency:


         mov      esi,offset MesSST
         mov      edi,esi
         mov      ecx,[BytesReaded]
         cld
NextByteCripting:
         lodsb
         or       al,al
         jz       short CanNotCript
         cmp      al,5Ah
         jz       short CanNotCript
         xor      al,5Ah
CanNotCript:
         stosb
         loop     NextByteCripting

         invoke GlobalUnlock, [WorkBuffer]
         invoke GlobalFree, [hMemory]
         invoke WriteFile,[FileHandle],offset MesSST ,[BytesReaded],offset BytesReaded,NULL
         invoke CloseHandle,[FileHandle]
         ret

GetCPUMSRs PROC

          cmp     [IntelProcessor],1
          jnz     NotIntelProcesorForRDMSR
          cmp     [CPUfamily],6
          jnz     NotIntelP6ForRDMSR
          cmp     [CPUmodel],3
          jb      NotIntelP6ForRDMSR
          jz      CanNotGetPlatformID
          cmp     [CPUmodel],0Bh
          ja      NotIntelP6ForRDMSR
          mov     ecx,17h
          call    CommandRDMSR
          or      edx,80000000h
          mov     [MSR00000017edx],edx
CanNotGetPlatformID:
          mov     ecx,2Ah
          call    CommandRDMSR
          or      eax,80000000h
          mov     [MSR0000002A],eax
          mov     ecx,11Eh
          call    CommandRDMSR
          or      eax,80000000h
          mov     [MSR0000011E],eax
          call    GetMicrocodeRev
          jmp     NotIntelProcesorForRDMSR
NotIntelP6ForRDMSR:
          cmp     [CPUfamily],0Fh
          jnz     NotIntelP4ForRDMSR
          cmp     [IntelExtendedFamily],0
          jnz     NotIntelP4ForRDMSR
          cmp     [CPUmodel],2
          ja      NotIntelP4ForRDMSR
          mov     ecx,2Ah
          call    CommandRDMSR
          or      eax,80000000h
          mov     [MSR0000002A],eax
          mov     ecx,2Ch
          call    CommandRDMSR
          or      eax,80000000h
          mov     [MSR0000002C],eax
          call    GetMicrocodeRev
          mov     ecx,17h
          call    CommandRDMSR
          or      edx,80000000h
          mov     [MSR00000017edx],edx
          jmp     NotIntelProcesorForRDMSR
NotIntelP4ForRDMSR:

NotIntelProcesorForRDMSR:
          cmp     [AMDProcessor],1
          jnz     short NotAMDProcesorForRDMSR
          cmp     [CPUfamily],5
          jnz     short GoToDetectAMDAthlonMSRs
          cmp     [CPUmodel],8
          jz      short GoToGetAMDMSRsModel8
          jb      short NotAMDProcesorForRDMSR
          jmp     short GoToGetAMDMSRs
GoToGetAMDMSRsModel8:
          cmp     [StepCPU],8
          jb      short NotAMDProcesorForRDMSR
GoToGetAMDMSRs:
          mov     ecx,0C0000082h
          call    CommandRDMSR
          or      eax,80000000h
          mov     [MSRC0000082],eax
          mov     ecx,0C0000087h
          call    CommandRDMSR
          or      eax,80000000h
          mov     [MSRC0000087],eax
GoToDetectAMDAthlonMSRs:

          cmp     [CPUfamily],6
          jnz     short NotAMDProcesorForRDMSR
          cmp     [CPUmodel],10
          ja      short NotAMDProcesorForRDMSR
          mov     ecx,0C0010015h
          call    CommandRDMSR
          or      eax,80000000h
          mov     [MSRC0010015],eax

NotAMDProcesorForRDMSR:
          cmp     [CyrixProcessor],1
          jnz     short NotCyrixProcesorForRDMSR
          cmp     [CPUfamily],6
          jnz     short NotCyrixProcesorForRDMSR
          cmp     [CPUmodel],5
          jnz     short NotCyrixProcesorForRDMSR
          mov     ecx,2Ah
          call    CommandRDMSR
          or      eax,80000000h
          mov     [MSR0000002A],eax
NotCyrixProcesorForRDMSR:
          cmp     [IDTProcessor],1
          jnz     short NotIDTProcesorForRDMSR
          cmp     [CPUfamily],6
          jnz     short NotIDTProcesorForRDMSR
          cmp     [CPUmodel],6
          jb      short NotIDTProcesorForRDMSR
          cmp     [CPUmodel],7
          ja      short NotIDTProcesorForRDMSR
          mov     ecx,2Ah
          call    CommandRDMSR
          or      eax,80000000h
          mov     [MSR0000002A],eax
NotIDTProcesorForRDMSR:
          ret
GetCPUMSRs ENDP

CompareVendors PROC
          mov     esi,offset VendorIDstring1
          mov     ecx,12
          cld
          repe cmpsb
          ret
CompareVendors ENDP

CommandOUTDXAL PROC
          mov     word ptr [ProcRDMSR],090EEh
          push    ebx
          mov     ebx,offset StructRDMSR
          call    far ptr [ebx]
          pop     ebx
          ret
CommandOUTDXAL ENDP

CommandOUTDXAX PROC
          mov     word ptr [ProcRDMSR],0EF66h
          push    ebx
          mov     ebx,offset StructRDMSR
          call    far ptr [ebx]
          pop     ebx
          ret
CommandOUTDXAX ENDP

CommandINALDX PROC
          mov     word ptr [ProcRDMSR],090ECh
          push    ebx
          mov     ebx,offset StructRDMSR
          call    far ptr [ebx]
          pop     ebx
          ret
CommandINALDX ENDP

CommandINAXDX PROC
          mov     word ptr [ProcRDMSR],0ED66h
          push    ebx
          mov     ebx,offset StructRDMSR
          call    far ptr [ebx]
          pop     ebx
          ret
CommandINAXDX ENDP

CommandRDMSR PROC
          mov     word ptr [ProcRDMSR],0320Fh
          push    ebx
          mov     ebx,offset StructRDMSR
          call    far ptr [ebx]
          pop     ebx
          ret
CommandRDMSR ENDP

CommandWRMSR PROC
          mov     word ptr [ProcRDMSR],0300Fh
          push    ebx
          mov     ebx,offset StructRDMSR
          call    far ptr [ebx]
          pop     ebx
          ret
CommandWRMSR ENDP

DetectIDEDriveName PROC

          push    bp
          push    es

          push    ds
          pop     es

          sub     bp,bp
          mov     dx,[IDE0BaseIO]            ;P
          mov     esi,offset NumDriveName0
          call    DetectAtaDevice
          mov     esi,offset NumDriveName1
          call    DetectAtaDevice
          mov     dx,[IDE1BaseIO]            ;S
          mov     esi,offset NumDriveName2
          call    DetectAtaDevice
          mov     esi,offset NumDriveName3
          call    DetectAtaDevice
          mov     dx,[IDE2BaseIO]            ;T
          mov     esi,offset NumDriveName4
          call    DetectAtaDevice
          mov     esi,offset NumDriveName5
          call    DetectAtaDevice             ;Q
          mov     dx,[IDE3BaseIO]
          mov     esi,offset NumDriveName6
          call    DetectAtaDevice
          mov     esi,offset NumDriveName7
          call    DetectAtaDevice
          pop     es
          pop     bp
          ret
DetectIDEDriveName ENDP

DetectAtaDevice PROC     ;получаем ATA параметры

          push    ax
          push    dx

          or      dx,dx
          jz      ATAdriveNotFound

          add     dx,6
          call    CommandINALDX
          and     al,0EFh
          mov     bx,bp
          and     bl,1
          shl     bl,4
          or      al,bl
          call    CommandOUTDXAL
          add     dx,200h
          mov     al,8
          call    CommandOUTDXAL
          sub     dx,205h
          sub     al,al
          call    CommandOUTDXAL
          add     dx,6

          call    WaitingBusyAndDRQClear
          jnc     short DriveStateOK
          test    al,80h
          jnz     ATAdriveNotFound
          call    WaitDRQClear

DriveStateOK:
          mov     ax,200h
          call    SetATABlockSize

          mov     al,0ECh ;Identify Device
          call    CommandOUTDXAL

          call    WaitBusyAndDataRequest
          jnc     short ATAdriveIsReady
          test    al,80h
          jnz     ATAdriveNotFound
          test    al,1h
          jz      ATAdriveNotFound

          call    GetATABlockSize
          cmp     cx,0EB14h ; ATAPI Device?
          jz      short FaindATAPIDevices
          jmp     ATAdriveNotFound

ATAdriveIsReady:
          mov     cx,100h
          call    AtaAtapiGetParam
          jc      ATAdriveNotFound

          mov     edi,[WorkBuffer]

          test    byte ptr [edi+1],80h
          jne     ATAdriveNotFound

          push    dx
          movzx   eax,word ptr [edi+2]        ;Определяем
          movzx   ebx,word ptr [edi+6]        ;размер
          mul     ebx                       ;жесткого
          movzx   ebx,word ptr [edi+12]       ;диска
          mul     ebx                       ;в MB.
          pop     dx
          shr     eax,11
          cmp     eax,819200
          ja      ATAdriveNotFound    ;Error если больше 800 GB

          call    GetATAScecInfo

          call    GetAtaAtapiDriveName
          jc      ATAdriveNotFound

;int 3
          call    GetRPM

          inc     [AtaDrive]
          mov     word ptr [esi+32+8],8000h ; признак ATA устройства
          clc
          jmp     ATAdriveIsFound

FaindATAPIDevices:
;          sub     dx,6
;          in      al,dx
;          add     dx,6
;          test    al,100b
;          jz      short ATAdriveNotFound

          mov     ax,200h
          call    SetATABlockSize
          mov     al,0A1h ;ATAPI Identify Device
          call    CommandOUTDXAL

          call    WaitBusyAndDataRequest
          jc      ATAdriveNotFound

          mov     cx,100h
          call    AtaAtapiGetParam
          jc      ATAdriveNotFound

          mov     edi,[WorkBuffer]
          mov     al,byte ptr [edi+1]
          and     al,11000000b ;Bit 15,14=10-ATAPI
          cmp     al,80h
          jnz     ATAdriveNotFound

          call    GetATAPIScecInfo

          call    GetAtaAtapiDriveName
          jc      short ATAdriveNotFound;CDdriveNotFound
          inc     [AtapiCDROM]
          mov     ah,20h
          mov     edi,[WorkBuffer]
          mov     al,byte ptr [edi+1]
          and     al,11111b ; Bit 12-8=5-CDROM
          mov     word ptr [esi+40],ax; признак ATAPI устройства

          call    GetATAPIDevParam
          jc      short ATAPIDevParamErrorInGet
          mov     edi,[WorkBuffer]
          cmp     byte ptr [edi+8],02Ah
          jz      short ATAPIDevParamOK
          call    GetATAPIDevParam
          jc      short ATAPIDevParamErrorInGet
          mov     edi,[WorkBuffer]
          cmp     byte ptr [edi+8],02Ah
          jnz     short ATAPIDevParamErrorInGet

ATAPIDevParamOK:
          cmp     byte ptr [edi+9],10h
          jl      short ATAPIDevParamErrorInGet

          mov     ax,word ptr [edi+10h] ;Max.Transfer Speed
          xchg    ah,al
          mov     word ptr [esi+88],ax
          mov     ax,word ptr [edi+14h] ;Buffer Size
          xchg    ah,al
          mov     word ptr [esi+52],ax
          mov     ax,word ptr [edi+16h] ;Current Transfer Speed
          xchg    ah,al
          mov     word ptr [esi+90],ax

          test    byte ptr [edi+11],11b
          jz      short NotCDRWDrive
          mov     ax,word ptr [edi+1Ah] ;Max. Write Speed
          xchg    ah,al
          mov     word ptr [esi+92],ax
          mov     ax,word ptr [edi+1Ch] ;Current Write Speed
          xchg    ah,al
          mov     word ptr [esi+94],ax
NotCDRWDrive:

ATAPIDevParamErrorInGet:
          clc
          jmp     short ATAdriveIsFound

ATAdriveNotFound:

          stc
ATAdriveIsFound:
          inc     bp
          pop     dx
          pop     ax
          ret
DetectAtaDevice ENDP

GetATABlockSize PROC
          dec     dx
          dec     dx
          call    CommandINALDX
          mov     ah,al
          dec     dx
          call    CommandINALDX
          add     dx,3
          mov     cx,ax
          ret
GetATABlockSize ENDP

SetATABlockSize PROC
          dec     dx
          dec     dx
          xchg    ah,al
          call    CommandOUTDXAL
          dec     dx
          mov     al,ah
          call    CommandOUTDXAL
          add     dx,3
          ret
SetATABlockSize ENDP

GetATAPIDevParam PROC

          mov     bx,4
CanNotGetATAPIPageAccess:
          call    WaitingBusyAndDRQClear
          jc      ATAPIdriveNotReadyForPacked

          sub     dx,6
          mov     al,2
          call    CommandOUTDXAL
          add     dx,6

          mov     ax,180h
          call    SetATABlockSize

          mov     al,0A0h ;ATAPI Packet
          call    CommandOUTDXAL

          call    WaitBusyAndDataRequest
          jc      short DriveNotReadyForGetATAPIPacket

          mov     [ATAPIPage],2Ah ;параметры устройства, текущие значения
          mov     [ATAPIPageLength],16h

          mov     cx,6
          call    SendAtapiPacket
          jc      short DriveNotReadyForGetATAPIPacket

          call    WaitBusyAndDataRequest
          jnc     short ATAPIPageReady
DriveNotReadyForGetATAPIPacket:
          dec     bx
          jnz     short CanNotGetATAPIPageAccess
          jmp     short ATAPIdriveNotReadyForPacked

ATAPIPageReady:
          mov     edi,[WorkBuffer]
          mov     bx,16
NextATAPIPageToGet:
          call    GetATABlockSize
          shr     cx,1
          jcxz    short ATAPIdriveNotReadyForPacked
          sub     dx,7
          cld
          cli
mmm001:
          call    CommandINAXDX
          stosw
          dec     cx
          jnz     mmm001
          sti

          add     dx,7
          call    WaitingBusyAndDRQClear
          jnc     short EndGetATAPIPages
          test    al,1h
          jnz     short ATAPIdriveNotReadyForPacked

          dec     bx
          jnz     short NextATAPIPageToGet
EndGetATAPIPages:
          test    al,1h
          jz      short ATAPIdriveReady
ATAPIdriveNotReadyForPacked:
          stc
          ret
ATAPIdriveReady:
          clc
          ret
GetATAPIDevParam ENDP

SendAtapiPacket PROC
          push    esi
          sub     dx,7
          mov     esi, offset ATAPIPacket
          cld
          cli
mmm002:
          lodsw
          call   CommandOUTDXAX
          dec    cx
          jnz    mmm002


          sti
          pop     esi
          add     dx,7
          call    CommandINALDX
          test    al,1 ;Error is Set?
          je      short ATAPISendPacketNoError
          stc
ATAPISendPacketNoError:
          ret
SendAtapiPacket ENDP

AtaAtapiGetParam PROC

          mov     edi,[WorkBuffer]
          sub     dx,7
          cld
          cli
mmm003:
          call    CommandINAXDX
          stosw
          dec     cx
          jnz     mmm003
          sti
          add     dx,7
          call    CommandINALDX
          test    al,1 ;Error is Set?
          je      short NoErrorInGetParam
          stc
NoErrorInGetParam:
          ret
AtaAtapiGetParam ENDP

WaitingBusyAndDRQClear PROC
          mov     cx,8000h; sub     cx,cx
WaitingForClearBusyAndDRQ:
          call    CommandINALDX
          test    al,88h    ; Test Bit 7 - Busy ;Bit 3 -DRQ
          je      short BusyAndDRQCleared
          dec     cx
          jnz     short WaitingForClearBusyAndDRQ
          stc
BusyAndDRQCleared:
          ret
WaitingBusyAndDRQClear ENDP


WaitingDRDYSet PROC
          mov     cx,8000h; sub     cx,cx
WaitingForSetDRDY:
          call    CommandINALDX
          test    al,40h    ; Test Bit 6 - DRDY
          jne     short DRDYIsSet
          dec     cx
          jnz     short WaitingForSetDRDY
          stc
DRDYIsSet:
          ret
WaitingDRDYSet ENDP

WaitingBusy PROC
          mov     cx,8000h; sub     cx,cx
WaitingForClearBusy:
          call    CommandINALDX
          test    al,80h    ; Test Bit 7 - Busy
          je      short BusyCleared
          dec     cx
          jnz     short WaitingForClearBusy
          stc
BusyCleared:
          ret
WaitingBusy ENDP

WaitBusyAndDataRequest PROC
          mov     cx,8000h; sub     cx,cx
WaitForDataRequest:
          call    CommandINALDX
          test    al,80h  ; Test Bit 7 - Busy
          jne     short WaitBusyFailed
          test    al,8h   ;test bit 3 - Data Request
          je      short WaitBusyFailed
          test    al,1b   ;ERR is set?
          je      short WaitDataRequestOK
          jmp     short BusyClearingFailed
WaitBusyFailed:
          dec     cx
          jnz     short WaitForDataRequest
BusyClearingFailed:
          stc
WaitDataRequestOK:
          ret
WaitBusyAndDataRequest ENDP

WaitDRQClear PROC

          mov     bx,10h
NextWaitDRQLoop:
          call    GetATABlockSize
          shr     cx,1
          jcxz    short DRQStateError
          cli
          sub     dx,7
ReadNextByte:
          call    CommandINAXDX
          dec     cx
          jnz     short ReadNextByte
          add     dx,7
          sti
          call    WaitBusyAndDataRequest
          jnc     short WaitingForGetNextPage
          test    al,81h
          jz      short DRQCleared
          jmp     short DRQStateError
WaitingForGetNextPage:
          dec     bx
          jnz     short NextWaitDRQLoop
DRQStateError:
          stc
DRQCleared:
          ret
WaitDRQClear ENDP

GetATAScecInfo PROC
          mov     ax,word ptr[edi+2]  ;celinders
          mov     word ptr [esi+34+8],ax
          mov     ax,word ptr [edi+6]  ;heads
          mov     word ptr [esi+36+8],ax
          mov     ax,word ptr [edi+12] ;sectors
          mov     word ptr [esi+38+8],ax
          call    DetectIDELBA
          mov     ax,word ptr [edi+160];revision
          mov     word ptr [esi+40+8],ax
          mov     ax,word ptr [edi+42] ;Cache Buffer Size
          shr     ax,1
          mov     word ptr [esi+44+8],ax
          call    GetATAATAPITransferMode
          ret
GetATAScecInfo ENDP

GetATAPIScecInfo PROC

          call    GetATAATAPITransferMode
          ret
GetATAPIScecInfo ENDP

GetATAATAPITransferMode PROC
          test    byte ptr [edi+106],10b
          jz      short Word6470NotValid
          mov     al,4
          test    byte ptr [edi+128],010b;PIO-4 support?
          jnz     short PIOModeDetected
          mov     al,3
          test    byte ptr [edi+128],01b;PIO-3 support?
          jnz     short PIOModeDetected
Word6470NotValid:
          mov     al,byte ptr [edi+103];PIO
          and     al,11b
          or      al,al
          jz      short PIOModeDetected
          inc     al
PIOModeDetected:
          inc     al   ; for not support detection
          mov     byte ptr [esi+46+8],al   ;PIO

          mov     al,3
          mov     bl,byte ptr [edi+63*2]
          test    bl,100b ;DMA 2
          jnz     short DMAsupport
          dec     al
          test    bl,10b  ;DMA 1
          jnz     short DMAsupport
          dec     al
          test    bl,1b   ;DMA 0
          jnz     short DMAsupport
          dec     al
DMAsupport:
          shl     al,4
          mov     byte ptr [esi+47+8],al

          mov     al,3
          mov     bl,byte ptr [edi+63*2+1]
          test    bl,100b ;DMA 2
          jnz     short SelectedDMANotSet
          dec     al
          test    bl,10b  ;DMA 1
          jnz     short SelectedDMANotSet
          dec     al
          test    bl,1b   ;DMA 0
          jnz     short SelectedDMANotSet
          dec     al
SelectedDMANotSet:
          shl     al,4
          mov     byte ptr [esi+96],al


          test    byte ptr [edi+106],100b
          jz      short Word70xxNotValid
          mov     al,byte ptr [edi+88*2]
          or      al,al
          jz      short UDMANotSupport
          mov     bl,9
NextUDMABitCheck:
          shl     al,1
          dec     bl
          jnc     short NextUDMABitCheck
          or      byte ptr [esi+47+8],bl   ;UDMA

          mov     al,byte ptr [edi+88*2+1]
          or      al,al
          jz      short UDMANotSupport
          mov     bl,9
NextSelectedUDMABitCheck:
          shl     al,1
          dec     bl
          jnc     short NextSelectedUDMABitCheck
          or      byte ptr [esi+96],bl   ;Selected UDMA
UDMANotSupport:
Word70xxNotValid:
          ret
GetATAATAPITransferMode ENDP

DetectIDELBA PROC
          cmp     word ptr [esi+34+8],03FFFh
          jz      short GoToDetectLBA
          cmp     word ptr [esi+34+8],07FFFh
          jz      short GoToDetectLBA
          cmp     word ptr [esi+34+8],0FFFFh
          jnz     short ExitFromDetectLBA
GoToDetectLBA:
          test    byte ptr [edi+106],10b
          jz      short ExitFromDetectLBA
;          mov     ax,word ptr [edi+61*2]
;          shl     eax,16
;          mov     ax,word ptr [edi+60*2]

      mov     eax,dword ptr [edi+60*2]


          cmp     eax,66059280
          jb      short Heads16InLBA
          mov     word ptr [esi+36+8],0FFh
Heads16InLBA:
          sub     edx,edx
          movzx   ebx,word ptr [esi+36+8]   ;503 GB max
          div     ebx
          movzx   ebx,word ptr [esi+38+8]
          sub     edx,edx
          div     ebx
          mov     word ptr [esi+34+8],ax
ExitFromDetectLBA:
          ret
DetectIDELBA ENDP

GetAtaAtapiDriveName PROC
          mov     ax,word ptr [edi+54]
          cmp     ax,2020h
          jz      short DetectSpace
          cmp     word ptr [edi+56],ax
          jz      ErrorInDriveName
DetectSpace:
          push    esi
          push    edi

          mov     edi,esi
          mov     esi,[WorkBuffer]
          add     esi,54
          mov     ecx,20
          cld
          cmp     dword ptr [esi],2D524353h
          jz      short NextAtaAtapiNameWordForSCR630
          call    GetIDString
          jmp     short EndAtaAtapiNameWord
NextAtaAtapiNameWordForSCR630:
          rep movsw
EndAtaAtapiNameWord:

          add     di,18
          mov     esi,[WorkBuffer]
          add     esi,20 ;Serial num
          mov     cx,10
          call    GetIDString
          inc     edi
          mov     esi,[WorkBuffer];offset WorkBuffer
          add     esi,46 ;Firmware
          mov     cx,4
          call    GetIDString
          pop     edi
          pop     esi
          mov    ebx,40
NextByteDriveModelToCorrect:
          cmp    byte ptr [esi+ebx-1],32
          ja     short EndCorrectDriveModel
          mov    byte ptr [esi+ebx-1],0
          dec    bx
          jnz    short NextByteDriveModelToCorrect
EndCorrectDriveModel:

          mov    ebx,40
NextByteDriveModelToDetectError:
          cmp    byte ptr [esi+ebx-1],0
          jz     short ZeroFoundInDriveName
          cmp    byte ptr [esi+ebx-1],32
          jb     short ErrorInDriveName
ZeroFoundInDriveName:
          dec    bx
          jnz    short NextByteDriveModelToDetectError

          mov    bx,20
NextByteSerialNumToCorrect:
          cmp    byte ptr [esi+ebx+57],32
          ja     short EndCorrectSerialNum
          mov    byte ptr [esi+ebx+57],0
          dec    bx
          jnz    short NextByteSerialNumToCorrect
EndCorrectSerialNum:
          mov    bx,8
NextByteRevisionToCorrect:
          cmp    byte ptr [esi+ebx+78],32
          ja     short EndCorrectRevision
          mov    byte ptr [esi+ebx+78],0
          dec    bx
          jnz    short NextByteRevisionToCorrect
EndCorrectRevision:
          clc
          ret
ErrorInDriveName:
          stc
          ret
GetAtaAtapiDriveName ENDP

GetIDString PROC
NextIDWord:
          lodsw
          xchg    ah,al
          stosw
          dec     cx
          jnz     short NextIDWord
          ret
GetIDString ENDP


GetRPM PROC

        push    esi
        push    dx
        invoke  QueryPerformanceFrequency, offset ClockPerSec
        pop     dx
        pop     esi

        or      eax,eax
        jz      ErrorInRPM

        call    WaitingBusy
        jc      short ErrorInRPM

        call    WatingRPMstate
        jc      short ErrorInRPM

        push    esi
        push    dx
        invoke   QueryPerformanceCounter, offset NumMsec
        mov      eax,[NumMsec]
        pop     dx
        pop     esi

        mov     bx,10
        ALIGN 2
NextGetRPM:
        push    eax
        call    WatingRPMstate
        pop     eax
        jc      short ErrorInRPM
        dec     bx
        jnz     short NextGetRPM

        push    eax
        push    esi
        push    dx
        invoke   QueryPerformanceCounter, offset NumMsec
        mov      ebx,[NumMsec]
        pop     dx
        pop     esi
        pop     eax
        sub     ebx,eax

        mov      eax,[ClockPerSec]
        mov      ecx,604
        mul      ecx

        div      ebx

          cmp     eax,3000
          jb      short ErrorInRPM
          cmp     eax,10500
          ja      short ErrorInRPM
          mov     word ptr [esi+42+8],ax
ErrorInRPM:
          ret
GetRPM ENDP

          ALIGN 2
WatingRPMstate PROC
          mov     cx,8000h; sub     cx,cx
NextWaitRPMstate:
          call    CommandINALDX    ;      in      al,dx
          test    al,2
          jz      short WaitRPMstateStep1OK
          dec     cx
          jnz     short NextWaitRPMstate
          jmp     short ErrorInWaitRPMstate
WaitRPMstateStep1OK:
          mov     cx,8000h; sub     cx,cx
NextWaitRPMstateJnz:
          call    CommandINALDX    ;      in      al,dx
          test    al,2
          jnz     short WaitRPMstateStep2OK
          dec     cx
          jnz     short NextWaitRPMstateJnz
ErrorInWaitRPMstate:
          stc
          ret
WaitRPMstateStep2OK:
          clc
          ret
WatingRPMstate ENDP

GetMicrocodeRev PROC
          mov     ecx,8Bh
          xor     eax,eax
          xor     edx,edx
          call    CommandWRMSR
          mov     eax,1
          cpuid
          mov     ecx,8Bh
          call    CommandRDMSR
          inc     edx
          mov     [MicrocodeRev],edx
          ret
GetMicrocodeRev ENDP


DetectMemBand proc

        mov     ecx,250

        call    MemSpeedBlockPeakLodsd32
        mov     ebx,eax
        shr     eax,1
        add     ebx,eax
        call    MemSpeedBlockPeakLodsd64
        cmp     ebx,eax
        jb      Get32LineSizePeakBand
        mov     ebx,eax
        shr     eax,1
        add     ebx,eax
        call    MemSpeedBlockPeakLodsd128
        cmp     ebx,eax
        jb      Get64LineSizePeakBand

;Get128LineSizePeakBand:
        call    MemSpeedBlockPeakLodsd128
        mov     [NumAveraging1],eax
        call    MemSpeedBlockPeakLodsd128
        mov     [NumAveraging2],eax
        call    MemSpeedBlockPeakLodsd128
        mov     [NumAveraging3],eax
        call    MemSpeedBlockPeakLodsd128
        mov     [NumAveraging4],eax
        call    MemSpeedBlockPeakLodsd128
        mov     [NumAveraging5],eax
        jmp     DetectAveragingPeakBand

Get64LineSizePeakBand:
        call    MemSpeedBlockPeakLodsd64
        mov     [NumAveraging1],eax
        call    MemSpeedBlockPeakLodsd64
        mov     [NumAveraging2],eax
        call    MemSpeedBlockPeakLodsd64
        mov     [NumAveraging3],eax
        call    MemSpeedBlockPeakLodsd64
        mov     [NumAveraging4],eax
        call    MemSpeedBlockPeakLodsd64
        mov     [NumAveraging5],eax
        jmp     DetectAveragingPeakBand

Get32LineSizePeakBand:
        call    MemSpeedBlockPeakLodsd32
        mov     [NumAveraging1],eax
        call    MemSpeedBlockPeakLodsd32
        mov     [NumAveraging2],eax
        call    MemSpeedBlockPeakLodsd32
        mov     [NumAveraging3],eax
        call    MemSpeedBlockPeakLodsd32
        mov     [NumAveraging4],eax
        call    MemSpeedBlockPeakLodsd32
        mov     [NumAveraging5],eax


DetectAveragingPeakBand:
        call    GetMaxAveraging5

        mov     [MemBand],eax
        ret
DetectMemBand endp

        ALIGN 16

MemSpeedBlockPeakLodsd32 proc ;Вход AX 0-250 Выход eax-MB/sec

        push    ebx
        push    ecx
        push    edx
        push    esi
        push    ebp

        call    DetectMemSize
        call    CalkNumBlockForMemTests

        mov     ebp,MemoryBaseAdr

        mov     esi,ebp
        shr     ecx,1
        lea     esi,[esi+ecx*8]
        neg     ecx
        mov     edx,ecx


        call    StartTimer
        jmp     NextMemSpeedBlockPeakLodsD

        ALIGN 16

NextMemSpeedBlockPeakLodsD:
LodsDBytesBlock:
        mov     eax,[esi+ecx*8]
        mov     eax,[esi+ecx*8+32]
        mov     eax,[esi+ecx*8+64]
        mov     eax,[esi+ecx*8+96]
        add     ecx,16
        jnz     LodsDBytesBlock

        mov     ecx,edx

        dec     bx
        jnz     NextMemSpeedBlockPeakLodsD

        invoke  StopTimerGetMBInSec,16

        pop     ebp
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx

        ret

MemSpeedBlockPeakLodsd32 endp

        ALIGN 16

MemSpeedBlockPeakLodsd64 proc ;Вход AX 0-250 Выход eax-MB/sec

        push    ebx
        push    ecx
        push    edx
        push    esi
        push    ebp

        call    DetectMemSize
        call    CalkNumBlockForMemTests

        mov     ebp,MemoryBaseAdr

        mov     esi,ebp
        shr     ecx,1
        lea     esi,[esi+ecx*8]
        neg     ecx
        mov     edx,ecx


        call    StartTimer
        jmp     NextMemSpeedBlockPeakLodsD

        ALIGN 16

NextMemSpeedBlockPeakLodsD:
LodsDBytesBlock:
        mov     eax,[esi+ecx*8]
        mov     eax,[esi+ecx*8+64]
        add     ecx,16
        jnz     LodsDBytesBlock

        mov     ecx,edx

        dec     bx
        jnz     NextMemSpeedBlockPeakLodsD

        invoke  StopTimerGetMBInSec,16

        pop     ebp
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx

        ret

MemSpeedBlockPeakLodsd64 endp

        ALIGN 16

MemSpeedBlockPeakLodsd128 proc ;Вход AX 0-250 Выход eax-MB/sec

        push    ebx
        push    ecx
        push    edx
        push    esi
        push    ebp

        call    DetectMemSize
        call    CalkNumBlockForMemTests

        mov     ebp,MemoryBaseAdr

        mov     esi,ebp
        shr     ecx,1
        lea     esi,[esi+ecx*8]
        add     esi,64


        neg     ecx
        mov     edx,ecx

        call    StartTimer
        jmp     NextMemSpeedBlockPeakLodsD

        ALIGN 16

NextMemSpeedBlockPeakLodsD:
LodsDBytesBlock:
        mov     eax,[esi+ecx*8-64]
        mov     eax,[esi+ecx*8+64]
        add     ecx,32
        jnz     LodsDBytesBlock

        mov     ecx,edx

        dec     bx
        jnz     NextMemSpeedBlockPeakLodsD

        invoke  StopTimerGetMBInSec,16

        pop     ebp
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        ret

MemSpeedBlockPeakLodsd128 endp

        ALIGN 16
StartTimer proc
        push    eax
        push    edx
        rdtsc
        mov     NumTimerLow,eax
        mov     NumTimerHigh,edx
        pop     edx
        pop     eax
        ret
StartTimer endp

        ALIGN 16
StopTimerGetMBInSec proc NumMByte:DWORD

        push    edx
        rdtsc
        push    ebx
        sub     eax,NumTimerLow
        sbb     edx,NumTimerHigh
        shrd    eax,edx,2
        push    eax
        mov     eax,400
        mul     NumMByte
        mul     TSC250ms
        pop     ebx
        div     ebx
        pop     ebx
        pop     edx
        ret
StopTimerGetMBInSec endp

        ALIGN 16
DetectMemSize proc
        mov     ax,cx
        mov     bl,25
        div     bl
        mov     cl,al

        mov     ebx,41
        movzx   eax,ah
        mul     ebx
        mov     ebx,1024
        add     ebx,eax

        shl     ebx,cl
;        and     bl,11111100b
        and     bl,11100000b

        ret
DetectMemSize endp

        ALIGN 16
CalkNumBlockForMemTests proc
        xor     edx,edx
        mov     eax,1048576*4
        mov     ecx,ebx
        div     ebx
        mov     ebx,eax

        ret
CalkNumBlockForMemTests endp

        ALIGN 16

GetMaxAveraging5 proc

        push    ebx
        push    ecx

        mov     ecx,4
NextPassesInGetMaxAverage:
        mov     eax,[NumAveraging5]
        cmp     eax,[NumAveraging4]
        jb      NumAverage5NoBig
        mov     ebx,[NumAveraging4]
        mov     [NumAveraging4],eax
        mov     [NumAveraging5],ebx
NumAverage5NoBig:

        mov     eax,[NumAveraging4]
        cmp     eax,[NumAveraging3]
        jb      NumAverage4NoBig
        mov     ebx,[NumAveraging3]
        mov     [NumAveraging3],eax
        mov     [NumAveraging4],ebx
NumAverage4NoBig:

        mov     eax,[NumAveraging3]
        cmp     eax,[NumAveraging2]
        jb      NumAverage3NoBig
        mov     ebx,[NumAveraging2]
        mov     [NumAveraging2],eax
        mov     [NumAveraging3],ebx
NumAverage3NoBig:

        mov     eax,[NumAveraging2]
        cmp     eax,[NumAveraging1]
        jb      NumAverage2NoBig
        mov     ebx,[NumAveraging1]
        mov     [NumAveraging1],eax
        mov     [NumAveraging2],ebx
NumAverage2NoBig:
        loop    NextPassesInGetMaxAverage

        mov     eax,[NumAveraging4]
        add     eax,[NumAveraging2]
        shr     eax,1
        add     eax,[NumAveraging3]
        shr     eax,1

        pop     ecx
        pop     ebx

        ret
GetMaxAveraging5 endp

        end Start
