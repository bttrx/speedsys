                   %TITLE "System Speed Test V4.79 05-Oct-2003"
                   IDEAL
                   JUMPS
                   P386

AllocatedMemory    EQU   384*1024/16; Выделить 384 KB памяти
;AllocatedMemory    EQU   264*1024/16; Выделить 262 KB ТОЛЬКО ДЛЯ ОТЛАДКИ!!!
ForSkaleProc       EQU  1 ; 1 !!!
Win32ModuleSize    EQU   7680 ; Размер Win32 модуля
SSTRESTMPSize      EQU   1122+4 ; Win32 data
CacheMissCor       EQU   64/4
SpeedsysVer        EQU   '4.79b04'
r                  EQU   252,253
tm                 EQU   254,255
ForCpuTest         EQU   1 ; не менять
PCIDevLength       EQU   offset EndOfPCISruct-offset NumberPCIBus
ClearedPCIDevLength EQU offset EndOfPCISruct-offset NumPCIVideoDev

                   ;INCLUDE "speedsys.inc"

                   SEGMENT PCIDataSeg1
                   EXTRN PCIDevData1:byte
                   ENDS PCIDataSeg1
                   SEGMENT PCIDataSeg2
                   EXTRN PCIDevData2:byte
                   ENDS PCIDataSeg2

                   SEGMENT Sseg Page Stack 'STACK'
                   DB 2048 DUP(0)
                   ENDS Sseg

                   SEGMENT Dseg Page Public 'DATA'
                   PUBLIC FileHandle,EndProgram,MultiTask,SkaleProc,ClockRatio
                   PUBLIC ReportDataSeg,CounterRepBuf,RepStrCounter
                   PUBLIC DataCacheL1,CacheL1,CacheL2,CacheL3,SPDSocket,BaseAdrSMBus,NumByteSPD
                   PUBLIC IntelProcessor,CorrectFrec,NumberPCIBus

FileName           DW 0
FileNameREP        DW 0
FileHandle         DW 0
FileHandleREP      DW 0
CreatePCX          DB 0
CreateREP          DB 0
CreateQuickREP     DB 0
CreateBIOS         DB 0
ClearCMOS          DB 0
EraseHDD           DB 0
PCXcreated         DB 0
Int13ExtResetByComLine DB 0
Int13ExtSetByComLine DB 0
DisableSPDread     DB 0
DisATAExtern       DB 0
video              DB ?
processor          DB ?
MemorySize         DW ?
RemoteCall         DW 0
EndProgram         DW ?
SPDDataSeg         DW ?
PCIDevRepOfs       DW 0
PCIDevRepSeg       DW ?
ReportDataSeg      DW ?
CounterRepBuf      DW 0
RepStrCounter      DB 0
PCIBusIsPresent    DB 0

          DB 13,10
MyMes     DB 'SYSTEM SPEED TEST            FREEWARE Version ',SpeedsysVer,'  Compiled xxx-xx-xxxx',13,10
          DB 'Coded by Vladimir Afanasiev  Irkutsk, Russia  Email: dxover@email.ru',13,10
          DB 'Home page: http://user.rol.ru/~dxover/speedsys',13,10,'$'

                   EXTRN MesHelp:byte,BIOSVendors:byte,PCIClassName:byte

CommLine           DB 80 dup(0)
Fcb1               DB 40 dup(0)
Fcb2               DB 40 dup(0)
ParamBlock         DW  0
Parm2              DD  0
Parm3              DD  0
Parm4              DD  0

StackOfs           DW ?
StackSeg           DW ?

MesVer             DB 17,3+8,22,95,0,18,'Ver ',SpeedsysVer,0
;MesVer             DB 17,3+8,22,98,0,18,'Ver ',SpeedsysVer,0
Win32PrgBuff       DB Win32ModuleSize+8 DUP ('-')
NumNameResTmp      DB 'C:\SSTRES'
Extension          DD 0
                   DB 0

MesNextStr         DB 13,10,'$'
MesError           DB 13,10,'ERROR: $'
Mes286Proc         DB 'CPU 80386 or higher not found.$'
NoVGA              DB 'Video adapter VGA not found.$'
NoReal             DB 13,10,'- CPU is in protected mode.$'
EMMPresent         DB 13,10,'- Remove EMM386 or other driver from memory.$'
QEMMPresent        DB 13,10,'- Remove QEMM from memory.$'
MultitaskPresent   DB 13,10,'- Please exit from multitask system.$'
WindowsPresent     DB 13,10,'- Please exit from Windows'
ForWinNT           DB '.$  '
NoXMS              DB 13,10,'- Cannot allocate 4 MB of XMS memory.$'
MesA20             DB 13,10,'- Cannot enable A20 gate.$'
NoMem              DB 'Not enough memory.$'
MsdexNotInst       DB 'MSCDEX not installed.$'
MesErrorCreate     DB 'Cannot create PCX image file.$'
MesErrorCreateREP  DB 'Cannot create TXT report file.$'
MesCreateSysBIOSOK DB 13,10,13,10,'System BIOS dump (SYSBIOS.ROM) is ready.$'
MesClearCMOS       DB 13,10,13,10,'CMOS is cleared.$'
MesErrComLine      DB 'Invalid command.$'
MesHDDNotPresent   DB 'Hard drive '
NumHDDNotPresent   DB '  not present.$'
MesSmartdrv        DB 13,10,'- SMARTDrive is found, remove it from memory.$'
MesErrConfig       DB 13,10,10,'WARNING: Several tests can not be performed!$'
MesWarningEraseHDD DB 13,10,10,'WARNING: ALL DATA ON NON-REMOVABLE DISK DRIVE '
ErasedDrive        DB 0,' WILL BE LOST!',13,10,10,'Press ''Y''(Yes) to confirm or other key to abort.$'

MesWarningEraseC   DB 13,10,10,'WARNING: Write test will destroy all disk C: content!'
                   DB 13,10,10,'Do you wish to cancel? Press ''N''(No) or other key to abort.$'

MesErasePassed     DB 13,10,13,10,'Hard Drive '
ErasedDrive1       DB 0,' erased succesfully.$'
MesEraseFailed     DB 13,10,13,10,'Unable to erase Hard Drive '
ErasedDrive2       DB 0,'.$'
MesErrDiv          DB 22,6,32,17,4,'ERROR: Divide overlflow.',0
BufNoErr           DB 0
ErrConfig          DB 0
MultiTask          DB 0
ErrConfigNoDisab   DB 0
ErrConfigNoDisab2  DB 0
PressAnyKeyEngNeeded DB 0

MesInit            DB 22,3,1,17,7+8,'Determining system contents...',0
MesDetCpuSpeed     DB 22,35,1,18,'CPU clock',0
MesDetMemSpeed     DB 22,35,1,18,'Memory speed',0
MesMMXMemSpeed     DB 22,35,1,18,'MMX Transfer',0
MesDetMemType      DB 22,35,1,18,'Memory type ',0
MesDetCPUTSCSpeed  DB 22,35,1,18,'Get TSC clock',0
MesDetMSR          DB 22,35,1,18,'Read MSRs    ',0
MesDetPnPBIOS      DB 22,35,1,18,'Get DMI info ',0
MesDetATADrive     DB 22,35,1,18,'ATA/ATAPI device '
NumATADev          DB '0 at port '
NumPortATA         DB 4 DUP (0),0
MesDetBIOSVendor   DB 22,35,1,18,'BIOS vendor                      ',0
MesDetBug2000      DB 22,35,1,18,'Year2000 Bug     ',0
MesDetISAPnP       DB 22,35,1,18,'ISA PnP RD port  ',0
MesDetPCI          DB 22,35,1,18,'PCI devices        ',0
MesDetISAPnPPort   DB 22,51,1,18
NumISAPnPPort      DB 3 DUP(0),0

CPUclass           DB 0
FPUcheck           DB 0
CPUIDsupport       DB 0
VendorIDstring1    DD 0
VendorIDstring2    DD 0
VendorIDstring3    DD 0
                   DB 0

AuthenticAMD       DB 'AuthenticAMD'
GenuineIntel       DB 'GenuineIntel'
CyrixInstead       DB 'CyrixInstead'
CentaurHauls       DB 'CentaurHauls'
NexGenDriven       DB 'NexGenDriven'
RiseRocks          DB 'RiseRiseRise'
GenuineTMx86       DB 'GenuineTMx86'
SiSSiSSiS          DB 'SiS SiS SiS '

FeatureFlag        DD 0
ExtFeatureFlag     DD 0

AMDProcessor       DB 0
IntelProcessor     DB 0
CyrixProcessor     DB 0
IDTProcessor       DB 0
NexGenProcessor    DB 0
RiseProcessor      DB 0
SiSProcessor       DB 0
TransmetaProcessor DB 0
CPUSerialNumberEAX DD 0
CPUSerialNumberEDX DD 0
CPUSerialNumberECX DD 0

PUBLIC BrandID,CPUstepping,CPUmodel,CPUfamily,CPUtype
PUBLIC RegEDXCPUIDlevel2,IntelExtendedFamily,IntelExtendedModel

BrandID            DB 0
CPUIDLevelSupport  DB ?
ExtCPUIDLevelSupport DD 0
RegEAXCPUIDlevel2  DD ?
RegEBXCPUIDlevel2  DD ?
RegECXCPUIDlevel2  DD ?
RegEDXCPUIDlevel2  DD ?
ExtCPUIDCacheL1InfoECX DD 0
ExtCPUIDCacheL1InfoEDX DD 0
ExtCPUIDCacheL2InfoECX DD 0

CPUstepping        DB 0
CPUmodel           DB 0;* не
CPUfamily          DB 0;* менять
CPUtype            DB 0;* порядок
ExtCPUstepping     DB 0;*
ExtCPUmodel        DB 0;*
ExtCPUfamily       DB 0;*
ExtCPUtype         DB 0;*
IntelExtendedFamily DB 0   ; 27-20 8 bit
IntelExtendedModel  DB 0   ; 19-16 4 bit
CPUName            DB 64 DUP(0),0
NotNidedRepCPUFrec DB 0

FeatureFlagMMX     DB 0
FeatureFlagTSC     DB 0
FeatureFlagMSR     DB 0
FeatureFlagSSE     DB 0
FeatureFlagSSE2    DB 0
FeatureFlagSN      DB 0
FeatureFlagAMD3D   DB 0
FeatureFlagAMD3DExt DB 0
DataCacheL1        DW 0
CacheL1            DW 0
CacheL2            DW 0
CacheL3            DW 0
MSR00000017edx     DD 0
MSR0000002A        DD 0
MSR0000002C        DD 0
MSR0000011E        DD 0
MSRC0000087        DD 0
MSRC0000082        DD 0
MSRC0010015        DD 0
MicrocodeRev       DD 0
DetectViaMSR       DB 0

mes80386dx         DB '80386DX',0
mes80386sx         DB '80386SX',0
mes80486dx         DB '80486DX',0
mes80486sx         DB '80486SX',0
intel              DB 'Intel ',0
Intel486           DB '486',0
intel486dx         DB '486DX',tm,0
intel486sx         DB '486SX',tm,0
intel486dx2        DB '486DX2',tm,0
intel486sx2        DB '486SX2',tm,0
intel486sl         DB '486SL',tm,0
inteldx4           DB '486DX4',tm,0
inteldx2wb         DB '486DX2',tm,'WB',0
pentium            DB 'Pentium',r,0
pentiumvr          DB 'Pentium',r,'VRT',0
pentiummmx         DB 'Pentium',r,'MMX',tm,0
pentiumpro         DB 'Pentium',r,'Pro',0
pentium2           DB 'Pentium',r,'I',31,'I',0
Xeon               DB 'Pentium',r,'I',31,'I Xeon',tm,0
pentium3           DB 'Pentium',r,'I',31,'I',31,'I',0
pentium3m          DB 'Pentium',r,'I',31,'I',31,'I-M',0
pentium4           DB 'Pentium',r,'4',0
pentium4Xeon       DB 'Xeon',tm,,0
pentium3Xeon       DB 'Pentium',r,'I',31,'I',31,'I Xeon',tm,0
Celeron            DB 'Celeron',tm,0
IntelItanium       DB 'Itanium',tm,0
IntelItanium2      DB 'Itanium 2',tm,0

amd                DB 'AMD ',0
amd486dx2          DB 'Am486DX2',tm,0
amd486dx2wb        DB 'Am486DX2WB',tm,0
amd486dx4          DB 'Am486DX4',tm,0
amd486dx4wb        DB 'Am486DX4WB',tm,0
amd5x86            DB 'Am5x86',tm,0
amd5x86wb          DB 'Am5x86WB',tm,0
amdk5              DB 'K5',tm,0
amdk6              DB 'K6',tm,0
amdk63d            DB 'K6',tm,31,'-2',0
amdk6III           DB 'K6',tm,31,'I',31,'I',31,'I',0
amdk62plus         DB 'K6',tm,31,'-2+',0
amdk6IIIplus       DB 'K6',tm,31,'I',31,'I',31,'I+',0
amdK7              DB 'K7',0
amdAthlon          DB 'Athlon',tm,0
amdAthlon4         DB 'Athlon 4',tm,0
amdAthlonXP        DB 'Athlon',tm,'XP '
amdAthlonXPclk     DB 'xxxx+',0
amdAthlonMP        DB 'Athlon',tm,'MP '
amdAthlonMPclk     DB 'xxxx+',0
amdDuron           DB 'Duron',tm,0
amdOpteron         DB 'Opteron',tm,0
amdK8              DB 'K8',0

cyrix              DB 'Cyrix ',0
cyrix486SLC        DB 'Cx486SLC',tm,0
cyrix486DLC        DB 'Cx486DLC',tm,0
cyrix486SLC2       DB 'Cx486SLC2',tm,0
cyrix486DLC2       DB 'Cx486DLC2',tm,0
cyrix486SRx        DB 'Cx486SRx',tm,0
cyrix486DRx        DB 'Cx486DRx',tm,0
cyrix486SRx2       DB 'Cx486SRx2',tm,0
cyrix486DRx2       DB 'Cx486DRx2',tm,0
cyrix486S          DB 'Cx486S',tm,0
cyrix486S2         DB 'Cx486S2',tm,0
cyrix486Se         DB 'Cx486Se',tm,0
cyrix486S2e        DB 'Cx486S2e',tm,0
cyrix486DX         DB 'Cx486DX',tm,0
cyrix486DX2        DB 'Cx486DX2',tm,0
cyrix486DX4        DB 'Cx486DX4',tm,0
MediaGX            DB 'MediaGX',tm,0
cyrix5x86          DB '5x86',tm,0
cyrix6x86          DB '6x86',tm,0
cyrixGXm           DB 'GXm',tm,0
cyrix6x86mx        DB '6x86MX',tm,0
cyrixMII           DB 'MI',31,'I',tm,0
MediaGXGXm         DB 'MediaGX/GXm',0
cyrix52unknown     DB ' (M5/2-'
Num52method        DB 2 DUP(0),'h)',0
cyrix52detect      DB 0
VIA                DB 'VIA ',0
CyrixIII           DB 'Cyrix',r,'I',31,'I',31,'I',0
ViaC3              DB 'C3',r,0

idt                DB 'IDT ',0
winchipc6          DB 'WinChip C6',tm,0
winchip2           DB 'WinChip 2',tm,0
winchip3           DB 'WinChip 3',tm,0
winchip4           DB 'WinChip 4',tm,0

NexGen             DB 'NexGen ',0
Nx586              DB 'Nx586',tm,0

Rise               DB 'Rise ',0
RisemP6            DB 'mP6',tm,0
RisemP62           DB 'mP6',tm,31,'I',31,'I',0

Transmeta          DB 'Transmeta ',0
TMCrusoe           DB 'Crusoe',tm,0

SiS                DB 'SiS ',0
SiS55x             DB '55x',0

BIOSVendorDetectOK DB 0

processorMes       DB 22,3,2,17,7+8,'Processor',23,16,': ',31,0
CPUIDunknown       DB 'Unknown',0
MesCPUparam        DB 13,23,3,'CPUID (TFMS) : ',31
NumCPUtype         DB 1 DUP(0)
NumCPUfamily       DB 1 DUP(0)
NumCPUmodel        DB 1 DUP(0)
NumCPUstepping     DB 1 DUP(0),0

PriznMMXAMD3D      DB 0
MesMMXyes          DB 23,30,'MMX',tm,23,34,':Yes',0
MesMMXno           DB 23,30,'MMX',tm,23,34,':No',0
MesSSEyes          DB 23,39,'IA ',31,'SSE:Yes',0
MesSSEno           DB 23,39,'IA ',31,'SSE:No',0
MesSSE2yes         DB 23,39,'IA ',31,'SSE2:Yes',0
MesSSE2no          DB 23,39,'IA ',31,'SSE2:No',0
MesAMD3Dyes        DB 23,39,'3DNow!',tm,23,46,':Yes',0
MesAMD3Dno         DB 23,39,'3DNow!',tm,23,46,':No',0
MesAMD3DExtyes     DB 23,39,'3DNow! Extensions:Yes',0
MesAMD3DExtno      DB 23,39,'3DNow! Extensions:No',0
MesFPUyes          DB 23,34,'NPU:Yes',0
MesFPUno           DB 23,34,'NPU:No',0

MesCPUIDnotSupport DB 13,23,3,'CPUID not support',0
Mhz                DD 0
MhzTSC             DW 0
OriginalFSB        DW 0
OriginalFSBExt     DD 0
OriginalFrequency  DW 0
;OriginalClockRatio DW 0
Overclocking       DD 0

SSTLabel           DD 0        ; SST_
MHzTSCFull         DD 0        ; DATA from Win32
GetVerEAX          DD 0        ;
MemStatusSructLen  DD 0        ;
dwMemoryLoad       DD 0        ;
dwTotalPhys        DD 0        ;
dwAvailPhys        DD 0        ;
dwTotalPageFile    DD 0        ;
dwAvailPageFile    DD 0        ;
dwTotalVirtual     DD 0        ;
dwAvailVirtual     DD 0        ;
ComputerName       DB 16 DUP(0);
UserName           DB 16 DUP(0);
Win32MSR0000011E   DD 0        ;
NumFixedDisk       DD 0        ;
DriveBuffer        DD 56 DUP(0);
Win32MSRC0000082   DD 0        ;
Win32MSRC0000087   DD 0        ;
Win32MSRC0010015   DD 0        ;
Win32MSR00000017edx DD 0       ;
Win32MSR0000002A   DD 0        ;
Win32MSR0000002C   DD 0        ;
Win32MicrocodeRev  DD 0
NumDriveName0   DB 40 DUP(0)
AtaAtapiPM      DW 0,8 DUP(0),15 DUP(0),5 DUP(0)  ;byte offset+97 - reserved
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

DevMHZ             DD 5005045
CorrectFrec        DW 0
Hastota            DB 17,7+8
NumHastota         DB 5 DUP(0),' ',31,'MHz',0
MesMhzViaRDTSC     DB 13,23,3,     'Speed via TSC: ',31,0
NumMhzViaRDTSC     DB 7 DUP (0),' ',31,'MHz',0
PerevodStr         DB 13,23,3,0
ClockRatio         DW 0
PnPBusSpeed        DW 0
MesClockFrequency  DB 13,23,3,     'Extern. clock: ',31,0
NumBusClock        DB 4 DUP(0),' ',31,'MHz',0

MesDDRClock        DB 7 DUP(0),32,31,'DDR (',0
MesQDRClock        DB 7 DUP(0),32,31,'QDR (',0
MesExtClock        DB 7 DUP(0),32,31,'MHz x ',0
NumRatio           DB 5 DUP(0),0

MesCPUCaches       DB 13,23,3,     'CPU cache(s) : ',31,0
MesCache           DB 'L'
NumCacheNumber     DB 1 DUP(0),'-',0
NumCacheSizeKB     DB 5 DUP(0),32,31,'KB',0
NumCacheSizeMB     DB 5 DUP(0),32,31,'MB',0
MesL2Latency       DB 'L2(l'
NumL2Latency       DB 1 DUP(0),')-',0
MesZpt             DB ', ',31,0

MesFeatureReg      DB 23,31,' Feature: '
NumFeatureRegH     DB 4 DUP (0)
NumFeatureRegL     DB 4 DUP (0),'h',0
MesCodeName        DB ' Codename: ',0

WinPres            DB 0
WinNTPres          DB 0
vermesn            DB 13,23,3,'OS version',23,32,': ',0
DosVer             DB 'DOS ',0
PcDosVer           DB 'PC-DOS ',0
DrDosVer           DB 'DR-DOS ',0
MsDosVer           DB 'MS-DOS ',0
PtsDosVer          DB 'PTS-DOS ',0
vermes01           DB 1 DUP(0)
vermese            DB '.'
vermes02           DB 2 DUP (0),0
MesWindows         DB 17,4,'Windows',0
MesWindows95       DB '95',0
MesWindows95OSR2   DB '95',32,31,'OSR2',0
MesWindows98       DB '98',0
MesWindows2000     DB '2000',0
MesWindowsXP       DB 'XP',0
MesWindowsNET      DB '.NET',0
MesWindowsME       DB 'ME',0
MesWindowsNT       DB 'NT',0
MesTM              DB tm,0
MesDosLabel        DB '('
NumDosLabel        DB 2 DUP(0),'h) ',0

MesBios            DB 13,23,3,'BIOS: '
NumBios            DB 42 DUP (0),0 ;42 не менять
NumBiosDate1       DB 17,2+8,' ('
NumBiosDate        DB 8 DUP (0),')',17,7+8,0
MesPerexod         DB 32,25,16,32,0
ForBaseFrame       DB 0
ForBaseLine        DB 0
MesMotherboard     DB 13,23,3,'Mainboard: ',0
MesChipset         DB 13,23,3,'Chipset  : ',0
ChipsetForRep      DW 0

PnPBiosSupport     DB 0
BiosSelector       DW 0
PnPCall            DD 0
DMIstorageSize     DW 0
DMIstorageBase     DD 0
StructureSize      DW 0
NumStructures      DW 0
DMIBiosRevision    DB 0
Structure          DW 0

PerevodStroki      DB 13,0
StrTotalMem        DB 13,13,23,3,   'Memory size',23,32,':',23,35
TotalMem           DB 4 DUP(0),' ',31,'MB',30,0
MesMemoryType      DB 18,23,3,      'Memory     ',23,9,0

NumMemMapBlocks    DB 0
ErrorInMemMap      DB 0
AdrFromMemMap      DD 0
SizeFromMemMap     DD 0
TypeFromMemMap     DD 0

MesNewMemMap       DB 22,3,36,17,3+8,18,'Memory Map (15/E820)',13,17,7+8
                   DB 13,23,4,'Address',23,42-27,'Length',23,50-27,'Type',13,0
MesMemMap          DB 13,23,3
NumAdrMemMap       DB 8 DUP(0),23,12
NumSizeMemMap      DB 7 DUP(0),' ',31,'KB',23,23,0

MesAvailableToOS   DB 'Available',0
MesReserved        DB 'Reserved',0
MesACPIReclaim     DB 'ACPI Reclaim',0
MesACPINVS         DB 'ACPI NVS',0

NextStructCounter  DB 0

MainBoardForSpd    DB 0
BaseAdrSMBus       DW ?
SPDSocket          DB 50h
NumByteSPD         DB 0
NumberDIMMModules  DB 0
NumberRIMMModules  DB 0
NumberDDRModules   DB 0
SPDMemInfo         DD 0
MemModuleSize      DW 0
SPDAllMemType      DD 0
JEDECID            DD ?
JEDECID2           DD ?
ModuleSN           DD ?
NumRowAddrBits     DB ?
NumColumnAddrBits  DB ?

NumPhysicBanks     DB ?
ModDataWidth       DW ?
SDRAMDeviceWidth   DB ?
NumLogicBanks      DB ?

SPDRevision        DB 0
SDRAMModAttrib     DB 0
SDRAMCycleTime     DB ?
SDRAMCycleTimeForTrpTrcd DB ?
SDRAMCycleTime2nd  DB ?
SDRAMCycleTime3nd  DB ?
AliSMBusHost       DB 0
AMD756SMBusHost    DB 0
nForceMCPTSMBusHost DB 0
SISSMBusHost       DB 0
SMBusHost          DB ?
                                         ;  DMI  ;  SPD  ;
MesMemOther        DB ' ',31,'???',0     ; bit 0 ;       ;
MesMemUnknown      DB ' ',31,'???',0     ; bit 1 ; bit 8 ;
MesMemStandard     DB ' ',31,'SPM',0     ; bit 2 ;       ;
MesMemFPM          DB ' ',31,'FPM',0     ; bit 3 ;       ;
MesMemEDO          DB ' ',31,'EDO',0     ; bit 4 ; bit 9 ;
MesMemParity       DB ' ',31,'EC',0      ; bit 5 ; bit 18;
MesMemECC          DB ' ',31,'ECC',0     ; bit 6 ; bit 19;
MesMemSIMM         DB ' ',31,'SIMM',0    ; bit 7 ;       ;
MesMemDIMM         DB ' ',31,'DIMM',0    ; bit 8 ; bit 4 ;
MesMemRIMM         DB ' ',31,'RIMM',0    ;       ; bit 5 ;
MesMemSORIMM       DB ' ',31,'SO-RIMM',0 ;       ; bit 6 ;
MesMemEmbedded     DB ' ',31,'EMBED.',0  ;       ; bit 7 ;
MesMemBEDO         DB ' ',31,'BEDO',0    ; bit 9 ;       ;
MesMemSDRAM        DB ' ',31,'SDRAM',0   ; bit 10; bit 10;
MesMemDRDRAM       DB ' ',31,'DRDRAM',0  ;       ; bit 11;
MesMemPN           DB ' ',31,'PN',0      ;       ; bit 12;
MesMemROM          DB ' ',31,'ROM',0     ;       ; bit 13;
MesMemSGDDR        DB ' ',31,'DDR-SGRAM',0       ; bit 14;
MesMemSDDDR        DB ' ',31,'DDR-SDRAM',0       ; bit 15;
MesMemVCSDRAM      DB ' ',31,'VCSDRAM',0         ; bit 16;
MesMemPC200        DB ' ',31,'PC1600',0          ; bit 20;
MesMemPC266        DB ' ',31,'PC2100',0          ; bit 21;
MesMemPC333        DB ' ',31,'PC2700',0          ; bit 22;
MesMemPC400        DB ' ',31,'PC3200',0          ; bit 23;
MesMemPC66         DB ' ',31,'PC66',0            ; bit 24;
MesMemPC100        DB ' ',31,'PC100',0           ; bit 25;
MesMemPC133        DB ' ',31,'PC133',0           ; bit 26;
MesMem600          DB ' ',31,'PC600',0           ; bit 28;
MesMem700          DB ' ',31,'PC700',0           ; bit 29;
MesMem800          DB ' ',31,'PC800',0           ; bit 30;

NumAdrMemBuf       DW MesMemOther,MesMemUnknown,MesMemStandard,MesMemFPM
                   DW MesMemEDO,MesMemParity,MesMemECC,MesMemSIMM
                   DW MesMemDIMM,MesMemBEDO,MesMemSDRAM
NumAdrSPDMemBuf    DW MesMemUnknown,MesMemUnknown,MesMemUnknown,MesMemUnknown
                   DW MesMemDIMM   ,MesMemRIMM   ,MesMemSORIMM ,MesMemEmbedded
                   DW MesMemUnknown,MesMemEDO    ,MesMemSDRAM  ,MesMemDRDRAM
                   DW MesMemPN     ,MesMemROM    ,MesMemSGDDR  ,MesMemSDDDR
                   DW MesMemVCSDRAM,MesMemUnknown,MesMemParity ,MesMemECC
                   DW MesMemPC200  ,MesMemPC266  ,MesMemPC333  ,MesMemPC400
                   DW MesMemPC66   ,MesMemPC100  ,MesMemPC133  ,MesMemUnknown
                   DW MesMem600    ,MesMem700    ,MesMem800    ,MesMemUnknown

SPDMemModSize      DW 0
SPDCheckSum        DB 0
MesSPDCheckSumErr  DB 23,74,17,4,'SPD-EEPROM Checksum Error',17,7+8,0

MesMemInfo         DB 22,3+35,36,17,3+8,18,'Memory Module Information',13,17,7+8
                   DB 13,23,3+35,'Row Type',23,23+8+35,'Size',23,73,'Manufacturer',23,88,'Part Number',13,0
MesMemSocket       DB 13,23,3+36
NumMemSocket       DB '0',23,41,0
MesSDRAMCT         DB 32,31,0
NumSDRAMCTHigh     DB 2 DUP(0),'.'
NumSDRAMCTLow      DB 1 DUP(0),18,'ns',0
MesMinus           DB 23,74,0C4h,0

SDRAMAccess        DB ?
MesSDRAMAccess     DB 23,68,'tAC:',0
NumSDRAMAccessHigh DB 2 DUP(0),'.'
NumSDRAMAccessLow  DB 1 DUP(0),'ns',0

SupCASlat          DB ?
MesSupCASlat       DB 13,23,41,'CAS#:',0
NumSupCASlat       DB 1 DUP(0),0
MesUpTo            DB ' (up to ',0
MesUpToForT        DB ' (xT up to ',0
NumUpTo            DB 3 DUP(0),' MHz)',0

MesCASLat1         DB '1',0
MesCASLat15        DB '1.5',0
MesCASLat2         DB '2',0
MesCASLat25        DB '2.5',0
MesCASLat3         DB '3',0
MesCASLat35        DB '3.5',0
PrnZpt             DB ',',0

MinRowPRecTime     DB ?

MesSpace           DB ' ',0
MesMinRowPRecTime  DB 23,67,18,'tRP:'
NumMinRowPRecTime  DB 2 DUP (0),0
MesNS              DB 'ns',13,0
MesNSonly          DB 'ns',0
MesErrSPDnum       DB '???',0
MesPlus0           DB '.0',0
MesPlus025         DB '.25',0
MesPlus05          DB '.5',0
MesPlus075         DB '.75',0
MesSDRAMLabel      DB 23,62,'Label: ',0
MesPCxxx           DB 'PCxxx',0
MesUnbuffered      DB 'U-',0
MesXxx             DB 'xxx-',0
NumTacAndSPDRev    DB 'xxx',0

MesPCxxxx          DB 'PCxxxx',0
MesXxxxx           DB 'xxxxx',0

TRCD               DB ?
TRAS               DB ?

MesTRAS            DB 23,56,18,'tRAS:'
NumTRAS            DB 2 DUP (0),0

MinPrToRASTime     DB ?
MesMinPrToRASTime  DB 13,23,3+36+3,'tRP-R,min:'
NumMinPrToRASTime  DB 2 DUP (0),'T',0
RDRAMFmin          DW ?
RDRAMFmax          DW ?
MesFMinMax         DB 30,23,73,18,'Fmin:'
NumFMin            DB 4 DUP (0),32,31,'MHz',30,23,88,'Fmax:'
NumFMax            DB 4 DUP (0),32,31,'MHz',13,0

MesMemModSize      DB 30,23,66,0
NumMemModSize      DB 5 DUP(0),32,31,'MB',23,74,31,0

NumJEDECID         DB 2 DUP(0),'h',0
MesManufPartNum    DB 23,88,18,' '
NumManufPartNum    DB 17 DUP(0),0

MesMemDMISpeed     DB 3 DUP(0),'ns',0
DIMMmodules        DB 0
MSpeedIdx          DD 0
MemSpeedIndex      DB 13,23,3,'Memory Bandwidth  ',23,32,':',23,33,32,31,0
NumMemSpeed        DB 8 DUP(0),32,31,'MB/s',0
XMSmemLength       DD ?
EndOfMemCoder      DD ?
MemCoderEBX        DD ?
MemCheckSum        DD ?
ForMemPrgBar       DW ?
MemCheckCounter    DD ?
PriznMemLoop       DB 0
MesMemCounter      DB 19,17,7+8,22,96,35
NumMemCounter      DB '    0',0
MesTestingMem      DB 19,17,7+8,22,63,35,'Testing extended memory... ',0
MesMemErr          DB 19,17,4,22,96,35,  'FAILED',0
MesMemDone         DB 19,17,2+8,22,96,35,'PASSED',0
MesMemSkipped      DB 19,17,2+8,22,96,35,'SKIPPED',0

PCIVideoDetected   DB 0
VideoMEM           DW 0
MesVESAMem         DB 13,23,3,      'VESA memory  : ',0
MesVideoMem        DB 13,23,3,      'Video memory : ',0
TotalVESAMem       DB 6 DUP (0),32,31,'KB',0
VideoMemRange      DD ?
NvidiaMem          DW 0
TotalVideoMem      DB 3 DUP (0),32,31,'MB',0

MesVideoMemSpeed   DB ' (',0
NumVideoSpeedVGA   DB 7 DUP(0),32,31,'KB/s)',0

MesVideo           DB 13,23,3,      'VESA OEM : '
VESAOEMString      DB 32 DUP(0),0
VGASpeed           DD 0
VideoMode          DW 0
AllTestVideoMode   DB 0
VESA101105         DB 0

HDDTestComplite    DB 0
MesCpuTest         DB 22,35+5,40,17,7+8,'Processor benchmark',0
MesHDDTest         DB 22,35+8,53,17,7+8,'Hard drive speed',0
MesPercentCompl    DB 22,14,40,18,17,7+8
NumPercentCompl    DB 2 DUP(0),' % Complete',0
MesCDTest          DB 22,35+9,53,17,7+8,'CD drive speed',0
MesTesting         DB 22,3,53,17,7+8,'Testing...',0
MesSkipped         DB 22,3,53,20,17,2+8,18,' Skipped '
SkippedTT          DB '  ',0
MesCDSkipped       DB 17,2+8,18,'Skipped   ',0
MesAvgMaxSkipped   DB 23,79,17,2+8,18,' Skipped         ',0

NumCpuSpeed        DB 22,2,40,17,7+8
NumCpuSpeedH       DB 8 DUP(0),0
NumHDDSpeed        DB 22,2,53,17,7+8
NumHDDSpeedH       DB 7 DUP(0),0

SkaleProc          DB 1
NumberDrives       DB 0

                   ALIGN 2
Heads              DD ?
Sectors            DD ?
Tracks             DD ?
TotalNumSectL      DD ?
;TotalNumSectH      DD ?
;BytePerSect        DD ?
Int13ExtSup        DB ?
Int13ExtDriveCapable DW 0
Int13Error         DB 0

                   ALIGN 2
ResWriteTrack      DD ?
DiskAdrPack        DB 10h;PacketSize
                   DB 0  ;
NumTransferBlock   DW ?  ;
TransferBufferL    DW 0  ; Ofs
TransferBufferH    DW ?  ; Seg
AbsNumBlockL       DD ?  ;
AbsNumBlockH       DD ?  ;

PCIIDEDevList      DW 105Ah,0D30h,105Ah,0D38h,105Ah,4D30h,105Ah,4D33h
                   DW 105Ah,4D38h,1095h,0646h,1095h,0648h,1095h,0649h
                   DW 1103h,0300h,1103h,0400h
                   DD 0; END
PCIVideoDevList    DW 5333h,8A22h,5333h,8A23h
                   DD 0; END

                   ALIGN 2
IDE0BaseIO         DW 1F0h
IDE1BaseIO         DW 170h
IDE2BaseIO         DW 1E8h
IDE3BaseIO         DW 168h
HddSize            DW ?
TotalAllDrive      DW ?
TotalHDD           DB 0
TotalCD            DB 0
AllDrives          DB 0
AllParam           DB 13,23,3,    'Hard drive '
DiskNumber         DB '0 : ',0
NumTracks          DB 6 DUP(0),0
MesCelinders       DB 'C ',31,0
NumHeads           DB 6 DUP(0),0
MesHeads           DB 'H ',31,0
NumSectors         DB 6 DUP(0),0
MesSectors         DB 'S',30,0

MesHddSizeGB       DB 23,32
NumHddSizeGB       DB 7 DUP(0),' ',31,'GB',0
MesHddSizeMB       DB 23,35
NumHddSizeMB       DB 4 DUP(0),' ',31,'MB',0
MesATA             DB 23,43,17,7,'(ATA',0
MesNumATA          DB '-'
NumATA             DB 1 DUP (0),0
MesATAscobka       DB ')',17,7+8,0
MesPrnAtaFuture    DB 17,7+8,22,53,3,0

MesRPM             DB 'Spindle speed: ',31,0
NumRPM             DB 5 DUP (0),32,31,'RPM',0
MesCacheBufferSize DB 'Cache: ',31,0
NumCacheBufferSize DB 5 DUP (0),32,31,'KB ',0
MesPIO             DB 'PIO ',31
NumPIO             DB 1 DUP (0),' ',0
MesDMA             DB 'DMA ',31
NumDMA             DB 1 DUP (0),0
MesUDMA            DB 'UDMA ',31
NumUDMA            DB 1 DUP (0),0
MesSelectedDMA     DB '('
NumSelectedDMA     DB 1 DUP (0),')',0

DefaultDrive       DB 0
TotalSpeedCounter  DB 0
TestingHDDnumber   DB 0
HeadNumber         DB 0

MesHDDforInfo      DB 13,23,3,17,6+8,'HDD ',31,'Model ',31,'('
IDEATAdevices      DB 2 DUP(0),'): ',17,7+8,0
MesATAPIforInfo    DB 13,23,3,'ATAPI dev(',0
MesCDROMforInfo    DB 13,23,3,'CD drive (',0
IDEATAPIdevices    DB 2 DUP(0),'): ',0

ATAPIPacket        DB 5Ah
                   DB 0
ATAPIPage          DB ?
                   DB 4 DUP(0)
ATAPIPageLength    DW ?
                   DB 3 DUP(0)

PrnHDDmodel        DB 13,23,4,31,192,196,31,' Model (',0

BadDownScr         DB 0
SkipDriveSelect    DB 0
MesDriveSelect     DB 22,69,4,17,3+8,18,'Drive Selection',0
MesForWin          DB 22,71
YposForPrn         DB 3,17
LitingPriznak      DB 7+8,0
MesHDDForWin       DB 'Hard drive '
NumberHDD          DB '0',0
MesCDForWin        DB 'CD drive   '
NumberCD           DB '0',0
NumFastFullTest    DB 22,69,3,17,3+8,'Method: ',0

MesHddNum          DB 22,53,2,17,7+8,19,'HDD ',31
HDDNum             DB 1,' ',0
MesTestingTrack    DB 17,7+8,22,53,33,19,'Testing track :',0                                      ;
MesHDDFastTest     DB 23,94,19,17,6+8,'FAST ',31,'TEST',0
MesHDDFullTest     DB 23,94,19,17,2+8,'FULL ',31,'TEST',0
MesInt13Ex         DB 23,88,19,17,7,' I13E ',0
MesLTreugScob      DB '<',0
MesRTreugScob      DB '>',0

MesFastTest        DB 19,17,6+8,'FAST TEST',0
MesFullTest        DB 19,17,2+8,'FULL TEST',0
MesRandomSeekTime  DB 17,5+8,22,53,5,19, 'Random seek time',23,76,':',0
RandomResultSeek   DB 17,5+8,22,80,5,18,31
NumRandomSeekSpeed DB 5 DUP(0),32,31,'ms',0
MesTrackSeekTime   DB 17,4+8,22,53,4,19, 'Average/Max seek time',23,76,':',0

AvgMaxSeekTime     DB 17,4+8,22,80,4,18,31
AvgSeekSpeed       DB 5 DUP(0),23,87,31
MaxSeekSpeed       DB 6 DUP(0),0
MesAvgMaxSeekTime  DB 17,4+8,22,85,4,'/',23,93,31,'ms',0

MesTimingSeek      DB 18,17,7+8,22,69,33
Track              DB 6 DUP(32)
ForUscoren         DB ' from '
TotalTrack         DB 6 DUP(32),0
ResultTT           DB 17,2,22,53,6,19,'Track-to-track seek',23,76,':   ',18,31
TTSpeed            DB 5 DUP(0),32,31,'ms',0

MesRandomAccess    DB 17,1+8,22,53
LineCorrect1       DB 7,19,           'Random access time',23,76,':   ',18,31
NumRandomAccess    DB 5 DUP(0),32,31,'ms',0

ResultSpeedHDD     DB 17,6,22,53
LineCorrect2       DB 9,19,           'Linear verify speed',23,76,':  ',18,31
VerifySpeedHDD     DB 6 DUP(0),32,31,'KB/s',0

ResultReadHDD      DB 17,6+8,22,53
LineCorrect        DB 10,19,          'Linear read speed',23,76,':  ',18,31
ReadSpeedHDD       DB 6 DUP(0),32,31,'KB/s',0

ResultWriteHDD     DB 17,7,22,53
LineCorrect5       DB 11,19,          'Linear write speed',23,76,':  ',18,31
WriteSpeedHDD      DB 6 DUP(0),32,31,'KB/s',0

ResultBufferedHDD  DB 17,5+8,22,53
LineCorrect4       DB 8,19,           'Buffered read speed',23,76,':  ',18,31,0
MesBufferedSpeedHDD DB 23,79,18,30,31
BufferedSpeedHDD   DB 6 DUP(0),32,31,'KB/s',0

HDDResBuff         DB 17*4*8 DUP(0)
CDResBuff          DB 10*4*4 DUP(0)

                   ALIGN 4
RealTrack          DD ?
TotallSeekSpeed    DD ?
SumSeekSpeed       DD ?
OldTotallSeekSpeed DD ?
TotallTTSpeed      DD ?
NewTekushSpeed     DD 0
TotallRandomAccess DD 0
AverageRNDAccess   DD 0

AntialisingPer1    DD ?

AntialisingPer2    DD ?
AntialisingPer3    DD ?

AntialisingSeed    DB 0
DisableAntialising DB 0

SumVertKoord       DD ?
NumVertKoord       DW ?
TekuhPointHor      DW ?

MashtabHdd         DW ?
MashtabHddSeek     DW ?
MashtabHddSeekTT   DW ?
TekuhPointVert     DW ?
PointVert          DW ?
OldTekuhPointVert  DW ?
OldTekuhPointVertFast DW ?
CounterHDDFastTest DD ?
HDDKolichProxodov  DD ?
Seek1_3            DW 0
SeekProblem        DB 0
SkipVerify         DB 0

SeekMashtab        DB 13,19,17,7+8,22,95
NumYposSeekMashtab DB ?
NumSeekMashtab     DB 6 DUP(0)
NumSDxSpeed        DB 0,102,31
NumXSpeedMastab    DB 3 DUP(0),'X',0
MesMs              DB 13,19,22,97,32,'(ms)',0
MesKbsec           DB 13,19,22,95,33,'(KB/s)',0

                   ALIGN 2
ZamerSpeedEAX      DD ?
ZamerReadEAX       DD ?
TotallReadSpeed    DD ?
ResHDDCacheSpeed   DD ?
AverageSeek        DD ?
MaxSeek            DD ?
AverageSeekHDD     DD ?
AverageSpeed       DD ?
MaxHDDtransfer     DD ?
MinHDDtransfer     DD ?

SeekZamer          DW ?
MashtabHddRead     DW ?
AverageTT          DW ?
MesTestCancel      DB 22,3,31,17,4,'Testing cancelled.',17,7+8,' Press ',17,2+8,'SPACE',17,7+8,' to menu.',0
MesVTOCErr         DB 22,3,31,17,4,'Error TOC.',0
MesTestComplete    DB 22,3,31,17,7+8,'Tests complete. Press ',17,2+8,'SPACE',17,7+8,' to menu.',0
AutoPCXFileName    DB 'sstimg'
NumPCXFileName     DB 2 DUP(0),'.pcx',0
AutoReportFileName DB 'sstrep'
NumReportFileName  DB 2 DUP(0),'.txt',0
SysBiosFileName    DB 'sysbios.rom',0

MesReportOK        DB 22,3,32,17,7+8,'Reports are ready.',0
MesPressSpace      DB 22,3,33,17,7+8,'Press ',17,2+8,'SPACE',17,7+8,' to continue or ',17,2+8,'ESC',17,7+8,' to exit.',0
MesErrPCX          DB 22,3,32,17,4,  'Write error. ',17,7+8,'Can not create PCX report file.',0
MesErrReport       DB 22,3,32,17,4,  'Write error. ',17,7+8,'Can not create TXT report file.',0
MesPressAnyKey     DB 22,3,32,17,7+8,'Press ',17,2+8,'ESC',17,7+8,' to exit.',0
MesPressC          DB 22,3,31,17,7+8,'Press ',17,2+8,'C',17,7+8,'- add comments, ',17,2+8,'S',17,7+8,'- Save As... or',17,2+8,' ENTER',17,7+8,'.',0
MesPressR          DB 22,3,32,17,7+8,'Press ',17,2+8,'R',17,7+8,' to create PCX and TXT report files.',0
MesPressDriveSl    DB 22,3,32,17,7+8,'Use keys: ',17,2+8,25,24,' ',25,25,' ENTER SPACE ESC',17,7+8,'.',0
MesPressI          DB 22,3,33,17,7+8,'Press ',17,2+8,'I',17,7+8,' to get PCI and ISA PnP information.',0
MesPressIM         DB 22,3,33,17,7+8,'Press ',17,2+8,'I',17,7+8,' or ',17,2+8,'M',17,7+8,' to get PCI/PnP or memory info.',0
MesPressM          DB 22,3,33,17,7+8,'Press ',17,2+8,'M',17,7+8,' to get memory information.',0
MesPressL          DB 22,3,33,17,7+8,'Press ',17,2+8,'L',17,7+8,' for continuous loop of memory test.',0

DOSCommandStr      DB 80 DUP(0)
MesPressAnyKeyEng  DB 13,10,'Press any key...',13,10,'$'
DetSMARTdrv        DB 0
CacheDIV           DD ?
SavedCR0           DD 0
NumberMemTest      DB 0
ALIGN 2
ResCacheSpeedRepl  DD 13 DUP(0)
ResCacheSpeedLodsd DD 13 DUP(0)
ResCacheSpeedStosd DD 13 DUP(0)
ResCacheSpeedMovsq DD 13 DUP(0)
ResCacheSpeedLodsq DD 13 DUP(0)
ResCacheSpeedStosq DD 13 DUP(0)

ResultsNew         DB 13 DUP(0) ;Результаты о найденных кэш
L1FastRes          DD ?
MemSpeedSkala      DW 0
LastCache          DW 0
DivMastabaMemSpeed DD 0
LastPointInMemGrp  DW 0

AllCache           DB 0
MesZamerMemSpeed   DB 17,7+8,22,63
CorrectIfMemErr1   DB 36,0
MesCacheSpeed      DB 13,23,63,'Data ',31,'cache ',31,'L'
NumberCache        DB 0,' ',31,'('
CacheSize          DB 4 DUP (0),' ',31,'KB)-'
NumCacheSpeed      DB 8 DUP(0),32,31,'MB/s',0

MesZamerMemSpeedM  DB 13,23,63,19,'Memory throughput',23,84,'-'
NumZamerMemSpeedM  DB 8 DUP(0),32,31,'MB/s',0

DisableMem         DB 0
DisablePnP         DB 0

MemTestExit        DB 0
MemTestErr         DD 0
MesErrorMemAdress  DB 17,7+8,22,63,36,19,'Number of passes:'
NumPasses          DB 5 DUP(0),0

MesBlockTest       DB 19,17,7+8,22,63
CorrectIfMemErr2   DB 36,'Results testing memory-timing',22,98,36,'(MB/s)',22,60,58,31
NumBSHkala         DB 5 DUP(0),23,66,31
                   DB 5 DUP(0),23,75,31
                   DB 5 DUP(0),23,84,31
                   DB 5 DUP(0),23,93,31
                   DB 5 DUP(0),23,100,32
                   DB 5 DUP(0)
                   DB 17,7+8,22,99,38,31
NumHkala1          DB 5 DUP(0),22,99,42,31
NumHkala2          DB 5 DUP(0),22,99,46,31
NumHkala3          DB 5 DUP(0),22,99,50,31
NumHkala4          DB 5 DUP(0),22,99,54,31
NumHkala5          DB 5 DUP(0),0

MesReadBlock       DB 19,22,87,43,17,6+8,196,196,17,7+8,' Reading',0
MesWriteBlock      DB 19,22,87,44,17,1+8,196,196,17,7+8,' Writing',0
MesReplBlock       DB 19,22,87,45,17,2+8,196,196,17,7+8,' Moving',0

MesMMXReadBlock    DB 19,22,87,47,17,6,196,196,17,7+8,' MMX Reading',0
MesMMXWriteBlock   DB 19,22,87,48,17,1,196,196,17,7+8,' MMX Writing',0
MesMMXMoveBlock    DB 19,22,87,49,17,5,196,196,17,7+8,' MMX Moving',0

AtaAtapi           DB ?
CDROMTest          DB 0
CDtested           DB 0
HddTest            DB 0
EnableWriteHDDInCL DB 0
EnableWriteHDD     DB 0
Method             DB 0
KolihCDROM         DB ?
ForvCDROM          DB ?
AllSectorCDROM     DD ?
TekSectorCDROM     DD ?

TekSectorCDROMfast DD ?
TekSectorCDROML    DD ?
TekSectorCDROMH    DD ?
OsnovnDivade       DD ?
CDtestSkipped      DB 0
HorKoord           DW 0
SectorsRead        DW ?
SectorsCounter     DB 0
ErrorRead          DB 0
OldErrorRead       DB 0
OldReadUnstab      DW 0
UnstabRead         DB 0
OldUnstab          DB 0
SectorSize         DW ?
TotalResultSpeedL  DD ?
TotalResultSpeedH  DD ?
KolihProhodov      DD ?
DivMastabCDROM     DD 0
TotalRead          DW 0
KolihProhodovM1    DB 0
MaxResultSpeed     DD 0
MaxResultSpeedSecond DD 0
MaxResultSpeedTek  DD 0
RealResultSpeed    DD 0
TotalUnstab        DW 0
TotalError         DW 0
BasicDivadeL       DD 0
BasicDivadeH       DD 0
BasicDivadeG       DD 0
TekushSpeedCDROM   DD ?
TekushSpeedCDGrp   DD ?
TekushSeekCDROM    DD ?
CDROMSeekColor     DW ?
MaxResSpeedMashtab DD 0
ResultSeekMashtab  DW 0
CompareGraph       DW ?
MesFullMethod      DB 17,2+8,22,96,36,'FULL',22,96,37,'TEST',0
MesSmartMethod     DB 17,6+8,22,96,36,'FAST',22,96,37,'TEST',0
MesCDROM           DB 19,22,53,2,17,7+8, 'Results testing CD drive '
NumCDROM           DB 'X'
                   DB 22,53,3,17,2+8,    'Average read speed',23,76,':',23,84,32,31,'KB/s -       X',30
                   DB 22,53,4,17,2,      'Maximal read speed',23,76,':',23,84,32,31,'KB/s -       X',30,0
MesCDROMunstab     DB 22,53,5,17,6+8,    'Unstable read zone',23,76,':'
                   DB 22,53,6,17,4+8,    'Fatal errors zone' ,23,76,':',0
MesRandAccessCDROM DB 18,22,53,5,17,1+8, 'Random access time',23,76,':',23,84,32,31,19,'ms',30,0
Mes13SeekCDROM     DB 18,22,53,6,17,6+8, '1/3 seek time',23,76,':',23,84,32,31,19,'ms',30,0
MesFullSeekCDROM   DB 18,22,53,7,17,5+8, 'Full seek time',23,76,':',23,84,32,31,19,'ms',30,0
MesSeekTestCDROM   DB 18,22,53,8,17,4+8, 'Average access time',23,76,':',23,84,32,31,19,'ms',30,0

MesCheckReadSpeed  DB 22,54,36,17,7+8,18,'Checking read speed...',0
MesCheckAccessTime DB 22,54,36,17,7+8,18,'Checking access time...',0

MesSectorAllSec    DB 22,54,36,17,7+8,18,'Testing sector   :',0
MesFrom            DB 23,81,'from '
NumSectorCDROM     DB 6 DUP(0),0
MesSectorAllRead   DB 22,54,37,          'Total read',23,71,':',23,78,'MB from ',31
NumAllTotalRead    DB 4 DUP(0),30,'MB',0
InposibleCDTEST    DB 22,53,8,17,4+8,18,'Access time test and compare results'
                   DB 22,53,9,       'were skipped. Testing disk ',0
SmallCD            DB 'less 596 MB.',0
ErrorCD            DB 'has errors.',0

MesReadSpeedCDROM  DB 18,22,83-4,3,17,2+8
NumReadSpeedCDROM  DB 5 DUP (32)
                   DB 23,91
NumXspeed          DB 3 DUP (48),'.',2 DUP (48)
MesMaxReadSpeedCD  DB 22,83-4,4,17,2
NumMaxReadSpeedCD  DB 5 DUP (32)
MesMaxXspeed       DB 23,91
NumMaxXspeed       DB 3 DUP (48),'.',2 DUP (48)
                   DB 19,22,84-4,5,17,6+8
NumTotalUnstab     DB 3 DUP (32)
                   DB 22,84-4,6,17,4+8
NumTotalError      DB 3 DUP (32),0

DriveCDROMNotReady DB 22,3,31,17,7+8,  'Insert ',17,2+8,'Data CD',17,7+8,' in CD drive '
NumCDdrive         DB '0',0

MesESC             DB 22,3,32,17,7+8,'Press ',17,2+8,'ESC',17,7+8,' to cancel tests,',17,2+8,' SPACE',17,7+8,' to skip test.',0

MesSectorCDROM     DB 18,22,53+21,36,17,7+8
NumTekSectorCDROM  DB 6 DUP(32),22,53+21,37,31
NumTotalRead       DB 4 DUP(32),30,0

NumRndSeekTestCDROM  DB 18,22,82-4,5,17,1+8
NumRndSeekTestCDROMH DB 6 DUP (0),0

Num13SeekTestCDROM   DB 18,22,82-4,6,17,6+8
Num13SeekTestCDROMH  DB 6 DUP (0),0

NumFullSeekTestCDROM  DB 18,22,82-4,7,17,5+8
NumFullSeekTestCDROMH DB 6 DUP (0),0

NumSeekTestCDROM   DB 18,22,82-4,8,17,4+8
NumSeekTestCDROMH  DB 6 DUP (0),0

MesSectorCDROMSeek DB 18,22,53+21,36,17,7+8
NumTekSectorCDROMH DB 6 DUP(32)
NumSkipTekSectorCDROML DB '  ',25,17,25,16,'  '
NumTekSectorCDROML DB 6 DUP(32),0

MesFullTestStart   DB 22,3,31,17,7+8,'Press ',17,2+8,'ENTER',17,7+8,' to run full '
NumFullTestHDD     DB ' CD tests.',0

PCICounter         DB 0
ISAPnPCounter      DB 0
NumberLastPCIBus   DB ?

NumPCIStr          DB 0

NumberPCIBus       DB 0 ;1 Первый байт структуры
NumRepPCIDev       DB 0 ;1
NumRepPCIFun       DB 0 ;1
PIClass            DB 0 ;1
SubClass           DB 0 ;1
ClassCode          DB 0 ;1
HeaderType         DB 0 ;1
PCIVEN             DW ? ;2
PCIDEV             DW ? ;2
PCIREV             DB ? ;1
PCISUBSYSVEN       DW ? ;2
PCISUBSYSDEV       DW ? ;2
NumPCISeg          DW 0 ;2
NumPCIDevVendor    DW 0 ;2
NumPCIDevName      DW 0 ;2
NumPCIVideoDev     DB 0 ;1 Данные которые обнуляются перед новым устройством
VerAGP             DB 0 ;1
SupAGPRate         DB 0 ;1
AGPDataRate        DB 0 ;1
AGPEnable          DB 0 ;1
AGPCapIdReg        DD 0 ;4
AGPStatusReg       DD 0 ;4
AGPCommandReg      DD 0 ;4
MemBase0           DD 0 ;4
MemBase1           DD 0 ;4
MemBase2           DD 0 ;4
MemBase3           DD 0 ;4
MemBase4           DD 0 ;4
MemBase5           DD 0 ;4
MemBaseRange0      DD 0 ;4
MemBaseRange1      DD 0 ;4
MemBaseRange2      DD 0 ;4
MemBaseRange3      DD 0 ;4
MemBaseRange4      DD 0 ;4
MemBaseRange5      DD 0 ;4
EndOfPCISruct      DB 0 ;1 Последний байт структуры

FoundAGPController DB 0

StringPos          DW ?
MesDitailedInfo    DB 23,24-3
NumPCIVen          DB 4 DUP(0)
                   DB 23,33-6
NumPCIDev          DB 4 DUP(0)
                   DB 23,44-11
NumPCIRev          DB 2 DUP(0)
                   DB ' '
NumPCISubSysVen    DB 4 DUP(0)
NumPCISubSysDev    DB 4 DUP(0),' ',0

MesPciInstalled    DB 22,3,36,17,3+8,18,'PCI/AGP Device Information',0
MesPCIBIOSVersion  DB 30,18,17,3+8,'PCI ',31
NumMajorPciVersion DB 1 DUP (0),'.'
NumMinorPciVersion DB 2 DUP (0),0
MesAGPVersion      DB 18,17,3+8,'AGP ',31
NumMajorAGPVersion DB 1 DUP (0),'.'
NumMinorAGPVersion DB 1 DUP (0),0
MesSupAGPRate      DB 18,17,3+8,32,31,'('
NumSupAGPRate      DB 1 DUP (0),'x)',0

MesPCIVideo        DB 13,23,3,'Video: ',0
MesAGPVideoNotRate DB 13,23,3,'AGP: ',0
MesAGPVideo        DB 13,23,3,'AGP/',17
NumAGPColorRate    DB 6+8
NumSupAGPVideoRate DB 1 DUP (0),'x',17,7+8,': ',0

OldPCIDevice       DW ?
NumPCIDeviceID     DB 4 DUP (0),'h',0
MesPCITitle        DB 22,3,38,17,7+8,'Bus Dev Fun IRQ  Device',13,0
MesPCITitle1       DB 22,3,38,17,7+8,'Bus Dev Fun IRQ  VenID DevID Rev SubSysID  Class',13,0
MesNumberPCIBus    DB 13,23,2
NumNumberPCIBus    DB 4 DUP (0)
NumNumberPCIDevice DB 4 DUP (0)
NumNumberPCIFunct  DB 4 DUP (0)
NumIRQPCIDevice    DB 4 DUP (0),'  ',0
XPosPCIList        DB 0
YPosPCIList        DB 0
GetPCIInfoOK       DB 0
PCIRepInfoGeting   DB 0
NextBusScanOK      DB 0
NumPCIVendor       DB 256 DUP (0)

Bug2000testErr     DB 0
MesFoundBug2000    DB 13,17,4,23,3,'RTC/BIOS Year2000 Bug: ',17,7+8,0
Bug2000Test1            DB 0
Test1WithBugDate        DD ?
Bug2000Test1NormalYear  DW 2000h
Bug2000Test1NormalDay   DB 01h
Bug2000Test1NormalMonth DB 01h
Bug2000Test1Year        DW 1999h
Bug2000Test1Day         DB 31h
Bug2000Test1Month       DB 12h
Bug2000Test1Minutes     DB 59h
Bug2000Test1Hour        DB 23h
Bug2000Test1DayLight    DB 0
Bug2000Test1Seconds     DB 59h
RealYear           DW ?
RealDay            DB ?
RealMonth          DB ?
RealMinutes        DB ?
RealHour           DB ?
RealDayLight       DB ?
RealSeconds        DB ?
Year               DW ?
Day                DB ?
Month              DB ?
Minutes            DB ?
Hour               DB ?
DayLight           DB ?
Seconds            DB ?
MesDateTime        DB   22,3,32,17,7+8
NumDay             DB 2 DUP(0),'-'
NumMonth           DB 2 DUP(0),'-'
NumYear            DB 4 DUP(0),0
MesHour            DB ' '
NumHour            DB 2 DUP(0),':'
NumMinutes         DB 2 DUP(0),':'
NumSeconds         DB 2 DUP(0),0

CurrCSN            DB 0
pnprdr             DB 80h
ANSIIDstring       DB 0
ISAConfigStrucSupport DB 0
CSNFromISAConfigStruc DB 0FFh

XPosISAPnP         DB 18
MesISAPnP          DB 22,3
PCIcorrection      DB 36,17,3+8,18,'ISA PnP Device Information',13,13
                   DB 23,3,17,7+8,'Card  Vendor ID  Serial No  ANSI ID String',13,0

MesISAPnPCard      DB 13,23,3+3
NumISAPnPCard      DB 48,23,11,0
PosAdrNamePnPCard  DW AdrNameISAPnP+2
AdrNameISAPnP      DW NameISAPnP,9 DUP (0)
PosNameISAPnPBuf   DW NameISAPnP
SerialIDbuff       DB 72 DUP (0);Vendor_ID+Ser.Num по 9 байт на плату, 8 плат
VendorIDISAPnP     DB 7 DUP (0),'   '
SerialNoIDISAPnP   DB 8 DUP (0),'  ',0
NameISAPnP         DB 256 DUP (0)

CacheBenchLabel    DB 0

MesCacheMemBench   DB 22,38,36,17,3+8,18,'Cache/Memory Benchmark',13,17,7+8
                   DB 13,23, 58+3-3,'Read',23,67+2+3-2,'Write',23,80+2+3-1,'Move',23,92+3,'Average',13,0
MesMMXCacheMemBench DB 22,38,48,17,3+8,18,'MMX',tm,'Cache/Memory Benchmark',13,17,7+8
                    DB 13,23,55+3-3,'MMX Read',23,66+3-2,'MMX Write',23,79+3-1,'MMX Move',23,92+3,'Average',13,0
MesCacheLevel      DB 13,23,38,'Cache Level ',31
NumberCacheBench   DB 1 DUP(0),30,0
MesMemBench        DB 13,23,38,'Memory',0
NumCacheMemBench   DB 23,55-3
NumReadMemBench    DB 8 DUP(0),32,31,'MB/s',30,23,67-2
NumWriteMemBench   DB 8 DUP(0),32,31,'MB/s',30,23,79-1
NumReplMemBench    DB 8 DUP(0),32,31,'MB/s',30,23,91
NumAverageMemBench DB 8 DUP(0),32,31,'MB/s',30,0

NumAveraging1      DD ?
NumAveraging2      DD ?
NumAveraging3      DD ?
NumAveraging4      DD ?
NumAveraging5      DD ?

          EXTRN ChipsetsList, MemManufacturerList:word

MesRepFile         DB 13,'System Speed Test  Ver ',SpeedsysVer,26,33,'Report file - created on ',0
MesPCXRepFile      DB 22,3,31,17,7+8,'System Speed Test  Ver ',SpeedsysVer,22,3,33,'Report file - created on ',0

MesRepV86Mode      DB 13,13,'CPU is in V86 mode: ',0
MesRepNo           DB 'No',0
MesRepYes          DB 'Yes',0
MesRepCPU          DB 13,   'Processor',26,18,': ',0
NumRepCPUVendor    DW 0
NumRepCPUModel     DW 0
MesRepMhzViaRDTSC  DB 13,   'Frequency via TSC : ',0
MesRepExternClock  DB 13,   'External clock    : ',0
MesRepWriteAloc    DB 13,   'Write Allocate    : ',0
MesRepCPUID        DB 13,   'CPUID (TFMS)',26,18,': ',0
MesRepMicrocodeRev DB 13,   'Microcode Revision: ',0
NumRepMicrocodeRev DB 8 DUP(0),0

MesRepFeatureReg   DB 13,   'Feature',26,18,': ',0
MesExtCPUparam     DB 13,   'Extended CPUID',26,18,': '
ExtNumCPUtype      DB 1 DUP(0)
ExtNumCPUfamily    DB 1 DUP(0)
ExtNumCPUmodel     DB 1 DUP(0)
ExtNumCPUstepping  DB 1 DUP(0),'  ',0
CPUNameString      DB 13,   'CPU Name String   : ',0
MesRepOriginalClock   DB 13,   'Original CPU Clock',26,18,': ',0
OriginalCPUClock      DB 4 DUP(0),' MHz (',0
OriginalExternalClock DB 4 DUP(0),' MHz x ',0
OriginalMultiplier    DB 5 DUP(0)
MesScobka             DB ')',0
MesRepOverclocking    DB ' (Overclocking: +',0
NumRepOverclocking    DB 7 DUP(0),'%)',0
MesRepPlatformID      DB 13,   'Platform ID',26,18,': ',0
MesRepBrandID         DB 13,   'Brand ID',26,18,': '
NumRepBrandID         DB 2 DUP(0),'h',0
MesRepSlot1           DB 'Slot 1',0
MesRepSlot2           DB 'Slot 2',0
MesRepMobileBGA2      DB 'Mobile BGA2',0
MesRepSocket370pga    DB 'Socket 370 (PPGA Package)',0
MesRepSocket370fcpga  DB 'Socket 370 (FC-PGA Package)',0
MesRepSocket370fcpga2 DB 'Socket 370 (FC-PGA2 Package)',0
MesRepMobileuPGA2     DB 'Mobile uPGA2',0
MesRepSocket423       DB 'Socket 423',0
MesRepSocket478       DB 'Socket 478',0

MesRepCache        DB 13,   'L'
NumRepCacheNumber  DB 1 DUP(0),' Cache size',26,18,': ',0
NumRepCache        DB 5 DUP (0),' KB',0

MesRepL2Latency    DB 13,   'L2 Cache Latency',26,18,': '
NumRepL2Latency    DB 1 DUP (0),0

MesRepSN           DB 13,   'Serial Number',26,18,': ',0
NumCPUSerialNumberEAXH DB 4 DUP(0),'-'
NumCPUSerialNumberEAXL DB 4 DUP(0),'-'
NumCPUSerialNumberEDXH DB 4 DUP(0),'-'
NumCPUSerialNumberEDXL DB 4 DUP(0),'-'
NumCPUSerialNumberECXH DB 4 DUP(0),'-'
NumCPUSerialNumberECXL DB 4 DUP(0),0

MesRepExtFeature   DB 13,   'Extended Feature  : '
NumExtFeatureRegH  DB 4 DUP (0)
NumExtFeatureRegL  DB 4 DUP (0),'h',0

MesRepCPUbench     DB 13,   'CPU speed index   : ',0
NumRepCodeName     DW 0

MesRepMemorySize   DB 13,13,'Total memory size : ',0
MesRepChipset      DB 13,'Mainboard chipset : ',0
MesRepMainboard    DB 13,'Mainboard model   : '
NumRepMainboard    DB 64 DUP (0)
MesRepFoundBug2000 DB 13,   'Year2000 Bug',26,18,': ',0

MesRepPCIVideo     DB 13,13,'PCI Video',26,18,': ',0
MesRepAGPVideo     DB 13,13,'AGP Video',26,18,': ',0
MesSupportAGPrate  DB 13,   'Support AGP rate  : ',0
NumSupportAGPrate  DB 1 DUP (0),'x',0
MesDesiredAGPrate  DB 13,   'Desired AGP rate  : '
NumDesiredAGPrate  DB 1 DUP (0),'x',0
MesAGPoperations   DB 13,   'AGP Operations',26,18,': ',0
MesAGPEnabled      DB 'Enabled',0
MesAGPDisabled     DB 'Disabled',0
MesFastWrites      DB 13,   'AGP Fast Writes   : ',0
MesSBA             DB 13,   'AGP SBA',26,18,': ',0
MesFWSupport       DB 'Supported, Status: ',0
MesNotSupport      DB 'Not Supported',0

MesAGPStatusReg    DB 13,'AGP Status Reg.   : '
NumAGPStatusRegH   DB 4 DUP(0)
NumAGPStatusRegL   DB 4 DUP(0),'h',13,'AGP Command Reg.  : '
NumAGPCommandRegH  DB 4 DUP(0)
NumAGPCommandRegL  DB 4 DUP(0),'h',0
MesRepVESAOEM      DB 13,13,'VESA OEM String   : ',0
MesRepVESAMem      DB 13,   'VESA video memory : ',0
MesRepVideoMem     DB 13,   'Total video memory: ',0

AllParamForRep     DB 13,   'Hard drive '
DiskNumberForRep   DB '0',26,18,': ',0
MesRepMaxSeekTime  DB 13,26,18,'Average/Max seek time',26,41,': ',0
MesRepSeekTime     DB 13,26,18,'Random seek time',26,41,': ',0
MesRepTtoTSeek     DB 13,26,18,'Track-to-track seek',26,41,': ',0
MesRepRandAccess   DB 13,26,18,'Random access time',26,41,': ',0
MesRepLinTransfer  DB 13,26,18,'Linear verify speed',26,41,': ',0

MesRepMaxMinVerify DB 13,26,18,'Min/Max verify speed',26,41,': ',0
MesRepPrnDev       DB ' / ',0

MesRepLinRead      DB 13,26,18,'Linear read speed',26,41,': ',0
MesRepMaxMinRead   DB 13,26,18,'Min/Max read speed',26,41,': ',0

MesRepLinWrite     DB 13,26,18,'Linear write speed',26,41,': ',0
MesRepMaxMinWrite  DB 13,26,18,'Min/Max write speed',26,41,': ',0

MesRepBufferedRead DB 13,26,18,'Buffered read speed',26,41,': ',0
MesRepHDDSpeedIdx  DB 13,26,18,'Hard Drive speed index',26,41,': ',0
NumRepSpeedInMS    DB 6 DUP(0),' ms',0
MesRepUsesFastTest DB 13,26,18,'Tested in FAST mode',0
MesRepUsesFullTest DB 13,26,18,'Tested in FULL mode',0

CDParamForRep      DB 13,   'CD drive '
CDDiskNumberForRep DB '0',26,18,': ',0
MesCDNotTested     DB '<Not Tested>',0
MesCDDiskSize      DB 'Disk size - ',0
MesRepCDsectors    DB 'S, ',0
MesRepMinus        DB ' - ',0
MesRepCDReadSpeed  DB 13,26,18,'Average read speed',26,41,': ',0
MesRepCDMaxRead    DB 13,26,18,'Maximal read speed',26,41,': ',0
MesRepCD13Seek     DB 13,26,18,'1/3 seek time',26,41,': ',0
MesRepCDFullSeek   DB 13,26,18,'Full seek time',26,41,': ',0
RepNumXspeed       DB 3 DUP (48),'.'
                   DB 2 DUP (48),' X',0
MesRepCDAccessTime DB 13,26,18,'Average access time',26,41,': ',0
MesRepCDUnstabZone DB 13,26,18,'Unstable read zone',26,41,': ',0
MesRepCDErrorZone  DB 13,26,18,'Fatal errors zone' ,26,41,': ',0
MesRepCDSpeedIdx   DB 13,26,18,'CD drive speed index',26,41,': ',0

MesATAATAPI        DB 13,13,26,16,'ATA/ATAPI Device Information',0
MesRepIDE0Master   DB 13,13,'IDE'
NumIDEForRep       DB 1 DUP('0'),196,194,196,'Master',196,0
MesRepIDE0Slave    DB 13,26,5,179,13,26,5,192,196,'Slave',196,196,0
MesRepEmpty        DB '<Empty>',0
MesATAForRep       DB '<ATA',0
MesATAPIForRep     DB '<ATAPI',0
MesATAVerForRep    DB '-'
NumATAVerForRep    DB 1 DUP (0),0
MesRepNameTire     DB '>',196,32,0
MesHDDGeometry     DB 'Cylinders: ',0
NumRepCylinders    DB 5 DUP (0),', Heads: ',0
NumRepHeads        DB 5 DUP (0),', Sectors: ',0
NumRepSectors      DB 5 DUP (0),' (',0
NumRepSizeGB       DB 7 DUP (0),' GB)',0
NumRepSizeMB       DB 4 DUP (0),' MB)',0
MesMaxTransferSpeed DB 'Maximum Transfer Speed',26,41,': ',0
MesSelectedSpeed    DB 'Selected Transfer Speed',26,41,': ',0
MesMaxWriteSpeed      DB 'Maximum Write Speed',26,41,': ',0
MesSelectedWriteSpeed DB 'Selected Write Speed',26,41,': ',0
MesMaxTransfer      DB 'Maximum Transfer Mode',26,41,': ',0
MesSelectedTransfer DB 'Selected DMA Transfer Mode',26,41,': ',0

MesATASerialNum     DB 'Serial Number',26,41,': ',0
MesATAFirmwareRev   DB 'Firmware Revision',26,41,': ',0
MesHDDCacheSize     DB 'Cache Buffer Size',26,41,': ',0
MesSpindleSpeed     DB 'Spindle Speed',26,41,': ',0
MesRepXSpeed        DB ' (',0
NumRepXSpeed        DB 3 DUP(0),'X)',0

MesRepPIOmode      DB 'PIO '
NumRepPIOmode      DB 1 DUP (0),0
MesRepUDMAmode     DB ', UDMA '
NumRepUDMAmode     DB 1 DUP (0),0
MesRepDMAmode      DB ', DMA '
NumRepDMAmode      DB 1 DUP (0),0
MesRepUltraDMA     DB ' (UltraDMA/',0
MesRepUDMA33       DB '33)',0
MesRepUDMA44       DB '44)',0
MesRepUDMA66       DB '66)',0
MesRepUDMA100      DB ' (ATA-100)',0
MesRepUDMA133      DB ' (ATA-133)',0

MesRepPos          DB 13,26,5
NumRepPos          DB 179,26,11,0

MesRepOSversion    DB 13,   'OS version',26,18,': ',0
NumRepOSver1       DW 0
NumRepOSver2       DW 0
NumRepOSver3       DW 0
MesWin2000Build    DB ' Build ',0
NumWin2000Build    DB 5 DUP(0),0
MesRepBIOS         DB 13,   'BIOS vendor',26,18,': ',0
MesRepComputerName DB 13,13,'Computer name',26,18,': ',0
MesRepUserName     DB 13,   'Current user name',26,18,': ',0

MesRepStrMemBench     DB 13,26,16,179,'     Read     ',179,'     Write    ',179,'     Move     ',179,'    Average   ',179,0
MesRepMMXMemBench     DB 13,26,16,179,'   MMX Read   ',179,'   MMX Write  ',179,'   MMX Move   ',179,'    Average   ',179,0
MesRepStr1            DB 13,13,26,16,'Cache/Memory Benchmark',0
MesRepMMXStr1         DB 13,13,26,16,'MMX(tm) Cache/Memory Benchmark',0
MesRepStr1a           DB 13,26,16,218,14 DUP(196),194,14 DUP(196),194,14 DUP(196),194,14 DUP(196),191,0
MesRepStr2            DB 13,218,15 DUP(196),197,14 DUP(196),197,14 DUP(196),197,14 DUP(196),197,14 DUP(196),180,0
MesRepStr3            DB 13,192,15 DUP(196),193,14 DUP(196),193,14 DUP(196),193,14 DUP(196),193,14 DUP(196),217,0
MesRepCacheLevel      DB 13,179,' Cache Level '
NumberRepCacheBench   DB 1 DUP(0),' ',179,' ',0
MesRepMemBench        DB 13,179,' Memory        ',179,' ',0
NumRepReadMemBench    DB 8 DUP(0),' MB/s',179,' '
NumRepWriteMemBench   DB 8 DUP(0),' MB/s',179,' '
NumRepReplMemBench    DB 8 DUP(0),' MB/s',179,' '
NumRepAverageMemBench DB 8 DUP(0),' MB/s',179,' ',0

MesMemModulesForRep   DB 13,13,26,16,'Memory Modules Information',0
MesFoundForRep        DB 13,13,26,11,'SMBus/i2c Host Controller',26,41,': ',0
MesPIIX4              DB 'Intel PIIX4',0
Mes82440MXSMBus       DB 'Intel 82440MX',0
MesICH                DB 'Intel ICH',0
MesICH0               DB 'Intel ICH0',0
MesICH2               DB 'Intel ICH2',0
MesICH2M              DB 'Intel ICH2-M',0
MesICH3E              DB 'Intel ICH3',0
MesICH3               DB 'Intel ICH3',0
MesICH4               DB 'Intel ICH4',0
MesICH5               DB 'Intel ICH5',0
MesVIA596             DB 'VIA 596A/B',0
MesVIA686A            DB 'VIA 686A/B',0
MesAMD755             DB 'AMD-755',0
MesAMD756             DB 'AMD-756',0
MesAMD766             DB 'AMD-766',0
MesAMD768             DB 'AMD-768',0
MesALIM7101           DB 'ALI M7101',0
MesVIA686             DB 'VIA 686',0
MesVIAVT8235          DB 'VIA VT8235',0
MesVIAVT8231          DB 'VIA VT8231',0
MesVIAVT8233          DB 'VIA VT8233',0
MesVIAVT8233C         DB 'VIA VT8233C',0
MesVIAVT8233D         DB 'VIA VT8233',0
MesVIAVT8233A         DB 'VIA VT8235',0
MesVIAVT8237          DB 'VIA VT8237',0
MesRelOSB4            DB 'Reliance OSB4',0
MesRel0227            DB 'Reliance 0227',0
MesSiS5595B           DB 'SiS 5595B',0
MesSiSSMBus           DB 'SiS SMBus Host',0
MesnForceSMBus        DB 'nForce',0
MesnForceMCPTSMBus    DB 'nForce MCP-T',0
MesnForceMCP3SMBus    DB 'nForce MCP3',0
MesSMBA               DB ', I/O: ',0
NumSMBA               DB 4 DUP(0),'h',0
MesNotDetect          DB 'Not Detected',0

MesRepSlotNumber      DB 13,13,'<Slot '
NumRepSlotNumber      DB 0,'>',0
MesRepSPDError        DB 'SPD-EEPROM Checksum',26,41,': ',0
MesRepOK              DB 'OK',0
MesRepError           DB 'Error',0
MesRepMemModuleSize   DB 13,26,11,'Memory Module Size',26,41,': ',0
MesRepMemModuleType   DB 13,26,11,'Memory Type',26,41,':',0
MesRepTechnology      DB 13,26,11,'Technology',26,41,': ',0
NumRepNumberChips     DB 3 DUP(0),'x[',0
NumRepSDRAMBanks      DB 3 DUP(0),'Mx',0
NumRepSDRAMWidth      DB 3 DUP(0),'], ',0
NumRepChipMbit        DB 4 DUP(0),' Mbit',0
MesRepSDRAMAccesTime  DB 13,26,11,'SDRAM Access time       (tAC) : ',0
MesRepCycleTime       DB 13,26,11,'SDRAM Cycle time       (tCYC) : ',0
MesRepSupportedCAS    DB 13,26,11,'Supported CAS# Latency',26,41,': ',0
MesRepMinRowPreTime   DB 13,26,11,'Min. Row Precharge Time (tRP) : ',0
MesRepMinRAStoCAS     DB 13,26,11,'Min. RAS to CAS Delay  (tRCD) : ',0
MesRepNewStrForUpTo   DB 13,26,47,0
MesRepMinRASPules     DB 13,26,11,'Min. RAS Pulse Width   (tRAS) : ',0
NumMemMHz             DB 5 DUP(0),' MHz)',0
MesRepMinPrToRASTime  DB 13,26,11,'Min. Precharge to RAS (tRP-R) : ',0
MesRepFmax            DB 13,26,11,'Max. Frequency         (Fmax) : ',0
MesRepFmin            DB 13,26,11,'Min. Frequency         (Fmin) : ',0
NumRepFMinMax         DB 4 DUP (0),' MHz',0

MesRepManufacturer    DB 13,26,11,'Manufacturer',26,41,': ',0
MesRepSerialNumber    DB 13,26,11,'Serial Number',26,41,': ',0
MesRepManufPartN      DB 13,26,11,'Manufacturer''s Part Number',26,41,': ',0
MesNotPresent         DB 'Not Present',0
MesModuleLabel        DB 13,26,11,'Label',26,41,': ',0

MesPciInstalledForRep DB 13,13,26,16,'PCI/AGP Device Information ',0
MesRepPCIInfo      DB 13,'['
NumRepPCIBus       DB 2 DUP(0),'-'
NumNumRepPCIDev    DB 2 DUP(0),'-'
NumNumRepPCIFun    DB 1 DUP(0),']',0
MesReportPCIVEN    DB 'VEN_'
NumReportPCIVEN    DB 4 DUP(0),', DEV_'
NumReportPCIDEV    DB 4 DUP(0),', REV_'
NumReportPCIREV    DB 2 DUP(0)
SkipSubsys         DB ', SUBSYS_'
NumRepPCISUBSYSDEV DB 4 DUP(0)
NumRepPCISUBSYSVEN DB 4 DUP(0),0
MesRepPrn13        DB 13,32,32,32,32,192,196,196,196,196,196,32,0
MesRepPrnForHDDMod DB 13,26,11,192,196,196,196,196,196,32,0
MesTab2611         DB 13,26,11,0
MesUnknownPCIVen   DB 'Unknown Vendor',0
MesUnknownPCIDev   DB 'Unknown Device',0
MesRepMemoryBase   DB 13,26,11,'Memory Base Address ',0
MesRepMemoryBaseRange DB 13,26,11,'Memory Base Range ',0
MesRepIOBase       DB 13,26,11,'I/O Base Address ',0
MesRepIOBaseRange  DB 13,26,11,'I/O Base Range ',0

MesRepClassCode    DB 13,26,11,'Class Code : '
NumRepClassCode    DB 6 DUP(0),' - ',0

NumRepAdrNumber    DB 1 DUP(0),26,41,': ',0
MesRepRengeLegth   DB ' (',0
MesRepRangeInByte  DB 5 DUP(0),')',0
MesRepRangeInKB    DB 5 DUP(0),'KB)',0
MesRepRangeInMB    DB 5 DUP(0),'MB)',0

NumMemoryBaseH     DB 4 DUP(0)
NumMemoryBaseL     DB 4 DUP(0),0

MerRepISAPNP           DB 13,13,26,16,'ISA PnP Device Information',13,13
                       DB 26,3,'Card  Vendor ID  Serial No  ANSI ID String',13,0
MesISAPnPCardForRep    DB 13,26,6
NumISAPnPCardForRep    DB 48,26,11,0
VendorIDISAPnPForRep   DB 7 DUP (0),'   '
SerialNoIDISAPnPForRep DB 8 DUP (0),'  ',0

MesEndOfReport     DB 13,13,'End of report.',13,0

MesMax36Chars      DB 22,3,31,'Max. Length: 36 chars',0
MesMax8Chars       DB 22,3,31,'Max. Length: 8 chars',0
;MesComments        DB 22,3,32,18,'Comments: '
NumCommentsBufPrn  DB 18
NumCommentsBuf     DB '_',38 DUP(0)
MesComments        DB 22,3,32,18,'Comments: ',0
MesRepComments     DB 13,13,'Comments to report: ',0

MesFileName        DB 22,3,32,18,'File Name: ',0
NumComments        DB 36 DUP(0),0
NumFileName        DB 8 DUP(0)
CommentsCursorPos  DW 0
NumMaxChars        DB 32

          ENDS Dseg

          SEGMENT Cseg Page Public 'CODE'

          PUBLIC ErrorDiv

          EXTRN MemSpeedBlockRepl:proc,MemSpeedBlockForZamerRepl:proc
          EXTRN MemSpeedBlockLodsd:proc,MemSpeedBlockForZamerLodsd:proc
          EXTRN MemSpeedBlockStosd:proc,MemSpeedBlockForZamerStosd:proc
          EXTRN MemSpeedBlockLodsq:proc,MemSpeedBlockForZamerLodsq:proc
          EXTRN MemSpeedBlockLodsqPrg:proc,MemSpeedBlockLodsdPrg:proc
          EXTRN MemSpeedBlockStosq:proc,MemSpeedBlockForZamerStosq:proc
          EXTRN MemSpeedBlockStosqPrg:proc,MemSpeedBlockMovsq:proc
          EXTRN MemSpeedBlockForZamerMovsq:proc,MemSpeedBlockMovsqPrg:proc
          EXTRN MemSpeedBlockMovsdPrg:proc,MemSpeedBlockStosdPrg:proc
          EXTRN GetIntelCacheSize:proc,ClearHMSblock:proc;,MemIDX:proc
          EXTRN GetMemPeakBandwidth32:proc,GetMemPeakBandwidth64:proc,GetMemPeakBandwidth128:proc
          EXTRN HkalaMash:proc,HkalaMashMSB:proc,HkalaMashCDROM:proc
          EXTRN LongTimerL:word,StopMotor:Proc,AdrScreen:proc,ColorFrame:proc
          EXTRN BinToAscHex:proc,NzInMes:proc,KeyWaiting:proc,GetCh:proc
          EXTRN ColorVerLine:proc,ColorLine:proc,ColorHorLine:proc
          EXTRN ColorStr6x8:proc,CursorPos:proc,Rectangle:proc
          EXTRN Bintoascdec:proc,BintoascdecH:proc,BinToAscDec2:proc
          EXTRN StartNewTimer:proc,StopNewTimer:proc,Encoding:proc
          EXTRN SetNewInterrupt:proc,RestoreInterrupt:proc
          EXTRN SetTimerInterrupt:proc,RestoreTimerInterrupt:proc
          EXTRN Rnd:proc,SetRnd:proc,CreatePCXfile:proc
          EXTRN InitXMSAccess:proc,WriteFile:proc,GetStringLength:proc
          EXTRN ClearWindowMesages3:proc,ClearWindowMesages2:proc,ClearWindowMesages:proc
          EXTRN FaindPCIDevice:proc,ReadCfgByte:proc,WriteCfgByte:proc
          EXTRN ReadCfgWord:proc,WriteCfgWord:proc,ReadCfgDWord:proc,WriteCfgDWord:proc
          EXTRN ClearRightScreen:proc,ClearDownScreen:proc
          EXTRN Skale:proc,PrintSravnenieCPU:proc,PrintSravnenieHDD:proc,PrintSravnenieCD:proc
          EXTRN DetectRiseCodeName:proc,DetectIDTCodeName:proc
          EXTRN DetectCyrixCodeName:proc,DetectIntelCodeName:proc,DetectAMDCodeName:proc
          EXTRN GetIntelClockRatio:proc,GetK6ClockRatio:proc
          EXTRN GetK7ClockRatio:proc,GetCyrixIIIClockRatio:proc, GetSamuelClockRatio:proc
          EXTRN PutWordToReportBuf:proc,PrnRepLine:proc,PutByteToReportBuf:proc,PutToReportBuf:proc,PutDOSStr:proc
          EXTRN GetALISPDByte:proc,GetAMD756SPDByte:proc,GetIntelSPDByte:proc,GetnForceMCPTByte:proc
          EXTRN Setka:proc,EnDisSPDAccessOnCUSL2:proc,EnDisSPDAccessOnCUR:proc
          EXTRN EnDisSPDAccessOnP4B:proc,EnDisSPDAccessOnA7A:proc
          EXTRN UnpackPCIString:proc,GetSISSPDByte:proc,GetSISSPDByte2:proc,NonZeroPrn:proc
          EXTRN CorrectSPDSpeedToStd:proc,CorrectDDRSPDSpeedToStd:proc
          EXTRN CheckMSCDEX:proc,GetCorrectFrec:proc,CorrectDMIFSB:proc
          EXTRN Wait3SecKeyWaiting:proc,DetectPentiumClockRatio:proc
          EXTRN CorrectDMIMainBoardName:proc,GetBlockSizeForTesting:proc
          EXTRN MesagesFrame:proc,GetATABlockSize:proc,SetATABlockSize:proc
          EXTRN AtaAtapiGetParam:proc,GetRPM:proc,GetIDString:proc
          EXTRN WaitingBusyAndDRQClear:proc,WaitingDRDYSet:proc,WaitingBusy:proc
          EXTRN WaitBusyAndDataRequest:proc,WaitDRQClear:proc,GetHDDSizeInGB:proc
          EXTRN CalcResMem:proc,WaitingAndGetCh:proc,DetectGA5AA:proc
          EXTRN ReadPCIConfig:proc,ReadPCIConfigDword:proc,WritePCIConfigDword:proc
          EXTRN ISAPnPDelay:proc,ISAPnPCheckSum:proc,InBitMap:proc,ISAPnPKey:proc
          EXTRN GetTransmetaCPUName:proc,GetAMDCPUName:proc

          ASSUME cs:Cseg, ss:Sseg, ds:Dseg, es:Dseg

          ALIGN 2
          SegMyProg DW ?
PUBLIC AdrHMS,MemSizePriznak
AdrHMS              DD 110000h
MemSizePriznak      DB 0

Start:
          mov     [word cs:SegMyProg],es
          mov     ax,Dseg        ;Установка адреса сегмента данных
          mov     es,ax
          push    ax
          mov     cx,40
          mov     si,80h
          mov     di,offset DOSCommandStr
          cld
          rep     movsw
          pop     ds

          mov     ah,30h         ; Получить версию DOS
          int     21h
          cmp     al,5
          jb      short VerExit
          mov     ax,1A00h
          int     10h
          mov     dx,offset MyMes
          call    PutCSMesage
          cmp     al,1Ah
          jz      short VGAPresent

          mov     dx,offset NoVGA
PrintAndExit:
          push    dx
          mov     dx,offset MesError
          call    PutDOSStr
          pop     dx
ErrComLine:
          call    PutDOSStr
VerExit:
          mov     ax,4C00h
          int     21h
VGAPresent:

          mov     bx,AllocatedMemory
          push    es
          mov     es,[word cs:SegMyProg]
          mov     ah,4Ah
          int     21h
          pop     es
          mov     dx,offset NoMem
          jc      short PrintAndExit

          mov     ax,EndPrgSeg
          mov     [SPDDataSeg],ax  ;Сегмент для SPD данных
          add     ax,128           ;128*16=2048 - для SPD данных
          mov     [PCIDevRepSeg],ax
          add     ax,128           ;2KB для с PCI устройств
          mov     [ReportDataSeg],ax  ;Сегмент для для файла отчета
          add     ax,2048          ;2048*16=32KB - для файла отчета
          mov     [EndProgram],ax  ;Сегмент для работы
          mov     [TransferBufferH],ax

          call    DetectCPUclass
          mov     [Processor],al
          mov     dx,offset Mes286Proc
          cmp     al,2
          jz      short PrintAndExit
No286Processor:

          call    StopMotor

          call    CPUIDmethod
          call    GetMemorySize

          smsw    ax
          test    al,1
          mov     dx,offset NoReal
          je      short RealModeDetected
          mov     [ErrConfig],1
          call    PutDOSStr

          push    es
          mov     ax,1687h
          int     2Fh
          pop     es
          or      ax,ax
          mov     dx,offset EMMPresent
          pushf
          push    es
          push    dx
          mov     ax,0D201h
          mov     bx,'QE'
          mov     cx,'MM'
          mov     dx,'42'
          int     2Fh
          pop     dx
          pop     es
          cmp     bx,'OK'
          jnz     short TestMultiTask
          mov     dx,offset QEMMPresent
TestMultiTask:
          popf
          jne     short NoMultitask

          mov     [MultiTask],1
          mov     ax,1600h
          int     2Fh
          or      al,al
          jz      short NoWindows
          mov     [WinPres],1
          mov     dx,offset WindowsPresent
          jmp     short NoMultitask
NoWindows:
          mov     ax,3306h
          int     21h
          cmp     bx,3205h
          jne     short NotWinNT
          mov     [WinNTpres],1
          mov     [dword ds:ForWinNT],'$.TN'
          mov     dx,offset WindowsPresent
          jmp     short NoMultitask
NotWinNT:
          mov     dx,offset MultitaskPresent
NoMultitask:
          jmp     short PrnMultitaskMsg
RealModeDetected:

          mov     ax,[MemorySize]
          mov     bl,1

          cmp     ax,9
          jae     short GoToInitXMSAccess
          dec     bl
          cmp     ax,5
          mov     dx,offset NoXMS
          jb      short CannotFoundFreeXMSMem
GoToInitXMSAccess:
          mov     [byte cs:MemSizePriznak],bl

          call    InitXMSAccess
          mov     dx,offset MesA20
          jc      short NoGateA20enabl
          jmp     short AdvancedMemAccessOK
CannotFoundFreeXMSMem:
NoGateA20enabl:
          mov     [ErrConfig],1
PrnMultitaskMsg:
          call    PutDOSStr

AdvancedMemAccessOK:
ConfigError1:

          call    CheckMSCDEX
          jnz     short MSCDEXnotFound
          mov     ax,1500h
          xor     bx,bx
          int     2Fh
          mov     [TotalCD],bl
MSCDEXnotFound:

          mov     ax,4A10h
          xor     bx,bx
          mov     cx,0EBABh
          int     2Fh      ; Проверить наличие SMARTDRV
          cmp     ax,0BABEh
          jnz     short SMARTDRVNotFound
          mov     [DetSMARTdrv],1
          mov     dx,offset MesSmartdrv
          call    PutDOSStr
          mov     [ErrConfigNoDisab],1
SMARTDRVNotFound:
          mov     si,offset DOSCommandStr
          cld
          lodsb
          or      al,al
          jnz     short DOSCommandStrPresent
          jmp     DetectCDROMtestPresent
ErrorInComStr:
GetHelp:
          mov     [ErrConfigNoDisab2],1
          call    PutMesHelp
          jmp     VerExit

DOSCommandStrPresent:
          xor     ch,ch
          mov     cl,al
          cmp     cl,79
          jbe     short ComLineIsSmoll
          mov     cl,79
ComLineIsSmoll:
          push    cx
          push    si
NextCheckSimvolComLine:
          cmp     [byte ds:si],32
          jb      short CorrectComLine
          cmp     [byte ds:si],123
          jb      short SkipCorrect
CorrectComLine:
          mov     [byte ds:si],32
SkipCorrect:
          inc     si
          loop    NextCheckSimvolComLine
          mov     [byte ds:si],13

          pop     si
          pop     cx
          mov     [BufNoErr],1

;********* Обработка командной строки
NextDOSSimvol:
          lodsb
          cmp     al,13
          jz      EndPoiskNextDOSSimvol
          cmp     al,' '
          jbe     short DetectProb
          cmp     al,'/'
          jz      short DetectProb
          cmp     al,'?'
          jz      short GetHelp
          or      al,32
          cmp     al,'s'
          jz      DetectDisableMem
          cmp     al,'c'
          jz      short DetectCDtest
          cmp     al,'p'
          jz      DetectPcxCreate
          cmp     al,'r'
          jz      DetectRepCreate
          cmp     al,'t'
          jz      DetectMethod
          cmp     al,'b'
          jz      DetectSysBIOSCreate
          cmp     al,'h'
          jz      DetectHDDTest
          cmp     al,'l'
          jz      DetectLoopMemTest
          cmp     al,'d'
          jz      DetectDisableI13E
          cmp     al,'e'
          jz      DetectEnableI13E
          cmp     al,'w'
          jz      DetectEnableWriteTestHDD
          mov     [BufNoErr],0
          jmp     EndPoiskNextDOSSimvol
DetectProb:
          loop    short NextDOSSimvol
          jmp     EndPoiskNextDOSSimvol
DetectCDtest:
          mov     [BufNoErr],0
          lodsb
          dec     cx
          or      al,32
          cmp     al,'d'
          jz      short DetectCdtestSkipDetectClkCmos
          cmp     al,'l'
          jnz     EndPoiskNextDOSSimvol
          lodsd
          or      eax,20202020h
          cmp     eax,'somc'
          jnz     EndPoiskNextDOSSimvol
          mov     [ClearCMOS],1
          inc     [BufNoErr]
          jmp     EndPoiskNextDOSSimvol

DetectCdtestSkipDetectClkCmos:
          cmp     [HddTest],0
          jnz     EndPoiskNextDOSSimvol
          inc     [BufNoErr]
          inc     [CDROMTest]
          inc     [SkipDriveSelect]
HDD_CDROMDetectDrive:
          lodsb
          dec     cx
          cmp     al,'0'
          jb      short ErrDetectCDROM
          cmp     al,'7'
          ja      short ErrDetectCDROM
          sub     al,48
          mov     [DefaultDrive],al
          jmp     NextDOSSimvol
ErrDetectCDROM:
          dec     si
          inc     cx
          jmp     NextDOSSimvol
DetectPcxCreate:
          mov     [BufNoErr],0
          dec     si
          lodsd
          sub     cx,3
          or      eax,20202020h
          cmp     eax,':xcp'
          jnz     EndPoiskNextDOSSimvol
          mov     [FileName],si
          mov     [CreatePCX],1
          inc     [BufNoErr]
SkipFileName:
          lodsb
          cmp     al,' '
          jz      NextDOSSimvol
          cmp     al,0Dh
          jz      NextDOSSimvol
          jmp     short SkipFileName
DetectRepCreate:
          mov     [BufNoErr],0
          mov     [CreateQuickREP],1
          cmp     [byte ds:si],' '
          jz      short GetQuickRep
          cmp     [byte ds:si],0Dh
          jz      short GetQuickRep
          mov     [CreateQuickREP],0
          dec     si
          lodsd
          sub     cx,3
          or      eax,20202020h
          cmp     eax,':per'
          jnz     EndPoiskNextDOSSimvol
          mov     [FileNameREP],si
          mov     [CreateREP],1
GetQuickRep:
          inc     [BufNoErr]
          jmp     short SkipFileName
DetectEnableI13E:
          mov     [BufNoErr],0
          lodsd
          or      eax,20000020h
          cmp     eax,'e31i'
          jnz     short NoEnI13Extension
          mov     [Int13ExtSetByComLine],1
          inc     [BufNoErr]
          jmp     NextDOSSimvol
NoEnI13Extension:
          cmp     eax,'ddhr'
          jnz     EndPoiskNextDOSSimvol
          lodsb
          cmp     al,' '
          jnz     short SkipSpace
          lodsb
SkipSpace:
          cmp     al,'0'
          jb      EndPoiskNextDOSSimvol
          cmp     al,'7'
          ja      EndPoiskNextDOSSimvol
          sub     al,48
          mov     [DefaultDrive],al
          mov     [EraseHDD],1
          inc     [BufNoErr]
          jmp     EndPoiskNextDOSSimvol

DetectDisableI13E:
          mov     [BufNoErr],0
          lodsd
          or      eax,20202020h
          cmp     eax,'cedi'
          jz      short DetectDisableATAExternalContr
          cmp     eax,'e31i'
          jz      short DetectDI13E

          cmp     eax,'rdps'
          jnz     EndPoiskNextDOSSimvol
          mov     [DisableSPDread],1
          jmp     short NoComLineEror

DetectDisableATAExternalContr:
          mov     [DisATAExtern],1
          jmp     short NoComLineEror
DetectDI13E:
          mov     [Int13ExtResetByComLine],1
NoComLineEror:
          inc     [BufNoErr]
          jmp     NextDOSSimvol
DetectSysBIOSCreate:
          mov     [BufNoErr],0
          dec     si
          lodsd
          sub     cx,3
          or      eax,20202020h
          cmp     eax,'soib'
          jnz     EndPoiskNextDOSSimvol
          mov     [CreateBIOS],1
          inc     [BufNoErr]
          jmp     EndPoiskNextDOSSimvol

DetectMethod:
          mov     [BufNoErr],0
          lodsb
          dec     cx
          sub     al,49
          or      al,al
          jz      short MethodDetect
          cmp     al,1
          jz      short MethodDetect

          jmp     EndPoiskNextDOSSimvol
MethodDetect:
          inc     [BufNoErr]
          mov     [Method],al
          jmp     NextDOSSimvol
DetectHDDTest:
          mov     [BufNoErr],0
          lodsb
          dec     cx
          or      al,32
          cmp     al,'d'
          jnz     short EndPoiskNextDOSSimvol
          cmp     [CDROMTest],0
          jnz     short EndPoiskNextDOSSimvol
          inc     [BufNoErr]
          inc     [HddTest]
          inc     [SkipDriveSelect]
          jmp     HDD_CDROMDetectDrive
DetectEnableWriteTestHDD:
          mov     [BufNoErr],0
          lodsb
          dec     cx
          or      al,32
          cmp     al,'t'
          jnz     short EndPoiskNextDOSSimvol
          cmp     [HddTest],1
          jnz     short EndPoiskNextDOSSimvol
          inc     [BufNoErr]
          mov     [EnableWriteHDDInCL],1
          jmp     NextDOSSimvol

DetectDisableMem:
          mov     [BufNoErr],0
          lodsb
          dec     cx
          or      al,32
          cmp     al,'m'
          jnz     short NoMemDisableDOSSimvol
          inc     [BufNoErr]
          inc     [DisableMem]
          jmp     NextDOSSimvol

NoMemDisableDOSSimvol:
          cmp     al,'p'
          jnz     short EndPoiskNextDOSSimvol
          inc     [BufNoErr]
          inc     [DisablePnP]
          jmp     NextDOSSimvol
DetectLoopMemTest:
          inc     [BufNoErr]
          mov     [PriznMemLoop],1
          jmp     NextDOSSimvol

EndPoiskNextDOSSimvol:
          cmp     [BufNoErr],0
          jnz     short NoErrorInComStr
          mov     dx,offset MesNextStr
          call    PutDOSStr
          mov     dx,offset MesErrComLine
          jmp     short CDNotFound
NoErrorInComStr:
          cmp     [CDROMTest],1
          jz      short PresentCDtestCheck

          cmp     [HddTest],0
          jz      short ThisCDpresent
          mov     dl,[DefaultDrive]
          mov     ah,8
          or      dl,80h
          int     13h
          jnc     short ThisCDpresent
          mov     al,[DefaultDrive]
          mov     dx,offset MesHDDNotPresent
PrnMesCDnotFound:
          add     al,48
          mov     [NumHddNotPresent],al
CDNotFound:
          push    dx
          mov     dx,offset MesError
          call    PutDOSStr
          pop     dx
          call    PutDOSStr
          call    PutMesHelp
          jmp     VerExit

PresentCDtestCheck:

          call    CheckMSCDEX
          jz      short MSCDEXInst
          mov     dx,offset MsdexNotInst
          jmp     PrintAndExit
MSCDEXInst:
          mov     al,[DefaultDrive]
          cmp     al,[TotalCD]
          jb      short ThisCDpresent
          mov     dx,offset MesHDDNotPresent+2
          mov     [word ds:MesHDDNotPresent+2],'DC'
          jmp     PrnMesCDnotFound
ThisCDpresent:
          cmp     [ClearCMOS],1
          jnz     short NotClearCMOS
          mov     cx,7Fh
NextPutToClearCmos:

          mov     al,cl
          out     70h,al
          out     0EDh,al
          mov     al,0FFh
          out     71h,al
          loop     short NextPutToClearCmos
          mov     dx,offset MesClearCMOS
          call    PutDOSStr
          jmp     VerExit

NotClearCMOS:
          cmp     [CreateBIOS],1
          jnz     short NotCreateSysBIOSdump
          mov     dx,offset SysBiosFileName
          mov     ax,3C00h    ; Попробовать создать sysbios.rom
          xor     cx,cx
          int     21h
          jnc     short CreateFileForBIOSdumpOK
          mov     dx,offset MesErrorCreate
          jmp     PrintAndExit
CreateFileForBIOSdumpOK:
          push    ax
          push    ds
          push    es
          mov     ax,[EndProgram]
          mov     es,ax
          push    0F000h
          pop     ds
          mov     cx,0FFFFh
          sub     si,si
NextPutBiosDump:
          mov     al,[byte ds:si]
          mov     [byte es:si],al
          inc     si
          loop    short NextPutBiosDump
          pop     es
          pop     ds
          pop     bx

          push    ds
          mov     ax,[EndProgram]
          mov     ds,ax
          mov     ah,40h
          mov     cx,0FFFFh
          sub     dx,dx
          int     21h
          pop     ds
          jnc     short WriteFileForBIOSdumpOK
          mov     dx,offset MesErrorCreate
          jmp     PrintAndExit
WriteFileForBIOSdumpOK:
          mov     dx,offset MesCreateSysBIOSOK
          call    PutDOSStr
          jmp     VerExit

NotCreateSysBIOSdump:
          cmp     [EraseHDD],1
          jnz     short NoEraseHDD
          mov     dl,[DefaultDrive]
          add     dl,48
          mov     [ErasedDrive],dl
          mov     [ErasedDrive1],dl
          mov     [ErasedDrive2],dl
          mov     dx,offset MesWarningEraseHDD
          call    PutDOSStr
          call    GetCh
          or      al,20h
          cmp     al,'y'
          jnz     short EraseHddSkipped
          mov     cx,1
          mov     dh,0
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ax,0380h ;Write 128 sectors
          push    es
          push    ax
          mov     ax,[EndProgram]
          mov     es,ax
          push    cx
          push    ax
          sub     al,al
          mov     cx,0FFFFh
          sub     di,di
          cld
          rep stosb
          pop     ax
          pop     cx
          xor     bx,bx
          pop     ax
          int     13h
          pop     es

          mov     dx,offset MesErasePassed
          jnc     short EraseHDDPassed
EraseHddSkipped:
          mov     dx,offset MesEraseFailed
EraseHDDPassed:
          call    PutDOSStr
          jmp     VerExit

NoEraseHDD:

          cmp     [EnableWriteHDDInCL],1
          jnz     short WriteNotEnableFromComLine
          mov     dl,[DefaultDrive]
          add     dl,48
          mov     [ErasedDrive],dl
          mov     dx,offset MesWarningEraseHDD
          call    PutDOSStr
          call    GetCh
          or      al,20h
          cmp     al,'y'
          mov     [EnableWriteHDD],1
          jz      short WriteEnablingConfirm
          mov     [EnableWriteHDD],0
          jmp     VerExit
WriteEnablingConfirm:
          mov     dx,offset MesWarningEraseC
          cmp     [DefaultDrive],0
          jnz     short WriteNotDiskC
          call    PutDOSStr
          call    GetCh
          or      al,20h
          cmp     al,'n'
          jz      short WriteDiskCConfirm
          mov     [EnableWriteHDD],0
          jmp     VerExit

WriteDiskCConfirm:
WriteNotDiskC:
WriteNotEnableFromComLine:

          cmp     [CreatePCX],1          ; Надо создавать PCX файл ?
          jnz     short DetectCreateRepFile
          mov     si,[FileName]
NextSimvol:
          lodsb
          cmp     al,0Dh
          jz      short EndNextSimvolFile
          cmp     al,' '
          jz      short EndNextSimvolFile
          cmp     al,"."
          jz      short EndNextSimvolFile
          jmp     short NextSimvol
EndNextSimvolFile:
          dec     si
          mov     di,si
          mov     eax,'xcp.'
          stosd
          xor     al,al
          stosb
          mov     dx,[FileName]
          mov     ax,3C00h          ; Попробовать создать PCX файл
          xor     cx,cx
          int     21h
          mov     [FileHandle],ax
          jnc     short DetectCreateRepFile
          mov     dx,offset MesErrorCreate
          jmp     PrintAndExit

DetectCreateRepFile:
          cmp     [CreateREP],1
          jnz     short DetectCDROMtestPresent
          mov     si,[FileNameREP]
NextSimvolForRep:
          lodsb
          cmp     al,0Dh
          jz      short EndNextSimvolFileForRep
          cmp     al,' '
          jz      short EndNextSimvolFileForRep
          cmp     al,"."
          jz      short EndNextSimvolFileForRep
          jmp     short NextSimvolForRep
EndNextSimvolFileForRep:
          dec     si
          mov     di,si
          mov     eax,'txt.'
          stosd
          xor     al,al
          stosb
          mov     dx,[FileNameREP]
          mov     ax,3C00h          ; Попробовать создать report файл
          xor     cx,cx
          int     21h
          mov     [FileHandleREP],ax
          jnc     short DetectCDROMtestPresent
          mov     dx,offset MesErrorCreateREP
          jmp     PrintAndExit

DetectCDROMtestPresent:
          cmp     [ErrConfigNoDisab],1
          jz      short ConfigError
          cmp     [ErrConfig],1
          jz      short ConfigError
          cmp     [ErrConfigNoDisab2],1
          jz      short ConfigError10
          jmp     short NoConfigError
ConfigError:
          mov     dx,offset MesErrConfig
          call    PutDOSStr
ConfigError10:
          mov     dx,offset MesPressAnyKeyEng
          call    PutDOSStr
          mov     [PressAnyKeyEngNeeded],1
NoConfigError:

          call    SetNewInterrupt

          cmp     [WinNTPres],1
          jz      short CanNotDetectPCIBusFromWinNT
          call    DetectPCIBus
          cmp     [PCIBusIsPresent],0
          jz      short PciBiosNotInstalledForIDEDriveName

          mov     [PCICounter],1
          call    GetPCIInfo

          cmp     [DisATAExtern],1
          jz      short PciBiosNotInstalledForIDEDriveName

          call    GetIDEBaseIOPort

PciBiosNotInstalledForIDEDriveName:
CanNotDetectPCIBusFromWinNT:

          call    GetNumFromWin32

          cmp     [WinNTpres],0
          jz      short WinNTnotDetectForMemSize
          mov     eax,[dwTotalPhys]
          or      eax,eax
          jz      short WinNTnotDetectForMemSize
          shr     eax,20
          inc     ax
          mov     [MemorySize],ax
          dec     ax
          movzx   eax,ax
          shl     eax,18

          mov     [XMSmemLength],eax
WinNTnotDetectForMemSize:

          mov     ah,0Fh
          int     10h
          mov     [video],al ;Запомнить текущий видео режим

          call    VideoSpeedTest

          sub     ax,ax
          mov     al,[video]
          int     10h
          mov     ax,0012h   ;640*480*16
          int     10h

          xor     ax,ax      ;Рамка на полный экран
          mov     bx,ax
          mov     cx,639
          mov     dx,479
          mov     bp,3+8
          call    colorframe

          mov     si,offset MesVer
          call    ColorStr6x8
          mov     si,offset MesInit
          call    ColorStr6x8

          mov     si,offset MesDetCpuSpeed
          call    ColorStr6x8

          xor     ebx,ebx
          mov     cx,10
NewCallCPUSpeed:
          call    CpuSpeed
          add     ebx,eax
          loop    short NewCallCPUSpeed
          mov     [Mhz],ebx

          call    MemTimingTest

          smsw    ax
          shr     al,1
          jc      short V86ModePresents
          cmp     [FeatureFlagTSC],1
          jnz     TSCNotSuported
          jmp     short GetCPUClockViaTSCorMSR

V86ModePresents:
          cmp     [WinPres],1
          jz      ConfigErrorWinPresent
          cmp     [WinNTPres],1
          jz      ConfigErrorWinPresent
          cmp     [FeatureFlagTSC],1
          jnz     TSCNotSuported
          cmp     [FeatureFlagMSR],1
          jnz     TSCNotSuported
          mov     [DetectViaMSR],1
GetCPUClockViaTSCorMSR:

          mov     si,offset MesDetCPUTSCSpeed
          call    ColorStr6x8

          sub     al,al
          mov     [byte cs:LongTimerL],al
          ALIGN 2
LongTimerNoChenge:
          cmp     al,[byte cs:LongTimerL]
          jz      short LongTimerNoChenge

          call    GetTSCdata
          push    eax

          mov     al,5
          ALIGN 2
LongTimerNoChenge1:
          cmp     al,[byte cs:LongTimerL]
          jnz     short LongTimerNoChenge1

          call    GetTSCdata

          pop     ebx
          sub     eax,ebx
          xor     edx,edx
          mov     ebx,2197
          div     ebx

          mov     [MHzTSCFull],eax
          sub     edx,edx
          mov     ebx,100
          div     ebx
          cmp     dx,50
          jb      short NoBig50
          inc     ax
NoBig50:
          mov     [MHzTSC],ax

          cmp     [FeatureFlagMSR],1
          jnz     RDMSRNotSupported
          cmp     [FeatureFlagTSC],1
          jnz     TSCNotSuported
          mov     si,offset MesDetMSR
          call    ColorStr6x8
          cmp     [IntelProcessor],1
          jnz     NotIntelProcesorForRDMSR
          cmp     [CPUfamily],6
          jnz     short NotIntelP6ProcesorForRDMSR
          cmp     [CPUmodel],3
          jb      short NotIntelP6ProcesorForRDMSR
          jz      short CanNotDetectPlatformID
          cmp     [CPUmodel],0Bh
          ja      short NotIntelP6ProcesorForRDMSR
          mov     ecx,17h
          DB      0Fh,32h ;rdmsr
          or      edx,80000000h
          mov     [MSR00000017edx],edx
CanNotDetectPlatformID:
          mov     ecx,2Ah
          DB      0Fh,32h ;rdmsr
          or      eax,80000000h
          mov     [MSR0000002A],eax
          call    GetIntelClockRatio
          mov     ecx,11Eh
          DB      0Fh,32h ;rdmsr
          or      eax,80000000h
          mov     [MSR0000011E],eax
          call    GetMicrocodeRev
          jmp     short NotIntelProcesorForRDMSR
NotIntelP6ProcesorForRDMSR:
          cmp     [CPUfamily],0Fh
          jnz     short NotIntelP4ProcesorForRDMSR
          cmp     [IntelExtendedFamily],0
          jnz     short NotIntelP4ProcesorForRDMSR
          cmp     [CPUModel],2
          ja      short NotIntelP4ProcesorForRDMSR

          mov     ecx,2Ah
          DB      0Fh,32h ;rdmsr
          or      eax,80000000h
          mov     [MSR0000002A],eax
          mov     ecx,2Ch
          DB      0Fh,32h ;rdmsr
          or      eax,80000000h
          mov     [MSR0000002C],eax

          mov     eax,[MSR0000002A]
          cmp     [CPUModel],2
          jnz     NoNortwoodCPU
          mov     eax,[MSR0000002C]
NoNortwoodCPU:
          call    GetIntelClockRatio

          call    GetMicrocodeRev
          mov     ecx,17h
          DB      0Fh,32h ;rdmsr
          or      edx,80000000h
          mov     [MSR00000017edx],edx
          jmp     short NotIntelProcesorForRDMSR
NotIntelP4ProcesorForRDMSR:

NotIntelProcesorForRDMSR:
          cmp     [AMDProcessor],1
          jnz     short NotAMDProcesorForRDMSR
          cmp     [CPUfamily],5
          jnz     short GoToDetectAMDAthlonMSRs
          cmp     [CPUmodel],8
          jz      short GoToGetAMDMSRsModel8
          jb      RDMSRNotSupported
          jmp     short GoToGetAMDMSRs
GoToGetAMDMSRsModel8:
          cmp     [CPUstepping],8
          jb      RDMSRNotSupported
GoToGetAMDMSRs:
          mov     ecx,0C0000082h
          DB      0Fh,32h ;rdmsr
          or      eax,80000000h
          mov     [MSRC0000082],eax
          mov     ecx,0C0000087h
          DB      0Fh,32h ;rdmsr
          mov     [MSRC0000087],eax
          call    GetK6ClockRatio
GoToDetectAMDAthlonMSRs:

          cmp     [CPUfamily],6
          jnz     short NotAMDProcesorForRDMSR
          cmp     [CPUmodel],10
          ja      short RDMSRNotSupported
          mov     ecx,0C0010015h
          DB      0Fh,32h ;rdmsr
          mov     [MSRC0010015],eax
          call    GetK7ClockRatio

NotAMDProcesorForRDMSR:

          cmp     [CyrixProcessor],1
          jnz     short NotCyrixProcesorForRDMSR
          cmp     [CPUfamily],6
          jnz     short NotCyrixProcesorForRDMSR
          cmp     [CPUmodel],5
          ja      short NotCyrixProcesorForRDMSR
          mov     ecx,2Ah
          DB      0Fh,32h ;rdmsr
          or      eax,80000000h
          mov     [MSR0000002A],eax
          call    GetCyrixIIIClockRatio
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
          DB      0Fh,32h ;rdmsr
          or      eax,80000000h
          mov     [MSR0000002A],eax
          call    GetSamuelClockRatio
NotIDTProcesorForRDMSR:

TSCNotSuported:
RDMSRNotSupported:
ConfigErrorWinPresent:

          cmp     [WinPres],1
          jnz     NotWindowsPresentsForGetMultiplierFromWin32mod
          cmp     [SSTLabel],'_TSS'
          jnz     short NotWindowsPresentsForGetMultiplierFromWin32mod
          mov     eax,[Win32MSRC0000087]
          test    eax,80000000h
          jz      short NotK6ClockMultiplier
          call    GetK6ClockRatio
          jmp     short NotK7ClockMultiplier
NotK6ClockMultiplier:
          mov     eax,[Win32MSRC0010015]
          test    eax,80000000h
          jz      short NotK7ClockMultiplier
          call    GetK7ClockRatio
NotK7ClockMultiplier:

          cmp     [IntelProcessor],1
          jnz     short NotIntelClockMultiplier

          mov     eax,[Win32MSR0000002A]

          cmp     [CPUfamily],0Fh
          jnz     short NotIntelNortwoodForClockMultiplier
          cmp     [IntelExtendedFamily],0
          jnz     short NotIntelNortwoodForClockMultiplier
          cmp     [CPUModel],2
          jnz     short NotIntelNortwoodForClockMultiplier

          mov     eax,[Win32MSR0000002C]

NotIntelNortwoodForClockMultiplier:

          test    eax,80000000h
          jz      short NotIntelClockMultiplier
          call    GetIntelClockRatio
NotIntelClockMultiplier:

          cmp     [CyrixProcessor],1
          jnz     short NotCyrixClockMultiplier
          mov     eax,[Win32MSR0000002A]
          test    eax,80000000h
          jz      short NotCyrixClockMultiplier
          call    GetCyrixIIIClockRatio
NotCyrixClockMultiplier:
          cmp     [IDTProcessor],1
          jnz     short NotIDTClockMultiplier
          mov     eax,[Win32MSR0000002A]
          test    eax,80000000h
          jz      short NotIDTClockMultiplier
          call    GetSamuelClockRatio
NotIDTClockMultiplier:

Win32MultiplierDetected:

NotWindowsPresentsForGetMultiplierFromWin32mod:

          call    GetOriginalIntelClock

          cmp     [DisablePnP],1
          jz      NotSuportPnPBiosForBusFrec

          mov     si,offset MesDetPnPBIOS
          call    ColorStr6x8

          call    GetPnPBios     ;Check BIOS PnP support

          cmp     [PnPBiosSupport],1
          jnz     NotSuportPnPBiosForBusFrec

          push    es
          mov     ax,0F000h
          mov     es,ax
          sub     si,si
          mov     cx,16384
DetectASUSMainBoard:
          mov     eax,[dword es:si]
          or      eax,20202020h
          cmp     eax,'susa'
          jz      short FainASUSmainboard
          inc     si
          loop    short DetectASUSMainBoard
          jmp     NotAsusMainboard
FainASUSmainboard:
          sub     si,si
          mov     cx,16384
DetectASUSMainBoardName:
          mov     eax,[dword es:si]
          cmp     eax,'X4V3'
          jz      FainASUSP3V4Xmainboard
          cmp     eax,'X4VU'
          jz      FainASUSCUV4Xmainboard
          cmp     eax,'LPUC'
          jz      FainASUSCUPLmainboard
          cmp     eax,'XBUC'
          jz      FainASUSP3Bmainboard
          cmp     eax,'2LSU'
          jz      FainASUSCUSL2mainboard
          cmp     eax,'2CUC'
          jz      FainASUSCUC2orCUC2000mainboard
          cmp     eax,'2VUC'
          jz      FainASUSCUV2mainboard
          cmp     eax,'2PEU'
          jz      FainASUSUEP2mainboard
          cmp     eax,'ISUC'
          jz      FainASUSCUSImainboard
          cmp     eax,'GEUT'
          jz      FainASUSTUEGmainboard
          and     eax,0FFFFFFh
          cmp     eax,'B3P'
          jz      FainASUSP3Bmainboard
          cmp     eax,'WEM'
          jz      short FainASUSMEWmainboard
          cmp     eax,'WUC'
          jz      short FainASUSCUWmainboard
          cmp     eax,'V7K'
          jz      short FainASUSK7VBmainboard
          cmp     eax,'A7A'
          jz      short FainASUSA7Amainboard
          cmp     eax,'V7A'
          jz      short FainASUSA7Vmainboard
          cmp     eax,'S7A'
          jz      short FainASUSA7Smainboard
          cmp     eax,'P7A'
          jz      short FainASUSP7Vmainboard
          cmp     eax,'M7A'
          jz      short FainASUSA7Mmainboard
          cmp     eax,'RUC'
          jz      short FainASUSCURmainboard
          cmp     eax,'C3P'
          jz      short FainASUSP3Cmainboard
          cmp     eax,'B4P'
          jz      short FainASUSP4Bmainboard
          inc     si
          loop    DetectASUSMainBoardName
          jmp     short NotAsusMainboard
FainASUSP4Bmainboard:
          mov     [MainBoardForSpd],8
          jmp     short ASUSMainboardDetect
FainASUSA7Amainboard:
          mov     [MainBoardForSpd],7
          jmp     short ASUSMainboardDetect
FainASUSCURmainboard:
          mov     [MainBoardForSpd],6
          jmp     short ASUSMainboardDetect
FainASUSA7Smainboard:
FainASUSUEP2mainboard:
FainASUSTUEGmainboard:
FainASUSP3Cmainboard:
FainASUSMEWmainboard:
FainASUSCUC2orCUC2000mainboard:
FainASUSCUSL2mainboard:
FainASUSCUWmainboard:
FainASUSCUV2mainboard:
FainASUSCUSImainboard:
          mov     [MainBoardForSpd],5
          jmp     short ASUSMainboardDetect
FainASUSP3V4Xmainboard:
          mov     [MainBoardForSpd],1
          jmp     short ASUSMainboardDetect
FainASUSP3Bmainboard:
          mov     [MainBoardForSpd],3
          jmp     short ASUSMainboardDetect
FainASUSCUV4Xmainboard:
FainASUSCUPLmainboard:
          mov     [MainBoardForSpd],4
          jmp     short ASUSMainboardDetect
FainASUSP7Vmainboard:
FainASUSA7Mmainboard:
FainASUSA7Vmainboard:
FainASUSK7VBmainboard:
          mov     [MainBoardForSpd],2
ASUSMainboardDetect:
NotAsusMainboard:
          pop     es

          call    GetISAPnPInfoFromPnPBIOS

          sub     cx,cx
NextCheckBiosStructures:
          mov     [Structure],cx
          mov     ax,[EndProgram]
          mov     gs,ax
          call    GetPnPBiosStructure
          jc      short CPUStructureNotSupport
          cmp     [byte gs:0],4    ;CPU structure
          jnz     short CPUStructureNotSupport
          mov     ax,[word gs:12h]
          call    CorrectDMIFSB
          mov     [PnPBusSpeed],ax
          jmp     short ExitForCPUStructureDetection
CPUStructureNotSupport:
          inc     cx
          cmp     cx,[NumStructures]
          jnz     short NextCheckBiosStructures
ExitForCPUStructureDetection:

NotSuportPnPBiosForBusFrec:

          cmp     [WinNTpres],1
          jz      short CanNotDetMemTypeWinNT
          mov     si,offset MesDetMemType
          call    ColorStr6x8
          call    GetSPDMemType

          mov     [CacheBenchLabel],1
          cmp     [NumberDIMMModules],0
          jz      short NotSPDDIMMmodulesPresentForCacheBench
          dec     [CacheBenchLabel]
NotSPDDIMMmodulesPresentForCacheBench:

CanNotDetMemTypeWinNT:
          cmp     [MultiTask],1
          jz      short CanNotDetectInMultitask
          call    DetectIDEDriveName  ;Определение имен ATA/ATAPI
CanNotDetectInMultitask:

          mov     si,offset MesDetBIOSVendor
          call    ColorStr6x8

          push    ds
          mov     ax,0F000h
          mov     ds,ax
          mov     si,0FFF5h
          mov     di,offset NumBiosDate
          mov     cx,4
          cld
          rep movsw
          mov     [byte es:di+2-8],'/'
          mov     [byte es:di+5-8],'/'
          sub     si,si
          mov     cx,65520
NextByteTestForAwardModularBIOS:
          cmp     [dword ds:si],'rawA'   ;Award Modular BIOS
          jnz     short NotAwardModularBIOS
          cmp     [dword ds:si+11],'B ra'
          jnz     short NotAwardModularBIOS
          cmp     [dword ds:si+16],'v SO'
          jnz     short NotAwardModularBIOS
          mov     cx,26
          mov     di,offset NumBios
          rep movsb
          sub     al,al
          stosb
          pop     ds
          jmp     short DetectedAwardModularBios
NotAwardModularBIOS:
          inc     si
          loop    short NextByteTestForAwardModularBIOS
          pop     ds

          push    es      ;Определение производителя BIOS
          mov     ax,0F000h
          mov     es,ax
          mov     ebp,20202020h
          mov     si,offset BiosVendors
OtherBIOSVendor:
          mov     cx,65520
          sub     di,di
NextByteBIOSVendor:
          mov     eax,[dword ds:si]
          or      eax,ebp
          mov     ebx,[dword es:di]
          or      ebx,ebp
          cmp     ebx,eax
          jnz     short String1NotFound
          mov     eax,[dword ds:si+4]
          or      eax,ebp
          mov     ebx,[dword es:di+4]
          or      ebx,ebp
          cmp     ebx,eax
          jnz     short String1NotFound
          mov     eax,[dword ds:si+8]
          or      eax,ebp
          mov     ebx,[dword es:di+8]
          or      ebx,ebp
          cmp     ebx,eax
          jnz     short String1NotFound
          jmp     short BIOSVendorFound
String1NotFound:
          inc     di
          loop    short NextByteBIOSVendor
NextBiosVendorSelect:
          lodsb
          cmp     al,1
          jz      short BIOSVendorEndString
          or      al,al
          jz      short OtherBIOSVendor
          jmp     short NextBiosVendorSelect
BIOSVendorEndString:
          pop     es
          jmp     short BIOSVendorUnknownOrNotFound
BIOSVendorFound:
          pop     es
          mov     cx,30
          mov     di,offset NumBios
          rep movsb
DetectedAwardModularBios:
          mov     [BIOSVendorDetectOK],1
BIOSVendorUnknownOrNotFound:

          mov     si,offset MesDetBug2000
          call    ColorStr6x8
          call    TestBug2000
          jnc     short Bug2000testOK
          mov     [Bug2000testErr],1
Bug2000testOK:

          cmp     [WinNTpres],1
          jz      short CanNotGetISAPnPinWinNT
          cmp     [DisablePnP],1
          jz      short CanNotGetISAPnPinWinNT
          mov     si,offset MesDetISAPnP
          call    ColorStr6x8
          call    DetectISAPnP
CanNotGetISAPnPinWinNT:

          mov     ax,8   ;Удаление надписи "Определение параметров системы"
          mov     bx,ax
          mov     cx,399
          mov     dx,16
          xor     bp,bp
          call    rectangle

          call    PrintProcessor
          call    DetectMHZ
          call    PrintCPUparam

          mov     ax,[CacheL1]
          or      ax,ax
          jz      short CPUCachesNotFound
          mov     si,offset MesCPUCaches
          call    ColorStr6x8
          mov     [NumCacheNumber],'1'
          mov     si,offset MesCache
          call    ColorStr6x8
          call    PrnKBorMB

          mov     ax,[CacheL2]
          or      ax,ax
          jz      short CPUCachesEnd
          mov     si,offset MesZpt
          call    ColorStr6x8
          mov     eax,[MSR0000011E]
          or      eax,eax
          jnz     short FainInfoMSR11E
          mov     eax,[Win32MSR0000011E]
          or      eax,eax
          jz      short L2CacheLatencyNotDetect

FainInfoMSR11E:
          shr     ax,1
          and     ax,1111b
          mov     cx,1
          mov     di,offset NumL2Latency
          call    BinToAscHex
          mov     si,offset MesL2Latency
          call    ColorStr6x8
          jmp     short L2SizeAndLatencyPrnOK
L2CacheLatencyNotDetect:
          mov     [NumCacheNumber],'2'
          mov     si,offset MesCache
          call    ColorStr6x8
L2SizeAndLatencyPrnOK:
          mov     ax,[CacheL2]
          call    PrnKBorMB

          mov     ax,[CacheL3]
          or      ax,ax
          jz      short CPUCachesEnd
          mov     si,offset MesZpt
          call    ColorStr6x8
          mov     [NumCacheNumber],'3'
          mov     si,offset MesCache
          call    ColorStr6x8
          call    PrnKBorMB

CPUCachesEnd:
          inc     [ForBaseLine]
          inc     [ForBaseFrame]
CPUCachesNotFound:

          cmp     [MhzTSC],0
          jz      NoTestedRDTSC
          inc     [ForBaseLine]
          inc     [ForBaseFrame]
          mov     si,offset MesMhzViaRDTSC
          call    colorstr6x8

          mov     eax,[MHzTSCFull]
          mov     cx,4
          mov     di,offset NumMhzViaRDTSC
          call    BinToAscDec2

          mov     si,offset NumMhzViaRDTSC
          call    NonZeroPrn
          call    colorstr6x8

          call    MMX_AMD3Ddetection

          call    DetectPentiumClockRatio

          movzx   ebx,[ClockRatio]
          or      bx,bx
          jz      ClockRatioNotDetect
          shr     bx,1
          mov     eax,[MHzTSCFull]
          mov     ecx,1000
          mul     ecx
          sub     edx,edx
          div     ebx
          sub     edx,edx
          mov     ecx,10
          div     ecx
          cmp     dx,5
          jb      short NoBig06
          inc     eax
NoBig06:
          mov     cx,4
          mov     di,offset MesDDRClock
          call    BinToAscDec2

          movzx   ebx,[ClockRatio]
          or      bx,bx
          jz      ClockRatioNotDetect
          shr     bx,2
          mov     eax,[MHzTSCFull]
          mov     ecx,1000
          mul     ecx
          sub     edx,edx
          div     ebx
          sub     edx,edx
          mov     ecx,10
          div     ecx
          cmp     dx,5
          jb      short NoBig07
          inc     eax
NoBig07:
          mov     cx,4
          mov     di,offset MesQDRClock
          call    BinToAscDec2

          movzx   ebx,[ClockRatio]
          push    ebx
          mov     eax,[MHzTSCFull]
          mov     ecx,1000
          mul     ecx
          sub     edx,edx
          div     ebx
          sub     edx,edx
          mov     ecx,10
          div     ecx
          cmp     dx,5
          jb      short NoBig05
          inc     eax
NoBig05:
          mov     cx,4
          mov     di,offset MesExtClock
          call    BinToAscDec2
          pop     eax
          mov     cx,2
          mov     di,offset NumRatio
          call    BinToAscDec2
          cmp     [byte ds:di+4],'0'
          jnz     short NotZeroInNumRatio
          mov     [byte ds:di+4],0
NotZeroInNumRatio:
          mov     si,offset MesClockFrequency
          call    ColorStr6x8

          cmp     [IntelProcessor],1
          jnz     short NotP4CPUForPrnExternalFrec
          cmp     [CPUFamily],0Fh
          jnz     short NotP4CPUForPrnExternalFrec
          cmp     [IntelExtendedFamily],0
          jnz     short NotP4CPUForPrnExternalFrec
          mov     si,offset MesQDRClock
          jmp     short PrnQDRClock

          cmp     [AMDProcessor],1
          jnz     short NotAMDCPUForPrnExternalFrec
          cmp     [word ds:CPUmodel],256*6+4
          ja      short NotAMDCPUForPrnExternalFrec
          cmp     [word ds:CPUmodel],256*6
          jb      short NotAMDCPUForPrnExternalFrec
          mov     si,offset MesDDRClock
PrnQDRClock:
          call    NonZeroPrn
          call    ColorStr6x8
          mov     si,offset MesExtClock
          call    NonZeroPrn
          call    ColorStr6x8
          mov     si,offset NumRatio
          call    NonZeroPrn
          call    ColorStr6x8

          mov     si,offset MesATAscobka
          call    ColorStr6x8
          jmp    short GetClockRatioOK

NotP4CPUForPrnExternalFrec:
NotAMDCPUForPrnExternalFrec:
          mov     si,offset MesExtClock
          call    NonZeroPrn
          call    ColorStr6x8
          mov     si,offset NumRatio
          call    NonZeroPrn
          call    ColorStr6x8
          jmp    short GetClockRatioOK

ClockRatioNotDetect:
NoTestedRDTSC:

          mov     ax,[PnPBusSpeed]
          or      ax,ax
          jz      short PnPBusSpeedNotSupport
          mov     cx,4
          mov     di,offset NumBusClock
          call    BinToAscDec
          call    NZInMes
          mov     si,offset MesClockFrequency
          call    ColorStr6x8
          mov     si,offset NumBusClock
          call    NonZeroPrn
          call    ColorStr6x8
          call    MMX_AMD3Ddetection
GetClockRatioOK:
          inc     [ForBaseLine]
          inc     [ForBaseFrame]

MMXAMD3DPrinting:
PnPBusSpeedNotSupport:

          movzx   eax,[MemorySize]
          mov     di,offset TotalMem
          mov     cx,4
          call    BinToAscDecH
          call    NZInMes

          mov     si,offset StrTotalMem
          call    colorstr6x8

          mov     eax,[SPDAllMemType]
          or      eax,eax
          jz      short SPDMemModuleNotFound

          mov     si,offset MesMemoryType
          call    ColorStr6x8
          mov     bx,offset NumAdrSPDMemBuf
          mov     cx,32

NextBitSPDMemTypeToTest:
          shr     eax,1
          jnc     short SPDMemTypeBitNotSet
          mov     si,[word ds:bx]
          call    ColorStr6x8
SPDMemTypeBitNotSet:
          add     bx,2
          loop    short NextBitSPDMemTypeToTest
          jmp     GoToGetMemSpeedIndex

SPDMemModuleNotFound:

          cmp     [PnPBiosSupport],1
          jnz     NotPnPBios

          sub     cx,cx
GetNextPnPBiosStructureForMemMod:
          mov     [Structure],cx
          mov     ax,[EndProgram]
          mov     gs,ax
          call    GetPnPBiosStructure
          jc      short MemStructureNotDetect
          cmp     [byte gs:0],6 ;Memory structure
          jnz     short MemStructureNotDetect
          mov     al,[byte gs:0Ah]
          and     al,01111111b
          cmp     al,7Fh
          jz      short MemModuleNotInstalled
          mov     ax,[word gs:07h]
          cmp     ax,1
          jnz     short FoundMemModule
MemStructureNotDetect:
MemModuleNotInstalled:
          inc     cx
          cmp     cx,[NumStructures]
          jnz     short GetNextPnPBiosStructureForMemMod
          jmp     short NotFoundMemDMIInfo
FoundMemModule:

          test    al,0111b
          jnz     short NotFoundMemDMIInfo

          mov     si,offset MesMemoryType
          call    ColorStr6x8

          test    ax,100000000b   ;DIMM
          jnz     short DIMMpresents
          test    ax,10000000000b ;SDRAM
          jz      short NotDIMMpresents
DIMMpresents:
          mov     [DIMMmodules],1
NotDIMMpresents:

          mov     cx,11
          mov     bx,offset NumAdrMemBuf
NextBitMemTypeToTest:
          shr     ax,1
          jnc     short MemTypeBitNotSet
          mov     si,[word ds:bx]
          call    ColorStr6x8
MemTypeBitNotSet:
          add     bx,2
          loop    short NextBitMemTypeToTest

          mov     ax,[EndProgram]
          mov     gs,ax
          mov     al,[byte gs:06h]
          or      al,al
          jz      short NotSpeedFound
          cmp     al,0FFh
          jz      short NotSpeedFound

          cmp     [DIMMmodules],1
          jnz     short NotDIMMmodules
          cmp     al,17
          ja      short NotSpeedFound
NotDIMMmodules:
          cmp     al,7
          jb      short NotSpeedFound

          mov     di,offset MesMemDMISpeed
          mov     cx,3
          sub     ah,ah
          cmp     al,9
          ja      short Not9nsOrFastes
          dec     cx
          inc     di
Not9nsOrFastes:
          call    BinToAscDec
          call    NZInMes
          call    ColorStr6x8
NotSpeedFound:
NotFoundMemDMIInfo:
NotPnPBios:

GoToGetMemSpeedIndex:

          mov     eax,[MSpeedIdx]
          or      eax,eax
          jnz     short MemBandDetected

          mov     eax,[MemBand]
          or      eax,eax
          jz      short ConfigErrorForMemSpeed
          mov     [MSpeedIdx],eax
          jmp     short Win32MemBandDetected
MemBandDetected:
          call    CalcResMem
Win32MemBandDetected:
          mov     di,offset NumMemSpeed
          mov     cx,5
          call    BinToAscDec2
          mov     si,offset MemSpeedIndex
          call    ColorStr6x8
          mov     si,offset NumMemSpeed
          call    ColorStr6x8
          inc     [ForBaseFrame]
ConfigErrorForMemSpeed:

          mov     si,offset PerevodStroki
          call    ColorStr6x8

          call    PCIDisplayAdapter

          push    es
          mov     ax,[EndProgram]
          mov     es,ax
          mov     ax,4F00h
          xor     di,di
          mov     [dword es:di],'2EBV'
          int     10h
          pop     es
          cmp     ax,004Fh
          jnz     short NotVesaSupport

          push    ds
          mov     ax,[EndProgram]
          mov     ds,ax
          xor     di,di
          mov     ax,[word ds:di+18]
          test    ah,11100000b
          jnz     short VESAVideoMemSizeError
          mov     [word es:VideoMEM],ax
VESAVideoMemSizeError:
          mov     si,[word ds:di+6]
          mov     ax,[word ds:di+8]
          mov     ds,ax
          mov     di,offset VESAOEMString
          mov     cx,16
          cld
          rep movsw
          pop     ds

          mov     si,offset VESAOEMString
NextSimvolVESAOEM:
          lodsb
          or      al,al
          jz      short GoToPrnVESAOEM
          cmp     al,31
          ja      short NextSimvolVESAOEM
          mov     [byte ds:si-1],32
          jmp     short NextSimvolVESAOEM

GoToPrnVESAOEM:
          cmp     [PCIVideoDetected],1
          jz      short PCIVideoWasPrint
          mov     si,offset MesVideo
          call    ColorStr6x8
          inc     [ForBaseFrame]
PCIVideoWasPrint:

NotVesaSupport:
          movzx   eax,[VideoMEM]
          shl     eax,6
          mov     cx,6
          mov     di,offset TotalVESAMem
          call    BinToAscDecH

          mov     ax,[NvidiaMem]
          or      ax,ax
          jz      short NotNvidiaCardForVideoMem
          mov     cx,3
          mov     di,offset TotalVideoMem
          call    BinToAscDec

          mov     si,offset MesVideoMem
          call    colorstr6x8
          mov     si,offset TotalVideoMem
          jmp     short PrnNvidiaVideoMem
NotNvidiaCardForVideoMem:

          mov     si,offset MesVESAMem
          call    colorstr6x8
          mov     si,offset TotalVESAMem
          mov     ax,[VideoMEM]
          or      ax,ax
          jnz     short VESAMemPresent
          mov     si,offset CPUIDunknown
PrnNvidiaVideoMem:
VESAMemPresent:
          call    NonZeroPrn
          call    colorstr6x8

          mov     ecx,[VGASpeed]
          jecxz   short SkipVideoMemSpeedPrn
          mov     si,offset MesVideoMemSpeed
          call    colorstr6x8
          xor     edx,edx
          mov     eax,195700674
          div     ecx

          mov     di,offset NumVideoSpeedVGA
          mov     cx,7
          call    BinToAscDecH
          mov     si,offset NumVideoSpeedVGA
          call    NonZeroPrn
          call    colorstr6x8

SkipVideoMemSpeedPrn:
          mov     si,offset PerevodStroki
          call    colorstr6x8

;****** Определение количества и размеров HDD
          mov     [TotalAllDrive],0
          mov     ah,8
          mov     dl,80h
          int     13h
          cmp     [WinNTpres],1
          jnz     short WinNTNotPresentsForGetFixedDrive
          cmp     [NumFixedDisk],0
          jz      short WinNTNotPresentsForGetFixedDrive
          mov     dl,[byte ds:NumFixedDisk]
WinNTNotPresentsForGetFixedDrive:
          mov     [NumberDrives],dl

          call    GetDriveNameFromWin32

DetectNextDrive:
          mov     dx,[TotalAllDrive]
          mov     [TestingHDDnumber],dl
          cmp     dl,[NumberDrives]
          jz      short ExistDriveNotFound

          call    DetectHdd
          jc      short GoToIncForNextDrive
          inc     [TotalHDD]
          rol     [Int13ExtDriveCapable],1
          cmp     [Int13ExtSup],1
          jnz     short NotDetectInt13ExtSupport
          or      [Int13ExtDriveCapable],1
NotDetectInt13ExtSupport:
          call    DetectHDDsizeInMB
          call    GetInt13Param

          call    GetRealATAName

          call    GetNameTestingHDD
          jc      short HDDNameNotDetectForInfo
          push    si
          mov     si,offset PrnHDDmodel
          call    colorstr6x8
          mov     si,offset IDEATAdevices
          call    colorstr6x8
          pop     si
          push    [dword ds:si+31]

          cmp     [byte ds:si+32],0
          jz      short NotNidedCorrectForHDDModelStrLength
          mov     [dword ds:si+31],01019h
NotNidedCorrectForHDDModelStrLength:

          call    colorstr6x8
          pop     [dword ds:si+31]
          inc     [ForBaseFrame]
HDDNameNotDetectForInfo:

GoToIncForNextDrive:
          inc     [TotalAllDrive]
          jmp     DetectNextDrive

ExistDriveNotFound:

          call    SetIDEPM
          call    PrintHDD
          call    SetIDEPS
          call    PrintHDD
          call    SetIDESM
          call    PrintHDD
          call    SetIDESS
          call    PrintHDD
          call    SetIDETM
          call    PrintHDD
          call    SetIDETS
          call    PrintHDD
          call    SetIDEQM
          call    PrintHDD
          call    SetIDEQS
          call    PrintHDD

          cmp     [TotalAllDrive],0
          jnz     short HDDFoundGoToPerevodStroki
          cmp     [AtaDrive],0
          jz      short HDDNotFoundSkipPerevodStroki
HDDFoundGoToPerevodStroki:
          mov     si,offset PerevodStroki
          call    colorstr6x8
          inc     [ForBaseFrame]
HDDNotFoundSkipPerevodStroki:
;********** Проверка наличия CDROM **************
          mov     si,offset NumDriveName0
          mov     [word ds:IDEATAPIdevices],'MP'
          call    PrintCDROM
          mov     si,offset NumDriveName1
          mov     [word ds:IDEATAPIdevices],'SP'
          call    PrintCDROM
          mov     si,offset NumDriveName2
          mov     [word ds:IDEATAPIdevices],'MS'
          call    PrintCDROM
          mov     si,offset NumDriveName3
          mov     [word ds:IDEATAPIdevices],'SS'
          call    PrintCDROM
          mov     si,offset NumDriveName4
          mov     [word ds:IDEATAPIdevices],'MT'
          call    PrintCDROM
          mov     si,offset NumDriveName5
          mov     [word ds:IDEATAPIdevices],'ST'
          call    PrintCDROM
          mov     si,offset NumDriveName6
          mov     [word ds:IDEATAPIdevices],'MQ'
          call    PrintCDROM
          mov     si,offset NumDriveName7
          mov     [word ds:IDEATAPIdevices],'SQ'
          call    PrintCDROM
          cmp     [AtapiCDROM],0
          jz      short CDROMNotFound
          mov     si,offset PerevodStroki
          call    ColorStr6x8
          inc     [ForBaseFrame]
CDROMNotFound:

; Определение чипсета

          cmp     [PCIBusIsPresent],0
          jz      short ChipsetNotDetect

          mov     si,offset ChipsetsList
          cld
NextCheckChipsetID:
          lodsd
          cmp     al,1
          jz      short ChipsetNotDetect
          mov     dx,ax
          shr     eax,16
          mov     cx,ax
          push    si
          call    FaindPCIDevice
          pop     si
          jnc     short FaindChipset
NextSkipASCIIInChipsetsList:
          lodsb
          or      al,al
          jnz     short NextSkipASCIIInChipsetsList
          jmp     short NextCheckChipsetID

FaindChipset:
          push    si
          mov     [ChipsetForRep],si
          mov     si,offset MesChipset
          call    ColorStr6x8
          inc     [ForBaseFrame]
          pop     si
          call    ColorStr6x8

ChipsetNotDetect:

; Определения модели материнки
          cmp     [PnPBiosSupport],1
          jnz     NotPnPBiosForMotherboardDetect

          sub     cx,cx
NextCheckBiosStructuresForMainBoard:
          mov     [Structure],cx
          mov     ax,[EndProgram]
          mov     gs,ax
          call    GetPnPBiosStructure
          jc      short ErrorBiosForMotherboardDetect
          cmp     [byte gs:0],2
          jz      short BiosStructuresForMainBoardDetect
ErrorBiosForMotherboardDetect:
          inc     cx
          cmp     cx,[NumStructures]
          jnz     short NextCheckBiosStructuresForMainBoard
          jmp     NotPnPBiosForMotherboardDetect
BiosStructuresForMainBoardDetect:
          mov     di,offset NumPCIVendor
          push    ds
          mov     ax,[EndProgram]
          mov     ds,ax

          sub     si,si
          mov     cl,[byte ds:si+4]
          call    PosDMIString
          jc      NotPnPBiosForManufacturer

          cmp     [dword ds:si+3],'S-OR'
          jnz     short NotVendorMSI
          mov     cl,10
          jmp     PrnMSI

NotVendorMSI:

          cmp     [dword ds:si],'etnI'
          jnz     short NotVendorIntel
          mov     cl,5
          jmp     PrnIntel

NotVendorIntel:
          cmp     [dword ds:si],' DMA'
          jnz     short NotVendorAMD
          mov     cl,3
          jmp     PrnAMD

NotVendorAMD:

          cmp     [dword ds:si],'epuS'
          jnz     short NotVendorSupermicro
          mov     cl,10
          jmp     PrnSupermicro

NotVendorSupermicro:
          cmp     [dword ds:si],'rkeT'
          jnz     short NotVendorTekram
          mov     cl,6
          jmp     short PrnTekram

NotVendorTekram:
          cmp     [dword ds:si],'TIBA'
          jnz     short NotVendorABIT
          mov     cl,5
          jmp     short PrnABIT

NotVendorABIT:
          cmp     [dword ds:si+3],'I ts'
          jnz     short NotVendorFIC
          mov     [dword ds:si],' CIF'
          mov     cl,3
          jmp     short PrnFIC

NotVendorFIC:
          cmp     [dword ds:si],'yYgG'
          jz      short VendorGigaByte
          cmp     [dword ds:si],'agiG'
          jz      short VendorGigaByte
          cmp     [dword ds:si],'AGIG'
          jz      short VendorGigaByte
          cmp     [dword ds:si],' .AG'
          jnz     short NotVendorGigaByte
VendorGigaByte:
          mov     [dword ds:si],'AGIG'
          mov     [dword ds:si+4],'ETYB'
          mov     cl,8
          jmp     short PrnGigaByte

NotVendorGigaByte:
          cmp     [dword ds:si],'SUSA'
          jnz     short NotVendorASUSTeK
          mov     cl,4
          jmp     short PrnASUSTeK

NotVendorASUSTeK:
          call    CorrectDMIMainBoardName
PrnMSI:
PrnIntel:
PrnAMD:
PrnSupermicro:
PrnTekram:
PrnABIT:
PrnFIC:
PrnGigaByte:
PrnASUSTeK:
          cld
          rep movsb
          mov     al,32
          stosb
NotPnPBiosForManufacturer:

          sub     si,si
          mov     cl,[byte ds:si+5]
          call    PosDMIString
          jc      short NotPnPBiosForMotherboardModel
          call    CorrectDMIMainBoardName

          call    DetectGA5AA

          rep movsb
NotPnPBiosForMotherboardModel:
          pop     ds
          cmp     [byte cs:DMIStringCounter],0
          jz      short NotPnPBiosForMotherboardDetect
          sub     al,al
          stosb
          mov     si,offset MesMotherboard
          call    ColorStr6x8

          mov     si,offset NumPCIVendor
          push    si
          mov     di,offset NumRepMainboard
          mov     cx,63
          cld
          rep movsb
          pop     si
          mov     [dword ds:si+35],01019h
          call    ColorStr6x8
          inc     [ForBaseFrame]
NotPnPBiosForMotherboardDetect:

;******* Определение производителя и даты BIOS
          cmp     [BIOSVendorDetectOK],1
          jnz     short BIOSVendorUnknown
          mov     si,offset MesBios
          call    ColorStr6x8
          cmp     [Bug2000testErr],1
          jnz     short Bug2000TestError
          mov     [NumBiosDate1+1],6+8
          jmp     short NotFoundBug2000
Bug2000TestError:
          mov     al,[Bug2000Test1]
          or      al,al
          jz      short NotFoundBug2000
          mov     [NumBiosDate1+1],7+8
NotFoundBug2000:
          mov     si,offset NumBiosDate1
          call    ColorStr6x8
          inc     [ForBaseFrame]
          jmp     DetectDosVersion

BIOSVendorUnknown:
          push    ds
          push    0F000h
          pop     ds
          sub     si,si
          mov     cx,65530
NextSearchBIOSDate:
          lodsd
          and     eax,0FFFFFFh
          cmp     eax,'891'
          jz      short DetectDateComplete
          cmp     eax,'991'
          jz      short DetectDateComplete
InfinitBIOSDate:
          sub     si,3
          loop    short NextSearchBIOSDate
          jmp     short NoFoundBiosManuf
DetectDateComplete:
          cmp     [byte ds:si],','
          jz      short DetectOk
          cmp     [byte ds:si],'-'
          jz      short DetectOk
          cmp     [byte ds:si],' '
          jz      short DetectOk
          jmp     short InfinitBIOSDate
DetectOk:
          mov     cx,12
NextTestSimvolBios:
          lodsb
          cmp     al,65
          jb      short NotTextDetect
          cmp     al,90
          ja      short NotTextDetect
          dec     si
          mov     di,offset NumBios
          mov     cx,30
          rep movsb
          pop     ds
          jmp     short NextPoiskSimv
NotTextDetect:
          loop    short NextTestSimvolBios
          pop     ds
          jmp     short NoFoundBiosManuf

NextPoiskSimv:
          mov     si,offset NumBios
          mov     cx,30
NextByteBios:
          lodsb
          cmp     al,'.'
          jz      short DetectPoint
          cmp     al,32
          jb      short NoFoundBiosManuf
          cmp     al,127
          ja      short NoFoundBiosManuf
          loop    NextByteBios
DetectPoint:
          mov     di,offset NumBiosDate1
          xchg    si,di
          mov     cx,12
          rep movsw
          inc     [ForBaseFrame]
          mov     si,offset MesBios
          call    colorStr6x8

NoFoundBiosManuf:
DetectDosVersion:

          cmp     [Bug2000testErr],1
          jz      short Bug2000TestNotFound
          cmp     [Bug2000Test1],0
          jz      short Bug2000Test1NotFound
          mov     si,offset MesFoundBug2000
          call    colorStr6x8
          inc     [ForBaseFrame]
          mov     eax,[dword ds:Bug2000Test1Year]
          mov     [dword ds:Year],eax
          call    PrintDateTime
          mov     si,offset NumDay
          call    colorStr6x8
          mov     si,offset MesPerexod
          call    colorStr6x8
          mov     eax,[Test1WithBugDate]
          mov     [dword ds:Year],eax
          call    PrintDateTime
          mov     si,offset NumDay
          call    colorStr6x8
Bug2000Test1NotFound:
Bug2000TestNotFound:

;********* Определение версии DOS ******************
          mov     si,offset vermesn
          call    colorstr6x8
          cmp     [WinNTpres],1
          jz      WindowsPress
          mov     ah,30h
          int     21h
          cmp     [WinPres],1
          jz      short WindowsPress
          or      bh,bh
          mov     si,offset PcDosVer
          mov     [NumRepOSver1],si
          jz      short DOSVendorDetected
          cmp     bh,0FFh
          mov     si,offset MsDosVer
          mov     [NumRepOSver1],si
          jz      short DOSVendorDetected
          cmp     bh,0EEh
          mov     si,offset DrDosVer
          mov     [NumRepOSver1],si
          jz      short DOSVendorDetected
          cmp     bh,066h
          mov     si,offset PtsDosVer
          mov     [NumRepOSver1],si
          jz      short DOSVendorDetected
          push    ax
          sub     ah,ah
          mov     al,bh
          mov     cx,2
          mov     di, offset NumDosLabel
          call    BinToAscHex
          mov     si, offset MesDosLabel
          mov     [NumRepOSver1],si
          call    colorstr6x8
          pop     ax
          mov     si,offset DosVer
          mov     [NumRepOSver2],si
DOSVendorDetected:
          call    colorstr6x8
          push    ax
          xor     ah,ah
          mov     cx,1
          mov     di,offset vermes01
          call    bintoascdec
          pop     ax
          mov     al,ah
          xor     ah,ah
          mov     cx,2
          mov     di,offset vermes02
          call    bintoascdec
          mov     si,offset vermes01
          mov     [NumRepOSver2],si
          call    colorstr6x8
          jmp     short OkPrnDOS
WindowsPress:
          mov     si,offset MesWindows
          mov     [NumRepOSver1],si
          call    colorstr6x8
          mov     si,offset MesWindowsNT
          cmp     [WinNTpres],1
          jz      short WinNTDetect
          mov     ax,1600h
          int     2Fh

          mov     si,offset MesWindows95
          cmp     ax,0004h
          jz      short Win95Detect
          mov     si,offset MesWindows95osr2
          cmp     ax,0304h
          jz      short Win95Detect
          mov     si,offset MesWindows98
          cmp     ax,0A04h
          jz      short Win95Detect
          mov     si,offset MesWindowsME
          cmp     ax,5A04h
          jz      short Win95Detect
          jmp     short PrintTM
WinNTDetect:
          test    [GetVerEAX],80000000h
          jnz     short NotWindows2000
          cmp     [byte ds:GetVerEAX],5
          jnz     short NotWindows2000
          mov     si,offset MesWindows2000
NotWindows2000:
          cmp     [byte ds:GetVerEAX],128+6
          jnz     short NotWindowsXP
          mov     si,offset MesWindowsXP
NotWindowsXP:
          cmp     [byte ds:GetVerEAX],128+7
          jnz     short NotWindowsNET
          mov     si,offset MesWindowsNET
NotWindowsNET:
Win95Detect:
          mov     [NumRepOSver2],si
          call    colorstr6x8
PrintTM:
          mov     si,offset MesTM
          mov     [NumRepOSver3],si
          call    colorstr6x8
OkPrnDOS:
;******** Рамка конфигурации системы *****
          mov     dl,[ForBaseFrame]
          sub     dh,dh
          shl     dx,3
          add     dx,82-8   ; Длина рамки

          mov     ax,8
          mov     bx,10
          mov     cx,296
          mov     bp,3+8
          call    colorframe
          mov     bl,[ForBaseLine]
          shl     bx,3
          add     bx,35
          call    ColorHorLine

;******** Рамка системных сообщений *****
          call    MesagesFrame
          call    ClearWindowMesages
          mov     si,offset MesESC
          call    ColorStr6x8

          cmp     [CDROMTest],1
          jz      GoToTestCDROM
          cmp     [HDDTest],1
          jz      GoToTestHDD
;*************************************************************
;**********               Тест процессора                 ****
;*************************************************************
;jmp mm1
          mov     ax,12
          mov     bx,317
          mov     cx,350
          mov     dx,12
          mov     bp,3+8
          call    ColorFrame
          sub     al,4
          sub     bx,26
          add     dx,52
          add     cx,8
          call    ColorFrame

          mov     si,offset MesTesting
          mov     [word ds:si+1],2803h
          call    ColorStr6x8
          mov     si,offset MesCpuTest
          call    ColorStr6x8
          mov     [SkaleProc],ForSkaleProc
          call    PrintSravnenieCPU

          xor     ebx,ebx
          mov     bp,sp
          mov     ax,[EndProgram]
          mov     [word cs:EndProgramCS],ax
          mov     cx,33      ;Не менять

          ALIGN 2

NewCallCPUSpeedInTest:

          push    cx
          push    ds
          push    es

          push    cx
          push    dx
          mov     [word cs:CounterCPUspeed],cx
          mov     ax,99
          mov     dx,cx
          add     dx,dx
          add     dx,cx
          sub     ax,dx

          mov     cx,2
          mov     di,offset NumPercentCompl
          call    BinToAscDec
          call    NZinMes
          mov     si,offset MesPercentCompl
          call    ColorStr6x8
          pop     dx
          pop     cx

          push    cs
          push    cs
          pop     ds
          pop     es
          mov     si,offset StartCPUTestingInstr-ForCpuTest*33
          mov     ax,ForCpuTest
          mul     cx
          add     si,ax
          mov     di,offset StartCPUTestingInstr
          mov     cx,offset EndCPUTestingInstr
          sub     cx,di
          mov     di,si
          sub     di,ForCpuTest
          cld
          rep movsb
          pop     es
          pop     ds
          pop     cx
          dec     sp

          call    CpuSpeedTest
          add     ebx,eax

          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      SkipCPUSpeedTest
          cmp     al,' '
          jz      SkipCPUSpeedTest

          loop    short NewCallCPUSpeedInTest
          mov     sp,bp

          mov     edx,10
          mov     eax,1939288546
          div     ebx
          mov     di,offset NumCpuSpeedH
          mov     cx,5
          call    BinToAscDec2
          xor     edx,edx
          mov     ebx,100     ;Два знака после запятой
          div     ebx
          shr     eax,1
          or      eax,eax
          jnz     short NotZeroInCPUspeed
          inc     eax
NotZeroInCPUspeed:
          call    Skale
          push    ax
          mov     ax,8+1
          mov     bx,421-26+2-8*13
          mov     dx,64-3
          mov     cx,358-3
          sub     bp,bp
          call    Rectangle
          pop     cx
          mov     ax,12+1
          mov     bx,319
          mov     dx,9
          mov     bp,1+8
          call    Rectangle
          dec     ax
          mov     bx,317
          mov     cx,350
          mov     dx,ax
          mov     bp,3+8
          call    ColorFrame
          mov     ax,8
          sub     bx,26
          add     dx,52
          add     cx,8
          call    ColorFrame
          mov     si,offset NumCpuSpeed
          call    ColorStr6x8
          mov     si,offset MesCpuTest
          call    ColorStr6x8
          call    PrintSravnenieCPU
          jmp     short TestingKeyWait
SkipCPUSpeedTest:
          cmp     [CreateQuickREP],1
          jz      MakeQuickREP
          mov     sp,bp
          mov     si,offset MesSkipped
          mov     [dword ds:si],20280216h
          call    ColorStr6x8
TestingKeyWait:
          cmp     al,1Bh
          jnz     short VideoTestStart
          jmp     CDErrExit
VideoTestStart:

          cmp     [CreateQuickREP],1
          jz      MakeQuickREP
;******************************************************
;*******************      Тест памяти       ***********
;******************************************************
;mm1:
          cmp     [ErrConfig],1
          jz      ConfigError4
          cmp     [DisableMem],0
          jnz     MemTestComplite
          call    HkalaMashMSB
          call    MahtabMemSpeed
          call    InitXMSAccess
          call    CheckMemory

NextMemTest:
          mov     si,offset MesBlockTest
          call    ColorStr6x8

          mov     [LastPointInMemGrp],0
          call    ClearHMSblock

          xor     ax,ax
          mov     bp,ax
NextTestMemBlock:
          push    ax

          cmp     [NumberMemTest],0
          jz      short ReadTest
          cmp     [NumberMemTest],1
          jz      short WriteTest
          cmp     [NumberMemTest],2
          jz      short ReplaceTest

          cmp     [FeatureFlagMMX],1
          jnz     short NotMMXTransferGraph

          cmp     [NumberMemTest],3
          jz      short MMXReadTest
          cmp     [NumberMemTest],4
          jz      short MMXWriteTest
          cmp     [NumberMemTest],5
          jz      short MMXMoveTest
NotMMXTransferGraph:
          jmp     EndMemTests

ReadTest:
          or      ax,ax
          jnz     short SkipReadMem
          mov     si,offset MesReadBlock
          call    ColorStr6x8
SkipReadMem:
          call    MemSpeedBlockLodsd
          call    MSBgrapf
          mov     bp,6+8
          jmp     short BuildMemGraph


WriteTest:
          or      ax,ax
          jnz     short SkipWriteMem
          mov     si,offset MesWriteBlock
          call    ColorStr6x8
SkipWriteMem:
          call    MemSpeedBlockStosd
          call    MSBgrapf
          mov     bp,1+8
          jmp     short BuildMemGraph

ReplaceTest:
          or      ax,ax
          jnz     short SkipReplMem
          mov     si,offset MesReplBlock
          call    ColorStr6x8
SkipReplMem:
          call    MemSpeedBlockRepl
          call    MSBgrapf
          mov     bp,2+8
          jmp     short BuildMemGraph

MMXReadTest:
          or      ax,ax
          jnz     short SkipMMXReadMem
          mov     si,offset MesMMXReadBlock
          call    ColorStr6x8
SkipMMXReadMem:
          call    MemSpeedBlockLodsq
          call    MSBgrapf
          mov     bp,6
          jmp     short BuildMemGraph

MMXWriteTest:
          or      ax,ax
          jnz     short SkipMMXWriteMem
          mov     si,offset MesMMXWriteBlock
          call    ColorStr6x8
SkipMMXWriteMem:
          call    MemSpeedBlockStosq
          call    MSBgrapf
          mov     bp,1
          jmp     short BuildMemGraph

MMXMoveTest:
          or      ax,ax
          jnz     short SkipMMXMoveMem
          mov     si,offset MesMMXMoveBlock
          call    ColorStr6x8
SkipMMXMoveMem:
          call    MemSpeedBlockMovsq
          call    MSBgrapf
          mov     bp,5

BuildMemGraph:

          call    ColorVerLine
          pop     ax
          inc     ax
          mov     bp,ax

          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      CDErrExit
          cmp     al,' '
          jz      short SkipMemLodsSpeedTest

          mov     ax,bp
          cmp     ax,250

          jnz     NextTestMemBlock
          jmp     short GoToNextMemTest
SkipMemLodsSpeedTest:

          cmp     [NumberMemTest],0
          jnz     short NotReadMemTest
          add     [NumberMemTest],2
          jmp     GoToNextMemTest
NotReadMemTest:
          cmp     [NumberMemTest],3
          jz      short EndMemTests

GoToNextMemTest:
          inc     [NumberMemTest]
          jmp      NextMemTest
EndMemTests:

          mov     si,offset MesBlockTest
          call    ColorStr6x8
          mov     si,offset MesZamerMemSpeed
          call    ColorStr6x8
          mov     [AllCache],0

          mov     si,offset ResultsNew
          mov     di,offset ResCacheSpeedRepl
          sub     cl,cl
NextByteCacheSpeedPrn:
          lodsb
          or      al,al
          jz      short NextCacheForSpeed
          inc     [AllCache]
          cmp     [AllCache],4
          jz      short CacheForSpeedNotFound
          push    si
          push    di
          push    cx
          mov     al,[AllCache]
          add     al,48
          mov     [NumberCache],al

          push    di
          mov     ax,4
          shl     ax,cl

          cmp     [AMDProcessor],1
          jnz     short NotAMDCPUForCorrectL2Cache
          cmp     [word ds:CPUmodel],256*6+3;AMD Duron ?
          jz      short AMDDuronCPUForCorrectL2Cache
          cmp     [word ds:CPUmodel],256*6+7;AMD Duron ?
          jnz     short NotAMDDuronCPUForCorrectL2Cache
AMDDuronCPUForCorrectL2Cache:
          cmp     ax,128
          jnz     short NotAMDDuronCPUForCorrectL2Cache
          mov     al,64
          jmp     short AMDDuronCacheSizeCorrected
NotAMDDuronCPUForCorrectL2Cache:
          cmp     [word ds:CPUmodel],256*6+4;AMD Athlon TBird ?
          jz      short AMDCPUForCorrectL2Cache
          cmp     [word ds:CPUmodel],256*6+6;AMD Athlon Palomino ?
          jnz     short NotAMDCPUForCorrectL2Cache
AMDCPUForCorrectL2Cache:
          cmp     ax,512
          jnz     short NotAMDCPUForCorrectL2Cache
          mov     ax,256
AMDDuronCacheSizeCorrected:
NotAMDCPUForCorrectL2Cache:

          mov     di,offset CacheSize
          mov     cx,4
          call    BinToAscDec
          call    NZInMes
          pop     si

          call    GetAverageMemBenchForGraphs

          mov     di,offset NumCacheSpeed
          call    BinToAscDec2
          mov     si,offset MesCacheSpeed
          call    ColorStr6x8
          pop     cx
          pop     di
          pop     si
NextCacheForSpeed:
          add     di,4
          inc     cl
          mov     al,[byte cs:MemSizePriznak]
          add     al,10
          cmp     cl,al
          jnz     NextByteCacheSpeedPrn
CacheForSpeedNotFound:

          mov     si,offset ResCacheSpeedRepl
          mov     ax,10
          add     al,[byte cs:MemSizePriznak]
          shl     ax,2
          add     si,ax
          call    GetAverageMemBenchForGraphs

          mov     di,offset NumZamerMemSpeedM
          call    BinToAscDec2
          mov     si,offset MesZamerMemSpeedM
          call    ColorStr6x8

NotTestCache:
MemTestComplite:
ConfigError4:
GoToTestHDD:

          jmp     short SkipMenuInit

HDDTestStart:
          mov     [LitingPriznak],7+8
          mov     [YposForPrn],3
          mov     [NumberHDD],'0'
          mov     [NumberCD],'0'
          mov     [DefaultDrive],0
          mov     [CDROMtest],0
          cmp     [BadDownScr],1
          jz      short ClearDownScr
          cmp     [CDtested],0
          jz      short CDnotTested
ClearDownScr:
          call    ClearDownScreen
          mov     [CDtested],0
CDnotTested:
          call    ClearRightScreen

SkipMenuInit:
;*******************************************
;****** Выбор тестируемого драйва **********
;*******************************************
          cmp     [WinNTpres],1
          jz      HDDTestStart01

          cmp     [SkipDriveSelect],0
          jnz     HDDTestStart01

          mov     cl,[TotalHDD]
          or      cl,cl
          jnz     short HDDIsFound
          mov     [CDROMtest],1
HDDIsFound:
          mov     al,[TotalCD]
          add     al,cl
          jz      HDDTestStart01
          mov     [AllDrives],al
          mov     [YposForPrn],6  ;позиция по горизонтали

          call    ClearWindowMesages
          mov     si,offset MesPressDriveSl
          call    ColorStr6x8

          mov     ax,404
          mov     bx,36
          mov     cx,124
          sub     dh,dh
          mov     dl,[AllDrives]
          shl     dx,3
          add     dx,4*8
          mov     bp,3+8
          call    ColorFrame
          mov     si,offset MesDriveSelect
          call    ColorStr6x8

NextPrnHDDforWin:
          mov     cl,[TotalHDD]
          cmp     [DefaultDrive],cl
          jz      short EndPrnHDDforWin
          call    PrnMesForWin
          mov     [LitingPriznak],3
          call    PrnMesHDDforWin
          inc     [DefaultDrive]
          inc     [YposForPrn]
          inc     [NumberHDD]
          jmp     short NextPrnHDDforWin
EndPrnHDDforWin:
          mov     [DefaultDrive],0
NextPrnCDforWin:
          mov     cl,[TotalCD]
          cmp     [DefaultDrive],cl
          jz      short EndPrnCDforWin
          call    PrnMesForWin
          mov     [LitingPriznak],3
          call    PrnMesCDforWin
          inc     [DefaultDrive]
          inc     [YposForPrn]
          inc     [NumberCD]
          jmp     short NextPrnCDforWin
EndPrnCDforWin:

          mov     [YposForPrn],6   ;позиция по горизонтали
          mov     [DefaultDrive],0
          cmp     [Method],0
          jz      short FullTestMethodSelect
          mov     [Method],0
          jmp     short GotoDetectedSpaceKey
FullTestMethodSelect:
          mov     [Method],1
GotoDetectedSpaceKey:
          jmp     DetectedSpaceKey

GetNewKeyForDriveSelection:
          call    GetCh
          cmp     ax,0068h
          jz      short DetectedUpKey
          cmp     ax,0070h
          jz      short DetectedDownKey
          cmp     al,0Dh
          jz      DetectedEnterKey
          cmp     al,1Bh
          jz      short DriveSelectionExit
          cmp     al,' '
          jz      DetectedSpaceKey
          jmp     short GetNewKeyForDriveSelection
DetectedUpKey:
          cmp     [YposForPrn],6    ;позиция по горизонтали
          jz      short GetNewKeyForDriveSelection

          mov     [LitingPriznak],3
          call    PrnMesForWin

          cmp     [CDROMtest],1
          jz      short RealCDtestUP
          call    PrnMesHDDforWin
          dec     [DefaultDrive]
          mov     al,[DefaultDrive]

          call    GoPrnMesHDDforWin

          jmp     GetNewKeyForDriveSelection
DriveSelectionExit:
          call    ClearRightScreen
          jmp     NormalExit

RealCDtestUP:
          call    PrnMesCDforWin
          mov     al,[DefaultDrive]
          or      al,al
          jz      short GoToHDDdrive
          dec     [DefaultDrive]
          dec     [YposForPrn]
          call    GoPrnMesCDforWin
          jmp     GetNewKeyForDriveSelection

GoToHDDdrive:
          dec     [CDROMtest]
          mov     al,[TotalHDD]
          dec     al
          mov     [DefaultDrive],al
          call    GoPrnMesHDDforWin
          jmp     GetNewKeyForDriveSelection

DetectedDownKey:
          mov     al,[AllDrives]
          add     al,6-1   ;позиция по горизонтали -1
          cmp     [YposForPrn],al
          jz      GetNewKeyForDriveSelection
          mov     [LitingPriznak],3
          call    PrnMesForWin

          cmp     [CDROMtest],1
          jz      short RealCDtest
          mov     al,[DefaultDrive]
          add     al,6     ;позиция по горизонтали
          mov     [YposForPrn],al

          mov     al,[DefaultDrive]
          add     al,48
          mov     [NumberHDD],al

          call    PrnMesHDDforWin
          mov     [LitingPriznak],7+8
          inc     [YposForPrn]
          call    PrnMesForWin

          mov     al,[DefaultDrive]
          mov     ah,[TotalHDD]
          dec     ah
          cmp     ah,al
          jz      short GoToCDdrive
          inc     al

          mov     [DefaultDrive],al
          add     al,48
          mov     [NumberHDD],al
          call    PrnMesHDDforWin
          jmp     GetNewKeyForDriveSelection
GoToCDdrive:
          xor     al,al
          mov     [DefaultDrive],al

          inc     [CDROMtest]
          mov     [NumberCD],48
          call    PrnMesCDforWin
          jmp     GetNewKeyForDriveSelection
RealCDtest:
          mov     al,[DefaultDrive]
          add     al,48
          mov     [NumberCD],al

          call    PrnMesCDforWin
          inc     [DefaultDrive]
          inc     [YposForPrn]
          call    GoPrnMesCDforWin
          jmp     GetNewKeyForDriveSelection

DetectedSpaceKey:
          mov     si,offset NumFastFullTest
          mov     al,[AllDrives]
          mov     [byte ds:si+2],al
          add     [byte ds:si+2],6+1     ;позиция по горизонтали +1
          call    ColorStr6x8
          cmp     [Method],0
          jnz     short NotFullMethod
          mov     [Method],1
          mov     si,offset MesFullTest
          call    ColorStr6x8
          jmp     GetNewKeyForDriveSelection
NotFullMethod:
          mov     [Method],0
          mov     si,offset MesFastTest
          call    ColorStr6x8
          jmp     GetNewKeyForDriveSelection

DetectedEnterKey:
          cmp     [CDROMTest],1
          jz      GoToTestCDROM

;****************************************************
;*************      Тест винчестера       ***********
;****************************************************
HDDTestStart01:

          mov     [SkipDriveSelect],0
          mov     ax,8+1
          mov     bx,421-26+2
          mov     dx,64-3
          mov     cx,358-3
          sub     bp,bp
          call    Rectangle
          cmp     [PCXcreated],0
          jz      short NoPcxCreated
          call    ClearDownScreen
NoPcxCreated:

          call    ClearRightScreen
          call    ClearWindowMesages
          cmp     [WinNTpres],1
          jz      NormalExit
          mov     si,offset MesESC
          call    ColorStr6x8
          xor     ax,ax
          mov     [TotalUnstab],ax
          mov     [TotalError],ax

          mov     al,[TotalHDD]  ; А вобще то есть винчестер ?
          or      al,al
          jnz     short HardDrivePresent
          call    ClearWindowMesages
          jmp     NormalExit          ; Если винта нет - скип его тест
HardDrivePresent:
          cmp     [DefaultDrive],al
          jb      short HardDrivePresentGoToTest
          mov     [DefaultDrive],0
HardDrivePresentGoToTest:
          mov     al,[DefaultDrive]
          add     al,48
          mov     [HddNum],al
          call    PrnBaseCompareWindow
          mov     si,offset MesHDDTest
          call    ColorStr6x8
          mov     [SkaleProc],ForSkaleProc
          mov     si,offset MesTesting
          mov     [word ds:si+1],3503h
          call    ColorStr6x8
          call    PrintSravnenieHDD

          mov     [HDDTestComplite],0

          call    HardDriveTest

          cmp     [Method],1
          jz      short CompliteFullTestHDD
          mov     [word ds:NumFullTestHDD],'DH'
          call    PrnFFullTest
          jz      HDDTestStart01
CompliteFullTestHDD:

          jmp     CDNormalExit
;************************************************
;*********     Тест CD-ROM               ********
;************************************************
GoToTestCDROM:
          mov     [SkipDriveSelect],0
          call    ClearDownScreen
          call    ClearRightScreen
          mov     [CDtested],1
          cmp     [DetSMARTdrv],1
          jnz     short SMartDRVNot2
          mov     ax,4A10h
          mov     bx,2
          int     2Fh
SMartDRVNot2:
          xor     eax,eax
          mov     [TotalResultSpeedL],eax
          mov     [TotalResultSpeedH],eax
          mov     [HorKoord],ax
          mov     [TotalUnstab],ax
          mov     [TotalError],ax

          mov     [SectorsRead],248
          mov     di,offset NumTotalUnstab
          mov     cx,3
          call    BinToAscDec
          call    NZInMes
          mov     di,offset NumTotalError
          xor     ax,ax
          call    BinToAscDec
          call    NZInMes
          call    ClearRightScreen

          mov     ax,1500h
          xor     bx,bx
          int     2Fh
          mov     [KolihCDROM],bl
          mov     [ForvCDROM],cl
          mov     al,[DefaultDrive]
          cmp     al,bl
          jae     short CDDriveOk
          add     [ForvCDROM],al
          jmp     short CDDriveOk1
CDDriveOk:
          mov     [DefaultDrive],0
CDDriveOk1:

          call    Setka
          mov     si,offset MesCDROM
          mov     al,[DefaultDrive]
          add     al,48
          mov     [NumCDROM],al
          call    ReadyDrive
          call    ReadVTOC

          mov     si,offset CDResBuff
          mov     al,10*4
          mul     [DefaultDrive]
          add     si,ax
          mov     eax,[AllSectorCDROM]
          mov     [dword ds:si],eax
          cmp     [Method],0
          mov     [byte ds:si+20],1
          jz      short CDTestedInFastMode
          mov     [byte ds:si+20],2
CDTestedInFastMode:

          cmp     eax,298
          jb      VTOCError
          movzx   ebx,[SectorSize]
          cmp     bx,2048
          jnz     VTOCError

          mov     eax,234249436 ;Для калибровки CDROM Speed
          movzx   ebx,[SectorsRead]
          mul     ebx
          mov     [BasicDivadeL],eax
          mov     [BasicDivadeH],edx

          mov     ax,312
          mov     bx,282
          mov     cx,300
          mov     dx,26
          mov     bp,3+8
          call    ColorFrame
          mov     ax,564
          mov     cx,dx
          call    ColorVerLine
          cmp     [Method],0
          mov     si,offset MesFullMethod
          jnz     short FullMethod
          mov     si,offset MesSmartMethod
FullMethod:
          call    ColorStr6x8
;******************   Вычисление масштаба   ****************

          mov     si,offset MesCheckReadSpeed
          call    ColorStr6x8
          mov     [TekSectorCDROM],16

RepeatSpinUp:
          sub     eax,eax
          mov     [MaxResultSpeed],eax
          mov     cx,3
NextDetectSpinUp:
          push    cx
          call    ZamerCDROMSpeed
          mov     ebx,[MaxResultSpeed]
          cmp     ebx,eax
          jae     short NormalMaxSpinUp
          mov     [MaxResultSpeed],eax
NormalMaxSpinUp:

          movzx   ecx,[SectorsRead]
          add     [TekSectorCDROM],ecx
          pop     cx
          loop    short NextDetectSpinUp

          sub     eax,eax
          mov     [MaxResultSpeedSecond],eax
          mov     cx,3
NextDetectSpinUpSecond:
          push    cx
          call    ZamerCDROMSpeed
          mov     ebx,[MaxResultSpeedSecond]
          cmp     ebx,eax
          jae     short NormalMaxSpinUpSecond
          mov     [MaxResultSpeedSecond],eax
NormalMaxSpinUpSecond:

          movzx   ecx,[SectorsRead]
          add     [TekSectorCDROM],ecx
          pop     cx
          loop    short NextDetectSpinUpSecond

          mov     eax,[MaxResultSpeed]
          mov     ebx,100
          mul     ebx
          sub     edx,edx
          div     [MaxResultSpeedSecond]
          cmp     al,98 ; Если разница более 2% - продолжаем раскрутку.
          jb      short RepeatSpinUp

          mov     eax,[MaxResultSpeedSecond]
          mov     [MaxResSpeedMashtab],eax

          call    MastabSpeedCDROM
          mov     [DivMastabCDROM],ebx

;***********  Инициализация переменных CDROM Test  ************

          xor     eax,eax
          mov     [TekuhPointVert],ax
          mov     [OldTekuhPointVert],ax
          mov     [KolihProhodov],eax
          mov     [MaxResultSpeed],eax
          mov     [MaxResultSpeedTek],eax
          mov     [HorKoord],ax
          mov     [TekSectorCDROMfast],eax
          mov     [TekSectorCDROM],eax
          mov     [OsnovnDivade],eax
          mov     [CDtestSkipped],al

          cmp     [WinPres],1
          jnz     short WindowsNotPresents
          mov     al,10h
WindowsNotPresents:
          mov     [TekSectorCDROM],eax

          cmp     [Method],0
          jnz     short NoFastTest
          mov     ebx,18600
          cmp     [AllSectorCDROM],ebx
          jbe     short TestInposeble
          mov     eax,[AllSectorCDROM]
          sub     eax,ebx
          push    eax
          mov     ebx,8
          xor     edx,edx
          div     ebx
          pop     eax
          sub     eax,edx
          mov     [TekSectorCDROM],eax
          jmp     short NoFastTest
TestInposeble:
          mov     [Method],1
NoFastTest:
          mov     eax,[AllSectorCDROM]

          push    eax
          mov     cx,6
          mov     di,offset NumSectorCDROM
          call    BinToAscDecH
          call    NZInMes
          mov     ebx,298
          xor     edx,edx
          div     ebx
          mov     [OsnovnDivade],eax
          movzx   ebx,[SectorSize]
          pop     eax

          mul     ebx
          shr     eax,20
          mov     cx,4
          mov     di,offset NumAllTotalRead
          call    BinToAscDecH
          call    NZInMes
          mov     ax,318
          mov     bx,287
          mov     cx,238
          mov     dx,18
          sub     bp,bp
          call    Rectangle
          mov     si,offset MesCDROM
          call    ColorStr6x8
          mov     si,offset MesCDROMunstab
          call    ColorStr6x8
          mov     si,offset MesSectorAllSec
          call    ColorStr6x8
          mov     si,offset MesFrom
          call    ColorStr6x8
          mov     si,offset MesSectorAllRead
          call    ColorStr6x8

          cmp     [Method],1
          jnz     short NoFullCDTest
          call    PrnBaseCompareWindow
          mov     si,offset MesCDTest
          call    ColorStr6x8

          mov     [SkaleProc],ForSkaleProc
          call    PrintSravnenieCD
          mov     si,offset MesTesting
          mov     [word ds:si+1],3503h
          call    ColorStr6x8
NoFullCDTest:
;***********  Начало тестирования поверхности *********
          cmp     [DetSMARTdrv],1
          jnz     short SMartDRVNot1
          mov     ax,4A10h
          mov     bx,2
          int     2Fh
SMartDRVNot1:
          xor     eax,eax
          mov     [KolihProhodov],eax
          mov     [OldTekuhPointVert],ax

          call    SeekToSector0

NextCDBlockRead:
          call    ZamerCDROMSpeed
          cmp     eax,19660800
          jb      short NormalResCDread
          mov     eax,307200
NormalResCDread:

          mov     [RealResultSpeed],eax
          inc     [KolihProhodov]

          mov     ebx,[MaxResultSpeed]
          cmp     ebx,eax
          jb      short NormalMaxResultSpeed
          mov     eax,ebx
NormalMaxResultSpeed:
          mov     [MaxResultSpeed],eax
          push    eax
          mov     ebx,100
          xor     edx,edx
          div     ebx
          mov     di,offset NumMaxReadSpeedCD
          mov     cx,5
          call    BinToAscDecH
          call    NZInMes
          pop     eax
          mov     ebx,150
          xor     edx,edx
          div     ebx
          mov     cx,3
          mov     di,offset NumMaxXSpeed
          call    BinToAscDec2

          mov     eax,[BasicDivadeG]

          add     [TotalResultSpeedL],eax
          adc     [TotalResultSpeedH],0
          mov     eax,[TotalResultSpeedL]
          mov     edx,[TotalResultSpeedH]
          div     [KolihProhodov]

          mov     ebx,[BasicDivadeL]
          mov     edx,[BasicDivadeH]
          xchg    eax,ebx
          div     ebx

          mov     [TekushSpeedCDROM],eax
          cmp     [TekSectorCDROM],305152
          ja      short SizeMore
          mov     [TekushSpeedCDGrp],eax
SizeMore:

          push    eax
          xor     edx,edx
          mov     ebx,100
          div     ebx
          mov     cx,5
          mov     di,offset NumReadSpeedCDROM
          call    BinToAscDecH
          call    NZInMes
          pop     eax

          mov     ebx,150
          xor     edx,edx
          div     ebx
          mov     cx,3
          mov     di,offset NumXspeed
          call    BinToAscDec2

          mov     si,offset MesReadSpeedCDROM
          call    ColorStr6x8

          call    GrafikCDROM

          mov     ax,[TekuhPointVert]
          mov     [OldTekuhPointVert],ax
          cmp     [ErrorRead],20
          jz      CDErrExit
          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      CDErrExit
          cmp     al,' '
          jnz     short NotStopTestCDROM
          mov     ax,5B03h
          call    CursorPos
          mov     si,offset MesCDSkipped
          call    ColorStr6x8
          cmp     [Method],0
          jz      short FastCDTestRuning
          mov     ax,0335h
          call    CursorPos
          mov     si,offset MesCDSkipped
          call    ColorStr6x8
          mov     [CDtestSkipped],1
FastCDTestRuning:
          jmp     short CDTestWasSkipped

NotStopTestCDROM:
          call    PrnTekSector
          mov     eax,[TekSectorCDROMfast]
          movzx   ebx,[SectorsRead]
          add     eax,ebx
          mov     [TekSectorCDROMfast],eax
          mov     eax,[TekSectorCDROM]
          movzx   ebx,[SectorsRead]
          add     eax,ebx
          mov     [TekSectorCDROM],eax
          add     eax,ebx
          cmp     eax,[AllSectorCDROM]
          jb      NextCDBlockRead

          mov     si,offset CDResBuff
          mov     cl,[DefaultDrive]
          cmp     cl,3
          ja      short CDTestWasSkipped
          mov     al,10*4
          mul     cl
          add     si,ax
          mov     eax,[TekushSpeedCDROM]
          mov     [dword ds:si+4],eax
          mov     eax,[MaxResultSpeed]
          mov     [dword ds:si+8],eax
          mov     ax,[TotalUnstab]
          inc     ax
          mov     [word ds:si+12],ax
          mov     ax,[TotalError]
          mov     [word ds:si+14],ax

CDTestWasSkipped:
          mov     eax,[AllSectorCDROM]
          mov     [TekSectorCDROM],eax
          call    PrnTekSector
          call    MastabSpeedCDROM

;************* Тест CDROM RandomAccessTime **************

          cmp     [Method],0
          jz      DetectFastTestForRandomAccessTime

          mov     ax,318
          mov     bx,287
          mov     cx,238
          mov     dx,18
          sub     bp,bp
          call    Rectangle
          mov     si,offset MesSectorAllSec
          call    ColorStr6x8
          call    SetRnd

          mov     [SectorsRead],1
          mov     [BasicDivadeL],12    ;Для калибровки CDROM Seek
          xor     eax,eax
          mov     [KolihProhodov],eax
          mov     [TotalResultSpeedL],eax
          mov     [TotalResultSpeedH],eax
          mov     [TekushSeekCDROM],eax

          mov     bx,6*8-8
          mov     ax,53*6
          mov     cx,36*6
          mov     dx,8+8
          sub     bp,bp
          call    Rectangle
          mov     si,offset MesRandAccessCDROM
          call    ColorStr6x8
          call    Setka

          cmp     [CDtestSkipped],1
          jz      short SkipRefreshCDres
          mov     si,offset MesCDROM
          call    ColorStr6x8
          mov     [NumTotalUnstab],0
          mov     si,offset MesReadSpeedCDROM
          call    ColorStr6x8
SkipRefreshCDres:
          call    MastabSpeedCDROM
          mov     [NumSkipTekSectorCDROML],0
          call    SeekToSector0

NextCDSectorSeekForRandomAccessTime:

          mov     eax,[AllSectorCDROM]
          dec     eax
          call    Rnd
          mov     [TekSectorCDROM],eax
          call    ZamerCDROMRandomAccessTime
          inc     [KolihProhodov]
          add     [TotalResultSpeedL],eax
          adc     [TotalResultSpeedH],0

          mov     eax,[TotalResultSpeedL]
          mov     edx,[TotalResultSpeedH]
          div     [KolihProhodov]
          xor     edx,edx
          div     [BasicDivadeL]

          mov     [TekushSeekCDROM],eax
          mov     cx,3
          mov     di,offset NumRndSeekTestCDROMH
          call    BinToAscDec2
          mov     si,offset NumRndSeekTestCDROM
          call    ColorStr6x8

          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      CDErrExit
          cmp     al,' '
          jnz     short NotStopTestCDROMForRandomAccessTime
          mov     ax,4E05h
          call    CursorPos
          mov     si,offset MesCDSkipped
          call    ColorStr6x8
          jmp      SkipTestCDROMForRandomAccessTime
NotStopTestCDROMForRandomAccessTime:
          cmp     [KolihProhodov],192
          jnz     NextCDSectorSeekForRandomAccessTime
          mov     si,offset CDResBuff
          mov     cl,[DefaultDrive]
          cmp     cl,3
          ja      short CDTestRandomAccessWasSkipped
          mov     al,10*4
          mul     cl
          add     si,ax
          mov     eax,[TekushSeekCDROM]
          mov     [dword ds:si+25],eax
CDTestRandomAccessWasSkipped:

;********** Тест CDROM 1/3 Seek Time *****************

SkipTestCDROMForRandomAccessTime:

          xor     eax,eax
          mov     [KolihProhodov],eax
          mov     [TotalResultSpeedL],eax
          mov     [TotalResultSpeedH],eax
          mov     [TekSectorCDROM],eax
          mov     [TekushSeekCDROM],eax
          mov     eax,[AllSectorCDROM]
          mov     ebx,3
          sub     edx,edx
          div     ebx
          mov     [TekSectorCDROML],eax
          mov     eax,144
          add     [TekSectorCDROML],eax
          mov     [TekSectorCDROMH],eax

          mov     si,offset Mes13SeekCDROM
          call    ColorStr6x8
          mov     [NumSkipTekSectorCDROML],32

          call    SeekToSector0

NextCDSectorFor13SeekTime:

          call    ZamerCDROMSeek

          inc     [KolihProhodov]
          add     [TotalResultSpeedL],eax
          adc     [TotalResultSpeedH],0
          dec     [TekSectorCDROML]
          dec     [TekSectorCDROMH]
          mov     eax,[TotalResultSpeedL]
          mov     edx,[TotalResultSpeedH]
          div     [KolihProhodov]
          xor     edx,edx
          div     [BasicDivadeL]

          mov     [TekushSeekCDROM],eax
          mov     cx,3
          mov     di,offset Num13SeekTestCDROMH
          call    BinToAscDec2
          mov     si,offset Num13SeekTestCDROM
          call    ColorStr6x8


          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      CDErrExit
          cmp     al,' '
          jnz     short NotStopTestCDROMFor13SeekTime
          mov     ax,4E06h
          call    CursorPos
          mov     si,offset MesCDSkipped
          call    ColorStr6x8
          call    Setka
          jmp     SkipTestCDROMFor13SeekTime
NotStopTestCDROMFor13SeekTime:
          cmp     [KolihProhodov],64
          jnz     NextCDSectorFor13SeekTime

          mov     si,offset CDResBuff
          mov     cl,[DefaultDrive]
          cmp     cl,3
          ja      short CDTest13SeekWasSkipped
          mov     al,10*4
          mul     cl
          add     si,ax
          mov     eax,[TekushSeekCDROM]
          mov     [dword ds:si+29],eax
CDTest13SeekWasSkipped:

;********* Тест CDROM Full Seek Time ****************

SkipTestCDROMFor13SeekTime:

          mov     ax,4A10h
          mov     bx,2
          int     2Fh

          xor     eax,eax
          mov     [KolihProhodov],eax
          mov     [TotalResultSpeedL],eax
          mov     [TotalResultSpeedH],eax
          mov     [TekSectorCDROM],eax
          mov     [TekushSeekCDROM],eax

          mov     eax,[AllSectorCDROM]
          mov     [TekSectorCDROML],eax

          mov     [TekSectorCDROMH],144-64

          mov     si,offset MesFullSeekCDROM
          call    ColorStr6x8

          call    SeekToSector0

NextCDSectorForFullSeekTime:

          call    ZamerCDROMSeek

          inc     [KolihProhodov]
          add     [TotalResultSpeedL],eax
          adc     [TotalResultSpeedH],0
          mov     ebx,512
          dec     [TekSectorCDROML]
          dec     [TekSectorCDROMH]
          mov     eax,[TotalResultSpeedL]
          mov     edx,[TotalResultSpeedH]
          div     [KolihProhodov]
          xor     edx,edx
          div     [BasicDivadeL]

          mov     [TekushSeekCDROM],eax
          mov     cx,3
          mov     di,offset NumFullSeekTestCDROMH
          call    BinToAscDec2
          mov     si,offset NumFullSeekTestCDROM
          call    ColorStr6x8


          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      CDErrExit
          cmp     al,' '
          jnz     short NotStopTestCDROMForFullSeekTime
          mov     ax,4E07h
          call    CursorPos
          mov     si,offset MesCDSkipped
          call    ColorStr6x8
          call    Setka
          jmp     short SkipTestCDROMForFullSeekTime
NotStopTestCDROMForFullSeekTime:
          cmp     [KolihProhodov],64
          jnz     NextCDSectorForFullSeekTime

          mov     si,offset CDResBuff
          mov     cl,[DefaultDrive]
          cmp     cl,3
          ja      short CDTestFullSeekWasSkipped
          mov     al,10*4
          mul     cl
          add     si,ax
          mov     eax,[TekushSeekCDROM]
          mov     [dword ds:si+33],eax
CDTestFullSeekWasSkipped:


SkipTestCDROMForFullSeekTime:
DetectFastTestForRandomAccessTime:

;*********** Тест позиционирования CDROM **********
SeekTestCDROM:

          call    SeekToSector0

          cmp     [DetSMARTdrv],1
          jnz     short SMartDRVNot3
          mov     ax,4A10h
          mov     bx,2
          int     2Fh
SMartDRVNot3:
          cmp     [Method],0
          jnz     short DetectFullTest
          call    ClearWindowMesages
          mov     [word ds:NumFullTestHDD],'C '
          call    PrnFFullTest
          jz      GoToTestCDROM
          jmp     CDNormalExit

DetectFullTest:
          cmp     [AllSectorCDROM],305152
          jae     short SizeOk
          mov     si,offset InposibleCDTEST
          call    ColorStr6x8
          mov     si,offset SmallCD
          call    ColorStr6x8
          jmp     CDNormalExit

SizeOk:   cmp     [TotalError],1
          ja      short ErrorCDROM
          cmp     [TotalUnstab],6
          jbe     short NoErrorCDROM
ErrorCDROM:
          mov     si,offset InposibleCDTEST
          call    ColorStr6x8
          mov     si,offset ErrorCD
          call    ColorStr6x8
          jmp     CDNormalExit
NoErrorCDROM:
          mov     [SectorsRead],1
          xor     eax,eax
          mov     [KolihProhodov],eax
          mov     [HorKoord],ax
          mov     [BasicDivadeL],12    ;Для калибровки CDROM Seek
          mov     ax,318
          mov     bx,287
          mov     cx,238
          mov     dx,18
          sub     bp,bp
          call    Rectangle
          mov     si,offset MesCheckAccessTime
          call    ColorStr6x8
;******* Вычисление масштаба CDROM Seek ***********
          xor     eax,eax
          mov     [TekSectorCDROML],eax
          mov     [TotalResultSpeedL],eax
          mov     [TotalResultSpeedH],eax
          mov     [TekushSeekCDROM],eax
          mov     [TekSectorCDROML],512
          mov     eax,305152
          mov     [TekSectorCDROMH],eax
NextCDSectorForZamer:
          call    ZamerCDROMSeekForMashtab
          mov     [RealResultSpeed],eax
          inc     [KolihProhodov]
          add     [TotalResultSpeedL],eax
          adc     [TotalResultSpeedH],0
          mov     eax,512
          add     [TekSectorCDROML],eax
          sub     [TekSectorCDROMH],eax
          cmp     [KolihProhodov],8
          jnz     short NextCDSectorForZamer

          mov     eax,[TotalResultSpeedL]
          mov     edx,[TotalResultSpeedH]
          div     [KolihProhodov]

          mov     ebx,500
          sub     edx,edx
          div     ebx
          mov     ebx,10
          sub     edx,edx
          div     ebx
          mul     ebx
          add     eax,ebx
          mov     si,ax
          mov     ebx,312
          mul     ebx
          mov     ebx,100
          sub     edx,edx
          div     ebx
          mov     ebx,eax
GoToSeekTestCDROM:
          mov     [ResultSeekMashtab],si
          mov     [DivMastabCDROM],ebx
          call    GetSeekMashtab

;**********  Начало тестирования CDROM Seek ***********
          cmp     [DetSMARTdrv],1
          jnz     short SMartDRVNot6
          mov     ax,4A10h
          mov     bx,2
          int     2Fh
SMartDRVNot6:
          mov     ax,318
          mov     bx,287
          mov     cx,238
          mov     dx,18
          sub     bp,bp
          call    Rectangle

          mov     si,offset MesMs
          call    ColorStr6x8
          mov     si,offset MesSectorAllSec
          call    ColorStr6x8
          call    MastabSpeedCDROM
          mov     si,offset MesSeekTestCDROM
          call    ColorStr6x8

          xor     eax,eax
          mov     [KolihProhodov],eax
          mov     [TotalResultSpeedL],eax
          mov     [TotalResultSpeedH],eax
          mov     eax,152576
          mov     [TekSectorCDROML],eax
          mov     [TekSectorCDROMH],eax
          mov     [CDROMSeekColor],4+8
NextCDSectorSeek:
          call    ZamerCDROMSeek

          mov     [RealResultSpeed],eax
          inc     [KolihProhodov]
          add     [TotalResultSpeedL],eax
          adc     [TotalResultSpeedH],0
          mov     eax,[TotalResultSpeedL]
          mov     edx,[TotalResultSpeedH]
          div     [KolihProhodov]
          xor     edx,edx
          div     [BasicDivadeL]

          mov     [TekushSeekCDROM],eax
          mov     cx,3
          mov     di,offset NumSeekTestCDROMH
          call    BinToAscDec2
          mov     si,offset NumSeekTestCDROM
          call    ColorStr6x8

          call    GrafikCDROMSeek

          mov     ax,[TekuhPointVert]
          mov     [OldTekuhPointVert],ax
          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      CDErrExit
          cmp     al,' '
          jnz     short NotStopTestCDROMSeek
          mov     ax,4E08h
          call    CursorPos
          mov     si,offset MesCDSkipped
          call    ColorStr6x8
          mov     ax,0335h
          call    CursorPos
          mov     si,offset MesCDSkipped
          call    ColorStr6x8
          mov     [CDtestSkipped],1
          call    Setka
          mov     [CDtestSkipped],1
          jmp     short SkipTestCDROMSeek
NotStopTestCDROMSeek:
          mov     eax,512
          sub     [TekSectorCDROML],eax
          add     [TekSectorCDROMH],eax
          cmp     [KolihProhodov],299
          jnz     NextCDSectorSeek

          mov     si,offset CDResBuff
          mov     cl,[DefaultDrive]
          cmp     cl,3
          ja      short SkipTestCDROMSeek
          mov     al,10*4
          mul     cl
          add     si,ax
          mov     eax,[TekushSeekCDROM]
          mov     [dword ds:si+16],eax

SkipTestCDROMSeek:

;******** Обработка результатов тестирования CDROM *********

          call    MastabSpeedCDROM
          mov     si,[ResultSeekMashtab]
          call    GetSeekMashtab

          cmp     [CDtestSkipped],1
          jz      short SkipCDcompareRes
          mov     eax,[TekushSpeedCDGrp]
          mov     ebx,786
          mul     ebx
          div     [TekushSeekCDROM]

          mov     si,offset CDResBuff
          mov     cl,[DefaultDrive]
          cmp     cl,3
          ja      short SkipGetCDIndex
          push    eax
          mov     al,10*4
          mul     cl
          add     si,ax
          pop     eax
          mov     [dword ds:si+21],eax
SkipGetCDIndex:

          mov     di,offset NumHDDSpeedH
          mov     cx,4
          call    BinToAscDec2
          xor     edx,edx
          mov     ebx,100     ;Два знака после запятой
          div     ebx
          or      eax,eax
          jnz     short NotZeroInCDspeed
          inc     eax
NotZeroInCDspeed:
          call    Skale
          mov     [CompareGraph],ax
          call    PrnCompareWindow
          mov     si,offset NumHDDSpeed
          call    ColorStr6x8
          mov     si,offset MesCDTest
          call    ColorStr6x8
          call    PrintSravnenieCD
SkipCDcompareRes:

          jmp     CDNormalExit
;*********************************************************
;******       Завершение работы программы        *********
;*********************************************************
CDNormalExit:
          call    ClearWindowMesages
          mov     si,offset MesTestComplete
          call    ColorStr6x8

          jmp     short NormalExit
VTOCError:
          call    ClearWindowMesages
          mov     si,offset MesVTOCErr
          call    ColorStr6x8
          jmp     short NormalExit
NoExit:
          call    GetCh
CDErrExit:
          call    ClearWindowMesages
          mov     si,offset MesTestCancel
          call    ColorStr6x8

NormalExit:
          call    ClearWindowMesages2
          cmp     [CreatePCX],1
          mov     si,offset MesPressR
          jz      short CreatePCXforMes
          cmp     [CreateREP],1
          jnz     short NotCreatePCXforMes
CreatePCXforMes:
          mov     si,offset MesPressAnyKey
NotCreatePCXforMes:
          call    ColorStr6x8

NewCheckKey:
          call    ClearWindowMesages3

          mov     al,[PCICounter]
          or      al,[ISAPnPCounter]
          jz      short GoToDetectPressM
          mov     si,offset MesPressIM
          cmp     [NumberDIMMModules],0
          jnz     short GoToPrnPressKeyMes
          cmp     [ErrConfig],0
          jz      short GoToPrnPressKeyMes
          mov     al,[PCICounter]
          or      al,[ISAPnPCounter]
          jz      short GoToWaitPressM
          mov     si,offset MesPressI
          jmp     short GoToPrnPressKeyMes
GoToDetectPressM:
          mov     si,offset MesPressM
          cmp     [NumberDIMMModules],0
          jnz     short GoToPrnPressKeyMes
          cmp     [ErrConfig],0
          jz      short GoToPrnPressKeyMes
          jmp     short GoToWaitPressM

GoToPrnPressKeyMes:
          call    ColorStr6x8

GoToWaitPressM:
          call    GetCh
          cmp     ax,0120h; space
          jz      HDDTestStart
          cmp     al,1Bh
          jz      PcxAndRepCreatedInComandLine
          or      al,32
          cmp     ax,016dh; m or M
          jz      short GetMemoryInfo
          cmp     ax,0169h; i or I
          jz      short GetPCIListReport
          cmp     [CreatePCX],1
          jz      short CanNotWaitPresP
CanNotWaitPresP:
          cmp     [CreateREP],1
          jz      short CanNotWaitPresR
          cmp     ax,0172h; r or R
          jz      short GoToCreateREP
CanNotWaitPresR:
ToNewCheckKey:
          jmp     short NewCheckKey

GetMemoryInfo:
          cmp     [NumberDIMMModules],0
          jnz     short GoToPrintMemMap
          cmp     [ErrConfig],0
          jnz     short ToNewCheckKey
GoToPrintMemMap:
          call    PrintMemMap
          mov     [BadDownScr],1
          jmp     NewCheckKey
GetPCIListReport:
          mov     bl,[PCICounter]
          or      bl,[ISAPnPCounter]
          jz      short ToNewCheckKey
          call    PCIList
          mov     [BadDownScr],1
          jmp     short ToNewCheckKey
CreateREPDone:

          call    ClearWindowMesages
          mov     si,offset MesReportOK
          call    ColorStr6x8
NotClearIfErr:

          cmp     [CreateQuickRep],1
          jz      Exit
          mov     si,offset MesPressSpace
          call    ColorStr6x8
WaitNextSimvolForMenu:
          call    GetCh
          cmp     al,1Bh
          jz      Exit
          cmp     ax,0120h; space
          jnz     short WaitNextSimvolForMenu
          jmp     HDDTestStart

MakeQuickREP:
          jmp     short GoToCreateReport

GoToCreateREP:


          call    ClearWindowMesages
          mov     si,offset MesPressC
          call    ColorStr6x8

WaitNextSymbForRep:
          call    GetCh
          cmp     al,0Dh; enter
          jz      short GoToCreateReport
          cmp     al,1Bh  ;Esc
          jz      short GoToCreateReport

          or      al,32
          cmp     ax,0163h; c or C
          jnz     short NoAddComments
          call    ClearWindowMesages
          mov     si,offset MesMax36Chars
          call    ColorStr6x8
          mov     [NumMaxChars],36
          call    AddCommentsToReport
          mov     si, offset NumCommentsBuf
          mov     di,offset NumComments
          mov     cx,36
          cld
          rep movsb

          jmp     short WaitNextSymbForRep
NoAddComments:
          cmp     ax,0173h; s or S
          jnz     short WaitNextSymbForRep
          call    ClearWindowMesages
          mov     si,offset MesMax8Chars
          call    ColorStr6x8
          mov     [NumMaxChars],8
          call    AddCommentsToReport
          mov     si, offset NumCommentsBuf
          cmp     [byte ds:si],0
          jz      short EndCreateAndCheckFName
          mov     di, offset NumFileName
          mov     [dword ds:di],'    '
          mov     [dword ds:di+4],'    '
          mov     cx,8
          cld
NextSymbolFNameCheck:
          lodsb
          or      al,al
          jz      short EndCreateAndCheckFName
          cmp     al,' '
          jz      short EndCreateAndCheckFName
          stosb
          dec     cx
          jnz     short NextSymbolFNameCheck
EndCreateAndCheckFName:

          jmp     short WaitNextSymbForRep

GoToCreateReport:
          mov     bp,1
NextOpenReportFileTest:
          mov     ax,bp
          mov     cx,2
          mov     di,offset NumReportFileName
          call    BinToAscDec
          mov     ax,bp
          mov     di,offset NumPCXFileName
          call    BinToAscDec


          cmp     [NumFileName],0
          jz      FileNameNotSet
          mov     si,offset NumFileName
          mov     di,offset AutoPCXFileName
          mov     cx,8
          cld
          rep movsb
          mov     si,offset NumFileName
          mov     di,offset AutoReportFileName
          mov     cx,8
          cld
          rep movsb
;AutoPCXFileName    DB 'sstimg'
;NumPCXFileName     DB 2 DUP(0),'.pcx',0
;AutoReportFileName DB 'sstrep'
;NumReportFileName  DB 2 DUP(0),'.txt',0


FileNameNotSet:

          mov     dx,offset AutoReportFileName
          mov     ax,3D02h
          int     21h
          jc      short ReportFileNotFound
          mov     bx,ax
          mov     ah,3Eh
          int     21h
          jmp     short FaundReportFile
ReportFileNotFound:

          cmp     [CreateQuickRep],1
          jz      short AllReportFileNotFound

          mov     dx,offset AutoPCXFileName
          mov     ax,3D02h
          int     21h
          jc      short AllReportFileNotFound
          mov     bx,ax
          mov     ah,3Eh
          int     21h

FaundReportFile:

          inc     bp
          cmp     bp,100
          jz      short PCXReportFileErr
          jmp     short NextOpenReportFileTest
AllReportFileNotFound:
          mov     dx,offset AutoReportFileName
          mov     ax,3C00h; Попробовать создать файл отчета
          xor     cx,cx   ; с указанным именем ( проводками)
          int     21h
          mov     [FileHandleREP],ax
          jc      short TXTReportFileErr
          mov     dx,offset AutoReportFileName
          mov     [FileNameREP],dx
          call    GetTimeForReport
          call    CreateReportFile
          jc      short TXTReportFileErr

          cmp     [CreateQuickRep],1
          jz      CreateREPDone

          mov     dx,offset AutoPCXFileName
          mov     ax,3C00h          ; Попробовать создать PCX файл
          xor     cx,cx
          int     21h
          mov     [FileHandle],ax
          jc      short PCXReportFileErr
          mov     dx,offset AutoPCXFileName
          mov     [FileName],dx
          call    GetTimeForReport
          call    ClearWindowMesages2
          mov     si, offset NumComments
          cmp     [byte ds:si+2],0
          jz      NoComentsInRep
          push    si
          mov     si, offset MesComments
          call    ColorStr6x8
          pop     si
          call    ColorStr6x8
NoComentsInRep:

          call    CreatePCXfile

          jnc     CreateREPDone

PCXReportFileErr:
          call    ClearWindowMesages
          mov     si,offset MesErrPCX
          call    ColorStr6x8
          jmp     NotClearIfErr
TXTReportFileErr:
          call    ClearWindowMesages
          mov     si,offset MesErrReport
          call    ColorStr6x8
          jmp     NotClearIfErr

PcxAndRepCreatedInComandLine:
          cmp     [CreatePCX],1
          jnz     short NoCreatePCXInComLine
          call    GetTimeForReport
          call    CreatePCXfile
          jc      PCXReportFileErr
          cmp     [CreateREP],1
          jz      short NoCreatePCXInComLine
          jmp     short Exit

NoCreatePCXInComLine:
          cmp     [CreateREP],1
          jnz     short Exit
          call    GetTimeForReport
          call    CreateReportFile
          jc      short TXTReportFileErr

ErrDivExit:
Exit:
          mov     al,[video]
          xor     ah,ah
          int     10h
          call    RestoreInterrupt
          mov     ax, 4C00h
          int     21h

;*******************************************
;**       КОНЕЦ ПРОГРАММЫ       ************
;*******************************************
PROC ErrorDiv
          call    MesagesFrame
          call    ClearWindowMesages
          mov     si,offset MesErrDiv
          call    colorstr6x8
          call    GetCh
          jmp     short errdivexit
ENDP ErrorDiv

PROC GetNumFromWin32
          smsw    ax
          shr     al,1
          jnc     FileResTmpNotFoundGetCh
          cmp     [WinPres],1
          jz      short WindowsDetected
          cmp     [WinNTPres],1
          jnz     FileResTmpNotFoundGetCh
WindowsDetected:

          mov    si,offset Win32PrgBuff+8
          mov    cx,[word ds:Win32PrgBuff]
          call   Encoding

          mov    si,offset Win32PrgBuff+8
          mov    cx,[word ds:Win32PrgBuff]
LookFor2and3IDEBasePort:
          cmp    [dword ds:si],017001F0h
          jz     short Faind2and3IDEBasePort
          inc    si
          loop   short LookFor2and3IDEBasePort
          jmp    short End2and3IDEBasePort
Faind2and3IDEBasePort:
          mov    eax,[dword ds:IDE2BaseIO]
          cmp    ax,01E8h
          jz     short End2and3IDEBasePort
          mov    [dword ds:si+4],eax
End2and3IDEBasePort:

          mov     dx,offset NumNameResTmp
          mov     [Extension],'EXE.'
          mov     ah,3Ch
          sub     cx,cx
          int     21h
          jc      FileResTmpNotFoundGetCh ;can not create
          mov     bx,ax ;write w32prg
          mov     ah,40h
          mov     cx,[word ds:Win32PrgBuff]
          mov     dx,offset Win32PrgBuff+8
          int     21h
          jc      FileResTmpNotFoundGetCh ;can not create
          mov     ah,3Eh ;close
          int     21h

          mov     ax,sp
          mov     [StackOfs],ax
          mov     ax,ss
          mov     [StackSeg],ax

          mov     dx,offset CommLine
          mov     [word ds:Parm2],dx
          mov     ax,ds
          mov     [word ds:Parm2+2],ax
          mov     dx,offset Fcb1
          mov     [word ds:Parm3],dx
          mov     ax,ds
          mov     [word ds:Parm3+2],ax
          mov     dx,offset Fcb2
          mov     [word ds:Parm4],dx
          mov     ax,ds
          mov     [word ds:Parm4+2],ax

          mov     dx,offset NumNameResTmp
          mov     bx,offset ParamBlock
          mov     ax,4B00h
          int     21h
          mov     ax,Dseg
          mov     ds,ax
          mov     es,ax
          cli
          mov     sp,[StackOfs]
          mov     ss,[StackSeg]
          sti

          call    Wait4Tics

          mov     dx,offset NumNameResTmp
          mov     ah,41h
          xor     cx,cx
          int     21h

          call    Wait3SecKeyWaiting

          mov     dx,offset NumNameResTmp
          mov     [Extension],'PMT.'

          mov     ax,3D02h
          int     21h
          jc      short NotDetectWin32InfoCorectly
          mov     bx,ax
          sub     cx,cx
          sub     dx,dx
          mov     ax,4200h
          int     21h
          mov     ah,3Fh
          mov     cx,SSTRESTMPSize
          push    cx
          mov     dx,offset SSTLabel
          push    dx
          int     21h
          pop     si
          pop     cx
          push    cx
          call    Encoding
          pop     cx
          cmp     [SSTLabel],'_TSS'
          jz      short DetectWin32InfoCorectly
          mov     di,offset SSTLabel
          sub     al,al
          rep stosb
DetectWin32InfoCorectly:
          mov     eax,[MHzTSCFull]
          or      eax,eax
          jz      short NotDetectWin32InfoCorectly
          sub     edx,edx
          mov     ebx,100
          div     ebx
          cmp     dx,50
          jb      short NoBig50FromWin
          inc     ax
NoBig50FromWin:
          mov     [MHzTSC],ax

NotDetectWin32InfoCorectly:

          mov     dx,offset NumNameResTmp
          mov     ah,41h
          xor     cx,cx
          int     21h
          ret
FileResTmpNotFoundGetCh:
          cmp     [PressAnyKeyEngNeeded],1
          jnz     short NotMesageFound

          call    GetCh

NotMesageFound:
          ret
ENDP GetNumFromWin32

PROC GetTimeForReport
          call    GetDateAndTime
          call    PrintDateTime
          call    ClearWindowMesages
          mov     si,offset MesPCXRepFile
          call    ColorStr6x8
          mov     si,offset NumDay
          call    ColorStr6x8
          mov     si,offset MesHour
          call    ColorStr6x8
          ret
ENDP GetTimeForReport

PROC CreateReportFile
          push    ds
          push    es
          mov     [CounterRepBuf],0
          call    PrnRepLine
          mov     si,offset MesRepFile
          call    PutToReportBuf
          mov     si,offset NumDay
          call    PutToReportBuf
          mov     si,offset MesHour
          call    PutToReportBuf
          call    PrnRepLine


          mov     si, offset NumComments
          cmp     [byte ds:si+2],0
          jz      NoComentsInTxtRep
          push    si
          mov     si, offset MesRepComments
          call    PutToReportBuf
          pop     si
          call    PutToReportBuf
NoComentsInTxtRep:


          mov     si,offset ComputerName
          cmp     [byte ds:si],0
          jz      short ComputerNameNotDetect
          push    si
          mov     si,offset MesRepComputerName
          call    PutToReportBuf
          pop     si
          call    PutToReportBuf
ComputerNameNotDetect:

          mov     si,offset UserName
          cmp     [byte ds:si],0
          jz      short UserNameNotDetect
          push    si
          mov     si,offset MesRepUserName
          call    PutToReportBuf
          pop     si
          call    PutToReportBuf
UserNameNotDetect:

          mov     si,offset MesRepV86Mode
          call    PutToReportBuf
          mov     si,offset MesRepYes
          smsw    ax
          shr     al,1
          jc      short RealModeDetectedForRep
          mov     si,offset MesRepNo
RealModeDetectedForRep:
          call    PutToReportBuf

          mov     si,offset MesRepCPU
          call    PutToReportBuf
          mov     si,[NumRepCPUVendor]
          call    PutToReportBuf
          mov     si,[NumRepCPUModel]
          call    PutToReportBuf
          mov     si,offset Hastota
          call    PutToReportBuf

          call    GetOrigClockForRep

          cmp     [MhzTSC],0
          jz      CanNotDetectFrecViaTSC
          mov     si,offset MesRepMhzViaRDTSC
          call    PutToReportBuf
          mov     eax,[MHzTSCFull]
          mov     cx,4
          mov     di,offset NumMhzViaRDTSC
          call    BinToAscDec2
          mov     si,offset NumMhzViaRDTSC
          call    NonZeroPrn
          call    PutToReportBuf

          mov     eax,[Overclocking]
          or      eax,eax
          jz      short NotOverclockedForRep
          mov     si,offset MesRepOverclocking
          call    PutToReportBuf
          mov     cx,4
          mov     di,offset NumRepOverclocking
          call    BinToAscDec2
          mov     si,offset NumRepOverclocking
          call    NonZeroPrn
          call    PutToReportBuf

NotOverclockedForRep:

          cmp     [ClockRatio],0
          jz      short CanNotDetectClockRatio
          mov     si,offset MesRepExternClock
          call    PutToReportBuf

          cmp     [IntelProcessor],1
          jnz     short NotP4CPUForPrnExternalFrecForRep
          cmp     [CPUFamily],0Fh
          jnz     short NotP4CPUForPrnExternalFrecForRep
          cmp     [IntelExtendedFamily],0
          jnz     short NotP4CPUForPrnExternalFrecForRep
          mov     si,offset MesQDRClock
          jmp     short PrnQDRClockForRep

          cmp     [AMDProcessor],1
          jnz     short NotAMDCPUForRepExternalFrec
          cmp     [word ds:CPUmodel],256*6+4
          ja      short NotAMDCPUForRepExternalFrec
          cmp     [word ds:CPUmodel],256*6
          jb      short NotAMDCPUForRepExternalFrec
          mov     si,offset MesDDRClock
PrnQDRClockForRep:
          call    NonZeroPrn
          call    PutToReportBuf
          mov     si,offset MesExtClock
          call    NonZeroPrn
          call    PutToReportBuf
          mov     si,offset NumRatio
          call    NonZeroPrn
          call    PutToReportBuf

          mov     al,')'
          call    PutByteToReportBuf
          jmp     short CanNotDetectClockRatio

NotP4CPUForPrnExternalFrecForRep:
NotAMDCPUForRepExternalFrec:
          mov     si,offset MesExtClock
          call    NonZeroPrn
          call    PutToReportBuf
          mov     si,offset NumRatio
          call    NonZeroPrn
          call    PutToReportBuf
CanNotDetectClockRatio:
CanNotDetectFrecViaTSC:

          cmp     [CPUIDLevelSupport],1
          jb      CPUIDNotSupportForRep
          mov     si,offset MesRepCPUID
          call    PutToReportBuf
          mov     si,offset NumCPUtype
          call    PutToReportBuf
          mov     al,' '
          call    PutByteToReportBuf
          mov     si,offset MesCodeName
          call    PutToReportBuf
          mov     si,[NumRepCodeName]
          call    PutToReportBuf


          mov     al,[BrandID]
          or      al,al
          jz      short BrandIDNotSupported
          sub     ah,ah
          mov     di,offset NumRepBrandID
          mov     cx,2
          call    BinToAscHex
          mov     si,offset MesRepBrandID
          call    PutToReportBuf
BrandIDNotSupported:

          mov     eax,[MSR00000017edx]
          or      eax,eax
          jnz     short GoToDetectPlatformID
          mov     eax,[Win32MSR00000017edx]
          or      eax,eax
          jz      short PlatformIDNotSupport

GoToDetectPlatformID:
          mov     si,offset MesRepPlatformID
          call    PutToReportBuf
          shr     eax,12h
          and     al,111b
          cmp     [CPUfamily],06h
          jz      short DetectP6FamForRepPlatformID
          cmp     [CPUfamily],0Fh
          jnz     short NoExtendedFamForRepPlatformID
          cmp     [IntelExtendedFamily],0
          jz      short IntelP4ProcesorForRepPlatformID
NoExtendedFamForRepPlatformID:

          jmp     short PlatformIDNotSupport

DetectP6FamForRepPlatformID:
          mov     si,offset MesRepSlot1
          or      al,al
          jz      short PrnDetectRepPlatformID
          mov     si,offset MesRepSlot2
          cmp     al,2
          jz      short PrnDetectRepPlatformID
          mov     si,offset MesRepMobileBGA2
          cmp     al,3
          jz      short PrnDetectRepPlatformID
          cmp     al,4
          jnz     short NotSocket370PGAorFCPGA
          mov     si,offset MesRepSocket370fcpga2
          cmp     [CPUmodel],0Bh
          jae     short PrnDetectRepPlatformID
          mov     si,offset MesRepSocket370fcpga
          cmp     [CPUmodel],8
          jae     short PrnDetectRepPlatformID
          mov     si,offset MesRepSocket370pga
          jmp     short PrnDetectRepPlatformID

NotSocket370PGAorFCPGA:
          mov     si,offset MesRepMobileuPGA2
          cmp     al,5
          jz      short PrnDetectRepPlatformID
          mov     si,offset CPUIDunknown
          jmp     short PrnDetectRepPlatformID

IntelP4ProcesorForRepPlatformID:
          mov     si,offset MesRepSocket478
          cmp     al,2
          jz      short PrnDetectRepPlatformID
          mov     si,offset CPUIDunknown
PrnDetectRepPlatformID:
          call    PutToReportBuf

PlatformIDNotSupport:


          mov     eax,[Win32MicrocodeRev]
          or      eax,eax
          jnz     short Win32MicrocodeRevDetected
          mov     eax,[MicrocodeRev]
          or      eax,eax
          jz      short MicrocodeRevNotDetect
Win32MicrocodeRevDetected:
          dec     eax
          mov     cx,4
          mov     di,offset NumRepMicrocodeRev+4
          call    BinToAscHex
          shr     eax,16
          mov     di,offset NumRepMicrocodeRev
          call    BinToAscHex
          mov     si,offset MesRepMicrocodeRev
          call    PutToReportBuf
          mov     si,offset NumRepMicrocodeRev
          call    NonZeroPrn
          call    PutToReportBuf

MicrocodeRevNotDetect:

          mov     si,offset MesRepFeatureReg
          call    PutToReportBuf
          mov     si,offset NumFeatureRegH
          call    PutToReportBuf

          mov     ax,'  '
          call    PutWordToReportBuf

          mov     si,offset MesMMXno
          cmp     [FeatureFlagMMX],1
          jnz     short FeatureFlagMMXForRepNotSupport
          mov     si,offset MesMMXyes
FeatureFlagMMXForRepNotSupport:
          call    PutToReportBuf
          mov     ax,' ,'
          call    PutWordToReportBuf
          mov     si,offset MesSSEno
          cmp     [FeatureFlagSSE],1
          jnz     short FeatureFlagSSEForRepNotSupport
          mov     si,offset MesSSEyes
FeatureFlagSSEForRepNotSupport:
          call    PutToReportBuf
          mov     ax,' ,'
          call    PutWordToReportBuf
          mov     si,offset MesSSE2no
          cmp     [FeatureFlagSSE2],1
          jnz     short FeatureFlagSSE2ForRepNotSupport
          mov     si,offset MesSSE2yes
FeatureFlagSSE2ForRepNotSupport:
          call     PutToReportBuf

          cmp     [IntelProcessor],1
          jnz     NotIntelCPUForGetCacheInfoRep
          mov     ax,[CacheL1]
          or      ax,ax
          jz      short NotIntelL1CacheInfo
          mov     cx,5
          mov     di,offset NumRepCache
          call    BinToAscDec
          mov     [NumRepCacheNumber],'1'
          mov     si,offset MesRepCache
          call    PutToReportBuf
          mov     si,offset NumRepCache
          call    NonZeroPrn
          call    PutToReportBuf
NotIntelL1CacheInfo:
          mov     ax,[CacheL2]
          or      ax,ax
          jz      short NotIntelL2CacheInfo
          mov     cx,5
          mov     di,offset NumRepCache
          call    BinToAscDec
          mov     [NumRepCacheNumber],'2'
          mov     si,offset MesRepCache
          call    PutToReportBuf
          mov     si,offset NumRepCache
          call    NonZeroPrn
          call    PutToReportBuf

          mov     eax,[MSR0000011E]
          or      eax,eax
          jnz     short FainInfoMSR11ERep
          mov     eax,[Win32MSR0000011E]
FainInfoMSR11ERep:
          shr     ax,1
          and     ax,1111b
          or      ax,ax
          jz      short L2CacheLatencyNotDetectRep
          mov     cx,1
          mov     di,offset NumRepL2Latency
          call    BinToAscHex
          mov     si,offset MesRepL2Latency
          call    PutToReportBuf

L2CacheLatencyNotDetectRep:

NotIntelL2CacheInfo:
          mov     ax,[CacheL3]
          or      ax,ax
          jz      short NotIntelL3CacheInfo
          mov     cx,5
          mov     di,offset NumRepCache
          call    BinToAscDec
          mov     [NumRepCacheNumber],'3'
          mov     si,offset MesRepCache
          call    PutToReportBuf
          mov     si,offset NumRepCache
          call    NonZeroPrn
          call    PutToReportBuf
NotIntelL3CacheInfo:

          cmp     [FeatureFlagSN],1
          jnz     short NotSupportSN
          mov     si,offset MesRepSN
          call    PutToReportBuf
          mov     cx,4
          mov     ax,[word ds:CPUSerialNumberEAX+2]
          mov     di,offset NumCPUSerialNumberEAXH
          call    BinToAscHex
          mov     ax,[word ds:CPUSerialNumberEAX]
          mov     di,offset NumCPUSerialNumberEAXL
          call    BinToAscHex

          mov     ax,[word ds:CPUSerialNumberEDX+2]
          mov     di,offset NumCPUSerialNumberEDXH
          call    BinToAscHex
          mov     ax,[word ds:CPUSerialNumberEDX]
          mov     di,offset NumCPUSerialNumberEDXL
          call    BinToAscHex

          mov     ax,[word ds:CPUSerialNumberECX+2]
          mov     di,offset NumCPUSerialNumberECXH
          call    BinToAscHex
          mov     ax,[word ds:CPUSerialNumberECX]
          mov     di,offset NumCPUSerialNumberECXL
          call    BinToAscHex
          mov     si,offset NumCPUSerialNumberEAXH
          call    PutToReportBuf
NotSupportSN:

          call    RepGetCPUNameString
          jmp     SkipDetectionExtendedCPUID
NotIntelCPUForGetCacheInfoRep:

          cmp     [TransmetaProcessor],1
          jnz     short NotTransmetaCPUForRepNameString

          call    RepGetCPUNameString

          jmp     SkipDetectionExtendedCPUID
NotTransmetaCPUForRepNameString:

          cmp     [ExtCPUIDLevelSupport],80000001h
          jb      ExtCPUIDNotSupportForRep
          xor     ah,ah
          mov     cx,1
          mov     al,[ExtCPUtype]
          mov     di,offset ExtNumCPUtype
          call    BinToAscHex
          xor     ah,ah
          mov     al,[ExtCPUfamily]
          mov     di,offset ExtNumCPUfamily
          call    BinToAscHex
          xor     ah,ah
          mov     al,[ExtCPUmodel]
          mov     di,offset ExtNumCPUmodel
          call    BinToAscHex
          xor     ah,ah
          mov     al,[ExtCPUstepping]
          mov     di,offset ExtNumCPUstepping
          call    BinToAscHex
          mov     si,offset MesExtCPUparam
          call    PutToReportBuf

          call    RepGetCPUNameString

          mov     cx,4
          mov     ax,[word ds:ExtFeatureFlag+2]
          mov     di,offset NumExtFeatureRegH
          call    BinToAscHex
          mov     ax,[word ds:ExtFeatureFlag]
          mov     di,offset NumExtFeatureRegL
          call    BinToAscHex
          mov     si, offset MesRepExtFeature
          call    PutToReportBuf

          mov     ax,'  '
          call    PutWordToReportBuf
          mov     si,offset MesAMD3Dno
          cmp     [FeatureFlagAMD3D],1
          jnz     short FeatureFlagAMD3DForRepNotSupport
          mov     si,offset MesAMD3Dyes
FeatureFlagAMD3DForRepNotSupport:
          call    PutToReportBuf

          mov     ax,' ,'
          call    PutWordToReportBuf

          cmp     [FeatureFlagAMD3DExt],1
          mov     si,offset MesAMD3DExtNo
          jnz     short FeatureFlagAMD3DExtForRepNotSupport
          mov     si,offset MesAMD3DExtYes
FeatureFlagAMD3DExtForRepNotSupport:
          call    PutToReportBuf

          cmp     [AMDProcessor],1
          jnz     short NotAMDCPUForGetCacheInfoRep
          mov     ax,[CacheL1]
          or      ax,ax
          jz      short NotAMDCPUForGetCacheInfoRep
          mov     cx,5
          mov     di,offset NumRepCache
          call    BinToAscDec
          mov     [NumRepCacheNumber],'1'
          mov     si,offset MesRepCache
          call    PutToReportBuf
          mov     si,offset NumRepCache
          call    NonZeroPrn
          call    PutToReportBuf
          mov     ax,[CacheL2]
          or      ax,ax
          jz      short NotAMDCPUForGetCacheInfoRep
          mov     cx,5
          mov     di,offset NumRepCache
          call    BinToAscDec
          mov     [NumRepCacheNumber],'2'
          mov     si,offset MesRepCache
          call    PutToReportBuf
          mov     si,offset NumRepCache
          call    NonZeroPrn
          call    PutToReportBuf

NotAMDCPUForGetCacheInfoRep:
ExtCPUIDNotSupportForRep:
SkipDetectionExtendedCPUID:

CPUIDNotSupportForRep:

          cmp     [MSRC0000082],0
          jz      short NotAMDk62ForRepWriteAlloc
          mov     si,offset MesRepWriteAloc
          call    PutToReportBuf
          test    [MSRC0000082],10000h
          mov     si,offset MesAGPDisabled
          jz      short WriteAlocIsDisabled
          mov     si,offset MesAGPEnabled
WriteAlocIsDisabled:
          call     PutToReportBuf
NotAMDk62ForRepWriteAlloc:

          cmp     [Win32MSRC0000082],0
          jz      short NotAMDk62ForRepWriteAllocWin32
          mov     si,offset MesRepWriteAloc
          call    PutToReportBuf
          test    [Win32MSRC0000082],10000h
          mov     si,offset MesAGPDisabled
          jz      short WriteAlocIsDisabledWin32
          mov     si,offset MesAGPEnabled
WriteAlocIsDisabledWin32:
          call    PutToReportBuf
NotAMDk62ForRepWriteAllocWin32:

          mov     si,offset NumCpuSpeedH
          cmp     [dword ds:si],0
          jz      short CanNotGetCPUspeed
          push    si
          mov     si,offset MesRepCPUbench
          call    PutToReportBuf
          pop     si
          call    NonZeroPrn
          call    PutToReportBuf
CanNotGetCPUspeed:

          mov     si,offset MesRepMemorySize
          call    PutToReportBuf
          mov     si,offset TotalMem
          call    NonZeroPrn
          call    PutToReportBuf

          mov     eax,[SPDAllMemType]
          or      eax,eax
          jz      short SPDMemModuleNotFoundForRep
          push    eax
          mov     ax,'( '
          call    PutWordToReportBuf
          pop     eax
          mov     cx,32
          mov     bx,offset NumAdrSPDMemBuf
NextBitSPDMemTypeToTestForRep:
          shr     eax,1
          jnc     short SPDMemTypeBitNotSetForRep
          mov     si,[word ds:bx]
          inc     si
          call    PutToReportBuf
          or      eax,eax
          jz      short SPDMemTypeBitNotSetForRep
          push    eax
          mov     al,' '
          call    PutByteToReportBuf
          pop     eax
SPDMemTypeBitNotSetForRep:

          add     bx,2
          loop    short NextBitSPDMemTypeToTestForRep
          mov     al,')'
          call    PutByteToReportBuf

SPDMemModuleNotFoundForRep:

          mov     eax,[MSpeedIdx]
          or      eax,eax
          jz      short CanNotGetMemInfoForRep
          mov     si,offset MemSpeedIndex
          call    PutToReportBuf
          mov     si,offset NumMemSpeed
          call    NonZeroPrn
          call    PutToReportBuf

CanNotGetMemInfoForRep:

          call    GetDisplayAdapterForRep

          call    GetHDDforOS

          mov     si,[ChipsetForRep]
          or      si,si
          jz      short ChipsetNotDetectForRep
          push    si
          mov     si,offset MesRepChipset
          call    PutToReportBuf
          pop     si
          call    PutToReportBuf
ChipsetNotDetectForRep:

          cmp     [NumRepMainboard],0
          jz      short NotDefineMainboardModel
          mov     si,offset MesRepMainboard
          call    PutToReportBuf
NotDefineMainboardModel:

          mov     si,offset NumBIOS
          cmp     [word ds:si],0
          jz      short NotBIOSDetect
          push    si
          mov     si,offset MesRepBIOS
          call    PutToReportBuf
          pop     si
          call    PutToReportBuf
          cmp     [NumBiosDate],0
          jz      short NotBIOSDetect
          mov     si,offset NumBiosDate1
          call    PutToReportBuf

NotBIOSDetect:
          cmp     [Bug2000testErr],1
          jz      short Bug2000TestNotFoundForRep
          cmp     [Bug2000Test1],0
          jz      short Bug2000Test1NotFoundForRep
          mov     si,offset MesRepFoundBug2000
          call    PutToReportBuf
          mov     eax,[dword ds:Bug2000Test1Year]
          mov     [dword ds:Year],eax
          call    PrintDateTime
          mov     si,offset NumDay
          call    PutToReportBuf
          mov     si,offset MesPerexod
          call    PutToReportBuf
          mov     eax,[Test1WithBugDate]
          mov     [dword ds:Year],eax
          call    PrintDateTime
          mov     si,offset NumDay
          call    PutToReportBuf
Bug2000Test1NotFoundForRep:
Bug2000TestNotFoundForRep:

          mov     si,offset MesRepOSversion
          call    PutToReportBuf
          mov     si,[NumRepOSver1]
          or      si,si
          jz      short NotOSver1
          call    PutToReportBuf
NotOSver1:
          mov     si,[NumRepOSver2]
          or      si,si
          jz      short NotOSver2
          call    PutToReportBuf
NotOSver2:
          mov     si,[NumRepOSver3]
          or      si,si
          jz      short NotOSver3
          call    PutToReportBuf
NotOSver3:

          test    [GetVerEAX],80000000h
          jnz     short NotWindowsNTor2000ForBuild
          cmp     [byte ds:GetVerEAX],4
          jb      short NotWindowsNTor2000ForBuild
          mov     ax,[word ds:GetVerEAX+2]
          mov     di,offset NumWin2000Build
          mov     cx,5
          call    BinToAscDec
          mov     si,offset MesWin2000Build
          call    PutToReportBuf
          mov     si,offset NumWin2000Build
          call    NonZeroPrn
          call    PutToReportBuf

NotWindowsNTor2000ForBuild:
          call    GetIDEDevReport
          call    GetMemBenchReport
          call    GetMemoryModulesReport
          call    GetPCIReport
          call    GetISAPnPForRep
          call    PrnRepLine
          mov     si,offset MesEndOfReport
          call    PutToReportBuf
          mov     bp,[FileHandleREP]
          mov     di,[CounterRepBuf]
          mov     ax,[ReportDataSeg]
          mov     es,ax
          call    WriteFile
          jc      short ReportFileWriteError
          mov     bx,bp
          mov     ah,3Eh
          int     21h
ReportFileWriteError:
          pop     es
          pop     ds
          ret
ENDP CreateReportFile

PROC RepGetCPUNameString
          mov     si,offset CPUName
          cmp     [byte ds:si],0
          jz      short CPUNameNotSupport
          push    si
          mov     si,offset CPUNameString
          call    PutToReportBuf
          pop     si
          call    PutToReportBuf
CPUNameNotSupport:
          ret
ENDP RepGetCPUNameString

PROC GetOrigClockForRep
          mov     ax,[OriginalFrequency]
          or      ax,ax
          jz      OriginalFSBNotDetected

          mov     si,offset MesRepOriginalClock
          call    PutToReportBuf
          mov     di,offset OriginalCPUClock
          mov     cx,4
          call    BinToAscDec
          mov     si,offset OriginalCPUClock
          call    NonZeroPrn
          call    PutToReportBuf

          mov     eax,[OriginalFSBExt]
          push    eax
          add     eax,100
          movzx   ebx,[ClockRatio]
          mul     ebx
          sub     edx,edx
          mov     ecx,100
          div     ecx
          mov     ebx,eax
          mov     eax,[MHzTSCFull]
          cmp     ebx,eax
          pop     eax

          jae     short CPUNotOverclocked
          movzx   ebx,[ClockRatio]
          mul     ebx
          sub     edx,edx
          mov     ecx,100
          div     ecx
          mov     ebx,eax
          mov     eax,[MHzTSCFull]
          mov     ecx,10000
          mul     ecx
          div     ebx
          sub     eax,ecx
          mov     [Overclocking],eax
CPUNotOverclocked:

          mov     ax,[OriginalFSB]
          mov     di,offset OriginalExternalClock
          mov     cx,4
          call    BinToAscDec
          mov     si,offset OriginalExternalClock
          call    NonZeroPrn
          call    PutToReportBuf

          movzx   eax,[ClockRatio]
          mov     di,offset OriginalMultiplier
          mov     cx,2
          call    BinToAscDec2
          cmp     [byte ds:di+4],'0'
          jnz     short NotZeroInNumRatioForRep
          mov     [byte ds:di+4],0
NotZeroInNumRatioForRep:
          mov     si,offset OriginalMultiplier
          call    NonZeroPrn
          call    PutToReportBuf
          mov     si,offset MesScobka
          call    PutToReportBuf

OriginalFSBNotDetected:
          ret
ENDP GetOrigClockForRep

PROC GetHDDforOS
          cmp     [NumberDrives],0
          jz      ExistDriveNotFoundForRep
          mov     si,offset PerevodStroki
          call    PutToReportBuf
          mov     [TotalAllDrive],0
          mov     [TotalHDD],0

DetectNextDriveForRep:
          mov     dx,[TotalAllDrive]
          mov     [TestingHDDnumber],dl
          cmp     dl,[NumberDrives]
          jz      ExistDriveNotFoundForRep

          call    DetectHdd
          jc      GoToIncForNextDriveForRep
          inc     [TotalHDD]
          call    DetectHDDSizeInMB
          call    GetInt13ParamForRep
          call    GetNameTestingHDD
          jc      short HDDNameNotDetectForInfoForRep
          push    si
          mov     si,offset MesRepPrnForHDDMod
          call    PutToReportBuf
          mov     si,offset PrnHDDmodel+8
          call    PutToReportBuf
          mov     si,offset IDEATAdevices
          call    PutToReportBuf
          pop     si
          call    PutToReportBuf

HDDNameNotDetectForInfoForRep:

          mov     bp,offset HDDResBuff
          mov     cx,[TotalAllDrive]
          mov     al,17*4
          mul     cl
          add     bp,ax
          mov     al,[byte ds:bp+28]

          mov     si,offset MesRepUsesFastTest
          cmp     al,1
          jz      short HDDTestedInFastModeForRep
          mov     si,offset MesRepUsesFullTest
          cmp     al,2
          jnz     short HDDTestedNotFullModeForRep
HDDTestedInFastModeForRep:
          call    PutToReportBuf
HDDTestedNotFullModeForRep:

          mov     eax,[dword ds:bp]
          or      eax,eax
          jz      short SkipPutToRepMaxSeekTime
          mov     si,offset MesRepMaxSeekTime
          call    PutToReportBuf

          mov     eax,[dword ds:bp+49]
          mov     cx,3
          mov     di,offset NumRepSpeedInMS
          call    BinToAscDec2
          mov     si,offset NumRepSpeedInMS
          call    NonZeroPrn
          call    PutToReportBuf

          mov     si,offset MesRepPrnDev
          call    PutToReportBuf

          mov     eax,[dword ds:bp]

          mov     cx,3
          mov     di,offset NumRepSpeedInMS
          call    BinToAscDec2
          mov     si,offset NumRepSpeedInMS
          call    NonZeroPrn
          call    PutToReportBuf
SkipPutToRepMaxSeekTime:

          mov     eax,[dword ds:bp+4]
          or      eax,eax
          jz      short SkipPutToRepAverageSeekTime
          mov     cx,3
          mov     di,offset NumRepSpeedInMS
          call    BinToAscDec2
          mov     si,offset MesRepSeekTime
          call    PutToReportBuf
          mov     si,offset NumRepSpeedInMS
          call    NonZeroPrn
          call    PutToReportBuf
SkipPutToRepAverageSeekTime:

          mov     eax,[dword ds:bp+8]
          or      eax,eax
          jz      short SkipPutToRepTtoTSeekTime
          mov     cx,3
          mov     di,offset NumRepSpeedInMS
          call    BinToAscDec2
          mov     si,offset MesRepTtoTSeek
          call    PutToReportBuf
          mov     si,offset NumRepSpeedInMS
          call    NonZeroPrn
          call    PutToReportBuf
SkipPutToRepTtoTSeekTime:

          mov     eax,[dword ds:bp+12]
          or      eax,eax
          jz      short SkipPutToRepRandSeekTime
          mov     cx,3
          mov     di,offset NumRepSpeedInMS
          call    BinToAscDec2
          mov     si,offset MesRepRandAccess
          call    PutToReportBuf
          mov     si,offset NumRepSpeedInMS
          call    NonZeroPrn
          call    PutToReportBuf
SkipPutToRepRandSeekTime:

          mov     eax,[dword ds:bp+16]
          or      eax,eax
          jz      short SkipPutToRepLinTransfer
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          mov     si,offset MesRepLinTransfer
          call    PutToReportBuf
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf

          mov     si,offset MesRepMaxMinVerify
          call    PutToReportBuf

          mov     eax,[dword ds:bp+29+4]
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf
          mov     si,offset MesRepPrnDev
          call    PutToReportBuf
          mov     eax,[dword ds:bp+29+8]
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf

SkipPutToRepLinTransfer:

          mov     eax,[dword ds:bp+20]
          or      eax,eax
          jz      short SkipPutToRepLinRead
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          mov     si,offset MesRepLinRead
          call    PutToReportBuf
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf

          mov     si,offset MesRepMaxMinRead
          call    PutToReportBuf

          mov     eax,[dword ds:bp+29+12]
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf
          mov     si,offset MesRepPrnDev
          call    PutToReportBuf
          mov     eax,[dword ds:bp+29+16]
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf

SkipPutToRepLinRead:

          mov     eax,[dword ds:bp+53]
          or      eax,eax
          jz      short SkipPutToRepLinWrite
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          mov     si,offset MesRepLinWrite
          call    PutToReportBuf
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf

          mov     si,offset MesRepMaxMinWrite
          call    PutToReportBuf

          mov     eax,[dword ds:bp+57]
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf
          mov     si,offset MesRepPrnDev
          call    PutToReportBuf
          mov     eax,[dword ds:bp+61]
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf

SkipPutToRepLinWrite:

          mov     eax,[dword ds:bp+29]
          or      eax,eax
          jz      short SkipPutToRepBuffRead
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          mov     si,offset MesRepBufferedRead
          call    PutToReportBuf
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf
SkipPutToRepBuffRead:

          mov     eax,[dword ds:bp+24]
          or      eax,eax
          jz      short SkipPutToRepHDDIdx
          mov     cx,4
          mov     di,offset NumHDDSpeedH
          call    BinToAscDec2
          mov     si,offset MesRepHDDSpeedIdx
          call    PutToReportBuf
          mov     si,offset NumHDDSpeedH
          call    NonZeroPrn
          call    PutToReportBuf
SkipPutToRepHDDIdx:

GoToIncForNextDriveForRep:
          inc     [TotalAllDrive]
          jmp     DetectNextDriveForRep

ExistDriveNotFoundForRep:

          cmp     [KolihCDROM],0
          jz      NotCDfoundForRep
          mov     [TotalAllDrive],0

NextCDDriveForRep:
          mov     ax,[TotalAllDrive]
          add     ax,30h
          mov     [byte ds:CDDiskNumberForRep],al
          mov     si,offset CDParamForRep
          call    PutToReportBuf

          mov     bp,offset CDResBuff
          mov     cx,[TotalAllDrive]
          mov     al,10*4
          mul     cl
          add     bp,ax

          mov     eax,[dword ds:bp]
          or      eax,eax
          jnz     short CDIsTested
          mov     si,offset MesCDNotTested
          call    PutToReportBuf
          jmp     NotCDIndexForRep
CDIsTested:
          push    eax
          mov     cx,6
          mov     di,offset NumSectorCDROM
          call    BinToAscDecH
          mov     si,offset MesCDDiskSize
          call    PutToReportBuf
          mov     si,offset NumSectorCDROM
          call    NonZeroPrn
          call    PutToReportBuf
          mov     si,offset MesRepCDsectors
          call    PutToReportBuf
          pop     eax
          shr     eax,9
          mov     cx,4
          mov     di,offset NumAllTotalRead
          call    BinToAscDecH
          mov     si,offset NumAllTotalRead
          call    NonZeroPrn
          call    PutToReportBuf
          mov     al,[byte ds:bp+20]
          mov     si,offset MesRepUsesFastTest
          cmp     al,1
          jz      short CDTestedInFastModeForRep
          mov     si,offset MesRepUsesFullTest
          cmp     al,2
          jnz     short CDTestedNotFullModeForRep
CDTestedInFastModeForRep:
          call    PutToReportBuf
CDTestedNotFullModeForRep:
          mov     eax,[dword ds:bp+4]
          or      eax,eax
          jz      short NotDetectRepCDReadSpeed
          push    eax
          mov     ebx,100
          xor     edx,edx
          div     ebx
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          mov     si,offset MesRepCDReadSpeed
          call    PutToReportBuf
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf
          pop     eax
          call    GetXCDspeed

          mov     eax,[dword ds:bp+8]
          push    eax
          mov     ebx,100
          xor     edx,edx
          div     ebx
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          mov     si,offset MesRepCDMaxRead
          call    PutToReportBuf
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf
          pop     eax
          call    GetXCDspeed

NotDetectRepCDReadSpeed:

          mov     eax,[dword ds:bp+25]
          or      eax,eax
          jz      short NotDetectRepRandAccessTestCD
          mov     cx,3
          mov     di,offset NumRepSpeedInMS
          call    BinToAscDec2
          mov     si,offset MesRepRandAccess
          call    PutToReportBuf
          mov     si,offset NumRepSpeedInMS
          call    NonZeroPrn
          call    PutToReportBuf
NotDetectRepRandAccessTestCD:

          mov     eax,[dword ds:bp+29]
          or      eax,eax
          jz      short NotDetectRep13seekTestCD
          mov     cx,3
          mov     di,offset NumRepSpeedInMS
          call    BinToAscDec2
          mov     si,offset MesRepCD13Seek
          call    PutToReportBuf
          mov     si,offset NumRepSpeedInMS
          call    NonZeroPrn
          call    PutToReportBuf
NotDetectRep13seekTestCD:

          mov     eax,[dword ds:bp+33]
          or      eax,eax
          jz      short NotDetectRepFullSeekTestCD
          mov     cx,3
          mov     di,offset NumRepSpeedInMS
          call    BinToAscDec2
          mov     si,offset MesRepCDFullSeek
          call    PutToReportBuf
          mov     si,offset NumRepSpeedInMS
          call    NonZeroPrn
          call    PutToReportBuf
NotDetectRepFullSeekTestCD:

          mov     eax,[dword ds:bp+16]
          or      eax,eax
          jz      short NotDetectRepSeekTestCD
          mov     cx,3
          mov     di,offset NumRepSpeedInMS
          call    BinToAscDec2
          mov     si,offset MesRepCDAccessTime
          call    PutToReportBuf
          mov     si,offset NumRepSpeedInMS
          call    NonZeroPrn
          call    PutToReportBuf
NotDetectRepSeekTestCD:

          mov     ax,[word ds:bp+12]
          or      ax,ax
          jz      short NotDetectRepTotalUnstab
          dec     ax
          mov     di,offset NumTotalError
          mov     cx,3
          call    BinToAscDec
          mov     si,offset MesRepCDUnstabZone
          call    PutToReportBuf
          mov     si,offset NumTotalError
          call    NonZeroPrn
          call    PutToReportBuf
          mov     ax,[word ds:bp+14]
          mov     di,offset NumTotalError
          call    BinToAscDec
          mov     si,offset MesRepCDErrorZone
          call    PutToReportBuf
          mov     si,offset NumTotalError
          call    NonZeroPrn
          call    PutToReportBuf
NotDetectRepTotalUnstab:

          mov     eax,[dword ds:bp+21]
          or      eax,eax
          jz      short NotCDIndexForRep
          mov     di,offset NumHDDSpeedH
          mov     cx,4
          call    BinToAscDec2
          mov     si,offset MesRepCDSpeedIdx
          call    PutToReportBuf
          mov     si,offset NumHDDSpeedH
          call    NonZeroPrn
          call    PutToReportBuf
NotCDIndexForRep:

         inc      [TotalAllDrive]
         mov      ax,[TotalAllDrive]
         cmp      al,4
         jz       short NotCDfoundForRep
         cmp      al,[KolihCDROM]
         jnz      NextCDDriveForRep

NotCDfoundForRep:
         mov     si,offset PerevodStroki
         call    PutToReportBuf
         ret
ENDP GetHDDforOS

PROC GetNameTestingHDD
          mov     ax,8000h
          mov     bh,[TestingHDDnumber]
          inc     bh
          or      ah,bh
          call    SetIDEPM
          jz      short PrnHDDname
          call    SetIDEPS
          jz      short PrnHDDname
          call    SetIDESM
          jz      short PrnHDDname
          call    SetIDESS
          jz      short PrnHDDname
          call    SetIDETM
          jz      short PrnHDDname
          call    SetIDETS
          jz      short PrnHDDname
          call    SetIDEQM
          jz      short PrnHDDname
          call    SetIDEQS
          jz      short PrnHDDname
          stc
PrnHDDname:
          ret
ENDP GetNameTestingHDD

PROC GetXCDspeed
          mov     ebx,150
          xor     edx,edx
          div     ebx
          mov     cx,3
          mov     di,offset RepNumXSpeed
          call    BinToAscDec2
          mov     si,offset MesRepMinus
          call    PutToReportBuf
          mov     si,offset RepNumXSpeed
          call    NonZeroPrn
          call    PutToReportBuf
          ret
ENDP GetXCDspeed

PROC DetectHDDsizeInMB
          mov     eax,[Tracks]
          mul     [Sectors]
          mul     [Heads]
          shr     eax,11
          ret
ENDP DetectHDDsizeInMB

PROC GetISAPnPForRep
          mov     cl,[CurrCSN]
          sub     ch,ch
          or      cl,cl
          jz      short ISAPnPCardNotPresentForRep

          call    PrnRepLine
          mov     si,offset MerRepISAPNP
          call    PutToReportBuf

          mov     [NumISAPnPCardForRep],48

          mov     di,offset AdrNameISAPnP
          sub     bp,bp
NextISACardForRep:
          inc     [NumISAPnPCardForRep]
          mov     si,offset MesISAPnPCardForRep
          call     PutToReportBuf
          call    UnpackVendorIDISAPnP
          mov     si,offset VendorIDISAPnP
          call     PutToReportBuf

          mov     si,[word ds:di+bp]
          add     bp,2
          mov     ax,[word ds:di+bp]
          sub     ax,si
          cmp     ax,39+37
          jbe     short ANSIIDStringSizeOKForRep
          mov     al,39+37
          mov     [dword ds:si+35+37],00001019h
ANSIIDStringSizeOKForRep:
          cmp     [XPosISAPnP],al
          jae     short XPosISAPnPNoBigForRep
          mov     [XPosISAPnP],al
XPosISAPnPNoBigForRep:

          call     PutToReportBuf
          loop    short NextISACardForRep

ISAPnPCardNotPresentForRep:
          ret
ENDP GetISAPnPForRep

PROC GetMemoryModulesReport

          cmp     [DisableSPDread],1
          jnz     short GetSPDInfoRep
          ret
GetSPDInfoRep:
          call    PrnRepLine
          mov     si,offset MesMemModulesForRep
          call    PutToReportBuf
          mov     si,offset MesFoundForRep
          call    PutToReportBuf

          mov     al,[SMBusHost]
          mov     si,offset MesPIIX4
          cmp     al,1
          jz      SMBusHostDetected
          mov     si,offset MesICH
          cmp     al,2
          jz      SMBusHostDetected
          mov     si,offset MesICH0
          cmp     al,3
          jz      SMBusHostDetected
          mov     si,offset MesICH2
          cmp     al,4
          jz      SMBusHostDetected
          mov     si,offset MesICH2M
          cmp     al,5
          jz      SMBusHostDetected
          mov     si,offset MesICH3E
          cmp     al,6
          jz      SMBusHostDetected
          mov     si,offset MesICH3
          cmp     al,7
          jz      SMBusHostDetected
          mov     si,offset MesICH4
          cmp     al,8
          jz      SMBusHostDetected
          mov     si,offset MesVIA596
          cmp     al,9
          jz      SMBusHostDetected
          mov     si,offset MesVIA686A
          cmp     al,10
          jz      SMBusHostDetected
          mov     si,offset MesAMD756
          cmp     al,11
          jz      SMBusHostDetected
          mov     si,offset MesAMD766
          cmp     al,12
          jz      SMBusHostDetected
          mov     si,offset MesAMD768
          cmp     al,13
          jz      SMBusHostDetected
          mov     si,offset MesALIM7101
          cmp     al,14
          jz      SMBusHostDetected
          mov     si,offset MesVIA686
          cmp     al,15
          jz      short SMBusHostDetected
          mov     si,offset MesVIAVT8235
          cmp     al,16
          jz      short SMBusHostDetected
          mov     si,offset MesVIAVT8231
          cmp     al,17
          jz      short SMBusHostDetected
          mov     si,offset MesVIAVT8233
          cmp     al,18
          jz      short SMBusHostDetected
          mov     si,offset MesVIAVT8233C
          cmp     al,19
          jz      short SMBusHostDetected
          mov     si,offset MesVIAVT8233D
          cmp     al,20
          jz      short SMBusHostDetected
          mov     si,offset MesVIAVT8233A
          cmp     al,21
          jz      short SMBusHostDetected
          mov     si,offset MesRelOSB4
          cmp     al,22
          jz      short SMBusHostDetected
          mov     si,offset MesSiS5595B
          cmp     al,23
          jz      short SMBusHostDetected
          mov     si,offset MesSiSSMBus
          cmp     al,24
          jz      short SMBusHostDetected
          mov     si,offset MesnForceSMBus
          cmp     al,25
          jz      short SMBusHostDetected
          mov     si,offset MesnForceMCPTSMBus
          cmp     al,26
          jz      short SMBusHostDetected
          mov     si,offset MesnForceMCP3SMBus
          cmp     al,27
          jz      short SMBusHostDetected
          mov     si,offset Mes82440MXSMBus
          cmp     al,28
          jz      short SMBusHostDetected
          mov     si,offset MesAMD755
          cmp     al,29
          jz      short SMBusHostDetected
          mov     si,offset MesRel0227
          cmp     al,30
          jz      short SMBusHostDetected
          mov     si,offset MesICH5
          cmp     al,31
          jz      short SMBusHostDetected
          mov     si,offset MesVIAVT8237
          cmp     al,32
          jz      short SMBusHostDetected

          mov     si,offset MesNotPresent
          call    PutToReportBuf
          ret
SMBusHostDetected:
          call    PutToReportBuf
          mov     si,offset MesSMBA
          call    PutToReportBuf
          mov     ax,[BaseAdrSMBus]
          or      ax,ax
          jnz     short FoundSMBA
          mov     si,offset MesNotDetect
          call    PutToReportBuf
          ret
FoundSMBA:
          mov     cx,4
          mov     di,offset NumSMBA
          call    BinToAscHex
          mov     si,offset NumSMBA
          call    PutToReportBuf

          push    es
          push    [SPDDataSeg]
          pop     es
          sub     di,di
          mov     cx,8
          mov     [NumRepSlotNumber],'0'

NextMemSocketForRep:
          push    es
          push    cx
          push    di
          cmp     [word es:di],0FFFFh
          jz      NotFaundFullMemSocketForRep

          cmp     [NumberRIMMModules],0
          jnz     short FoundRIMMModulesForGetInfo
          call    GetSDRAMInfo
          jmp     short SDRAMInfoForRepGeting
FoundRIMMModulesForGetInfo:
          call    GetRDRAMInfo
SDRAMInfoForRepGeting:

          push    es
          push    ds
          push    di
          add     di,73
          mov     si,offset NumManufPartNum
          push    es
          push    ds
          pop     es
          pop     ds
          xchg    si,di
          cld
          mov     cx,17
          rep movsb
          pop     di
          pop     ds
          pop     es

          mov     si,offset MesRepSlotNumber
          call    PutToReportBuf
          mov     si,offset MesRepPrn13
          call    PutToReportBuf

          mov     si,offset MesRepSPDError
          call    PutToReportBuf
          mov     si,offset MesRepOK
          call    GetSPDCheckSum
          jnc     short NoSPDCheckSumErrForRep
          mov     si,offset MesRepError
NoSPDCheckSumErrForRep:
          call    PutToReportBuf

          call    GetMemTypeFromSPD
          call    CalkMemModuleSize
          push    ds
          pop     es
          mov     di,offset NumMemModSize
          mov     cx,5
          call    BinToAscDec
          mov     si,offset MesRepMemModuleSize
          call    PutToReportBuf
          mov     si,offset NumMemModSize
          call    NonZeroPrn
          call    PutToReportBuf
          mov     si,offset MesRepMemModuleType
          call    PutToReportBuf
          mov     bx,offset NumAdrSPDMemBuf
          mov     cx,32
          mov     eax,[SPDMemInfo]
          and     eax,0FFFFFFEFh
NextBitMemTypeForMemInfoForRep:
          shr     eax,1
          jnc     short MemTypeBitNotSetForMemInfoForRep
          mov     si,[word ds:bx]
          call    PutToReportBuf
MemTypeBitNotSetForMemInfoForRep:
          add     bx,2
          loop    short NextBitMemTypeForMemInfoForRep

          cmp     [NumberRIMMModules],0
          jnz     FoundRIMMModulesForRep

          mov     si,offset MesRepTechnology
          call    PutToReportBuf

          mov     ax,[ModDataWidth]     ;b6-7
          mul     [NumPhysicBanks]
          mov     bl,[SDRAMDeviceWidth] ;b13
          sub     bh,bh
          sub     dx,dx
          div     bx

          mov     di,offset NumRepNumberChips
          mov     cx,3
          call    BinToAscDec
          mov     si,offset NumRepNumberChips
          call    NonZeroPrn
          call    PutToReportBuf

          mov     cl,[NumRowAddrBits]
          add     cl,[NumColumnAddrBits]
          mov     eax,1
          shl     eax,cl
          movzx   ebx,[NumLogicBanks] ;b17
          mul     ebx
          shr     eax,20
          mov     di,offset NumRepSDRAMBanks
          mov     cx,3
          call    BinToAscDecH
          mov     si,offset NumRepSDRAMBanks
          call    NonZeroPrn
          call    PutToReportBuf
          mov     al,[SDRAMDeviceWidth]
          sub     ah,ah
          mov     di,offset NumRepSDRAMWidth
          call    BinToAscDec
          mov     si,offset NumRepSDRAMWidth
          call    NonZeroPrn
          call    PutToReportBuf
          mov     cl,[NumRowAddrBits]
          add     cl,[NumColumnAddrBits]
          mov     eax,1
          shl     eax,cl
          movzx   ebx,[NumLogicBanks] ;b17
          mul     ebx
          shr     eax,20
          mov     bl,[SDRAMDeviceWidth] ;b13
          sub     bh,bh
          mul     bx
          mov     di,offset NumRepChipMbit
          mov     cx,4
          call    BinToAscDec
          mov     si,offset NumRepChipMbit
          call    NonZeroPrn
          call    PutToReportBuf

NotRepTechForDDRMod:

          mov     al,[SDRAMCycleTime]
          sub     ah,ah
          or      al,al
          jz      short SDRAMCycleNotPresentForRep
          push    ax
          mov     si,offset MesRepCycleTime
          call    PutToReportBuf
          shr     al,4
          mov     cx,2
          mov     di,offset NumSDRAMAccesshigh
          call    BinToAscDec
          pop     ax
          and     al,01111b
          mov     cx,1
          mov     di,offset NumSDRAMAccessLow
          call    BinToAscDec
          mov     si,offset NumSDRAMAccessHigh
          call    NonZeroPrn
          call    PutToReportBuf

          call    GetMHzFromCycleTime

          mov     si,offset MesErrSPDnum
          cmp     ax,999
          ja      short ErrorInCycleTimeMHz
          mov     di,offset NumMemMHz
          mov     cx,5
          call    BinToAscDec
          mov     ax,'( '
          call    PutWordToReportBuf
          mov     si,offset NumMemMHz
          call    NonZeroPrn
ErrorInCycleTimeMHz:
          call    PutToReportBuf

SDRAMCycleNotPresentForRep:

          cmp     [NumberDDRModules],0
          jnz     GetDDRFuturesForRep

          mov     al,[SDRAMAccess]
          sub     ah,ah
          or      al,al
          jz      short SDRAMAcesseNotPresentForRep
          push    ax
          mov     si,offset MesRepSDRAMAccesTime
          call    PutToReportBuf
          shr     al,4
          mov     cx,2
          mov     di,offset NumSDRAMAccesshigh
          call    BinToAscDec
          pop     ax
          and     al,01111b
          mov     cx,1
          mov     di,offset NumSDRAMAccessLow
          call    BinToAscDec
          mov     si,offset NumSDRAMAccessHigh
          call    NonZeroPrn
          call    PutToReportBuf
SDRAMAcesseNotPresentForRep:

          mov     ax,8
          sub     dl,dl
          mov     bl,[SupCASlat]
NextBitCASlatForRep:
          shl     bl,1
          jnc     short ThisCASlatNotPresentForRep
          inc     dl
          mov     di,offset NumSupCASlat
          mov     cx,1
          call    BinToAscDec

          mov     si,offset MesRepSupportedCAS
          call    PutToReportBuf
          mov     si,offset NumSupCASlat
          call    PutToReportBuf

          call    PrnMesCLuptoForRep

ThisCASlatNotPresentForRep:
          dec     ax
          or      ax,ax
          jnz     short NextBitCASlatForRep

          mov     si,offset MesRepMinRowPreTime
          call    PutToReportBuf
          mov     al,[MinRowPRecTime]
          call    GetSPDInfoTime
          mov     [byte ds:MesUpToForT+2],'2'
          mov     bx,20000
          call    GetMesSPDTrcdTras

          mov     si,offset MesRepMinRAStoCAS
          call    PutToReportBuf
          mov     al,[TRcd]
          call    GetSPDInfoTime
          mov     [byte ds:MesUpToForT+2],'2'
          mov     bx,20000
          call    GetMesSPDTrcdTras

          mov     si,offset MesRepMinRASPules
          call    PutToReportBuf
          mov     al,[TRAS]
          call    GetSPDInfoTime
          mov     [byte ds:MesUpToForT+2],'5'
          mov     bx,50000
          call    GetMesSPDTrcdTras

          mov     si,offset MesModuleLabel
          call    PutToReportBuf


          mov     di,offset MesPCxxx+2
          call    GetMHzFromCycleTime
          call    CorrectSPDSpeedToStd
          mov     cx,3
          call    BinToAscDec
          mov     si,offset MesPCxxx
          call    PutToReportBuf

          mov     si,offset MesUnbuffered+1
          mov     ebx,[SPDMemInfo]
          test    ebx,04000000h ;PC133
          jz      short SkippDetectionBufferedSDRAMForRep
          dec     si
          test    [SDRAMModAttrib],11b
          jz      short SkippDetectionBufferedSDRAMForRep
          mov     [byte ds:si],'R'
SkippDetectionBufferedSDRAMForRep:

          call    PutToReportBuf

          call    GetCASForLabel
          call    PutToReportBuf

          mov     al,[SDRAMAccess]
          sub     ah,ah
          or      al,al
          jz      short SDRAMAcesseNotPresentForLabelForRep
          push    ax
          shr     al,4
          mov     cx,1
          mov     di,offset NumTacAndSPDRev
          call    BinToAscDec
          pop     ax
          and     al,01111b
          mov     cx,1
          mov     di,offset NumTacAndSPDRev+1
          call    BinToAscDec
          mov     al,[SPDRevision]
          test    al,11110000b
          jz      short NotIntelSPDRevSpecForRep
          shr     al,4
NotIntelSPDRevSpecForRep:
          mov     di,offset NumTacAndSPDRev+2
          call    BinToAscHex
SDRAMAcesseNotPresentForLabelForRep:
          mov     si,offset NumTacAndSPDRev
          call    PutToReportBuf

SkippDDRmemForRep:

          jmp     GoToDetectManufacturerForRep
GetDDRFuturesForRep:

          sub     dl,dl
          mov     bl,[SupCASlat]
          shl     bl,3
          jnc     short CASlat1NotSupForRep
          mov     si,offset MesRepSupportedCAS
          call    PutToReportBuf
          mov     si,offset MesCASLat35
          call    PutToReportBuf
          inc     dl
          call    PrnMesCLuptoForRep


CASlat1NotSupForRep:
          shl     bl,1
          jnc     short CASlat15NotSupForRep
          mov     si,offset MesRepSupportedCAS
          call    PutToReportBuf
          mov     si,offset MesCASLat3
          call    PutToReportBuf
          inc     dl
          call    PrnMesCLuptoForRep

CASlat15NotSupForRep:
          shl     bl,1
          jnc     short CASlat2NotSupForRep
          mov     si,offset MesRepSupportedCAS
          call    PutToReportBuf
          mov     si,offset MesCASLat25
          call    PutToReportBuf
          inc     dl
          call    PrnMesCLuptoForRep

CASlat2NotSupForRep:
          shl     bl,1
          jnc     short CASlat25NotSupForRep
          mov     si,offset MesRepSupportedCAS
          call    PutToReportBuf
          mov     si,offset MesCASLat2
          call    PutToReportBuf
          inc     dl
          call    PrnMesCLuptoForRep

CASlat25NotSupForRep:
          shl     bl,1
          jnc     short CASlat3NotSupForRep
          mov     si,offset MesRepSupportedCAS
          call    PutToReportBuf
          mov     si,offset MesCASLat15
          call    PutToReportBuf
          inc     dl
          call    PrnMesCLuptoForRep

CASlat3NotSupForRep:
          shl     bl,1
          jnc     short CASlat35NotSupForRep
          mov     si,offset MesRepSupportedCAS
          call    PutToReportBuf
          mov     si,offset MesCASLat1
          call    PutToReportBuf
          inc     dl
          call    PrnMesCLuptoForRep

CASlat35NotSupForRep:

          mov     si,offset MesRepMinRowPreTime
          call    PutToReportBuf
          mov     al,[MinRowPRecTime]
          call    GetDDRSPDInfoTime
          call    GetMesDDRSPDTrcdTras

          mov     si,offset MesRepMinRAStoCAS
          call    PutToReportBuf
          mov     al,[TRcd]
          call    GetDDRSPDInfoTime
          call    GetMesDDRSPDTrcdTras

          mov     si,offset MesRepMinRASPules
          call    PutToReportBuf
          mov     al,[TRAS]
          call    GetSPDInfoTime
          mov     [byte ds:MesUpToForT+2],'5'
          mov     bx,50000
          call    GetMesSPDTrcdTras

          mov     si,offset MesModuleLabel
          call    PutToReportBuf
          call    GetDDRLabel

          mov     si,offset MesPCxxxx
          call    PutToReportBuf
          mov     si,offset MesUnbuffered
          call    PutToReportBuf
          mov     si,offset MesXxxxx
          call    PutToReportBuf

          jmp    short GoToDetectManufacturerForRep
FoundRIMMModulesForRep:

          mov     si,offset MesRepMinPrToRASTime
          call    PutToReportBuf
          sub     ah,ah
          mov     al,[MinPrToRASTime]
          mov     cx,2
          mov     di,offset NumMinPrToRASTime
          call    BinToAscDec
          mov     si,offset NumMinPrToRASTime
          call    NonZeroPrn
          call    PutToReportBuf

          mov     si,offset  MesRepFmin
          call    PutToReportBuf
          mov     ax,[RDRAMFmin]
          mov     cx,4
          mov     di,offset NumRepFMinMax
          call    BinToAscDec
          mov     si,offset NumRepFMinMax
          call    NonZeroPrn
          call    PutToReportBuf

          mov     si,offset  MesRepFmax
          call    PutToReportBuf
          mov     ax,[RDRAMFmax]
          mov     cx,4
          mov     di,offset NumRepFMinMax
          call    BinToAscDec
          mov     si,offset NumRepFMinMax
          call    NonZeroPrn
          call    PutToReportBuf

GoToDetectManufacturerForRep:

          mov     si,offset MesRepManufacturer
          call    PutToReportBuf
          call    GetManufacturerName
          jnc     short PrnManufacturerNameForRep
          or      cl,cl
          jz      short PrnManufacturerUnknownForRep
          call    PutToReportBuf
          sub     ah,ah
          mov     al,bl
          mov     cx,2
          mov     di,offset NumJEDECID
          call    BinToAscHex
          mov     si,offset NumJEDECID
          jmp     short PrnManufacturerNameForRep

PrnManufacturerUnknownForRep:
          mov    si,offset MesNotPresent
PrnManufacturerNameForRep:
          call   PutToReportBuf

          mov    si,offset MesRepManufPartN
          call   PutToReportBuf
          call   CheckManufPartNum
          mov    si,offset MesNotPresent
          jz     short ReportNotPresent
          mov    si,offset NumManufPartNum
ReportNotPresent:
          call   PutToReportBuf

          mov    si,offset MesRepSerialNumber
          call   PutToReportBuf
          mov    si,offset MesNotPresent
          mov    eax,[ModuleSN]
          or     eax,eax
          jz     short SNNotPresent
          cmp    eax,0FFFFFFFFh
          jz     short SNNotPresent
          xchg   al,ah
          mov     cx,4
          mov     di,offset NumRepPCISUBSYSDEV
          call    BinToAscHex
          shr     eax,16
          xchg   al,ah
          mov     di,offset NumRepPCISUBSYSVEN
          call    BinToAscHex
          mov     si, offset NumRepPCISUBSYSDEV
SNNotPresent:
          call   PutToReportBuf

NotFaundFullMemSocketForRep:
          pop     di
          pop     cx
          pop     es
          inc     [NumRepSlotNumber]
          add     di,80h
          loop    NextMemSocketForRep
          pop     es
NotPresentMemModulesInfo:
          ret
ENDP GetMemoryModulesReport

PROC PutDDRCASForLabel
          push    cx
          cmp     cl,1
          jnz     short NotDDRCAS1
          mov     cx,'01'
NotDDRCAS1:
          cmp     cl,2
          jnz     short NotDDRCAS15
          mov     cx,'51'
NotDDRCAS15:
          cmp     cl,3
          jnz     short NotDDRCAS2
          mov     cx,'02'
NotDDRCAS2:
          cmp     cl,4
          jnz     short NotDDRCAS25
          mov     cx,'52'
NotDDRCAS25:
          cmp     cl,5
          jnz     short NotDDRCAS3
          mov     cx,'03'
NotDDRCAS3:
          cmp     cl,6
          jnz     short NotDDRCAS35
          mov     cx,'53'
NotDDRCAS35:
          mov     [word ds:MesXxxxx],cx
          pop     cx
          ret
ENDP PutDDRCASForLabel

PROC GetDDRLabel
          mov     si,offset MesPCxxxx+2

          mov     al,[SDRAMCycleTime]

          cmp     al,50h      ;5.0ns
          ja      short NotPC400DDRForLabel
          mov     [dword ds:si],'0023'
          jmp     short SkipDetectionDDRPCxxxxForLabel
NotPC400DDRForLabel:

          cmp     al,60h      ;6.0ns
          ja      short NotPC333DDRForLabel
          mov     [dword ds:si],'0072'
          jmp     short SkipDetectionDDRPCxxxxForLabel
NotPC333DDRForLabel:
          cmp     al,75h      ;7.5ns
          ja      short NotPC266DDRForLabel
          mov     [dword ds:si],'0012'
          jmp     short SkipDetectionDDRPCxxxxForLabel
NotPC266DDRForLabel:
          mov     [dword ds:si],'0061'
SkipDetectionDDRPCxxxxForLabel:

          mov     si,offset MesUnbuffered
          mov     ebx,[SPDMemInfo]
          test    [SDRAMModAttrib],11b
          jz      short SkippDetectionBufferedDDRSDRAMForRep
          mov     [byte ds:si],'R'
SkippDetectionBufferedDDRSDRAMForRep:
          call    GetDDRCASForLabel
          ret
ENDP GetDDRLabel

PROC GetMesSPDTrcdTras
          push    ax
          xchg    ax,bx
          sub     dx,dx
          div     bx
          sub     dx,dx
          mov     bx,10
          div     bx
          cmp     dx,5
          jb      short NotNidedCorrectTrcdTras
          inc     ax
NotNidedCorrectTrcdTras:
          cmp     ax,66
          jb      short ErrorForThisLatency
          cmp     ax,999
          ja      short ErrorForThisLatency
          mov     di,offset NumUpTo
          mov     cx,3
          call    BinToAscDec
          mov     si,offset MesUpToForT
          call    PutToReportBuf
          mov     si,offset NumUpTo
          call    NonZeroPrn
          call    PutToReportBuf
          clc
          jmp     short ExitFromGetMesSPDTrcdTras
ErrorForThisLatency:
          stc
ExitFromGetMesSPDTrcdTras:
          pop     ax
          ret
ENDP GetMesSPDTrcdTras

PROC GetMesDDRSPDTrcdTras
          mov     [byte ds:MesUpToForT+2],'2'
          push    ax
          push    ax
          sub     ah,ah
          shr     al,2
          mov     dx,100
          mul     dx
          pop     dx
          and     dx,11b
          sub     cx,cx
          or      dl,dl
          jz      short DDRTrcdTrasPlus
          mov     cx,25
          cmp     dl,1
          jz      short DDRTrcdTrasPlus
          mov     cx,50
          cmp     dl,2
          jz      short DDRTrcdTrasPlus
          mov     cx,75
DDRTrcdTrasPlus:
          add     ax,cx
          movzx   ebx,ax
          sub     edx,edx
          mov     eax,2000000
          div     ebx
          sub     dx,dx
          mov     cx,10
          div     cx
          cmp     dx,5
          jb      short NotNidedCorrectDDRTrcdTras
          inc     ax
NotNidedCorrectDDRTrcdTras:
          cmp     ax,66
          jb      short ErrorForThisDDRLatency
          cmp     ax,999
          ja      short ErrorForThisDDRLatency
          cmp     ax,100
          jae     short NotNidedCorrectForCAS3
          mov     [byte ds:MesUpToForT+2],'3'
          sub     edx,edx
          mov     eax,3000000
          div     ebx
          sub     dx,dx
          mov     cx,10
          div     cx
          cmp     dx,5
          jb      short NotNidedCorrectDDRTrcdTrasCAS3
          inc     ax
NotNidedCorrectDDRTrcdTrasCAS3:
NotNidedCorrectForCAS3:

          mov     di,offset NumUpTo
          mov     cx,3
          call    BinToAscDec
          mov     si,offset MesUpToForT
          call    PutToReportBuf
          mov     si,offset NumUpTo
          call    NonZeroPrn
          call    PutToReportBuf
          clc
          jmp     short ExitFromGetMesDDRSPDTrcdTras
ErrorForThisDDRLatency:
          stc
ExitFromGetMesDDRSPDTrcdTras:
          pop     ax
          ret
ENDP GetMesDDRSPDTrcdTras

PROC GetMHzFromCycleTime3ndCAS
          mov     al,[SDRAMCycleTime3nd]
          sub     ah,ah
          or      al,al
          jz      short NotNidedCorectSDRAMMhz
          push    ebx
          push    edx
          push    ax
          shr     al,2
          mov     bx,10
          mul     bx
          mov     bx,ax
          pop     ax
          and     al,11b
          cmp     al,3
          jnz     short Not3detectedForCorrectCycleTime3nd
          add     bx,8
Not3detectedForCorrectCycleTime3nd:
          cmp     al,2
          jnz     short Not2detectedForCorrectCycleTime3nd
          add     bx,5
Not2detectedForCorrectCycleTime3nd:
          cmp     al,1
          jnz     short Not1detectedForCorrectCycleTime3nd
          add     bx,3
Not1detectedForCorrectCycleTime3nd:
          movzx   ebx,bx
          jmp     short DetectMHzFromCycleTime

PROC GetMHzFromCycleTime2ndCAS
          mov     al,[SDRAMCycleTime2nd]
          jmp     GoToGetMHzFromCycleTime
PROC GetMHzFromCycleTime
          mov     al,[SDRAMCycleTime]
GoToGetMHzFromCycleTime:
          sub     ah,ah
          or      al,al
          jz      short NotNidedCorectSDRAMMhz
          push    ebx
          push    edx
          push    ax
          shr     al,4
          mov     bl,10
          mul     bl
          mov     bl,al
          pop     ax
          and     al,01111b
          add     bl,al
          sub     edx,edx
          movzx   ebx,bl
DetectMHzFromCycleTime:
          mov     eax,100000
          div     ebx
          sub     edx,edx
          mov     ebx,10
          div     ebx
          cmp     dl,4
          pop     edx
          pop     ebx
          jbe     short NotNidedCorectSDRAMMhz
          inc     ax
NotNidedCorectSDRAMMhz:
          ret
ENDP GetMHzFromCycleTime
ENDP GetMHzFromCycleTime2ndCAS
ENDP GetMHzFromCycleTime3ndCAS

PROC GetCASForLabel
          mov     [dword ds:MesXxx],'-xxx'
          mov     cx,8
          sub     dl,dl
          mov     bl,[SupCASlat]
NextBitCASlatForLabel:
          shl     bl,1
          jnc     short ThisCASlatNotPresentForLabel
          inc     dl
          cmp     dl,1
          jnz     short NotHighCAS
          call    GetMHzFromCycleTime
          call    CorrectSPDSpeedToStd
          mov     bp,ax
          mov     [byte ds:MesXxx],cl

          mov     al,[SDRAMCycleTime]
          mov     [SDRAMCycleTimeForTrpTrcd],al

NotHighCAS:
          cmp     dl,2
          jnz     short Not2ndHighCAS
          call    GetMHzFromCycleTime2ndCAS
          call    CorrectSPDSpeedToStd
          cmp     ax,bp
          jb      short Not2ndHighCAS
          mov     bp,ax
          mov     [byte ds:MesXxx],cl
          mov     al,[SDRAMCycleTime2nd]
          mov     [SDRAMCycleTimeForTrpTrcd],al
Not2ndHighCAS:
ThisCASlatNotPresentForLabel:
          loop    short NextBitCASlatForLabel
          add     [byte ds:MesXxx],48
          cmp     [byte ds:MesXxx],'4'
          jbe     short ResLabelCASlatOK
          mov     [byte ds:MesXxx],'?'
ResLabelCASlatOK:

          mov     si,offset MesXxx
          cmp     [SDRAMCycleTime],0
          jz      short ErrorSDRAMTcyc

          mov     al,[Trcd]
          call    DetectLabelTrpTrcd
          mov     [byte ds:MesXxx+1],al

          mov     al,[MinRowPRecTime]
          call    DetectLabelTrpTrcd
          mov     [byte ds:MesXxx+2],al
ErrorSDRAMTcyc:

          ret
ENDP GetCASForLabel

PROC GetDDRCASForLabel
          mov     [word ds:MesXxxxx],'xx'
          mov     cx,8
          sub     dl,dl
          mov     bl,[SupCASlat]
NextBitDDRCASlatForLabel:
          shl     bl,1
          jnc     short ThisDDRCASlatNotPresentForLabel
          inc     dl
          cmp     dl,1
          jnz     short NotHighDDRCAS
          call    GetMHzFromCycleTime
          call    CorrectDDRSPDSpeedToStd
          mov     bp,ax
          call    PutDDRCASForLabel


          mov     al,[SDRAMCycleTime]
          mov     [SDRAMCycleTimeForTrpTrcd],al

NotHighDDRCAS:
          cmp     dl,2
          jnz     short Not2ndHighDDRCAS
          call    GetMHzFromCycleTime2ndCAS
          call    CorrectDDRSPDSpeedToStd
          cmp     ax,bp
          jb      short Not2ndHighDDRCAS
          mov     bp,ax
          call    PutDDRCASForLabel
          mov     al,[SDRAMCycleTime2nd]
          mov     [SDRAMCycleTimeForTrpTrcd],al
Not2ndHighDDRCAS:
ThisDDRCASlatNotPresentForLabel:
          loop    short NextBitDDRCASlatForLabel

          mov     si,offset MesXxxxx
          cmp     [SDRAMCycleTime],0
          jz      short ErrorDDRSDRAMTcyc

          mov     al,[Trcd]
          call    DetectLabelDDRTrpTrcd
          mov     [byte ds:MesXxxxx+2],al

          mov     al,[MinRowPRecTime]
          call    DetectLabelDDRTrpTrcd
          mov     [byte ds:MesXxxxx+3],al
ErrorDDRSDRAMTcyc:

          mov     al,[SPDRevision]
          and     al,1111b
          mov     cx,1
          mov     di,offset MesXxxxx+4
          call    BinToAscHex

          ret
ENDP GetDDRCASForLabel

PROC DetectLabelTrpTrcd
          sub     ah,ah
          mov     bx,100
          mul     bx
          push    ax
          sub     bh,bh
          mov     bl,[SDRAMCycleTimeForTrpTrcd]
          push    bx
          shr     bl,4
          mov     ax,10
          mul     bx
          pop     bx
          and     bl,1111b
          add     bx,ax
          pop     ax

          sub     dx,dx
          div     bx
          sub     dx,dx
          mov     bx,10
          div     bx
          or      dx,dx
          jz      short NotNidedCorrectTrp
          inc     al
NotNidedCorrectTrp:
          add     al,48
          cmp     al,'4'
          jbe     short ResLabelTrpTrcdOK
          mov     al,'?'
ResLabelTrpTrcdOK:

          ret
ENDP DetectLabelTrpTrcd

PROC DetectLabelDDRTrpTrcd
          sub     ah,ah
          push    ax
          shr     ax,2
          mov     bx,100
          mul     bx
          pop     bx
          and     bl,11b
          sub     cx,cx
          or      bl,bl
          jz      short DDRTrcdTrasPlusForLabel
          mov     cx,25
          cmp     bl,1
          jz      short DDRTrcdTrasPlusForLabel
          mov     cx,50
          cmp     bl,2
          jz      short DDRTrcdTrasPlusForLabel
          mov     cx,75
DDRTrcdTrasPlusForLabel:
          add     ax,cx

          push    ax
          sub     bh,bh
          mov     bl,[SDRAMCycleTimeForTrpTrcd]
          push    bx
          shr     bl,4
          mov     ax,10
          mul     bx
          pop     bx
          and     bl,1111b
          add     bx,ax
          pop     ax
          movzx   eax,ax
          movzx   ebx,bx
          mov     ecx,10
          mul     ecx

          sub     edx,edx
          div     ebx

          sub     dx,dx
          mov     bx,100
          div     bx
          or      dx,dx
          jz      short NotNidedCorrectDDRTrp
          inc     al
NotNidedCorrectDDRTrp:
          add     al,48
          cmp     al,'4'
          jbe     short ResLabelDDRTrpTrcdOK
          mov     al,'?'
ResLabelDDRTrpTrcdOK:
          ret
ENDP DetectLabelDDRTrpTrcd

PROC PrnMesCLuptoForRep
          push    ax             ; в al- текущий CL
          push    bx

          call    GetMHzFromCycleTime
          cmp     dl,1
          jz      short PrnSDRAMUpTo
          call    GetMHzFromCycleTime2ndCAS
          cmp     dl,2
          jz      short PrnSDRAMUpTo
          call    GetMHzFromCycleTime3ndCAS
          cmp     dl,3
          jz      short PrnSDRAMUpTo

          jmp     short NotSDRAMCL2Detected
PrnSDRAMUpTo:
          or      ax,ax
          jz      short NotSDRAMCL2Detected
          cmp     ax,999
          ja      short NotSDRAMCL2Detected
          mov     di,offset NumUpTo
          mov     cx,3
          call    BinToAscDec
          mov     si,offset MesUpTo
          call    PutToReportBuf
          mov     si,offset NumUpTo
          call    NonZeroPrn
          call    PutToReportBuf
NotSDRAMCL2Detected:
          pop     bx
          pop     ax
          ret
ENDP PrnMesCLuptoForRep

PROC GetSPDInfoTime
          sub     ah,ah
          cmp     al,99
          mov     si,offset MesErrSPDnum
          ja      short ErrorSPDInfoTime
          mov     cx,2
          mov     di,offset NumMinRowPRecTime
          call    BinToAscDec
          mov     si,offset NumMinRowPRecTime
          call    NonZeroPrn
          call    PutToReportBuf
          mov     si,offset MesNSonly
ErrorSPDInfoTime:
          call    PutToReportBuf
          ret
ENDP GetSPDInfoTime

PROC GetDDRSPDInfoTime
          push    ax
          sub     ah,ah
          push    ax
          shr     al,2
          cmp     al,50
          ja      short ErrorDDRSPDInfoTime

          mov     cx,2
          mov     di,offset NumMinRowPRecTime
          call    BinToAscDec
          mov     si,offset NumMinRowPRecTime
          call    PutToReportBuf

          pop     ax
          and     al,11b
          mov     si,offset MesPlus0
          or      al,al
          jz      short PrnMesPlusForRep
          mov     si,offset MesPlus025
          cmp     al,1
          jz      short PrnMesPlusForRep
          mov     si,offset MesPlus05
          cmp     al,2
          jz      short PrnMesPlusForRep
          mov     si,offset MesPlus075
PrnMesPlusForRep:
          call    PutToReportBuf
          mov     si,offset MesNSonly
ErrorDDRSPDInfoTime:
          call    PutToReportBuf
          pop     ax
          ret
ENDP GetDDRSPDInfoTime

PROC GetIDEDevReport
          call    PrnRepLine
          mov     si,offset MesATAATAPI
          call    PutToReportBuf
          mov     [NumIDEForRep],'0'
          mov     si,offset MesRepIDE0Master
          mov     [NumRepPos],179
          call    PutToReportBuf
          mov     bp,offset NumDriveName0
          call    GetATAATAPIRep
          mov     si,offset MesRepIDE0Slave
          mov     [NumRepPos],32
          call    PutToReportBuf
          mov     bp,offset NumDriveName1
          call    GetATAATAPIRep
          inc     [NumIDEForRep]
          mov     si,offset MesRepIDE0Master
          mov     [NumRepPos],179
          call    PutToReportBuf
          mov     bp,offset NumDriveName2
          call    GetATAATAPIRep
          mov     si,offset MesRepIDE0Slave
          mov     [NumRepPos],32
          call    PutToReportBuf
          mov     bp,offset NumDriveName3
          call    GetATAATAPIRep
          inc     [NumIDEForRep]
          mov     si,offset MesRepIDE0Master
          mov     [NumRepPos],179
          call    PutToReportBuf
          mov     bp,offset NumDriveName4
          call    GetATAATAPIRep
          mov     si,offset MesRepIDE0Slave
          mov     [NumRepPos],32
          call    PutToReportBuf
          mov     bp,offset NumDriveName5
          call    GetATAATAPIRep
          inc     [NumIDEForRep]
          mov     si,offset MesRepIDE0Master
          mov     [NumRepPos],179
          call    PutToReportBuf
          mov     bp,offset NumDriveName6
          call    GetATAATAPIRep
          mov     si,offset MesRepIDE0Slave
          mov     [NumRepPos],32
          call    PutToReportBuf
          mov     bp,offset NumDriveName7
          call    GetATAATAPIRep
          ret
ENDP GetIDEDevReport

PROC GetATAATAPIRep
          mov      al,[byte ds:bp+33+8]
          and      al,11100000b
          cmp      al,80h
          jnz      short NotATADevForRep
          call     RepATAInfo
          jmp      short DetectSlaveForRep
NotATADevForRep:
          cmp      al,20h
          jnz      short NotATAPIDevForRep
          call     RepATAPIInfo
          jmp      short DetectSlaveForRep
NotATAPIDevForRep:
          mov      si,offset MesRepEmpty
          call     PutToReportBuf
DetectSlaveForRep:
          ret
ENDP GetATAATAPIRep

PROC RepATAInfo
          mov     si,offset MesATAForRep
          call    PutToReportBuf
          mov     bx,[word ds:bp+40+8]
          or      bx,bx
          jz      short ATAVersionNotPresentForRep
          cmp     bx,0FFFFh
          jz      short ATAVersionNotPresentForRep
          mov     ax,16
WaitATAversionForRep:
          dec     ax
          shl     bx,1
          jnc     short WaitATAversionForRep
          cmp     al,9
          ja      short ATAVersionNotPresentForRep
          mov     cx,1
          mov     di,offset NumATAVerForRep
          call    BinToAscDec
          mov     si,offset MesATAVerForRep
          call    PutToReportBuf
ATAVersionNotPresentForRep:
          mov     si,offset MesRepNameTire
          call    PutToReportBuf
          mov     si,bp
          call    PutToReportBuf
          mov     si,offset MesRepPos
          call    PutToReportBuf
          mov     si,offset MesHDDGeometry
          call    PutToReportBuf
          mov     ax,[word ds:bp+34+8]
          mov     cx,5
          mov     di,offset NumRepCylinders
          call    BinToAscDec
          mov     si,offset NumRepCylinders
          call    NonZeroPrn
          call    PutToReportBuf
          mov     ax,[word ds:bp+36+8]
          mov     cx,5
          mov     di,offset NumRepHeads
          call    BinToAscDec
          mov     si,offset NumRepHeads
          call    NonZeroPrn
          call    PutToReportBuf
          mov     ax,[word ds:bp+38+8]
          mov     cx,5
          mov     di,offset NumRepSectors
          call    BinToAscDec
          mov     si,offset NumRepSectors
          call    NonZeroPrn
          call    PutToReportBuf
          movzx   eax,[word ds:bp+34+8] ;Определяем
          movzx   ebx,[word ds:bp+36+8] ;размер
          mul     ebx                   ;жесткого
          movzx   ebx,[word ds:bp+38+8] ;диска
          mul     ebx                   ;в МБ.
          shr     eax,11
          cmp     eax,1024
          jb      short PrnRepHDDSizeInMB
          call    GetHDDSizeInGB
          mov     cx,4
          mov     di,offset NumRepSizeGB
          call    BinToAscDec2
          mov     si,offset NumRepSizeGB
          call    NonZeroPrn
          call    PutToReportBuf
          jmp     short SizeRepPrnOK
PrnRepHDDSizeInMB:
          mov     cx,4
          mov     di,offset NumRepSizeMB
          call    BinToAscDec
          mov     si,offset NumRepSizeMB
          call    NonZeroPrn
          call    PutToReportBuf
SizeRepPrnOK:

          call    ReportTransferModeAndCache

          mov     ax,[word ds:bp+42+8]
          or      ax,ax
          jz      short HDDRPMNotPresentForRep
          mov     cx,5
          mov     di,offset NumRPM
          call    BinToAscDec
          mov     si,offset MesRepPos
          call    PutToReportBuf
          mov     si,offset MesSpindleSpeed
          call    PutToReportBuf
          mov     si,offset NumRPM
          call    NonZeroPrn
          call    PutToReportBuf
HDDRPMNotPresentForRep:
          ret
ENDP RepATAInfo

PROC ReportTransferModeAndCache
          mov     ax,[word ds:bp+50+8]
          or      al,al
          jz      short ATASerialNumberNotPresent
          or      ax,ax
          jz      short ATASerialNumberNotPresent

          mov     si,offset MesRepPos
          call    PutToReportBuf
          mov     si,offset MesATASerialNum
          call    PutToReportBuf
          mov     si,bp
          add     si,58
          call    PutToReportBuf

ATASerialNumberNotPresent:

          mov     ax,[word ds:bp+79]
          or      al,al
          jz      short ATAFirmwareRevNotPresent
          or      ax,ax
          jz      short ATAFirmwareRevNotPresent

          mov     si,offset MesRepPos
          call    PutToReportBuf
          mov     si,offset MesATAFirmwareRev
          call    PutToReportBuf
          mov     si,bp
          add     si,71+8
          call    PutToReportBuf

ATAFirmwareRevNotPresent:

          mov     al,[byte ds:bp+46+8]
          or      al,al
          jz      TransferModeNotSupportForRep
          sub     ah,ah
          dec     al
          mov     cx,1
          and     al,111b
          mov     di,offset NumRepPIOmode
          call    BinToAscDec
          mov     si,offset MesRepPos
          call    PutToReportBuf
          mov     si,offset MesMaxTransfer
          call    PutToReportBuf
          mov     si,offset MesRepPIOmode
          call    PutToReportBuf

          mov     al,[byte ds:bp+47+8]
          or      al,al
          jz      short TransferModeNotSupportForRep
          push    ax
          shr     al,4
          or      al,al
          jz      short NotDMATransferSupportForRep
          dec     al
          mov     cx,1
          and     ax,1111b
          mov     di,offset NumRepDMAmode
          call    BinToAscHex
          mov     si,offset MesRepDMAmode
          call    PutToReportBuf

NotDMATransferSupportForRep:
          pop     ax
          and     ax,1111b
          or      al,al
          jz      short TransferModeNotSupportForRep
          dec     al
          push    ax
          mov     cx,1
          mov     di,offset NumRepUDMAmode
          call    BinToAscHex
          mov     si,offset MesRepUDMAmode
          call    PutToReportBuf
          pop     ax
          mov     si,offset MesRepUDMA33
          cmp     al,2
          jz      short PrnMesRepUDMA
          mov     si,offset MesRepUDMA44
          cmp     al,3
          jz      short PrnMesRepUDMA
          mov     si,offset MesRepUDMA66
          cmp     al,4
          jz      short PrnMesRepUDMA
          mov     si,offset MesRepUDMA100
          cmp     al,5
          jz      short PrnAta100133
          mov     si,offset MesRepUDMA133
          cmp     al,6
          jz      short PrnAta100133
          jmp     short TransferModeNotSupportForRep
PrnMesRepUDMA:
          push    si
          mov     si,offset MesRepUltraDMA
          call    PutToReportBuf
          pop     si
PrnAta100133:
          call    PutToReportBuf
TransferModeNotSupportForRep:

          mov     al,[byte ds:bp+96]
          or      al,al
          jz      short SelectedTransferModeNotSupportForRep
          mov     si,offset MesRepPos
          call    PutToReportBuf
          mov     si,offset MesSelectedTransfer
          call    PutToReportBuf

          push    ax
          shr     al,4
          or      al,al
          jz      short NotDMASelectedTransferSupportForRep
          dec     al
          mov     cx,1
          and     ax,1111b
          mov     di,offset NumRepDMAmode
          call    BinToAscHex
          mov     si,offset MesRepDMAmode+2
          call    PutToReportBuf
NotDMASelectedTransferSupportForRep:
          pop     ax

          and     ax,1111b
          or      al,al
          jz      short SelectedTransferModeNotSupportForRep
          dec     al
          mov     cx,1
          mov     di,offset NumRepUDMAmode
          call    BinToAscHex
          mov     si,offset MesRepUDMAmode

          mov     al,[byte ds:bp+96]
          shr     al,4
          or      al,al
          jnz     short SelectedDMADetectForRep
          add     si,2
SelectedDMADetectForRep:
          call    PutToReportBuf

SelectedTransferModeNotSupportForRep:

          mov     si,offset MesMaxTransferSpeed
          mov     ax,[word ds:bp+88]
          call    RepCDROMXspeed
          mov     si,offset MesSelectedSpeed
          mov     ax,[word ds:bp+90]
          call    RepCDROMXspeed
          mov     si,offset MesMaxWriteSpeed
          mov     ax,[word ds:bp+92]
          call    RepCDROMXspeed
          mov     si,offset MesSelectedWriteSpeed
          mov     ax,[word ds:bp+94]
          call    RepCDROMXspeed

          mov     ax,[word ds:bp+52]
          or      ax,ax
          jz      short CacheBufferSizeNotPresentForRep
          mov     cx,5
          mov     di,offset NumCacheBufferSize
          call    BinToAscDec
          mov     si,offset MesRepPos
          call    PutToReportBuf
          mov     si,offset MesHDDCacheSize
          call    PutToReportBuf
          mov     si,offset NumCacheBufferSize
          call    NonZeroPrn
          call    PutToReportBuf
CacheBufferSizeNotPresentForRep:
          ret
ENDP ReportTransferModeAndCache

PROC RepCDROMXspeed
          cmp     ax,176
          jl      short NotDetectCDROMXSpeed
          push    ax
          push    si
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDec
          mov     si,offset MesRepPos
          call    PutToReportBuf
          pop     si
          call    PutToReportBuf
          mov     si,offset ReadSpeedHDD
          call    NonZeroPrn
          call    PutToReportBuf
          pop     ax

          cmp     [byte ds:bp+40],5
          jnz     short NotDetectCDROMXSpeed
          mov     bx,176
          sub     dx,dx
          div     bx
          mov     cx,3
          mov     di,offset NumRepXSpeed
          call    BinToAscDec
          call    NZInMes
          mov     si,offset MesRepXSpeed
          call    PutToReportBuf
          mov     si,offset NumRepXSpeed
          call    NonZeroPrn
          call    PutToReportBuf
NotDetectCDROMXSpeed:
          ret
ENDP RepCDROMXspeed

PROC PrnKBorMB
          mov     cx,5
          cmp     ax,1024
          jae     short DetectSizeInMB
          mov     di,offset NumCacheSizeKB
          call    BinToAscDec
          mov     si,offset NumCacheSizeKB
          jmp     short PrnKB
DetectSizeInMB:
          shr     ax,10
          mov     di,offset NumCacheSizeMB
          call    BinToAscDec
          mov     si,offset NumCacheSizeMB
PrnKB:
          call    NonZeroPrn
          call    ColorStr6x8
          ret
ENDP PrnKBorMB

PROC RepATAPIInfo
          mov     si,offset MesATAPIForRep
          call    PutToReportBuf
          mov     si,offset MesRepNameTire
          call    PutToReportBuf
          mov     si,bp
          call    PutToReportBuf
          call    ReportTransferModeAndCache
          ret
ENDP RepATAPIInfo

PROC GetDisplayAdapterForRep
          sub      ch,ch
          mov      cl,[NumPCIStr]
          or       cx,cx
          jz       NoPCIBusFoundForPrnRepDisplayAdapter
          mov      [PCIDevRepOfs],0
FaindPCIDevInDataBaseForRep:
          push     cx
          call     GetPCIDeviceFromBuffer
          cmp      [NumPCIDevVendor],0
          jz       NotFaundPCIVideoDevForRep

          cmp      [NumPCIVideoDev],1
          jnz      NotFaundPCIVideoDevForRep
          cmp      [FoundAGPController],0
          jz       short NotPresentAGPBusForRep
          cmp      [NumberPCIBus],0
          jnz      short FaundAGPVideoForRep

NotPresentAGPBusForRep:

          mov      si,offset MesRepPCIVideo
          call     PutToReportBuf
          call     CreateVideoName
          mov      si,offset NumPCIVendor

          call     UnpackPCIString

          call     PutToReportBuf
          jmp      NotFaundPCIVideoDevForRep
FaundAGPVideoForRep:
          mov      si,offset MesRepAGPVideo
          call     PutToReportBuf
          call     CreateVideoName
          mov      si,offset NumPCIVendor

          call     UnpackPCIString

          call     PutToReportBuf
          mov      ebx,[AGPStatusReg]
          test     bl,1111b
          jz       short NotPresentForRepSupAGPRate
          mov      si,offset MesSupportAGPrate
          call     PutToReportBuf

          test     bl,1b
          jz       short NotSupportAGP1x
          mov      [NumSupportAGPrate],'1'
          mov      si,offset NumSupportAGPrate
          call     PutToReportBuf
NotSupportAGP1x:
          test     bl,10b
          jz       short NotSupportAGP2x
          mov      ax,' ,'
          call     PutWordToReportBuf
          mov      [NumSupportAGPrate],'2'
          mov      si,offset NumSupportAGPrate
          call     PutToReportBuf
NotSupportAGP2x:
          test     bl,100b
          jz       short NotSupportAGP4x
          mov      ax,' ,'
          call     PutWordToReportBuf
          mov      [NumSupportAGPrate],'4'
          mov      si,offset NumSupportAGPrate
          call     PutToReportBuf
NotSupportAGP4x:
          test     bl,1000b
          jz       short NotSupportAGP8x
          mov      ax,' ,'
          call     PutWordToReportBuf
          mov      [NumSupportAGPrate],'8'
          mov      si,offset NumSupportAGPrate
          call     PutToReportBuf
NotSupportAGP8x:
NotPresentForRepSupAGPRate:
          mov      al,[AGPDataRate]
          or       al,al
          jz       short NotPresentForRepDesiredAGPRate
          sub      ah,ah
          mov      cx,1
          mov      di,offset NumDesiredAGPrate
          call     BinToAscDec
          mov      si,offset MesDesiredAGPrate
          call     PutToReportBuf
NotPresentForRepDesiredAGPRate:
          mov      si,offset MesAGPoperations
          call     PutToReportBuf

          mov      si,offset MesAGPDisabled
          cmp      [AGPEnable],1
          jnz      short AGPForRepIsEnabled
          mov      si,offset MesAGPEnabled
AGPForRepIsEnabled:
          call     PutToReportBuf

          mov      si,offset MesSBA
          call     PutToReportBuf
          mov      ebx,[AGPStatusReg]
          test     bx,1000000000b
          mov      si,offset MesNotSupport
          jz       short PrnMesAGPSBADisabled
          mov      si,offset MesFWSupport
          call     PutToReportBuf
          mov      si,offset MesAGPDisabled
          mov      ebx,[AGPCommandReg]
          test     bx,1000000000b
          jz       short PrnMesAGPSBADisabled
          mov      si,offset MesAGPEnabled
PrnMesAGPSBADisabled:
          call     PutToReportBuf

          mov      si,offset MesFastWrites
          call     PutToReportBuf
          mov      ebx,[AGPStatusReg]
          test     bl,10000b
          mov      si,offset MesNotSupport
          jz       short PrnMesAGPFastWrites
          mov      si,offset MesFWSupport
          call     PutToReportBuf
          mov      ebx,[AGPCommandReg]
          mov      si,offset MesAGPDisabled
          test     bl,10000b
          jz       short PrnMesAGPFastWrites
          mov      si,offset MesAGPEnabled
PrnMesAGPFastWrites:
          call     PutToReportBuf
          mov      eax,[AGPStatusReg]
          mov      cx,4
          mov      di,offset NumAGPStatusRegL
          call     BinToAscHex
          shr      eax,16
          mov      di,offset NumAGPStatusRegH
          call     BinToAscHex
          mov      eax,[AGPCommandReg]
          mov      di,offset NumAGPCommandRegL
          call     BinToAscHex
          shr      eax,16
          mov      di,offset NumAGPCommandRegH
          call     BinToAscHex
          mov      si,offset MesAGPStatusReg
          call     PutToReportBuf

NotFaundPCIVideoDevForRep:
          pop      cx
          dec      cx
          jnz      FaindPCIDevInDataBaseForRep

          cmp      [NvidiaMem],0
          jz       short NvidiaMemNotPresent

          mov      si,offset MesRepVideoMem
          call     PutToReportBuf
          mov      si,offset TotalVideoMem
          call     NonZeroPrn
          call     PutToReportBuf

NvidiaMemNotPresent:

NoPCIBusFoundForPrnRepDisplayAdapter:

          cmp      [VESAOEMString],0
          jz       short NotVESAOEMStringPresents
          mov      si,offset MesRepVESAOEM
          call     PutToReportBuf
          mov      si,offset VESAOEMString
          call     PutToReportBuf
NotVESAOEMStringPresents:
          cmp      [TotalVESAMem],0
          jz       short NotVESAMemDetected
          mov      si,offset MesRepVESAMem
          call     PutToReportBuf
          mov      si,offset TotalVESAMem
          call     NonZeroPrn
          mov      ax,[VideoMEM]
          or       ax,ax
          jnz      short VESAMemPresentForRep
          mov      si,offset CPUIDunknown
VESAMemPresentForRep:
          call     PutToReportBuf
          cmp      [NumVideoSpeedVGA],0
          jz       short VideoMemSpeedNotPresent
          mov      si,offset MesVideoMemSpeed
          call     PutToReportBuf
          mov      si,offset NumVideoSpeedVGA
          call     NonZeroPrn
          call     PutToReportBuf
VideoMemSpeedNotPresent:
NotVESAMemDetected:
          ret
ENDP GetDisplayAdapterForRep

PROC CreateVideoName
          push     ds
          mov      si,[NumPCIDevVendor]
          mov      di,offset NumPCIVendor
          push     [NumPCISeg]
          pop      ds

          call     GetStringLength
          cld
          cmp      si,0FFFFh
          jz       short NotPrnPCIDevVendor
          rep movsb
          mov      al,' '
          stosb
NotPrnPCIDevVendor:
          mov      si,[word es:NumPCIDevName]
          call     GetStringLength
          rep movsb
          sub      al,al
          stosb
          pop      ds
          ret
ENDP CreateVideoName

PROC GetMemBenchReport
          cmp     [ErrConfig],1
          jz      short ExitMemBenchNotPresentForRep
          call    PrnRepLine
          mov     si,offset MesRepStr1
          call    PutToReportBuf
          mov     si,offset MesRepStr1a
          call    PutToReportBuf
          mov     si,offset MesRepStrMemBench
          call    PutToReportBuf
          mov     si,offset MesRepStr2
          call    PutToReportBuf
          mov     si,offset ResultsNew
          mov     di,offset ResCacheSpeedRepl
          call    GetMemBenchForRep

          cmp     [FeatureFlagMMX],1
          jnz     short NotMMXCPUForCacheTableRep
          mov     si,offset MesRepMMXStr1
          call    PutToReportBuf
          mov     si,offset MesRepStr1a
          call    PutToReportBuf
          mov     si,offset MesRepMMXMemBench
          call    PutToReportBuf
          mov     si,offset MesRepStr2
          call    PutToReportBuf
          mov     si,offset ResultsNew
          mov     di,offset ResCacheSpeedMovsq
          call    GetMemBenchForRep
NotMMXCPUForCacheTableRep:

ExitMemBenchNotPresentForRep:
           ret
ENDP GetMemBenchReport

PROC GetMemBenchForRep
          mov     [AllCache],0
          sub     cl,cl
NextByteCacheSpeedBenchRepPrn:
          lodsb
          or      al,al
          jz      short NextCacheForSpeedBenchRep
          inc     [AllCache]
          cmp     [AllCache],4
          jz      short CacheForSpeedBenchRepNotFound
          push    si
          push    di
          push    cx
          mov     al,[AllCache]
          add     al,48
          mov     [NumberRepCacheBench],al

          mov     si,offset MesRepCacheLevel
          call    PutToReportBuf
          call    MemBenchRep
          mov     si,offset NumRepReadMemBench
          call    PutToReportBuf

          pop     cx
          pop     di
          pop     si
NextCacheForSpeedBenchRep:
          add     di,4
          inc     cl
          mov     al,[byte cs:MemSizePriznak]
          add     al,10
          cmp     cl,al
          jnz     short NextByteCacheSpeedBenchRepPrn
CacheForSpeedBenchRepNotFound:

          mov     si,offset MesRepMemBench
          call    PutToReportBuf
          call    MemBenchRep
          mov     si,offset NumRepReadMemBench
          call    PutToReportBuf
          mov     si,offset MesRepStr3
          call    PutToReportBuf
          ret
ENDP GetMemBenchForRep

PROC GetPCIReport
          sub      ch,ch
          mov      cl,[NumPCIStr]
          or       cx,cx
          jz       PCIDevNotFound
          mov      [PCIDevRepOfs],0
          push     cx
          call     PrnRepLine
          mov      si,offset MesPciInstalledForRep
          call     PutToReportBuf

          mov      ax,'[ '
          call     PutWordToReportBuf

          mov      si,offset MesPCIBIOSVersion
          call     PutToReportBuf

          cmp     [NumMajorAGPVersion],0
          jz      short NoAGPBusForRep
          mov      ax,' ,'
          call     PutWordToReportBuf
          mov      si,offset MesAGPVersion
          call     PutToReportBuf

          cmp     [NumSupAGPRate],0
          jz       short NoAGPBusForRep
          mov      si,offset MesSupAGPRate
          call     PutToReportBuf

NoAGPBusForRep:
          mov      al,']'
          call     PutByteToReportBuf
          mov      ax,0A0Dh
          call     PutWordToReportBuf

          pop      cx
NextPCIDevRep:
          push     cx

          call     GetPCIDeviceFromBuffer

          mov      al,[NumberPCIBus]
          sub      ah,ah
          mov      di,offset NumRepPCIBus
          mov      cx,2
          call     BinToAscDec

          mov      al,[NumRepPCIDev]
          mov      di,offset NumNumRepPCIDev
          call     BinToAscDec

          mov      al,[NumRepPCIFun]
          mov      di,offset NumNumRepPCIFun
          mov      cx,1
          call     BinToAscDec

          mov      ax,[PCIVEN]
          mov      di,offset NumReportPCIVEN
          mov      cx,4
          call     BinToAscHex

          mov      ax,[PCIDEV]
          mov      di,offset NumReportPCIDEV
          call     BinToAscHex

          mov      al,[PCIRev]
          sub      ah,ah
          mov      di,offset NumReportPCIREV
          mov      cx,2
          call     BinToAscHex

          mov      ax,[PCISUBSYSVEN]
          mov      di,offset NumRepPCISUBSYSVEN
          mov      cx,4
          call     BinToAscHex

          mov      ax,[PCISUBSYSDEV]
          mov      di,offset NumRepPCISUBSYSDEV
          mov      cx,4
          call     BinToAscHex

          cmp     [HeaderType],1
          jnz     short NotHeaderType1ForRep
          mov     [SkipSubsys],0
NotHeaderType1ForRep:

          mov      si,offset MesRepPCIInfo
          call     PutToReportBuf
          mov      si,offset MesRepPrn13
          call     PutToReportBuf
          mov      si,offset MesReportPCIVEN
          call     PutToReportBuf
          mov      si,offset MesTab2611
          call     PutToReportBuf

          mov      [SkipSubsys],','

          mov      si,[NumPCIDevVendor]
          or       si,si
          jnz      short VendorPresentForRep
          mov      si,offset MesUnknownPCIVen
          call     PutToReportBuf
          jmp      short UnknownPCIVendorForRep

VendorPresentForRep:
          cmp      si,0FFFFh
          jz       short NotPrnPCIVendorForRep
          call     GetPCIDevNameForRep
          mov      al,' '
          call     PutByteToReportBuf

NotPrnPCIVendorForRep:
          mov      si,[NumPCIDevName]
          or       si,si
          jnz      short DevNamePresentForRep
          mov      si,offset MesUnknownPCIDev
          call     PutToReportBuf
          jmp      short UnknownPCIDevForRep
DevNamePresentForRep:
          call     GetPCIDevNameForRep
UnknownPCIDevForRep:
UnknownPCIVendorForRep:

          call     PrnClassCode

          mov      al,[HeaderType]
          or       al,al
          jz       short HeaderType0ForRep
          cmp      al,1
          jz       short HeaderType1ForRep
          cmp      al,2
          jz       short HeaderType2ForRep

          jmp      EndGetRepRange
HeaderType1ForRep:
          mov      [NumRepAdrNumber],'0'
          mov      eax,[MemBase0]
          mov      ebx,[MemBaseRange0]
          call     PrnMemBaseToBuf
          inc      [NumRepAdrNumber]
          mov      eax,[MemBase1]
          mov      ebx,[MemBaseRange1]
          call     PrnMemBaseToBuf

          jmp      EndGetRepRange
HeaderType2ForRep:
          mov      [NumRepAdrNumber],'0'
          mov      eax,[MemBase0]
          mov      ebx,[MemBaseRange0]
          call     PrnMemBaseToBuf
          inc      [NumRepAdrNumber]
          mov      eax,[MemBase1]
          mov      ebx,[MemBaseRange1]
          call     PrnMemBaseToBuf
          jmp      short EndGetRepRange

HeaderType0ForRep:

          mov      [NumRepAdrNumber],'0'
          mov      eax,[MemBase0]
          mov      ebx,[MemBaseRange0]
          call     PrnMemBaseToBuf
          inc      [NumRepAdrNumber]
          mov      eax,[MemBase1]
          mov      ebx,[MemBaseRange1]
          call     PrnMemBaseToBuf
          inc      [NumRepAdrNumber]
          mov      eax,[MemBase2]
          mov      ebx,[MemBaseRange2]
          call     PrnMemBaseToBuf
          inc      [NumRepAdrNumber]
          mov      eax,[MemBase3]
          mov      ebx,[MemBaseRange3]
          call     PrnMemBaseToBuf
          inc      [NumRepAdrNumber]
          mov      eax,[MemBase4]
          mov      ebx,[MemBaseRange4]
          call     PrnMemBaseToBuf
          inc      [NumRepAdrNumber]
          mov      eax,[MemBase5]
          mov      ebx,[MemBaseRange5]
          call     PrnMemBaseToBuf
EndGetRepRange:

          pop      cx
          loop     NextPCIDevRep
PCIDevNotFound:
          ret
ENDP GetPCIReport

PROC PrnClassCode
          mov      di,offset NumRepClassCode
          mov      cx,4
          mov      ax,[word ds:SubClass]
          call     BinToAscHex
          mov      di,offset NumRepClassCode+4
          mov      cx,2
          sub      ah,ah
          mov      al,[PIClass]
          call     BinToAscHex
          mov      si,offset MesRepClassCode
          call     PutToReportBuf
          call     GetClassCodeName
          call     PutToReportBuf
          ret
ENDP PrnClassCode

PROC GetClassCodeName
          mov      si,offset CPUIDunknown
          mov      ax,[word ds:SubClass]
          cmp      ah,12h
          jae      short EndClassCodeDetection
          or       ah,ah
          jz       short EndClassCodeDetection
          mov      si,offset PCIClassName

NextClassCodeFaind:
          cmp      ah,[byte ds:si+2]
          jz       short ClassCodeNameFaind
          call     FaindEndStr
          jmp      short NextClassCodeFaind
ClassCodeNameFaind:
          cmp      ax,[word ds:si+1]
          jz       short SubClassNameDetect
          call     FaindEndStr
          cmp      [byte ds:si+1],80h
          jz       short SubClassNameDetect
          jmp      short ClassCodeNameFaind
SubClassNameDetect:
          mov      di,si
          mov      bl,[PIClass]
NextPIClassFaind:
          cmp      bl,[byte ds:si]
          jz       short PIClassDetected
          call     FaindEndStr
          cmp      ax,[word ds:si+1]
          jz       short NextPIClassFaind
          mov      si,di
PIClassDetected:
          add      si,3

EndClassCodeDetection:
          ret
ENDP GetClassCodeName

PROC FaindEndStr
          add      si,2
NextEndStrFaind:
          inc      si
          cmp      [byte ds:si],0
          jnz      NextEndStrFaind
          inc      si
          ret
ENDP FaindEndStr

PROC PrnMemBaseToBuf
          or       eax,eax
          jz       MemBaseNotDetectForRep
          cmp      eax,0FFFFFFFFh
          jz       MemBaseNotDetectForRep

          push     eax
          push     ebx

          test     al,1
          jnz      short DetectedIOBase
          and      al,0F0h

          mov      si,offset MesRepMemoryBase
          or       ebx,ebx
          jz       short GoToRepMemOrIO
          mov      si,offset MesRepMemoryBaseRange
          jmp      short GoToRepMemOrIO
DetectedIOBase:
          and      al,0FCh
          mov      si,offset MesRepIOBase
          or       ebx,ebx
          jz       short GoToRepMemOrIO
          mov      si,offset MesRepIOBaseRange
GoToRepMemOrIO:
          call     PutToReportBuf
          mov      si,offset NumRepAdrNumber
          call     PutToReportBuf

          call     PrnMemPCIAdr

          pop      ebx
          pop      eax
          or       ebx,ebx
          jz       short MemBaseRangeNotDetectForRep
          mov      si,offset MesRepMinus
          call     PutToReportBuf
          push     eax
          mov      eax,ebx
          call     PrnMemPCIAdr
          pop      eax

          mov      si,offset MesRepRengeLegth
          call     PutToReportBuf

          test     al,1
          jnz      short DetectedIOBaseForRange
          and      al,0F0h
DetectedIOBaseForRange:
          and      al,0FCh
          inc      ebx
          sub      ebx,eax
          cmp      ebx,1024
          mov      di,offset MesRepRangeInByte
          jb       short GoToPrnBaseRengLength
          shr      ebx,10
          cmp      ebx,1024
          mov      di,offset MesRepRangeInKB
          jb       short GoToPrnBaseRengLength
          shr      ebx,10
          mov      di,offset MesRepRangeInMB
GoToPrnBaseRengLength:
          mov      ax,bx
          mov      cx,5
          call     BinToAscDec
          mov      si,di
          call     NonZeroPrn
          call     PutToReportBuf

MemBaseRangeNotDetectForRep:
MemBaseNotDetectForRep:
          ret
ENDP PrnMemBaseToBuf

PROC PrnMemPCIAdr
          push     eax
          push     ebx
          mov      cx,4
          mov      di,offset NumMemoryBaseL
          call     BinToAscHex
          shr      eax,16
          or       ax,ax
          jz       short NotHighWordInMemBaseRep
          mov      di,offset NumMemoryBaseH
          call     BinToAscHex
          mov      si,offset NumMemoryBaseH
          call     PutToReportBuf
          jmp      short PrnHwordOK
NotHighWordInMemBaseRep:
          mov      si,offset NumMemoryBaseL
          call     PutToReportBuf
PrnHwordOK:
          pop      ebx
          pop      eax
          ret
ENDP PrnMemPCIAdr

PROC GetPCIDevNameForRep
          mov      di,offset NumPCIVendor
          push     ds
          push     [NumPCISeg]
          pop      ds
          ALIGN 2
NextPutBytePCIForRep:
          lodsb
          or       al,al
          jz       short EndStrForPCIrep
          cmp      al,1
          jz       short EndStrForPCIrep
          cmp      al,2
          jz       short EndStrForPCIrep
          stosb
          jmp      short NextPutBytePCIForRep
          ALIGN 2
EndStrForPCIrep:
          sub       al,al
          stosb
          pop      ds
          mov      si,offset NumPCIVendor
          call     UnpackPCIString
          push     es
          push     [ReportDataSeg] ;Сегмент для для файла отчета
          pop      es
          mov      di,[CounterRepBuf]
          mov      si,offset NumPCIVendor
NextPutBytePCIForRepBuf:
          lodsb
          or       al,al
          jz       short EndStrForPCIRepBuf
          stosb
          jmp      short NextPutBytePCIForRepBuf
EndStrForPCIRepBuf:
          mov      [CounterRepBuf],di
          pop      es
          ret
ENDP GetPCIDevNameForRep

PROC GetMemorySize
          sub     ebx,ebx
          mov     [NumMemMapBlocks],bl
          mov     ecx,ebx
GetNextMemMap:
          call    GetMemMap
          jc      short NotSupportMemMapDetect
          inc     [NumMemMapBlocks]
          cmp     edx,1
          jnz     short MemFromOS
          add     ecx,eax
MemFromOS:
          or      ebx,ebx
          jnz     short GetNextMemMap
          mov     eax,ecx
          jecxz   short NotSupportMemMapDetect
          sub     edx,edx
          mov     ebx,1024*1024
          div     ebx
          or      edx,edx
          jz      short MemMapGeting
          inc     ax
MemMapGeting:
          jmp     short MemMapGetOK
NotSupportMemMapDetect:
          sub     ecx,ecx
          mov     edx,ecx
          mov     ax,0E801h
          int     15h
          jc      short oldstylemem
          and     edx,0ffffh
          shl     edx,6
          and     ecx,0ffffh
          add     ecx,edx
          jz      short oldstylemem
          mov     eax,ecx
          jmp     short MemUp64MbDetect
oldstylemem:
          cli
          sub     eax,eax
          mov     al,18h
          out     70h,al
          jmp     $+2
          in      al,71h
          sti
          xchg    ah,al
MemUp64MbDetect:
          mov     ebx,1024
          add     eax,ebx
          shr     eax,10
MemMapGetOK:
          mov     [MemorySize],ax
          dec     ax
          movzx   eax,ax
          shl     eax,18
          mov     [XMSmemLength],eax
          ret
ENDP GetMemorySize

PROC GoPrnMesHDDforWin
          add     al,48
          mov     [NumberHDD],al
          mov     [LitingPriznak],7+8
          dec     [YposForPrn]
          call    PrnMesForWin
PROC PrnMesHDDforWin
          mov     si,offset MesHDDForWin
          call    ColorStr6x8
          ret
ENDP PrnMesHDDforWin
ENDP GoPrnMesHDDforWin

PROC GoPrnMesCDforWin
          mov     al,[DefaultDrive]
          add     al,48
          mov     [NumberCD],al
          mov     [LitingPriznak],7+8
          call    PrnMesForWin
PROC PrnMesCDforWin
          mov     si,offset MesCDForWin
          call    ColorStr6x8
          ret
ENDP PrnMesCDforWin
ENDP GoPrnMesCDforWin

PROC PrnMesForWin
          mov     si,offset MesForWin
          call    ColorStr6x8
          ret
ENDP PrnMesForWin

PROC PrnFFullTest
          mov     si,offset MesFullTestStart
          call    ColorStr6x8
          mov     si,offset MesESC
          call    ColorStr6x8
          mov     [Method],1
          call    GetCh
          cmp     al,0Dh
          ret
ENDP PrnFFullTest

PROC PrnCompareWindow
          mov     ax,9
          mov     bx,397
          mov     dx,64-3
          mov     cx,358
          sub     bp,bp
          call    Rectangle
          mov     cx,[CompareGraph]
          mov     ax,13
          mov     bx,423
          mov     dx,9
          mov     bp,1+8
          call    rectangle
PROC PrnBaseCompareWindow
          mov     ax,12
          mov     bx,421
          mov     cx,350
          mov     dx,ax
          mov     bp,3+8
          call    ColorFrame
          mov     ax,8
          sub     bx,26
          add     dx,52
          add     cx,8
          call    ColorFrame
          ret
ENDP PrnBaseCompareWindow
ENDP PrnCompareWindow

PROC CpuSpeed
          push    cx
          push    bx
          push    es
          push    ds
          mov     ax,[EndProgram]
          mov     es,ax
          sub     di,di
          push    cs
          pop     ds
          cld
          mov     si,offset CPU_SS
          mov     cx,25+12
          rep movsb
          mov     cx,10240
NextDivEax:
          mov     ax,0F766h
          stosw
          mov     al,0F0h
          stosb
          loop    short NextDivEax
          mov     si,offset CPU_SE
          mov     cx,25
          rep movsb
          pop     ds
          pop     es
          mov     si,offset RemoteCall
          call    [dword ds:si]
          pop     bx
          pop     cx
          ret
ENDP CpuSpeed

PROC CPUSpeedStart
CPU_SS:
          in      al,061h
          and     al,0FCh
          out     061h,al
          mov     al,0B4h
          out     043h,al
          xor     al,al
          out     042h,al
          jmp     $+2
          out     042h,al
          in      al,061h
          or      al,001h
          cli
          out     061h,al
          sub     edx,edx
          mov     eax,edx
          inc     eax
ENDP CPUSpeedStart
PROC CPUSpeedEnd
CPU_SE:
          in      al,061h
          and     al,0FCh
          out     061h,al
          in      al,042h
          mov     ah,al
          in      al,042h
          xchg    al,ah
          neg     ax
          sti
          movzx   eax,ax
          retf
ENDP CPUSpeedEnd

PROC DetectMHZ
          cmp     [NotNidedRepCPUFrec],1
          jz      short NotNidedRepCPUFrecuency

          mov     ax,[OriginalFrequency]
          or      ax,ax
          jnz     short OriginalFreqDetected
          mov     ax,[MHzTSC]
          or      ax,ax
          jnz     short SpeedViaTSCpassed
          xor     edx,edx
          mov     eax,[DevMHZ]
          div     [Mhz]
SpeedViaTSCpassed:
          call    GetCorrectFrec
          mov     [CorrectFrec],ax

OriginalFreqDetected:
          mov     di,offset NumHastota
          mov     cx,5
          call    BinToAscDec
          call    NZInMes
          mov     si,offset Hastota
          call    colorstr6x8
NotNidedRepCPUFrecuency:
          ret
ENDP DetectMHZ

PROC DetectCPUclass
          P186
          pushf
          pop     ax
          mov     cx,ax
          and     ax,0FFFh
          push    ax
          popf
          pushf
          pop     ax
          and     ax,0F000h
          cmp     ax,0F000h
          mov     [CPUclass],1
          jz      short CPUdetectComplite
          P286
          smsw    ax
          and     ax,1
          or      cx,0F000h
          push    cx
          popf
          pushf
          pop     ax
          and     ax,0F000h
          mov     [CPUclass],2 ;286 proc
          jz      short CPUdetectComplite
          P386
          pushfd
          pop     edx
          mov     ecx,edx
          xor     edx,40000h
          push    edx
          popfd
          pushfd
          pop     edx
          push    ecx
          popfd
          xor     edx,ecx
          and     edx,40000h ;Test Alignment Check Bit
          mov     [CPUclass],3
          jz      short CPUdetectComplite
          P486
          pushfd
          pop     eax
          mov     ecx,eax
          xor     eax,00200000h
          push    eax
          popfd
          pushfd
          pop     eax
          xor     eax,ecx
          mov     [CPUclass],4
          jz      short CPUdetectComplite
          mov     [CPUIDsupport],1
CPUdetectComplite:
          P286
          P287
          fninit
          mov     ax,05A5Ah
          fnstsw  ax
          or      ax,ax
          jne     short FpuNotPresent
          mov     [FPUcheck],1
FpuNotPresent:
          xor     ah,ah
          mov     al,[CPUclass]
          ret
ENDP DetectCPUclass

PROC CPUIDmethod
          cmp     [CPUIDsupport],1
          jnz     NotSupportCPUID
          P586
          xor     eax,eax
          cpuid
          P386
          mov     [CPUIDLevelSupport],al
          mov     [VendorIDstring1],ebx
          mov     [VendorIDstring2],edx
          mov     [VendorIDstring3],ecx
          mov     di,offset AuthenticAMD
          call    CompareVendors
          jnz     short NotAMDprocessor
          mov     [AMDProcessor],1
NotAMDprocessor:
          mov     di,offset GenuineIntel
          call    CompareVendors
          jnz     short NotIntelprocessor
          mov     [IntelProcessor],1
NotIntelprocessor:
          mov     di,offset CyrixInstead
          call    CompareVendors
          jnz     short NotCyrixprocessor
          mov     [CyrixProcessor],1
NotCyrixprocessor:
          mov     di,offset CentaurHauls
          call    CompareVendors
          jnz     short NotIDTprocessor
          mov     [IDTProcessor],1
NotIDTprocessor:
          mov     di,offset NexGenDriven
          call    CompareVendors
          jnz     short NotNexGenprocessor
          mov     [NexGenProcessor],1
NotNexGenprocessor:
          mov     di,offset RiseRocks
          call    CompareVendors
          jnz     short NotRiseProcessor
          mov     [RiseProcessor],1
NotRiseProcessor:
          mov     di,offset GenuineTMx86
          call    CompareVendors
          jnz     short NotTransmetaProcessor
          mov     [TransmetaProcessor],1
NotTransmetaProcessor:

          mov     di,offset SiSSiSSiS
          call    CompareVendors
          jnz     short NotSiSProcessor
          mov     [SiSProcessor],1
NotSiSProcessor:
          cmp     [CPUIDLevelSupport],1
          jb      Level2CPUIDNotSupport
          mov     eax,1
          sub     ebx,ebx
          P586
          cpuid
          mov     [BrandID],bl
          mov     [CPUSerialNumberEAX],eax
          push    eax
          and     al,0Fh
          mov     [CPUStepping],al
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

          mov     [FeatureFlag],edx
          test    edx,10h
          jz      short NotSupportTSCinstr
          mov     [FeatureFlagTSC],1
NotSupportTSCinstr:
          test    edx,20h
          jz      short NotSupportMSRinstr
          mov     [FeatureFlagMSR],1
NotSupportMSRinstr:
          test    edx,800000h
          jz      short NotSupportMMXinstr
          mov     [FeatureFlagMMX],1
NotSupportMMXinstr:
          test    edx,2000000h
          jz      short NotSupportSSEinstr
          mov     [FeatureFlagSSE],1
NotSupportSSEinstr:
          test    edx,4000000h
          jz      short NotSupportSSE2instr
          mov     [FeatureFlagSSE2],1
NotSupportSSE2instr:
          cmp     [IntelProcessor],1
          jnz     short NotSupportSNinstr
          test    edx,40000h
          jz      short NotSupportSNinstr
          mov     [FeatureFlagSN],1
NotSupportSNinstr:

          cmp     [CPUIDLevelSupport],2
          jb      short Level2CPUIDNotSupport
          mov     eax,2 ;GetCacheInfo
          cpuid
          mov     [RegEAXCPUIDlevel2],eax
          mov     [RegEBXCPUIDlevel2],ebx
          mov     [RegECXCPUIDlevel2],ecx
          mov     [RegEDXCPUIDlevel2],edx
Level2CPUIDNotSupport:

          cmp     [FeatureFlagSN],1
          jnz     short Level3CPUIDNotSupport
          mov     eax,3 ;GetSN
          cpuid
          mov     [CPUSerialNumberECX],ecx
          mov     [CPUSerialNumberEDX],edx
Level3CPUIDNotSupport:

          mov     eax,80000000h
          P586
          cpuid
          P386
          cmp     eax,80000000h
          jbe     NoExtendedCPUIDsupport
          mov     [ExtCPUIDLevelSupport],eax
          mov     eax,80000001h
          P586
          cpuid
          P386
          push    ax
          and     al,0Fh
          mov     [ExtCPUStepping],al
          pop     ax
          shr     ax,4
          push    ax
          and     al,0Fh
          mov     [ExtCPUmodel],al
          pop     ax
          shr     ax,4
          push    ax
          and     al,0Fh
          mov     [ExtCPUfamily],al
          pop     ax
          shr     ax,4
          and     al,03h
          mov     [ExtCPUtype],al
          mov     [ExtFeatureFlag],edx
          test    edx,80000000h ;bit31
          jz      short Amd3DnowNotSupport
          mov     [FeatureFlagAMD3D],1
Amd3DnowNotSupport:

          test    edx,40000000h
          jz      short Amd3DnowExtNotSupport
          mov     [FeatureFlagAMD3DExt],1
Amd3DnowExtNotSupport:
          cmp     [ExtCPUIDLevelSupport],80000004h
          jb      NotSupportCPUName
          mov     si,offset CPUName
          call    GetAMDCpuName

          cmp     [ExtCPUIDLevelSupport],80000005h
          jb      short NotSupportCacheInfo
          mov     eax,80000005h
          P586
          cpuid
          P386
          mov     [ExtCPUIDCacheL1InfoECX],ecx
          mov     [ExtCPUIDCacheL1InfoEDX],edx
          cmp     [ExtCPUIDLevelSupport],80000006h
          jb      short NotSupportCacheInfo
          mov     eax,80000006h
          P586
          cpuid
          P386
          mov     [ExtCPUIDCacheL2InfoECX],ecx
NotSupportCacheInfo:
NotSupportCPUName:
          mov     eax,80860000h
          P586
          cpuid
          P386
          cmp     eax,80860006h
          jb      short TransmetaExtendedCPUIDNotSupport
          mov     si,offset CPUName
          call    GetTransmetaCPUName
TransmetaExtendedCPUIDNotSupport:

NoExtendedCPUIDsupport:

          cmp     [IntelProcessor],1
          jnz     short NotIntelCPUForGetCacheInfo
          mov     edx,[RegEDXCPUIDlevel2]
          call    GetIntelCacheInfo
          mov     edx,[RegECXCPUIDlevel2]
          call    GetIntelCacheInfo
          mov     edx,[RegEBXCPUIDlevel2]
          call    GetIntelCacheInfo
          mov     edx,[RegEAXCPUIDlevel2]
          sub     dl,dl
          call    GetIntelCacheInfo
NotIntelCPUForGetCacheInfo:
          cmp     [AMDProcessor],1
          jnz     short NotAMDCPUForGetCacheInfo
          cmp     [ExtCPUIDLevelSupport],80000005h
          jb      short NotAMDCPUForGetCacheInfo
          mov     eax,[ExtCPUIDCacheL1InfoECX]
          shr     eax,24
          mov     ebx,[ExtCPUIDCacheL1InfoEDX]
          shr     ebx,24
          add     ax,bx
          or      ax,ax
          jz      short NotAMDCPUForGetCacheInfo
          mov     [CacheL1],ax
          cmp     [ExtCPUIDLevelSupport],80000006h
          jb      short NotAMDCPUForGetCacheInfo
          mov     eax,[ExtCPUIDCacheL2InfoECX]
          shr     eax,16
          or      ax,ax
          jz      short NotAMDCPUForGetCacheInfo

          cmp     [word ds:CPUmodel],256*6+3;AMD Duron ?
          jnz     short NotAmdDuronForL2size
          cmp     [CPUstepping],0           ;steping A0?
          jnz     short NotAmdDuronForL2size
          mov     ax,64
NotAmdDuronForL2size:
          mov     [CacheL2],ax
NotAMDCPUForGetCacheInfo:

NotSupportCPUID:

;     mov   [IntelProcessor],0  ;Для отладки!!!
;     mov   [AMDProcessor],1
;     mov   [CPUstepping],3
;     mov   [word ds:CPUmodel],0Fh*256+3h
;     mov   [byte ds:BrandID],6
          ret
ENDP CPUIDmethod

PROC GetIntelCacheInfo
          call    GetIntelCacheSize
          shr     edx,8
          call    GetIntelCacheSize
          shr     edx,8
          call    GetIntelCacheSize
          shr     edx,8
          call    GetIntelCacheSize
          ret
ENDP GetIntelCacheInfo

PROC CompareVendors
          mov     si,offset VendorIDstring1
          mov     cx,12
          cld
          repe cmpsb
          ret
ENDP CompareVendors

PROC PrintProcessor
          mov     si,offset ProcessorMes
          call    colorstr6x8
          cmp     [CPUIDsupport],1
          jz      short ProcCPUIDSupport
          call    Cyrix52method
          cmp     [Cyrix52detect],1
          jz      EndCPUdetect
          cmp     [CPUclass],3
          jnz     short detectCpu486dx
          mov     eax,cr0
          mov     ebx,eax
          or      al,10h
          mov     cr0,eax
          mov     eax,cr0
          mov     cr0,ebx
          test    al,10h
          mov     si,offset Mes80386sx
          jz      short detect386dx
          mov     si,offset Mes80386dx
detect386dx:
          mov     [NumRepCPUModel],si
          jmp     EndCPUdetectprn
detectCpu486dx:
          mov     si,offset mes80486dx
          cmp     [FPUcheck],1
          jz      short FPUpresent
          mov     si,offset mes80486sx
FPUpresent:
          cmp     [CPUclass],4
          mov     [NumRepCPUModel],si
          jz      EndCPUdetectprn
          mov     si,offset CPUIDunknown
          mov     [NumRepCPUModel],si
          jmp     EndCPUdetectprn

ProcCPUIDSupport:

          cmp     [IntelProcessor],1
          jnz     NoIntelCPU

          mov     si,offset Intel
          mov     [NumRepCPUVendor],si
          call    colorstr6x8
          mov     ax,[word ds:CPUmodel]
          cmp     ah,4
          jnz     short PentiumDetect
          mov     si,offset intel486dx
          or      al,al
          jz      IntelCPUdetect
          cmp     al,1   ;4 1
          jz      IntelCPUdetect
          mov     si,offset intel486sx
          cmp     al,2   ;4 2
          jz      IntelCPUdetect
          mov     si,offset intel486dx2
          cmp     al,3   ;4 3
          jz      IntelCPUdetect
          mov     si,offset intel486sl
          cmp     al,4   ;4 4
          jz      IntelCPUdetect
          mov     si,offset intel486sx2
          cmp     al,5   ;4 5
          jz      IntelCPUdetect
          mov     si,offset inteldx2wb
          cmp     al,7   ;4 7
          jz      IntelCPUdetect
          mov     si,offset inteldx4
          cmp     al,8   ;4 8
          jz      IntelCPUdetect
          mov     si,offset intel486
          jmp     IntelCPUdetect
PentiumDetect:
          cmp     ah,5     ;5
          jnz     short DetectP6class
          mov     si,offset pentiumvr
          cmp     al,7   ;5 7
          jz      IntelCPUdetect
          mov     si,offset pentiummmx
          cmp     al,4   ;5 4
          jz      IntelCPUdetect
          cmp     al,8   ;5 8
          jz      IntelCPUdetect
          mov     si,offset pentium
          jmp     IntelCPUdetect

DetectP6class:
          cmp     ah,6
          jnz     NotP6class
          mov     [DevMHZ],4765138
          mov     si,offset pentiumpro
          or      al,al
          jz      IntelCPUdetect
          cmp     al,1
          jz      IntelCPUdetect
          mov     dl,[byte ds:RegEDXCPUIDlevel2]
          cmp     al,6
          jbe     short DetectP2CelXeon
          cmp     al,7
          jz      short DetectP3CelXeon
          cmp     al,8
          jz      short DetectP3CelXeon
          cmp     al,0Ah
          jz      short DetectP3CelXeon
          cmp     al,0Bh
          jz      short DetectP3CelTualatin

          mov     si,offset pentium3
          jmp     IntelCPUdetect
DetectP2CelXeon:
          mov     si,offset Celeron
          cmp     dl,40h     ;L2  cache 0?
          jz      IntelCPUdetect
          cmp     dl,41h     ;L2  cache 128KB?
          jz      IntelCPUdetect
          mov     si, offset Xeon
          cmp     dl,44h     ;L2  cache 1MB?
          jae     IntelCPUdetect
          mov     si,offset pentium2
          jmp     IntelCPUdetect
DetectP3CelTualatin:
          mov     si,offset Celeron
          cmp     [BrandID],3
          jz      IntelCPUdetect
          cmp     [BrandID],7
          jz      IntelCPUdetect
          mov     si,offset Pentium3m
          cmp     [BrandID],6
          jz      IntelCPUdetect
          mov     si,offset Pentium3
          jmp     IntelCPUdetect

DetectP3CelXeon:
          mov     si,offset Pentium3xeon
          cmp     [BrandID],3
          jz      IntelCPUdetect
          mov     si,offset Pentium3
          cmp     [BrandID],2
          jz      IntelCPUdetect
          mov     si,offset Celeron
          cmp     [BrandID],1
          jz      IntelCPUdetect
          cmp     dl,40h     ;L2  cache 0?
          jz      IntelCPUdetect
          cmp     dl,41h     ;L2  cache 128KB?
          jz      IntelCPUdetect
          mov     si,offset Pentium3
          jmp     IntelCPUdetect
NotP6class:
          cmp     ah,7
          jnz     short NotP7class
          mov     si,offset IntelItanium
          jmp     IntelCPUdetect

NotP7class:
          cmp     ah,0Fh
          jnz     short Not0Fclass

          cmp     [IntelExtendedFamily],0
          jnz     NoIntelP4coreInExt
          cmp     al,1
          ja      Detect013P4Core
          mov     si,offset pentium4Xeon
          cmp     [BrandID],0Eh
          jz      short IntelCPUdetect
          cmp     [BrandID],0Bh
          jz      short IntelCPUdetect
          mov     si,offset Celeron
          cmp     [BrandID],0Ah
          jz      short IntelCPUdetect
          mov     si,offset Pentium4
          jmp     short IntelCPUdetect
Detect013P4Core:
          cmp     al,2
          jnz     NoIntelP4013core
          mov     si,offset pentium4Xeon
          cmp     [BrandID],0Bh
          jz      short IntelCPUdetect
          cmp     [BrandID],0Ch
          jz      short IntelCPUdetect
          mov     si,offset Celeron
          cmp     [BrandID],08h
          jz      short IntelCPUdetect
          cmp     [BrandID],0Fh
          jz      short IntelCPUdetect
          cmp     [BrandID],0Ah
          jz      short IntelCPUdetect
          mov     si,offset Pentium4
          jmp     short IntelCPUdetect
NoIntelP4013core:
          cmp     al,3
          jnz     NoIntelP4coreInExt
          mov     si,offset Pentium4
          jmp     short IntelCPUdetect

NoIntelP4coreInExt:
          cmp     [IntelExtendedFamily],1
          jnz     NoIntelMcKinley
          mov     si,offset IntelItanium2
          jmp     IntelCPUdetect
NoIntelMcKinley:


Not0Fclass:
          mov     si,offset CPUIDunknown
IntelCPUdetect:
          jmp     EndCPUdetectprn

NoIntelCPU:
          cmp     [AMDProcessor],1
          jnz     NoAmdCPU
          mov     si,offset amd
          mov     [NumRepCPUVendor],si
          call    colorstr6x8
          mov     ax,[word ds:CPUmodel]
          cmp     ah,4      ;4 0
          jnz     short DetectAmdClass5
          mov     si,offset amd486dx2
          cmp     al,3
          jz      AmdCPUdetect
          mov     si,offset amd486dx2wb
          cmp     al,7
          jz      AmdCPUdetect
          mov     si,offset amd486dx4
          cmp     al,8
          jz      AmdCPUdetect
          mov     si,offset amd486dx4wb
          mov     [DevMHZ],4894640
          cmp     al,9
          jz      AmdCPUdetect
          mov     si,offset amd5x86
          cmp     al,14
          jz      AmdCPUdetect
          mov     si,offset amd5x86wb
          cmp     al,15
          jz      AmdCPUdetect
          mov     si,offset amd5x86
          jmp     AmdCPUdetect
DetectAmdClass5:
          cmp     ah,5      ;5 0
          jnz     short DetectAmdClass6
          mov     [DevMHZ],4550041
          mov     si,offset amdk5
          cmp     al,0   ;5 0
          jz      AmdCPUdetect
          cmp     al,1   ;5 1
          jz      AmdCPUdetect
          cmp     al,2   ;5 2
          jz      AmdCPUdetect
          cmp     al,3   ;5 3
          jz      AmdCPUdetect
          mov     [DevMHZ],2464826
          mov     si,offset amdk6
          cmp     al,6   ;5 6
          jz      AmdCPUdetect
          cmp     al,7   ;5 7
          jz      AmdCPUdetect
          mov     si,offset amdk63d
          cmp     al,8   ;5 8
          jz      AmdCPUdetect
          mov     si,offset amdk6III
          cmp     al,9   ;5 9
          jz      AmdCPUdetect
          cmp     al,0Dh ;5 D
          jnz     short NotAMDk62k62orIIIplus
          mov     si,offset amdk62plus
          cmp     [CPUstepping],3
          ja      AmdCPUdetect
          mov     si,offset amdk6IIIplus
          jmp     AmdCPUdetect
NotAMDk62k62orIIIplus:

          mov     si,offset amdk6
          jmp     AmdCPUdetect

DetectAmdClass6:
          cmp     ah,6
          jnz     short NoAMDClass6
          mov     [DevMHZ],4804421
          mov     si,offset AmdAthlon
          cmp     ax,1537   ;6 1
          jz      short AmdCPUdetect
          cmp     ax,1538   ;6 2
          jz      short AmdCPUdetect
          cmp     ax,256*6+4
          jz      short AmdCPUdetect
          mov     si,offset AmdDuron
          cmp     ax,256*6+3
          jz      short AmdCPUdetect
          cmp     ax,256*6+7
          jz      short AmdCPUdetect
          mov     si,offset AmdAthlon4
          cmp     ax,256*6+6
          jz      short AmdAthlonXPCPUdetect
          cmp     ax,256*6+8
          jz      short AmdAthlonXPCPUdetect
          cmp     ax,256*6+10
          jnz     short NotAmdAthlonXP

AmdAthlonXPCPUdetect:
          mov     si,offset amdAthlonXP
          cmp     [word ds:CPUName+15],'PX' ;AMD Athlon(tm) XP 1700+
          jz      short AmdCPUAlonXPdetect
          mov     si,offset amdAthlonMP
          cmp     [word ds:CPUName+15],'PM' ;AMD Athlon(tm) MP 1700+
          jz      short AmdCPUAlonXPdetect

          mov     si,offset AmdAthlon
          jmp     short AmdCPUdetect

AmdCPUAlonXPdetect:
          mov     [NotNidedRepCPUFrec],1
          mov     edx,[dword ds:CPUName+18]
          mov     [dword ds:amdAthlonXPclk],edx
          mov     [dword ds:amdAthlonMPclk],edx
          jmp     short AmdCPUdetect
NotAmdAthlonXP:
          mov     si,offset amdK7
          jmp     short AmdCPUdetect


NoAMDClass6:
          cmp     ah,0Fh
          jnz     short Not0FclassForAMD

          cmp     [IntelExtendedFamily],0
          jnz     NoAMDk8coreInExt
          mov     si,offset AmdOpteron
          cmp     al,5
          jz      short AmdCPUdetect
          mov     si,offset amdK8
          jmp     short AmdCPUdetect
NoAMDk8coreInExt:

Not0FclassForAMD:

          mov     si,offset CPUIDunknown

AmdCPUdetect:
          jmp     EndCPUdetectprn
NoAmdCPU:
          cmp     [CyrixProcessor],1
          jnz     NoCyrixCPU
          mov     ax,[word ds:CPUmodel]
          cmp     ah,6
          jb      short NotVIACyrixIII
          mov     si,offset VIA
          mov     [NumRepCPUVendor],si
          call    colorstr6x8
          mov     [DevMHZ],1597501
          cmp     ax,6*256+5
          mov     si, offset CyrixIII
          jz      short CyrixCPUdetect

          jmp     short CyrixCPUdetect
NotVIACyrixIII:
          mov     [DevMHZ],1597501
          mov     si,offset Cyrix
          mov     [NumRepCPUVendor],si
          call    colorstr6x8
          mov     ax,[word ds:CPUmodel]
          mov     si,offset mediaGX
          cmp     ax,4*256+4;4 4
          jz      short CyrixCPUdetect
          mov     si,offset cyrix5x86
          cmp     ax,4*256+9
          jz      short CyrixCPUdetect
          cmp     ah,4
          jz      short CyrixCPUdetect

          mov     [DevMHZ],1597501
          mov     si,offset cyrix6x86
          cmp     ax,5*256+2 ;5 2
          jz      short CyrixCPUdetect
          mov     si,offset cyrixGxm
          cmp     ax,5*256+4;1284 ;5 4
          jz      short CyrixCPUdetect
          mov     si,offset cyrix6x86
          cmp     ah,5
          jz      short CyrixCPUdetect

          mov     si,offset cyrixMII
          cmp     al,0
          ja      short CyrixCPUdetect
          cli
          mov     al,0FFh ;DIR1
          out     22h,al
          in      al,23h
          sti
          cmp     al,8
          jae     short CyrixCPUdetect
          mov     si,offset cyrix6x86MX

          jmp     short CyrixCPUdetect

CyrixCPUUnknown:
          mov     si,offset CPUIDunknown
CyrixCPUdetect:
          jmp     EndCPUdetectprn
NoCyrixCPU:
          mov     ax,[word ds:CPUmodel]
          cmp     [IDTProcessor],1
          jnz     short NoIDTCPU
          cmp     ah,6
          jnz     short NotCyrixIII
          mov     si,offset VIA
          mov     [NumRepCPUVendor],si
          call    colorstr6x8
          mov     si, offset CyrixIII
          cmp     ax,6*256+6
          jz      short IDTCPUdetect
          mov     si, offset ViaC3
          cmp     ax,6*256+7
          jz      short IDTCPUdetect
          cmp     ax,6*256+8
          jz      short IDTCPUdetect
          cmp     ax,6*256+9
          jz      short IDTCPUdetect
          mov     si, offset CyrixIII

          jmp     short IDTCPUdetect

NotCyrixIII:
          mov     si,offset IDT
          mov     [NumRepCPUVendor],si
          call    colorstr6x8
          cmp     ax,1288
          mov     si,offset winchip2
          jz      short IDTCPUdetect
          cmp     ax,1289
          mov     si,offset winchip3
          jz      short IDTCPUdetect
          cmp     ah,5;1284 ;5 4
          mov     si,offset winchipc6
          jz      short IDTCPUdetect
          mov     si,offset CPUIDunknown
IDTCPUdetect:
          jmp     EndCPUdetectprn
NoIDTCPU:
          cmp     [NexGenProcessor],1
          jnz     short NoNexGenCPU
          mov     si,offset NexGen
          mov     [NumRepCPUVendor],si
          call    colorstr6x8
          mov     ax,[word ds:CPUmodel]
          mov     si,offset Nx586
          cmp     ah,5
          jz      short NexGenCPUdetect
          mov     si,offset CPUIDunknown
NexGenCPUdetect:
          jmp     short EndCPUdetectprn
NoNexGenCPU:
          cmp     [RiseProcessor],1
          jnz     short NoRiseCPU
          mov     si,offset Rise
          mov     [NumRepCPUVendor],si
          call    colorstr6x8
          mov     ax,[word ds:CPUmodel]
          cmp     ah,5
          jnz     short NoRisepP5class

          mov     si,offset RisemP6
          cmp     al,0
          jz      short EndCPUdetectprn
          cmp     al,2
          jz      short EndCPUdetectprn
          mov     si,offset RisemP62
          cmp     al,8
          jz      short EndCPUdetectprn
          cmp     al,9
          jz      short EndCPUdetectprn
          mov     si,offset RisemP62
          jmp     short EndCPUdetectprn
NoRisepP5class:
          mov     si,offset CPUIDunknown
          jmp     short EndCPUdetectprn

NoRiseCPU:
          cmp     [TransmetaProcessor],1
          jnz     short NoTransmetaCPU
          mov     si,offset Transmeta
          mov     [NumRepCPUVendor],si
          call    colorstr6x8
          mov     si,offset TMCrusoe
          call    colorstr6x8
          jmp     short EndCPUdetectprn

NoTransmetaCPU:

          cmp     [SiSProcessor],1
          jnz     short NoSiSCPU
          mov     si,offset SiS
          mov     [NumRepCPUVendor],si
          call    colorstr6x8
          cmp     ah,5
          jnz     short Not55xClass
          cmp     al,0
          jnz     short Not55xModel
          mov     si,offset SiS55x
          jmp     short EndCPUdetectprn
Not55xModel:
Not55xClass:
          mov     si,offset CPUIDunknown
          jmp     short EndCPUdetectprn
NoSiSCPU:



          mov     si,offset VendorIDstring1
EndCPUdetectprn:
          mov     [NumRepCPUModel],si
          call    colorstr6x8
EndCPUdetect:
          ret
ENDP PrintProcessor

PROC PrintCPUparam
          mov     si,offset MesCPUIDnotSupport
          cmp     [CPUIDsupport],1
          jnz     NotCPUparam
          cmp     [CPUIDLevelSupport],1
          jb      NotCPUparam

          mov     cx,4
          mov     ax,[word ds:FeatureFlag+2]
          mov     di,offset NumFeatureRegH
          call    BinToAscHex
          mov     ax,[word ds:FeatureFlag]
          mov     di,offset NumFeatureRegL
          call    BinToAscHex

          xor     ah,ah
          mov     cx,1
          mov     al,[CPUtype]
          mov     di,offset NumCPUtype
          call    BinToAscHex
          xor     ah,ah
          mov     al,[CPUfamily]
          mov     di,offset NumCPUfamily
          call    BinToAscHex
          xor     ah,ah
          mov     al,[CPUmodel]
          mov     di,offset NumCPUmodel
          call    BinToAscHex
          xor     ah,ah
          mov     al,[CPUstepping]
          mov     di,offset NumCPUstepping
          call    BinToAscHex
          mov     si, offset MesCPUparam
          call    colorstr6x8

          mov     ax,[word ds:CPUmodel]
          cmp     [AMDProcessor],1
          jnz     short NotAMDCPUForCodeName
          call    DetectAMDCodeName
          jnc     short DetectedCodeName

NotAMDCPUForCodeName:
          cmp     [IntelProcessor],1
          jnz     short NotIntelCPUForCodeName
          call    DetectIntelCodeName
          jnc     short DetectedCodeName

NotIntelCPUForCodeName:

          cmp     [CyrixProcessor],1
          jnz     short NotCyrixCPUForCodeName
          call    DetectCyrixCodeName
          jnc     short DetectedCodeName

NotCyrixCPUForCodeName:

          cmp     [IDTProcessor],1
          jnz     short NotIDTCPUForCodeName
          call    DetectIDTCodeName
          jnc     short DetectedCodeName

NotIDTCPUForCodeName:

          cmp     [RiseProcessor],1
          jnz     short NotRiseCPUForCodeName
          call    DetectRiseCodeName
          jnc     short DetectedCodeName

NotRiseCPUForCodeName:

          mov     si,offset CPUIDunknown
          mov     [NumRepCodeName],si
          jmp     short CodeNameNotDetectGoPrnFeatureFlag
DetectedCodeName:
          push    si
          mov     [NumRepCodeName],si
          mov     si,offset MesCodeName
          call    colorstr6x8
          pop     si
          jmp     short PrnCodeName

CodeNameNotDetectGoPrnFeatureFlag:
          mov     si,offset MesFeatureReg
          jmp     short FPUpresent1
NotCPUparam:
          call    colorstr6x8
          mov     si,offset MesFPUyes
          cmp     [FPUcheck],1
          jz      short FPUpresent1
          mov     si,offset MesFPUno
FPUpresent1:
PrnCodeName:
          call    colorstr6x8
          ret
ENDP PrintCPUparam

PROC MMX_AMD3Ddetection
          cmp     [PriznMMXAMD3D],1
          jz      short MMX_AMD3DPrintingOK
          cmp     [CPUIDsupport],1
          jnz     short NotSupportCPUIDInstruction
          cmp     [FeatureFlagMMX],1
          mov     si,offset MesMMXyes
          jz      short MMXNotSupportForYes
          mov     si,offset MesMMXno
MMXNotSupportForYes:
          call    ColorStr6x8
          cmp     [IntelProcessor],1
          jz      short IntelProcessorPresents

          mov     si,offset MesAMD3Dno
          cmp     [FeatureFlagAMD3D],1
          jnz     short PrintMesAMD3Dno
          mov     si,offset MesAMD3Dyes
          jmp     short PrintMesAMD3Dno
IntelProcessorPresents:
          cmp     [FeatureFlagSSE],1
          mov     si,offset MesSSEyes
          jz      short SSENotSupportForYes
          mov     si,offset MesSSEno
SSENotSupportForYes:
PrintMesAMD3Dno:
          call    ColorStr6x8
NotSupportCPUIDInstruction:
          inc     [PriznMMXAMD3D]
MMX_AMD3DPrintingOK:
          ret
ENDP MMX_AMD3Ddetection

PROC Cyrix52method
          cmp     [CPUclass],4
          jnz     Not486instrSupport
          xor     ax,ax
          sahf
          mov     ax,5
          mov     bl,2
          div     bl
          lahf
          cmp     ah,bl
          jne     Not486instrSupport
          mov     [cyrix52detect],1
          mov     si,offset cyrix
          mov     [NumRepCPUVendor],si
          call    colorstr6x8
          cli
          mov     al,0FEh
          out     22h,al
          in      al,23h
          sti
          mov     ah,al
          and     ah,11110000b
          cmp     ah,20h
          mov     [DevMHZ],5561161
          mov     si,offset cyrix5x86
          jz      CPUdetect4
          mov     [DevMHZ],1597501
          cmp     ah,30h
          mov     si,offset cyrix6x86
          jz      CPUdetect4
          cmp     ah,40h
          mov     si,offset MediaGXGXm
          jz      CPUdetect4
          cmp     ah,50h
          jnz     short DetectCyrixCx486
          mov     si,offset cyrix6x86mx
          jmp     short CPUdetect4

DetectCyrixCx486:
          mov     si,offset Cyrix486SLC
          or      al,al
          jz      short CPUdetect4
          mov     si,offset Cyrix486DLC
          cmp     al,1
          jz      short CPUdetect4
          mov     si,offset Cyrix486SLC2
          cmp     al,2
          jz      short CPUdetect4
          mov     si,offset Cyrix486DLC2
          cmp     al,3
          jz      short CPUdetect4
          mov     si,offset Cyrix486SRx
          cmp     al,4
          jz      short CPUdetect4
          mov     si,offset Cyrix486DRx
          cmp     al,5
          jz      short CPUdetect4
          mov     si,offset Cyrix486SRx2
          cmp     al,6
          jz      short CPUdetect4
          mov     si,offset Cyrix486DRx2
          cmp     al,7
          jz      short CPUdetect4
          mov     si,offset Cyrix486S
          cmp     al,10h
          jz      short CPUdetect4
          mov     si,offset Cyrix486S2
          cmp     al,11h
          jz      short CPUdetect4
          mov     si,offset Cyrix486Se
          cmp     al,12h
          jz      short CPUdetect4
          mov     si,offset Cyrix486S2e
          cmp     al,13h
          jz      short CPUdetect4
          mov     si,offset Cyrix486DX
          cmp     al,1Ah
          jz      short CPUdetect4
          mov     si,offset Cyrix486DX2
          cmp     al,1Bh
          jz      short CPUdetect4
          mov     si,offset Cyrix486DX4
          cmp     al,1Fh
          jz      short CPUdetect4
          xor     ah,ah
          mov     cx,2
          mov     di,offset Num52method
          call    BinToAscHex
          mov     si,offset Cyrix52unknown
CPUdetect4:
          mov     [NumRepCPUModel],si
          call    colorstr6x8
Not486instrSupport:
          ret
ENDP Cyrix52method

PROC MSBgrapf
          xor     edx,edx
          div     [DivMastabaMemSpeed]
          mov     bx,464+8
          sub     bx,ax
          mov     dx,373
          add     dx,bp
          or      bp,bp
          jnz     short NoOnePoint1
          mov     [LastPointInMemGrp],bx
NoOnePoint1:
          mov     ax,dx
          mov     cx,1
          mov     dx,[LastPointInMemGrp]
          mov     [LastPointInMemGrp],bx
          cmp     bx,dx
          jz      short CheckKoord
          jb      short ThisPointNoBig
          push    bx
          sub     bx,dx
          mov     cx,bx
          pop     bx
          sub     bx,cx
          jmp     short CheckKoord
ThisPointNoBig:
          sub     dx,bx
          mov     cx,dx
CheckKoord:
          cmp     bx,280
          jb      short VrongGraph
          cmp     bx,471
          jbe     short NotVrongGraph
VrongGraph:
          mov     bx,280
          mov     cx,1
NotVrongGraph:
          cmp     cx,192
          jb      short VrongLineInMemGrp
          mov     cx,1
VrongLineInMemGrp:
          ret
ENDP MSBgrapf

PROC GetSpeedMashtab
          mov     [NumYposSeekMashtab],30
          jmp     short GoToGetSpeedMashtab
PROC GetSeekMashtab
          mov     [NumYposSeekMashtab],29
GoToGetSpeedMashtab:
          push    bx
          sub     eax,eax
          mov     ax,si

          mov     ebx,eax
          mov     cx,7
LoopNextNumSeekMashtab:
          push    eax
          push    ebx
          push    cx
          mov     cx,6
          mov     di,offset NumSeekMashtab
          call    BinToAscDecH
          call    NZInMes
          sub     edx,edx
          mov     ebx,150
          div     ebx
          cmp     ax,999
          jb      short No4razr
          sub     eax,eax
No4razr:
          mov     cx,3
          mov     di,offset NumXSpeedMastab
          call    BinToAscDec
          call    NZInMes

          mov     si,offset SeekMashtab
          call    ColorStr6x8
          pop     cx
          pop     ebx
          pop     eax
          add     eax,ebx
          sub     [NumYposSeekMashtab],4
          loop    short LoopNextNumSeekMashtab
          pop     bx
          ret
ENDP GetSeekMashtab
ENDP GetSpeedMashtab

PROC MemTimingTest
          cmp     [ErrConfig],1
          jz      CanNotDetectMemAndCacheSpeed

          mov     si,offset MesDetMemSpeed
          call    ColorStr6x8

          cmp     [Mhz],18771
          jb      short CpuSpeed266AndFast
          mov     [byte cs:MemSizePriznak],0
CpuSpeed266AndFast:

        mov     cx,200

        call    GetMemPeakBandwidth32
        mov     ebx,eax
        shr     eax,1
        add     ebx,eax
        call    GetMemPeakBandwidth64
        cmp     ebx,eax
        jb      short Get32LineSizePeakBand
        mov     ebx,eax
        shr     eax,1
        add     ebx,eax
        call    GetMemPeakBandwidth128
        cmp     ebx,eax
        jb      short Get64LineSizePeakBand

Get128LineSizePeakBand:
        call    GetMemPeakBandwidth128
        mov     [NumAveraging1],eax
        call    GetMemPeakBandwidth128
        mov     [NumAveraging2],eax
        call    GetMemPeakBandwidth128
        mov     [NumAveraging3],eax
        call    GetMemPeakBandwidth128
        mov     [NumAveraging4],eax
        call    GetMemPeakBandwidth128
        mov     [NumAveraging5],eax
        jmp     short DetectAveragingPeakBand

Get64LineSizePeakBand:
        call    GetMemPeakBandwidth64
        mov     [NumAveraging1],eax
        call    GetMemPeakBandwidth64
        mov     [NumAveraging2],eax
        call    GetMemPeakBandwidth64
        mov     [NumAveraging3],eax
        call    GetMemPeakBandwidth64
        mov     [NumAveraging4],eax
        call    GetMemPeakBandwidth64
        mov     [NumAveraging5],eax
        jmp     short DetectAveragingPeakBand

Get32LineSizePeakBand:
        call    GetMemPeakBandwidth32
        mov     [NumAveraging1],eax
        call    GetMemPeakBandwidth32
        mov     [NumAveraging2],eax
        call    GetMemPeakBandwidth32
        mov     [NumAveraging3],eax
        call    GetMemPeakBandwidth32
        mov     [NumAveraging4],eax
        call    GetMemPeakBandwidth32
        mov     [NumAveraging5],eax
DetectAveragingPeakBand:
        call    GetMaxAveraging5
        mov     [MSpeedIdx],eax

          call    ClearHMSblock

          mov     di,offset ResCacheSpeedRepl
          call    GetBlockSizeForTesting
          ALIGN 2
NextMemBlockToScan:
          push    ax
          push    ecx
          sub     ecx,CacheMissCor
          mov     ebx,ecx
          push    di

          call    MemSpeedBlockMovsdPrg

          call    MemSpeedBlockForZamerRepl

          pop     di
          pop     ecx
          stosd
          pop     ax
          shl     ecx,1
          dec     al
          or      al,al
          jnz     short NextMemBlockToScan

          mov     di,offset ResCacheSpeedLodsd
          call    GetBlockSizeForTesting
          ALIGN 2
NextMemBlockToScanLodsd:
          push    ax
          push    ecx
          sub     ecx,CacheMissCor
          mov     ebx,ecx

          call    MemSpeedBlockLodsdPrg

          call    MemSpeedBlockForZamerLodsd

          pop     ecx

          stosd
          pop     ax
          shl     ecx,1
          dec     al
          or      al,al
          jnz     short NextMemBlockToScanLodsd

          mov     di,offset ResCacheSpeedStosd
          call    GetBlockSizeForTesting
          ALIGN 2
NextMemBlockToScanStosd:
          push    ax
          push    ecx
          sub     ecx,CacheMissCor
          mov     ebx,ecx
          push    di

          call    MemSpeedBlockStosdPrg

          call    MemSpeedBlockForZamerStosd

          pop     di
          pop     ecx
          stosd
          pop     ax
          shl     ecx,1
          dec     al
          or      al,al
          jnz     short NextMemBlockToScanStosd

          cmp     [FeatureFlagMMX],1
          jnz     NotMMXCPUForCacheSpeed

          mov     si,offset MesMMXMemSpeed
          call    ColorStr6x8

          call    ClearHMSblock

          mov     di,offset ResCacheSpeedMovsq
          call    GetBlockSizeForTesting
          ALIGN 2
NextMemBlockToScanMovsq:
          push    ax
          push    ecx
          sub     ecx,CacheMissCor
          mov     ebx,ecx
          push    di

          mov     esi,[dword cs:AdrHMS]
          mov     edi,esi
          shr     ecx,5
          call    MemSpeedBlockMovsqPrg

          call    MemSpeedBlockForZamerMovsq

          pop     di
          pop     ecx
          cld
          stosd
          pop     ax
          shl     ecx,1
          dec     al
          or      al,al
          jnz     short NextMemBlockToScanMovsq

          mov     di,offset ResCacheSpeedLodsq
          call    GetBlockSizeForTesting
          ALIGN 2
NextMemBlockToScanLodsq:
          push    ax
          push    ecx
          sub     ecx,CacheMissCor
          mov     ebx,ecx
          push    di

          mov     esi,[dword cs:AdrHMS]
          shr     ecx,5
          call    MemSpeedBlockLodsqPrg

          call    MemSpeedBlockForZamerLodsq

          pop     di
          pop     ecx
          cld
          stosd
          pop     ax
          shl     ecx,1
          dec     al
          or      al,al
          jnz     short NextMemBlockToScanLodsq

          mov     di,offset ResCacheSpeedStosq
          call    GetBlockSizeForTesting
          ALIGN 2
NextMemBlockToScanStosq:
          push    ax
          push    ecx
          sub     ecx,CacheMissCor
          mov     ebx,ecx
          push    di

          mov     esi,[dword cs:AdrHMS]
          shr     ecx,5
          call    MemSpeedBlockStosqPrg

          call    MemSpeedBlockForZamerStosq

          pop     di
          pop     ecx
          cld
          stosd
          pop     ax
          shl     ecx,1
          dec     al
          or      al,al
          jnz     short NextMemBlockToScanStosq

NotMMXCPUForCacheSpeed:

          cmp     [IntelProcessor],1
          jnz     short NotIntelCPUForDetectCacheSize
          cmp     [CPUfamily],6
          jb      short NotIntelCPUForDetectCacheSize
          cmp     [CPUModel],6
          jb      short NotIntelCPUForDetectCacheSize

          mov     dx,[DataCacheL1]
          or      dx,[CacheL2]
          or      dx,[CacheL3]
          or      dx,dx
          jz      NotIntelCPUForDetectCacheSize
          mov     cx,1
NextByteStrInIntelCache:
          shr     dx,1
          test    dl,100b
          jz      short NotDetectIntelCache
          mov     di,offset ResultsNew
          add     di,cx
          mov     al,1
          cld
          stosb
          inc     [AllCache]
NotDetectIntelCache:

          inc     cl
          mov     bl,[byte cs:MemSizePriznak]
          add     bl,10
          cmp     cl,bl
          jnz     short NextByteStrInIntelCache
          jmp     short IntelPrgCacheDetected

          cmp     [CyrixProcessor],1
          jnz     short NotCyrixCPUForDetectCacheSize
          cmp     [CPUfamily],6
          jb      short NotCyrixCPUForDetectCacheSize

DetectCacheSizeThisOutWriteTests:
          mov     si,offset ResCacheSpeedStosd
          jmp     short GoCalcCacheInfo

NotIntelCPUForDetectCacheSize:
NotCyrixCPUForDetectCacheSize:

          mov     si,offset ResCacheSpeedRepl
          mov     eax,[dword ds:ResCacheSpeedRepl]
          cmp     eax,[dword ds:ResCacheSpeedLodsd]
          ja      short ResultsCacheSpeedMax
          mov     si,offset ResCacheSpeedLodsd
ResultsCacheSpeedMax:

GoCalcCacheInfo:
           mov     cx,1
NextByteStr:
          mov     di,offset ResultsNew
          mov     eax,[dword ds:si+4]
          mov     ebx,[dword ds:si+4+4]
          cmp     eax,ebx
          jbe     short NextByte
          push    ebx
          mov     ebx,100
          mul     ebx
          pop     ebx
          sub     edx,edx
          div     ebx
          cmp     eax,127; Кэш найден если медленнее предыдущего на 27%
          jb      short NextByte
          add     di,cx
          mov     al,1
          cld
          stosb
          inc     [AllCache]
Nextbyte: add     si,4
          inc     cl
          mov     al,[byte cs:MemSizePriznak]
          add     al,10
          cmp     cl,al
          jnz     short NextByteStr

IntelPrgCacheDetected:

          mov     si,offset ResultsNew
          mov     ax,[word ds:si]
          or      ax,ax
          jz      short CanNotDetectMemAndCacheSpeed
          mov     [byte cs:MemSizePriznak],0
CanNotDetectMemAndCacheSpeed:
          ret
ENDP MemTimingTest

PROC CheckMemory
          cmp     [PriznMemLoop],1
          jz      short LoopMemTestDetected
          mov     si,offset MesPressL
          call    ColorStr6x8
LoopMemTestDetected:

          mov     ax,536-1
          mov     bx,281
          mov     cx,29+3+3
          mov     dx,5
          mov     bp,3+8
          call    ColorFrame
          mov     si,offset MesTestingMem
          call    ColorStr6x8

NextLoopMemTest:
          mov     ax,537
          mov     bx,283
          mov     cx,26+3+3
          mov     dx,2
          xor     bp,bp
          call    Rectangle
          mov     [ForMemPrgBar],0

          cmp     [PriznMemLoop],1
          jnz     short NormalMemTest
          call    ClearWindowMesages3
          inc     [MemCheckCounter]
          mov     eax,[MemCheckCounter]
          cmp     eax,99999
          jz      short MemTestPass
          mov     di,offset NumMemCounter
          mov     cx,5
          call    BinToAscDecH
          call    NZInMes
          mov     si,offset MesMemCounter
          call    ColorStr6x8

NormalMemTest:
          call    GetCheckSum
          mov     [MemCheckSum],ebx
          jc      short TestingMemSkipped
          call    MemXorA5
          jc      short TestingMemSkipped
          call    MemXor0F
          jc      short TestingMemSkipped
          call    MemRor
          jc      short TestingMemSkipped
          call    MemXorF0
          jc      short TestingMemSkipped
          call    MemXorFF
          jc      short TestingMemSkipped
          call    MemXor0F
          jc      short TestingMemSkipped
          call    MemRol
          jc      short TestingMemSkipped
          call    MemXor5A
          jc      short TestingMemSkipped
          call    MemXorF0
          jc      short TestingMemSkipped
          call    GetCheckSum
          jc      short TestingMemSkipped
          cmp     ebx,[MemCheckSum]
          jnz     short CheckMemFailed
          cmp     [PriznMemLoop],1
          jnz     short MemTestPass
          call    WriteRndToMem
          jmp     NextLoopMemTest

CheckMemFailed:
          call    PrnMemErrRes
          mov     si,offset MesMemErr
          jmp     short ExitMemTest
TestingMemSkipped:
          mov     si,offset MesMemSkipped
          call    ColorStr6x8
          cmp     al,1Bh
          jz      CdErrExit
          jmp     short SkippedMemTest
MemTestPass:
          mov     si,offset MesMemDone
ExitMemTest:
          call    ColorStr6x8
SkippedMemTest:
          call    ClearWindowMesages3
          ret
ENDP CheckMemory

PROC PrnMemErrRes
          cmp     [PriznMemLoop],1
          jnz     short CycleMemTestDetected
          mov     eax,[MemCheckCounter]
          mov     cx,5
          mov     di,offset NumPasses
          call    BinToAscDecH
          call    NZInMes
          mov     si,offset MesErrorMemAdress
          call    ColorStr6x8
          add     [CorrectIfMemErr1],2
CycleMemTestDetected:
          ret
ENDP PrnMemErrRes

PROC MemCheckProgressBar
          push    ax
          push    cx
          push    bx
          push    dx
          mov     ax,537
          add     ax,[ForMemPrgBar]
          mov     bx,283
          mov     cx,2
          mov     dx,cx
          mov     bp,2+8
          call    Rectangle
          add     [ForMemPrgBar],3
          pop     dx
          pop     bx
          pop     cx
          pop     ax
          ret
ENDP MemCheckProgressBar

PROC WriteRndToMem
          mov     edi,[dword cs:AdrHMS]
          mov     ecx,[XMSmemLength]
          sub     ecx,64*1024
          cld

          push    es

          sub     ax,ax
          mov     es,ax

          mov     eax,0FFFFFFFFh
          call    Rnd
ALIGN 2
NextDwordForRnd:

          DB      66h,67h,0ABh   ;Stosd
          call    DetectKeyPressed
          dec     ecx
          jnz     short NextDwordForRnd

          pop     es

          jmp     EndOfMemTestNotBar

PROC GetCheckSum
          mov     esi,[dword cs:AdrHMS]
          xor     ebx,ebx
          mov     ecx,[XMSmemLength]
          sub     ecx,64*1024
          cld

          push    ds

          sub     ax,ax
          mov     ds,ax

ALIGN 2
NextDwordForCheckSum:
          DB      66h,67h,0ADh   ;Lodsd
          add     ebx,eax
          call    DetectKeyPressed
          dec     ecx
          jnz     short NextDwordForCheckSum

          pop     ds

          jmp     EndOfMemTest

PROC MemRor
          mov     edi,[dword cs:AdrHMS]
          mov     ecx,[XMSmemLength]
          sub     ecx,64*1024

          push    es
          sub     ax,ax
          mov     es,ax
ALIGN 2
NextDwordForRor:
          ror     [dword es:edi],15
          add     edi,4
          call    DetectKeyPressed
          dec     ecx
          jnz     short NextDwordForRor
          pop     es

          jmp     EndOfMemTest
PROC MemRol
          mov     edi,[dword cs:AdrHMS]
          mov     ecx,[XMSmemLength]
          sub     ecx,64*1024

          push    es
          sub     ax,ax
          mov     es,ax
ALIGN 2
NextDwordForRol:
          rol     [dword es:edi],15
          add     edi,4
          call    DetectKeyPressed
          dec     ecx
          jnz     short NextDwordForRol
          pop     es

          jmp     short EndOfMemTest
PROC MemXorFF
          mov     ebx,0FFFFFFFFh
          jmp     short GoToTestMemXor
PROC MemXorF0
          mov     ebx,0F00FF00Fh
          jmp     short GoToTestMemXor
PROC MemXor0F
          mov     ebx,00FF00FF0h
          jmp     short GoToTestMemXor
PROC MemXorA5
          mov     ebx,0AA55AA55h
          jmp     short GoToTestMemXor
PROC MemXor5A
          mov     ebx,055AA55AAh
GoToTestMemXor:
          mov     edi,[dword cs:AdrHMS]
          mov     ecx,[XMSmemLength]
          sub     ecx,64*1024

          push    es
          sub     ax,ax
          mov     es,ax
ALIGN 2
NextDwordForXor:
          xor     [dword es:edi],ebx
          add     edi,4
          call    DetectKeyPressed
          dec     ecx
          jnz     short NextDwordForXor
          pop     es

EndOfMemTest:
          call    MemCheckProgressBar
EndOfMemTestNotBar:
          cmp     [MemTestExit],1
          jz      short GetCheckSumExit
          clc
          ret
GetCheckSumExit:
          stc
          ret
ENDP MemXor5A
ENDP MemXorA5
ENDP MemXor0F
ENDP MemXorF0
ENDP MemXorFF
ENDP MemRol
ENDP MemRor
ENDP GetCheckSum
ENDP WriteRndToMem

ALIGN 2
PROC DetectKeyPressed
          cmp     cx,1
          jnz     short Not256testing

          push    ds
          push    es

          mov     ax,Dseg
          mov     ds,ax
          mov     es,ax

          pushf
          push    si
          push    ebx
          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      short KeyDetect
          cmp     al,' '
          jnz     short LoopKeyDetect
KeyDetect:
          mov     ecx,1
          mov     [MemTestExit],1
LoopKeyDetect:
          push    ax
          or      al,32
          cmp     ax,016Ch ;l
          jnz     short NotLPressed
          mov     [PriznMemLoop],1
          call    ClearWindowMesages3
          mov     si,offset MesMemCounter
          call    ColorStr6x8
NotLPressed:
          pop     ax
          pop     ebx
          pop     si
          popf

          pop     es
          pop     ds
Not256testing:
          ret
ENDP DetectKeyPressed

PROC MahtabMemSpeed
          mov     si,offset ResCacheSpeedRepl
          xor     ebx,ebx
          mov     cx,13*6-1
          cld
NextResultMemSpeed:
          lodsd
          cmp     ebx,eax
          ja      short NotChangeResultMemSpeed
          mov     ebx,eax
NotChangeResultMemSpeed:
          loop    NextResultMemSpeed

          mov     [L1FastRes],ebx
          mov     eax,10
          xchg    eax,ebx
          shr     eax,12
          sub     edx,edx
          div     ebx
          mul     ebx
          add     eax,ebx
          push    eax
          shl     eax,5
          mov     [DivMastabaMemSpeed],eax
          pop     eax

          mov     cx,5
          mov     ebx,eax
          mov     di,offset NumHkala5
          call    BinToAscDecH
          call    NZInMes
          add     eax,ebx
          mov     di,offset NumHkala4
          call    BinToAscDecH
          call    NZInMes
          add     eax,ebx
          mov     di,offset NumHkala3
          call    BinToAscDecH
          call    NZInMes
          add     eax,ebx
          mov     di,offset NumHkala2
          call    BinToAscDecH
          call    NZInMes
          add     eax,ebx
          mov     di,offset NumHkala1
          call    BinToAscDecH
          call    NZInMes

          mov     di,offset NumBSHkala
          mov     eax,4
          mov     cl,[byte cs:MemSizePriznak]
          shl     ax,cl
          mov     bl,6
NextPrnBSHkala:
          mov     cx,5
          call    BinToAscDecH
          call    NZInMes
          shl     ax,2
          add     di,8
          dec     bl
          jnz     short NextPrnBSHkala
          ret
ENDP MahtabMemSpeed

ALIGN 2
PROC GetTSCdata
          cmp     [DetectViaMSR],0
          jz      short GetClockViaRDTSC
          mov     ecx,10h
          DB      0Fh,32h ;rdmsr
          ret
GetClockViaRDTSC:
          DB      0Fh,31h ;rdtsc
          ret
ENDP GetTSCdata

ALIGN 16
PROC CpuSpeedTest
          push    ebp
          push    ebx
          push    ecx
          push    edx
          push    di
          call    StartNewTimer
          DB     33*ForCpuTest+1 DUP(90h)
StartCPUTestingInstr:
          cmp     [FPUcheck],1
          jnz     short CoProcessorNotFound
;******FractalFPU*****
;          jmp      SkipFractalFPU
          finit
          fld1
          fldl2t
          fldPI
          fidiv   [WORD cs:TUDY320]
          mov     bx,0FA00h
TUDY:
          mov     cx,64
          fsub    ST(2),ST
          fld1
PAINT:
          fld     ST
          fld     ST(4)
          mov     dl,100
CIKL:
          fld     ST(1)
          fmul    ST,ST
          fld     ST(1)
          fmul    ST,ST
          fsubp   ST(1),ST
          fadd    ST,ST(3)
          fld     ST(2)
          fmul    ST,ST(2)
          fadd    ST,ST
          fadd    ST,ST(7)
          fst     ST(2)
          fabs
          fcomp   ST(6)
          fstsw   ax
          fstp    ST(2)
          sahf
          jnc     short EndCalc
          dec     dx
          jnz     short Cikl
EndCalc:
          fcompp  ST(1)
          dec     bx
;          mov      [bx],dl
Snova:
          fsub    ST,ST(1)
          loop    short Paint
NewString:
          fcomp   ST(1)
          jnz     short Tudy
SkipFractalFPU:
          jmp     short BuildFractal
CoProcessorNotFound:

          sub     bx,bx
          mov     si,32
   Rou1:
          mov     di,-127
          dec     si
   Col1:
          inc     di
          je      short Rou1
          sub     bp,bp
          mov     cl,46
   Calc1:
          lea     bp,[bp+di+127]
          add     ax,si
          push    ax
          imul    bp
          sar     ax,5
          inc     ax
          pop     dx
          push    ax
          push    dx
          mov     ax,bp
          imul    bp
          mov     bp,ax
          pop     dx
          mov     ax,dx
          imul    dx
          mov     dx,ax
          pop     ax
          jb      short Paint11
          sub     bp,dx
          push    ax
          mov     ax,bp
          sar     ax,6
          mov     bp,ax
          pop     ax
          loop    short Calc1
  Paint11:
        ;  mov [bx],cl
          sub     ax,ax
          inc     bx
          jne     short Col1

BuildFractal:
;******Fractal******
;          jmp      SkipFractal
          sub     bx,bx
          mov     si,32
   Rou:   mov     di,-89
          dec     si
   Col:   inc     di
          je      short Rou
          sub     bp,bp
          mov     cl,46
   Calc:  lea     bp,[bp+di+127]
          add     ax,si
          push    ax
          imul    bp
          sar     ax,5
          inc     ax
          pop     dx
          push    ax
          push    dx
          mov     ax,bp
          imul    bp
          mov     bp,ax
          pop     dx
          mov     ax,dx
          imul    dx
          mov     dx,ax
          pop     ax
          jb      short Paint1
          sub     bp,dx
          push    ax
          mov     ax,bp
          sar     ax,6
          mov     bp,ax
          pop     ax
          loop    short Calc
  Paint1:;  mov [bx],cl
          sub     ax,ax
          inc     bx
          jne     short Col
FPUfractalOK:

SkipFractal:
          push    ebp
          mov     ebp,esp
          sub     esp,0028h*2
          mov     [dword bp-12h*2],0000
          mov     eax,66
          mov     [dword bp-14h*2],eax
CounterCpuTestProc32:
          mov     eax,[dword bp-0Ah*2]
          sub     eax,[dword bp-0Ah*2]
          cmp     eax,0800h
          jne     short NotEndCpuTestProc132
          jmp     short EndCpuTestProc32
NotEndCpuTestProc132:
          mov     eax,03h
          push    eax
          push    [dword bp-0Ch*2]
          mov     [word bp-0Fh*2],05h
          mov     [dword bp-10h*2],0FFF0h
          inc     eax
          pop     [dword bp-0Ch*2]
          pop     eax
          cmp     eax,03h
          je      short NotEndCpuTestProc232
          jmp     short EndCpuTestProc32
NotEndCpuTestProc232:
          mov     [dword bp-04h*2],0
NextTestCpuInstr32:
          push    [dword bp-04h*2]
          mov     eax,[dword bp-06h*2]
          add     eax,[dword bp-08h*2]
          mov     [bp-06h*2],eax
          pop     [dword bp-04h*2]
          inc     [dword bp-04h*2]
          cmp     [dword bp-04h*2],07D0h
          jl      short NextTestCpuInstr32
          inc     [dword bp-12h*2]
          mov     eax,[dword bp-14h*2]
          cmp     [dword bp-12h*2],eax
          jl      CounterCpuTestProc32
EndCpuTestProc32:
          mov     esp,ebp
          pop     ebp
SkipSorting:
          push    es
          push    ds
          push    cs
          pop     ds
          mov     ax,[word cs:EndProgramCS]
          mov     es,ax

          mov     di,[word cs:CounterCPUspeed]

          mov     si,offset String-34
          add     si,di
          cld
          mov     ecx,14
          push    ecx
          rep movsd
          pop     ecx
          mov     esi,edi
          sub     esi,14*4

          push    es
          pop     ds

          mov     ebx,2
NextMoveString:
          push    ecx
          rep movsd
          pop     ecx
          dec     ebx
          jnz     short NextMoveString

FlagSet:
          mov     si,[word cs:CounterCPUspeed]
          sub     edx,edx
          mov     ecx,14*4*3
NextDwordForSorting:
          mov     edi,esi
          lodsd
          mov     ebx,eax
          lodsd
          cmp     eax,ebx
          jng     short NoBig
          stosd
          mov     eax,ebx
          stosd
          inc     edx
NoBig:
          sub     esi,4
          dec     ecx
          jnz     short NextDwordForSorting
          or      edx,edx
          jnz     short FlagSet

          pop     ds
          pop     es
SkipLodsMovs:
          jmp     short EndCPUTestingInstr
String    DB '< System Speed Test 1.0 -st String Of Buble Sorting ...>'

          DB      ForCpuTest DUP(90h)

EndCPUTestingInstr:

          call    StopNewTimer
          pop     di
          pop     edx
          pop     ecx
          pop     ebx
          pop     ebp
          ret

          ALIGN 16

EndProgramCS  DW ?
CounterCPUspeed DW ?
TUDY320   DW      320
ENDP CpuSpeedTest

PROC GetMicrocodeRev
          mov     ecx,8Bh
          xor     eax,eax
          xor     edx,edx
          DB 0Fh,30h  ;wrmsr
          mov     eax,1
          p586
          cpuid
          p386
          mov     ecx,8Bh
          DB 0Fh,32h  ;rdmsr
          inc     edx
          mov     [MicrocodeRev],edx
          ret
ENDP GetMicrocodeRev

PROC GetOriginalIntelClock
          cmp    [IntelProcessor],1
          jnz    NotIntelCPUForOriginalClock
          cmp    [CPUfamily],06h
          jz     short P6FamilyForOriginalClock
          cmp    [CPUfamily],0Fh
          jnz    NotIntelCPUForOriginalClock
          cmp    [IntelExtendedFamily],0
          jnz    NotIntelCPUForOriginalClock

          mov    bx,100

          cmp    [CPUModel],2
          jb     short OrigExternalClockDetected
          jz     short IntelP4ProcesorForOriginalClock

          jmp    NotIntelCPUForOriginalClock

IntelP4ProcesorForOriginalClock:
          mov    eax,[MSR0000002C]
          test   eax,80000000h
          jnz    short P4OriginalClockDetected
          mov    eax,[Win32MSR0000002C]
          test   eax,80000000h
          jz     NotIntelCPUForOriginalClock
P4OriginalClockDetected:
          shr    eax,16
          and    al,111b
          mov    bx,100
          or     al,al
          jz     short OrigExternalClockDetected
          mov    bx,133
          cmp    al,001b
          jz     short OrigExternalClockDetected
          mov    bx,200
          cmp    al,010b
          jz     short OrigExternalClockDetected
          mov    bx,100
          jmp    short OrigExternalClockDetected


P6FamilyForOriginalClock:
          mov    eax,[MSR0000002A]
          test   eax,80000000h
          jnz    short P6OriginalClockDetected
          mov    eax,[Win32MSR0000002A]
          test   eax,80000000h
          jz     NotIntelCPUForOriginalClock

P6OriginalClockDetected:
          mov    bx,100
          test   eax,80000h ;bit19
          jnz    short OrigExternalClockDetected
          mov    bx,133
          test   eax,40000h ;bit18
          jnz    short OrigExternalClockDetected
          mov    bx,66
          test   eax,0C0000h;bit19:18
          jz     short OrigExternalClockDetected
          jmp    NotIntelCPUForOriginalClock

OrigExternalClockDetected:
          mov    [OriginalFSB],bx
          mov    ax,bx
          movzx   ebx,[ClockRatio]
          cmp     ax,66
          jnz     short Not66MhzExtClock
          mov     eax,6667
          jmp     short Not133MhzExtClock
Not66MhzExtClock:
          cmp     ax,100
          jnz     short Not100MhzExtClock
          mov     eax,10000
          jmp     short Not133MhzExtClock
Not100MhzExtClock:
          cmp     ax,133
          jnz     short Not133MhzExtClock
          mov     eax,13333
Not133MhzExtClock:
          cmp     ax,200
          jnz     short Not200MhzExtClock
          mov     eax,20000
Not200MhzExtClock:

          cmp     [word ds:CPUfamily],06*256+7 ;Katmai
          jnz     short NotKatmaiCore
          cmp     eax,6667
          jnz     short NotKatmaiCore
          mov     eax,10000
NotKatmaiCore:

          mov     [OriginalFSBExt],eax
          mul     ebx
          sub     edx,edx
          mov     ebx,10000
          div     ebx
          call    GetCorrectFrec
          mov     [OriginalFrequency],ax

NotIntelCPUForOriginalClock:
          ret
ENDP GetOriginalIntelClock

PROC VideoSpeedTest
          push    es
          mov     ax,[EndProgram]
          mov     es,ax
          mov     ax,4F00h
          xor     di,di
          int     10h
          pop     es
          cmp     ax,004Fh
          jnz     VESAModeNotSupported
          mov     [VGASpeed],0

          push    es
          mov     ax,[EndProgram]
          mov     es,ax
          add     di,0Eh
          mov     si,[word es:di]
          mov     ax,[word es:di+2]
          pop     es
          push    ds
          mov     ds,ax
          sub     bl,bl
          mov     cx,64
          cld
GetNextVESAMode:
          lodsw
          cmp     ax,0FFFFh
          jz      short EndOfVESAModeLost
          cmp     ax,101h
          jnz     short VESA101hNotSupported
          or      bl,1b
VESA101hNotSupported:
          cmp     ax,102h
          jnz     short VESA102hNotSupported
          or      bl,10b
VESA102hNotSupported:
          cmp     ax,103h
          jnz     short VESA103hNotSupported
          or      bl,100b
VESA103hNotSupported:
          cmp     ax,104h
          jnz     short VESA104hNotSupported
          or      bl,1000b
VESA104hNotSupported:
          cmp     ax,105h
          jnz     short VESA105hNotSupported
          or      bl,10000b
VESA105hNotSupported:
          loop    short GetNextVESAMode
EndOfVESAModeLost:
          pop     ds
          mov     [VESA101105],bl

          mov     [VideoMode],101h
          mov     [AllTestVideoMode],0
NextVideoModeTesting:
          mov     al,[VESA101105]
          test    al,1
          jz      short CannotSetMode

          mov     ax,4F02h
          mov     bx,[VideoMode]
          or      bx,8000h
          int     10h
          jc      short CannotSetMode
          cmp     ax,004Fh
          jnz     short CannotSetMode
          inc     [AllTestVideoMode]

          push    es
          cld
          mov     ax,0A000h
          mov     es,ax
          xor     eax,eax
          xor     di,di
          mov     cx,16384
          rep stosd

          call    StartNewTimer

          sub     di,di
          mov     ch,64
          rep stosd
          sub     di,di
          mov     ch,64
          rep stosd
          sub     di,di
          mov     ch,64
          rep stosd

          call    StopNewTimer

          pop     es

          add     [VGASpeed],eax
CannotSetMode:
          shr     [VESA101105],1
          inc     [VideoMode]
          cmp     [VideoMode],106h
          jnz      NextVideoModeTesting
          movzx   ecx,[AllTestVideoMode]
          jcxz    short TestNotCompliteSetMode
          mov     eax,[VGASpeed]
          xor     edx,edx
          div     ecx
          mov     [VGASpeed],eax
TestNotCompliteSetMode:
VESAModeNotSupported:
          ret
ENDP VideoSpeedTest

PROC DetectHdd
          sub     eax,eax
          mov     [Tracks],eax
          mov     [Heads],eax
          mov     [Sectors],eax
          cmp     [WinNTpres],1
          jnz     short WinNTNotPresentsForDetectHdd
          cmp     [NumFixedDisk],0
          jz      short WinNTNotPresentsForDetectHdd
          mov     al,1Ch
          mul     dl
          mov     si,offset DriveBuffer
          add     si,ax
          mov     eax,[dword ds:si]
          dec     eax
          mov     [Tracks],eax
          mov     eax,[dword ds:si+8+4]
          mov     [Heads],eax
          mov     eax,[dword ds:si+12+4]
          mov     [Sectors],eax
          jmp     Int13extNotSupport

WinNTNotPresentsForDetectHdd:

          or      dl,80h
          push    dx
          mov     ah,8
          int     13h
          pop     bx
          jc      DiskNotFound
          shr     dx,8
          inc     dx
          mov     [word ds:Heads],dx
          mov     al,cl
          and     al,3Fh
          mov     [byte ds:Sectors],al
          xor     ax,ax
          and     cl,0C0h
          mov     al,cl
          shl     ax,2
          mov     al,ch
          inc     ax
          mov     [word ds:Tracks],ax
          mov      [Int13ExtSup],0
          cmp      [Int13ExtResetByComLine],1
          jz       Int13extNotSupport
          mov      dl,bl
          push     dx
          mov      ah,41h
          mov      bx,55AAh
          int      13h
          pop      dx
          jc       Int13extNotSupport
          cmp      bx,0AA55h
          jnz      Int13extNotSupport
          mov      ax,[EndProgram]
          mov      ds,ax
          sub      si,si
          mov      [word ds:si],1Ah
          mov      ah,48h
          int      13h
          jc       short Int13extError

          mov      eax,[dword ds:si+10h] ;Total Number of Sect Low Dword
          mov      edx,[dword ds:si+10h+4] ;Total Number of Sect High Dword
          or       eax,eax
          jz       short Int13extError
          or       edx,edx               ; поддержка только 2000 GB
          jnz      short Int13extError
;          mov      ecx,[dword ds:si+18h];byte per sect
          push     es
          pop      ds
          mov      [TotalNumSectL],eax
;          mov      [TotalNumSectH],edx
          cmp      [Int13ExtSetByComLine],1
          jz       short SetInt13EByComLine
          cmp      eax,16514064
          jbe      short HardDrive84GBNotPresent
SetInt13EByComLine:

          cmp      eax,1024*128*63
          ja       short Enable255HeadsCHS
          mov      ebx,128*63
          div      ebx
          mov      [Tracks],eax
          mov      [Heads],128
          jmp      short Enable128HeadsCHSIsOK
Enable255HeadsCHS:
          mov      ebx,255*63
          div      ebx
          mov      [Tracks],eax
          mov      [Heads],255
Enable128HeadsCHSIsOK:
          mov      [Int13ExtSup],1
          mov      [Sectors],63
Int13extError:
          push     es
          pop      ds
HardDrive84GBNotPresent:
Int13extNotSupport:

          clc
DiskNotFound:
          ret
ENDP DetectHdd

PROC GetInt13Param
          cmp     eax,1024
          jb      short Not1Gb
          call    GetHDDSizeInGB
          mov     cx,4
          mov     di,offset NumHddSizeGB
          call    BinToAscDec2

          call    DetectHDDnumbers
          mov     si,offset MesHddSizeGB
          jmp     short PropuskNumHddSize
Not1Gb:
          mov     cx,4
          mov     di,offset NumHddSizeMB
          call    BinToAscDec
          call    NZInMes
          call    DetectHDDnumbers
          mov     si,offset MesHddSizeMB
PropuskNumHddSize:
          call    colorstr6x8
          ret
ENDP GetInt13Param

PROC GetInt13ParamForRep
          cmp     eax,1024
          jb      short Not1GbForRep
          call    GetHDDSizeInGB
          mov     cx,4
          mov     di,offset NumHddSizeGB
          call    BinToAscDec2

          call    DetectHDDnumbersForRep
          mov     si,offset MesHddSizeGB
          jmp     short PropuskNumHddSizeForRep
Not1GbForRep:
          mov     cx,4
          mov     di,offset NumHddSizeMB
          call    BinToAscDec
          call    NZInMes
          call    DetectHDDnumbersForRep
          mov     si,offset MesHddSizeMB
PropuskNumHddSizeForRep:
          call     PutToReportBuf
          ret
ENDP GetInt13ParamForRep

PROC BuildGraph
          push    eax
          push    ebx
          push    edx
          push    cx
          inc     [HDDKolichProxodov]
          mov     eax,[NewTekushSpeed]
          xor     edx,edx
          movzx   ebx,[MashtabHdd]
          div     ebx
          mov     edx,254
          cmp     eax,edx
          jbe     short CorrectMaxResult
          mov     eax,edx
CorrectMaxResult:

          cmp     [HDDKolichProxodov],1
          jnz     short NotTrack0Detected
          mov     [TekuhPointVert],ax
          mov     [NumVertKoord],1
          mov     [SumVertKoord],eax
          mov     [TekuhPointHor],0
          jmp     short HorKoordNoBig
NotTrack0Detected:
          add     [SumVertKoord],eax
          inc     [NumVertKoord]
          mov     eax,298*2
          mul     [HDDKolichProxodov]
          div     [CounterHDDFastTest]

          cmp     ax,[TekuhPointHor]
          jbe     short HorKoordNoBig
          mov     cx,[TekuhPointHor]
          mov     [TekuhPointHor],ax
          shr     ax,1
          shr     cx,1
          add     ax,313
          add     cx,313
          push    ax
          push    cx
          sub     edx,edx
          mov     eax,[SumVertKoord]
          movzx   ebx,[NumVertKoord]
          div     ebx
          mov     dx,[TekuhPointVert]
          mov     [TekuhPointVert],ax
          mov     bx,271
          sub     bx,ax
          mov     cx,271
          sub     cx,dx
          mov     dx,cx
          pop     cx
          pop     ax
          call    ColorLine

          sub     eax,eax
          mov     [SumVertKoord],eax
          mov     [NumVertKoord],ax
HorKoordNoBig:
          cmp     [Int13Error],1
          jnz     short Int13ErrorrNotDetected
          push    bp
          mov     bp,4
          mov     ax,[TekuhPointHor]
          shr     ax,1
          add     ax,313
          mov     cx,ax
          mov     bx,271
          mov     dx,bx
          sub     dx,[TekuhPointVert]
          call    ColorLine
          pop     bp
Int13ErrorrNotDetected:

          pop     cx
          pop     edx
          pop     ebx
          pop     eax
          ret
ENDP BuildGraph

PROC PrnTestingTrack
          push    cx
          mov     cx,6
          mov     di,offset Track
          call    BinToAscDecH
          call    NZInMes
          mov     si,offset MesTimingSeek
          call    ColorStr6x8
          pop     cx
          ret
ENDP PrnTestingTrack


PROC GraphAntialising21
          cmp     [HDDKolichProxodov],0
          jnz     short NoFirstStartAntialising21
          mov     [AntialisingPer1],eax
          ret
NoFirstStartAntialising21:
          push    ebx
          mov     ebx,[AntialisingPer1]
          mov     [AntialisingPer1],eax
          add     eax,ebx
          shr     eax,1
          pop     ebx
          ret
ENDP GraphAntialising21

PROC GraphAntialising31
          cmp     [AntialisingSeed],3
          jz      short FullAntialisingSeedDetected31
          cmp     [AntialisingSeed],0
          jnz     short NoFirstStartAntialising31
          sub     ebx,ebx
          mov     [AntialisingPer2],ebx
          mov     [AntialisingPer3],ebx
NoFirstStartAntialising31:
          inc     [AntialisingSeed]
FullAntialisingSeedDetected31:
          push    ebx
          push    edx
          mov     edx,[AntialisingPer3]
          mov     ebx,[AntialisingPer2]
          mov     [AntialisingPer3],ebx
          mov     [AntialisingPer2],eax

          add     eax,ebx
          add     eax,edx

          sub     edx,edx
          movzx   ebx,[byte ds:AntialisingSeed]
          div     ebx
          pop     edx
          pop     ebx
          ret
ENDP GraphAntialising31

          ALIGN 2
PROC ZeroResIfError
          cmp     [Int13Error],1
          jnz     short NoErrorInNextTrackHdd
          sub     eax,eax
NoErrorInNextTrackHdd:
          ret
ENDP ZeroResIfError

PROC HardDriveTest
          call    Setka

          mov     dl,[DefaultDrive]
          mov     [TestingHDDnumber],dl

          call    DetectHdd              ;Определение параметров винта
          mov     cl,[TotalHDD]
          sub     cl,[TestingHDDnumber]

          mov     ax,[Int13ExtDriveCapable]
          mov     [Int13ExtSup],0
          shr     ax,cl
          jnc     short Int13ExtNotSupportForThisDrive
          mov     [Int13ExtSup],1
Int13ExtNotSupportForThisDrive:

          mov     [ForUscoren],32
          mov     eax,[Tracks]
          mov     cx,6
          mov     di,offset TotalTrack
          call    BinToAscDecH
          call    NZInMes

          mov     si,offset HDDResBuff
          mov     al,17*4
          mul     [DefaultDrive]
          add     si,ax
          mov     al,[Method]
          inc     al
          mov     [byte ds:si+28],al

          mov     eax,1                   ;Замер скорости позиционирования
          call    SeekTrack               ;для определения масштаба
          call    StartNewTimer
          mov     eax,[Tracks]
          dec     eax
          push    eax
          call    SeekTrack
          mov     eax,1
          call    SeekTrack
          pop     eax
          call    SeekTrack
          mov     eax,1
          call    SeekTrack
          call    StopNewTimer

          call     ZeroResIfError

          xor     edx,edx
          mov     ebx,50
          div     ebx
          mov     [SeekZamer],ax
          mov     [LineCorrect2],9
          mov     [LineCorrect],10
          mov     [LineCorrect4],8
          mov     [LineCorrect5],11
          mov     [LineCorrect1],7
          cmp     ax,60
          jb      short HardSeekProblem
          cmp     [Int13ExtSup],1
          jnz     short NoHardSeekProblem
          cmp     [WinPres],1
          jnz     short NoHardSeekProblem
HardSeekProblem:
          mov     [SeekProblem],1
          sub     [LineCorrect],3
          sub     [LineCorrect1],3
          sub     [LineCorrect2],3
          sub     [LineCorrect4],3
          sub     [LineCorrect5],3
NoHardSeekProblem:
          call    MashtabSeek
          call    PrnMesHddNumAndInt13Ext
          call    PrnATAFutures
          cmp     [SeekProblem],1
          jz      SkipSeekTest
          mov     si,offset MesTimingSeek
          call    ColorStr6x8
          mov     si,offset MesTrackSeekTime
          call    colorstr6x8

          xor     eax,eax                    ;  ***************************
          mov     [TotallSeekSpeed],eax      ;  * ВЫЧИСЕНИЕ МАКСИМАЛЬНОГО *
          mov     [SumSeekSpeed],eax         ;  *   И СРЕДНЕГО ВРЕМЕНИ    *
          mov     [OldTotallSeekSpeed],eax   ;  *  ПОЗИЦИОНИРОВАНИЯ HDD   *
          mov     [ForUscoren],al            ;  ***************************
          mov     [RealTrack],eax
          mov     [HDDKolichProxodov],eax
          mov     [AntialisingSeed],al
          mov     si,offset MesAvgMaxSeekTime
          call    ColorStr6x8

          call    SeekTrack
          inc     eax
          call    SeekTrack
          dec     eax
          call    SeekTrack

          call    GetCounterTracksHDDForSeek

NextTestingTrackInHDDSeekTest:

          mov     eax,[RealTrack]
          call    PrnTestingTrack

          call    StartNewTimer

          call    SeekTrack
          sub     eax,eax
          call    SeekTrack
          call    StopNewTimer

          call    GraphAntialising31

          call    ZeroResIfError

          mov     [NewTekushSpeed],eax
          xor     edx,edx
          mov     ebx,24  ;При изменении необходима калибровка
          div     ebx     ;конст. MashtabHddSeek

          push    eax
          add     [SumSeekSpeed],eax

          mov     eax,[SumSeekSpeed]
          mov     ebx,[HDDKolichProxodov]
          inc     ebx
          sub     edx,edx
          div     ebx
          mov     [AverageSeek],eax
          mov     cx,2
          mov     di,offset AvgSeekSpeed
          call    BinToAscDec2
          pop     eax

          cmp     [OldTotallSeekSpeed],eax
          jae     short NoMaxResDetect

          mov     [OldTotallSeekSpeed],eax
          mov     [MaxSeek],eax
          mov     cx,3
          mov     di,offset MaxSeekSpeed
          call    BinToAscDec2
NoMaxResDetect:
          mov     si,offset AvgMaxSeekTime
          call    ColorStr6x8

          mov     bx,[MashtabHddSeek]
          mov     [MashtabHdd],bx

          mov     bp,4+8
          call    BuildGraph

          call    WaitingAndGetCh

          cmp     al,1Bh
          jz      short HDDAverageMaxSeekTestSkipped
          cmp     al,' '
          jnz     short HDDAverageMaxSeekTestNotSkipped
HDDAverageMaxSeekTestSkipped:
          mov     si,offset MesAvgMaxSkipped
          call    ColorStr6x8

          cmp     al,1Bh
          jz      ExitFromHardDriveTest
          jmp     short SkipSaveResultsMaxSeek

HDDAverageMaxSeekTestNotSkipped:

          sub     edx,edx
          mov     eax,[Tracks]

          dec     eax

          mul     [HDDKolichProxodov]
          div     [CounterHDDFastTest]
          mov     [RealTrack],eax

          mov     eax,[HDDKolichProxodov]
          cmp     eax,[CounterHDDFastTest]
          jb      NextTestingTrackInHDDSeekTest

          mov     si,offset HDDResBuff
          mov     al,17*4
          mul     [DefaultDrive]
          add     si,ax
          mov     eax,[MaxSeek]
          mov     [dword ds:si],eax
          mov     eax,[AverageSeek]
          mov     [dword ds:si+49],eax

SkipSaveResultsMaxSeek:                       ;****************************
          mov     si,offset MesRandomSeekTime ;* ОПРЕДЕЛЕНИЕ СЛУЧАЙНОГО   *
          call    colorstr6x8                 ;* ВРЕМЕНИ ПОЗИЦИОНИРОВАНИЯ *
          sub     eax,eax                     ;* ЖЕСТКОГО ДИСКА           *
          mov     [TotallSeekSpeed],eax       ;****************************
          mov     [RealTrack],eax
          mov     [ForUscoren],32
          call    SeekToTrack0
          call    SetRnd

          cmp     [Method],1
          mov     cx,300
          jz      short LoopTestingAverageHddSeek
          mov     cx,100
LoopTestingAverageHddSeek:
          push    cx

          call    StartNewTimer
          mov     cx,8
NextSeekRandomTrack:
          mov     eax,[Tracks]
          call    Rnd
          mov     ebp,eax
          call    SeekTrack
          loop    short NextSeekRandomTrack
          call    StopNewTimer

          call    ZeroResIfError

          add     [TotallSeekSpeed],eax
          mov     eax,ebp
          mov     cx,6
          mov     di,offset Track
          call    BinToAscDecH
          call    NZInMes
          mov     eax,[TotallSeekSpeed]
          xor     edx,edx
          mov     ebx,94
          div     ebx
          xor     edx,edx
          inc     [RealTrack]
          mov     ebx,[RealTrack]
          div     ebx
          mov     [AverageSeek],eax
          mov     cx,2
          mov     di,offset NumRandomSeekSpeed
          call    BinToAscDec2
          mov     si,offset MesTimingSeek
          call    ColorStr6x8
          mov     si,offset RandomResultSeek
          call    ColorStr6x8
          pop     cx
          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      short HDDRandomSeekSkipped
          cmp     al,' '
          jnz     short HDDRandomSeekNotSkipped
HDDRandomSeekSkipped:
          mov     si,offset MesSkipped
          mov     [dword ds:si],20204D17h
          call    ColorStr6x8
          cmp     al,1Bh
          jz      ExitFromHardDriveTest
          jmp     short GoToSpeedSeekTimeTesting

HDDRandomSeekNotSkipped:
          loop      LoopTestingAverageHddSeek

          mov     si,offset HDDResBuff
          mov     al,17*4
          mul     [DefaultDrive]
          add     si,ax
          mov     eax,[AverageSeek]
          mov     [dword ds:si+4],eax

GoToSpeedSeekTimeTesting:
          call    MashtabSeek
          call    PrnMesHddNumAndInt13Ext

          xor     eax,eax
          mov     [TotallSeekSpeed],eax
          mov     [OldTotallSeekSpeed],eax
          mov     [RealTrack],eax
          mov     [HDDKolichProxodov],eax
          mov     [AntialisingSeed],al
          mov     [TotallTTSpeed],eax
          mov     [ForUscoren],al

          inc     ax
          call    SeekTrack
          dec     ax
          call    SeekTrack
          inc     ax
          call    SeekTrack
          dec     ax

          call    GetCounterTracksHDDForSeek

NextSeekForTrackToTrackSeek:

          mov     eax,[RealTrack]
          call    PrnTestingTrack

          call    StartNewTimer     ;  ************************
          inc     eax               ;  *  TRACK TO TRACK SEEK *
          call    SeekTrack         ;  *                      *
          dec     eax               ;  ************************
          call    SeekTrack
          inc     eax
          call    SeekTrack

          call    StopNewTimer

          call    GraphAntialising31

          call    ZeroResIfError

          mov     [NewTekushSpeed],eax
          xor     edx,edx
          mov     ebx,38          ;При изменении необходима калибровка
          div     ebx             ;конст. MashtabHddSeekTT

          add     [TotallTTSpeed],eax

          mov     eax,[HDDKolichProxodov]
          inc     eax
          cmp     eax,[CounterHDDFastTest]
          jae     short SkipIfTrackToTrackEnd
          cmp     [CounterHDDFastTest],298
          jnz     short SkipIfTrackToTrackEnd
          mov     ebx,[Tracks]
          dec     ebx
          mul     ebx
          div     [CounterHDDFastTest]
          call    SeekTrack
SkipIfTrackToTrackEnd:

          mov     eax,[TotallTTSpeed]
          mov     ebx,[HDDKolichProxodov]
          xor     edx,edx
          inc     ebx
          div     ebx
          mov     [AverageTT],ax
          xor     dx,dx
          mov     cx,2
          mov     di,offset TTSpeed
          call    BinToAscDec2
          mov     si,offset ResultTT
          call    ColorStr6x8

          mov     bx,[MashtabHddSeekTT]
          mov     [MashtabHdd],bx

          mov     bp,2
          call    BuildGraph

          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      short HDDTrackToTrackSeekTestSkipped
          cmp     al,' '
          jnz     short HDDTrackToTrackSeekTestNotSkipped
HDDTrackToTrackSeekTestSkipped:
          mov     si,offset MesSkipped
          mov     [dword ds:si],20204D17h
          call    ColorStr6x8
          cmp     al,1Bh
          jz      ExitFromHardDriveTest
          jmp     short SkipSeekTest

HDDTrackToTrackSeekTestNotSkipped:
          sub     edx,edx
          mov     eax,[Tracks]

          dec     eax

          mul     [HDDKolichProxodov]
          div     [CounterHDDFastTest]
          mov     [RealTrack],eax

          mov     eax,[HDDKolichProxodov]
          cmp     eax,[CounterHDDFastTest]
          jb      NextSeekForTrackToTrackSeek

          mov     si,offset HDDResBuff
          mov     al,17*4
          mul     [DefaultDrive]
          add     si,ax
          movzx   eax,[AverageTT]
          mov     [dword ds:si+8],eax
SkipSeekTest:
          call    PrnMesHddNumAndInt13Ext

          call    MashtabSeek

;Замер скорости чтения для определения масштаба
          mov     [ForUscoren],32
          mov     eax,[Tracks]
          shr     eax,4
          call    PrnTestingTrack
          push    eax
          call    StartNewTimer
          call    ReadTrack
          call    StopNewTimer
          mov     ebx,eax
          pop     eax
          inc     eax
          call    PrnTestingTrack
          call    StartNewTimer
          call    ReadTrack
          call    StopNewTimer
          add     eax,ebx
          cmp     [Int13Error],1
          jnz     short NoErrorInReadForDetectMashtab
          mov     eax,2000000
NoErrorInReadForDetectMashtab:
          shr     eax,1
          mov     [ZamerReadEAX],eax
          mov     eax,[Tracks]
          shr     eax,1
          call    PrnTestingTrack
          push    eax
          call    StartNewTimer
          call    ReadTrack
          call    StopNewTimer
          mov     ebx,eax
          pop     eax
          inc     eax
          call    PrnTestingTrack
          call    StartNewTimer
          call    ReadTrack
          call    StopNewTimer
          add     eax,ebx
          cmp     [Int13Error],1
          jnz     short NoErrorInReadForDetectMashtab2
          mov     eax,2000000
NoErrorInReadForDetectMashtab2:
          shr     eax,1
          cmp     eax,[ZamerReadEAX]
          ja     short ReadHDDResultFast
          mov     [ZamerReadEAX],eax
ReadHDDResultFast:

          sub     eax,eax
          mov     [TotallRandomAccess],eax
          mov     [RealTrack],eax
          call    SeekToCentre
          call    SetRnd

          cmp     [Method],1
          mov     cx,300
          jz      short LoopTestingRandomAccessHDD
          mov     cx,100
LoopTestingRandomAccessHDD:
          push    cx
          call    StartNewTimer     ;ОПРЕДЕЛЕНИЕ СЛУЧАЙНОГО
          call    RandomAccessTrack ;ВРЕМЕНИ ДОСТУПА
          call    RandomAccessTrack
          call    RandomAccessTrack
          call    RandomAccessTrack
          call    StopNewTimer

          call    ZeroResIfError

          add     [TotallRandomAccess],eax

          inc     [RealTrack]
          mov     eax,[Tracks]
          call    Rnd
          mov     cx,6
          mov     di,offset Track
          call    BinToAscDecH
          call    NZInMes
          mov     eax,[TotallRandomAccess]
          xor     edx,edx
          mov     ebx,46
          div     ebx
          xor     edx,edx
          div     [RealTrack]
          mov     [AverageRNDAccess],eax
          mov     cx,2
          mov     di,offset NumRandomAccess
          call    BinToAscDec2
          mov     si,offset MesRandomAccess
          call    ColorStr6x8
          mov     si,offset MesTimingSeek
          call    ColorStr6x8
          pop     cx
          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      short HDDRandomAccessSkipped
          cmp     al,' '
          jnz     short HDDRandomAccessNotSkipped
HDDRandomAccessSkipped:
          call    PrnMesSkipped
          cmp     al,1Bh
          jz      ExitFromHardDriveTest
          jmp     short TestingReadSpeedHDD

HDDRandomAccessNotSkipped:
          loop    LoopTestingRandomAccessHDD

          mov     si,offset HDDResBuff
          mov     al,17*4
          mul     [DefaultDrive]
          add     si,ax
          mov     eax,[AverageRNDAccess]
          mov     [dword ds:si+12],eax
          inc     [HDDTestComplite]

TestingReadSpeedHDD:

          mov     si,offset ResultBufferedHDD
          call    ColorStr6x8

;Замер скорости проверки для определения масштаба

          mov     eax,[Tracks]
          shr     eax,4
          call    PrnTestingTrack
          push    eax
          call    StartNewTimer
          call    SpeedTrack
          call    StopNewTimer
          mov     ebx,eax
          pop     eax
          inc     eax
          call    PrnTestingTrack
          call    StartNewTimer
          call    SpeedTrack
          call    StopNewTimer
          add     eax,ebx

          cmp     [Int13Error],1
          jnz     short NoErrorInVerifyForMashtab
          mov     eax,2000000
NoErrorInVerifyForMashtab:
          shr     eax,1
          mov     [ZamerSpeedEAX],eax
          mov     eax,[Tracks]
          shr     eax,1
          call    PrnTestingTrack
          push    eax
          call    StartNewTimer
          call    SpeedTrack
          call    StopNewTimer
          mov     ebx,eax
          pop     eax
          inc     eax
          call    PrnTestingTrack
          call    StartNewTimer
          call    SpeedTrack
          call    StopNewTimer
          add     eax,ebx

          cmp     [Int13Error],1
          jnz     short NoErrorInVerifyForMashtab2
          mov     eax,2000000
NoErrorInVerifyForMashtab2:
          shr     eax,1
          cmp     eax,[ZamerSpeedEAX]
          ja     short NextHDDResultFast
          mov     [ZamerSpeedEAX],eax
NextHDDResultFast:

          mov     [SkipVerify],0
          mov     eax,[ZamerReadEAX]
          mov     ebx,100
          mul     ebx
          sub     edx,edx
          mov     ebx,[ZamerSpeedEAX]
          or      ebx,ebx
          jz      short ReadSpeedNoBigThenVerify
          div     ebx
          cmp     ax,95
          ja      short ReadSpeedNoBigThenVerify
          mov     eax,[ZamerReadEAX]
          mov     [ZamerSpeedEAX],eax
          mov     [SkipVerify],1
ReadSpeedNoBigThenVerify:

;*************************************
;******** Buffered read speed*********
;*************************************

          mov     si,offset ResultBufferedHDD
          call    ColorStr6x8

          mov     [ResHDDCacheSpeed],0
          mov     cx,2
          mov     [HeadNumber],0

NextResGetHDDCacheSpeed:
          push    cx
          call    GetHDDCacheSpeed
          push    eax
          sub     eax,eax
          mov     ax,cx
          mov     ebx,586161*16
          mul     ebx
          pop     ebx
          or      ebx,ebx
          jz      short HDDCacheSpeedError
          div     ebx
          jmp     short HDDCacheSpeedNoError
HDDCacheSpeedError:
          sub     eax,eax
HDDCacheSpeedNoError:
          cmp     eax,[ResHDDCacheSpeed]
          jb      short HDDCacheSpeedIsSmall

          mov     [ResHDDCacheSpeed],eax

          mov     cx,6
          mov     di,offset BufferedSpeedHDD
          call    BinToAscDecH
          call    NZInMes
          mov     si,offset MesBufferedSpeedHDD
          call    ColorStr6x8

HDDCacheSpeedIsSmall:
          pop     cx
          add     cx,4
          cmp     cx,127
          jb      short NextResGetHDDCacheSpeed

          mov     si,offset HDDResBuff
          mov     al,17*4
          mul     [DefaultDrive]
          add     si,ax
          mov     eax,[ResHDDCacheSpeed]
          mov     [dword ds:si+29],eax

          call    MashtabSpeed          ; ***************************
          xor     eax,eax               ; *   ВЫЧИСЛЕНИЕ СКОРОСТИ   *
                                        ; *   ПРОВЕРКИ ДОРОЖКИ      *
          mov     [TotallReadSpeed],eax ; ***************************
          mov     [MaxHDDtransfer],eax
          mov     [MinHDDtransfer],eax
          mov     [RealTrack],eax
          mov     [HDDKolichProxodov],eax
          mov     [AntialisingSeed],al

          call    SeekToTrack0

          call    GetCounterTracksHDD

NextTestingTrackInHDDVerify:
          sub     edx,edx
          mov     eax,[Tracks]
          div     [CounterHDDFastTest]
          cmp     eax,5
          jae     short GoTo4TrackMethodInVerifyTrack
          mov     eax,[RealTrack]
          call    PrnTestingTrack
          call    StartNewTimer
          call    SpeedTrack
          call    StopNewTimer

          jmp     short EndFullMethodInVerifyTrack
GoTo4TrackMethodInVerifyTrack:
          mov     eax,[RealTrack]
          call    PrnTestingTrack
          call    SpeedTrack
          sub     ebx,ebx
          mov     cx,4
NextTrackFrom4InVerify:
          inc     eax

          push    eax
          call    PrnTestingTrack
          call    StartNewTimer
          call    SpeedTrack
          call    StopNewTimer
          add     ebx,eax
          pop     eax

          call    ZeroResIfError
          jz      short EndFullMethodInVerifyTrack

          loop    NextTrackFrom4InVerify
          mov     eax,ebx
          shr     eax,2
EndFullMethodInVerifyTrack:

          push    eax     ;Вычисление скорости чтения одного кластера
          mov     eax,[Heads]
          mul     [Sectors]
          mov     ebx,586161
          mul     ebx
          pop     ebx
          dec     ebx
          div     ebx

          call    ZeroResIfError

          call    GraphAntialising21

          mov     [NewTekushSpeed],eax

          call    GetMinMaxHDDTransfer
          add     [TotallReadSpeed],eax

          mov     eax,[TotallReadSpeed]
          xor     edx,edx
          mov     ebx,[HDDKolichProxodov]
          inc     ebx
          div     ebx
          mov     [AverageSpeed],eax
          mov     cx,6
          mov     di,offset VerifySpeedHDD
          call    BinToAscDecH
          call    NZInMes
          mov     si,offset ResultSpeedHDD
          call    ColorStr6x8

          mov     bx,[MashtabHddRead]
          mov     [MashtabHdd],bx
          mov     bp,6
          call    BuildGraph

          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      short HDDReadSpeedTestSkipped
          cmp     al,' '
          jnz     short HDDReadSpeedTestNotSkipped
HDDReadSpeedTestSkipped:
          call    PrnMesSkippedForLinearVerifySpeed
          cmp     al,1Bh
          jz      ExitFromHardDriveTest
          jmp     short GoToReadTrackInHDDtest

HDDReadSpeedTestNotSkipped:
          sub     edx,edx
          mov     eax,[Tracks]

          mul     [HDDKolichProxodov]
          div     [CounterHDDFastTest]
          mov     [RealTrack],eax
          mov     eax,[HDDKolichProxodov]
          cmp     eax,[CounterHDDFastTest]
          jb      NextTestingTrackInHDDVerify

          mov     si,offset HDDResBuff
          mov     al,17*4
          mul     [DefaultDrive]
          add     si,ax
          mov     eax,[AverageSpeed]
          mov     [dword ds:si+16],eax
          mov     eax,[MinHDDTransfer]
          mov     [dword ds:si+29+4],eax
          mov     eax,[MaxHDDTransfer]
          mov     [dword ds:si+29+8],eax

          call    PrnMesHddNumAndInt13Ext

          call    MashtabSeek
          call    MashtabSpeed
          cmp     [SkipVerify],1
          jz      short GoToReadTrackInHDDtest
          inc     [HDDTestComplite]

GoToReadTrackInHDDtest:

SkipVerifySpeed:
          call    CompareRes

          call    MashtabSeek
          call    MashtabSpeed               ; ***************************
          xor     eax,eax                    ; *   ВЫЧИСЛЕНИЕ СКОРОСТИ   *
                                             ; *     ЧТЕНИЯ  ДОРОЖКИ     *
          mov     [TotallReadSpeed],eax      ; ***************************
          mov     [MaxHDDtransfer],eax
          mov     [MinHDDtransfer],eax
          mov     [RealTrack],eax
          mov     [HDDKolichProxodov],eax
          mov     [AntialisingSeed],al

          call    SeekToTrack0

          call    GetCounterTracksHDD

NextTestingTrackInHDDRead:
          sub     edx,edx
          mov     eax,[Tracks]
          div     [CounterHDDFastTest]
          cmp     eax,5
          jae     short GoTo4TrackMethodInReadTrack
          mov     eax,[RealTrack]
          call    PrnTestingTrack
          call    StartNewTimer
          call    ReadTrack
          call    StopNewTimer

          jmp     short EndFullMethodInReadTrack
GoTo4TrackMethodInReadTrack:
          mov     eax,[RealTrack]
          call    PrnTestingTrack
          call    ReadTrack
          sub     ebx,ebx
          mov     cx,4
NextTrackFrom4InRead:
          inc     eax
          push    eax
          call    PrnTestingTrack
          call    StartNewTimer
          call    ReadTrack
          call    StopNewTimer
          add     ebx,eax
          pop     eax

          call    ZeroResIfError
          jz      short EndFullMethodInReadTrack

          loop    NextTrackFrom4InRead

          mov     eax,ebx
          shr     eax,2
EndFullMethodInReadTrack:

          push    eax     ;Вычисление скорости чтения одного кластера
          mov     eax,[Heads]
          mul     [Sectors]
          mov     ebx,586161
          mul     ebx
          pop     ebx
          dec     ebx
          div     ebx

          call    ZeroResIfError

          call    GraphAntialising21

          mov     [NewTekushSpeed],eax
          call    GetMinMaxHDDTransfer
          add     [TotallReadSpeed],eax

          mov     eax,[TotallReadSpeed]
          xor     edx,edx
          mov     ebx,[HDDKolichProxodov]
          inc     ebx
          div     ebx
          mov     [AverageSpeed],eax
          mov     cx,6
          mov     di,offset ReadSpeedHDD
          call    BinToAscDecH
          call    NZInMes
          mov     si,offset ResultReadHDD
          call    ColorStr6x8

          mov     bx,[MashtabHddRead]
          mov     [MashtabHdd],bx
          mov     bp,6+8
          call    BuildGraph

          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      short HDDLinearReadSpeedTestSkipped
          cmp     al,' '
          jnz     short HDDLinearReadSpeedTestNotSkipped
HDDLinearReadSpeedTestSkipped:
          call    PrnMesSkippedForLinearReadSpeed

          cmp     al,1Bh
          jz      ExitFromHardDriveTest
          jmp     short SkipLinearReadHDDSpeedTest

HDDLinearReadSpeedTestNotSkipped:
          sub     edx,edx
          mov     eax,[Tracks]

          mul     [HDDKolichProxodov]
          div     [CounterHDDFastTest]
          mov     [RealTrack],eax
          mov     eax,[HDDKolichProxodov]
          cmp     eax,[CounterHDDFastTest]
          jb      NextTestingTrackInHDDRead

          inc     [HDDTestComplite]
          call    CompareRes

          mov     si,offset HDDResBuff
          mov     al,17*4
          mul     [DefaultDrive]
          add     si,ax
          mov     eax,[AverageSpeed]
          mov     [dword ds:si+20],eax
          mov     eax,[MinHDDTransfer]
          mov     [dword ds:si+29+12],eax
          mov     eax,[MaxHDDTransfer]
          mov     [dword ds:si+29+16],eax

          call    PrnMesHddNumAndInt13Ext

SkipLinearReadHDDSpeedTest:

          cmp     [EnableWriteHDD],1
          jnz     SkipLinearWriteHDDSpeedTest
          mov     [EnableWriteHDD],0

          call    MashtabSeek
          call    MashtabSpeed               ; ***************************
          xor     eax,eax                    ; *   ВЫЧИСЛЕНИЕ СКОРОСТИ   *
                                             ; *     ЗАПИСИ  ДОРОЖКИ     *
          mov     [TotallReadSpeed],eax      ; ***************************
          mov     [MaxHDDtransfer],eax
          mov     [MinHDDtransfer],eax
          mov     [RealTrack],eax
          mov     [HDDKolichProxodov],eax
          mov     [AntialisingSeed],al

          call    SeekToTrack0

          call    GetCounterTracksHDD

          push    es
          mov     ax,[EndProgram]
          mov     es,ax
          sub     al,al
          mov     cx,0FFFFh
          sub     di,di
          cld
          rep stosb
          pop     es


NextTestingTrackInHDDWrite:
          sub     edx,edx
          mov     eax,[Tracks]
          div     [CounterHDDFastTest]
          cmp     eax,5
          jae     short GoTo4TrackMethodInWriteTrack
          mov     eax,[RealTrack]
          call    PrnTestingTrack
          call    StartNewTimer
          call    WriteTrack
          call    StopNewTimer

          jmp     short EndFullMethodInWriteTrack
GoTo4TrackMethodInWriteTrack:
          mov     eax,[RealTrack]
          call    PrnTestingTrack
          call    WriteTrack
          sub     ebx,ebx
          mov     cx,4
NextTrackFrom4InWrite:
          inc     eax
          push    eax
          call    PrnTestingTrack
          call    StartNewTimer
          call    WriteTrack
          call    StopNewTimer
          add     ebx,eax
          pop     eax

          call    ZeroResIfError
          jz      short EndFullMethodInWriteTrack

          loop    NextTrackFrom4InWrite

          mov     eax,ebx
          shr     eax,2
EndFullMethodInWriteTrack:

          push    eax     ;Вычисление скорости чтения одного кластера
          mov     eax,[Heads]
          mul     [Sectors]
          mov     ebx,586161
          mul     ebx
          pop     ebx
          dec     ebx
          div     ebx

          call    ZeroResIfError

          call    GraphAntialising21

          mov     [NewTekushSpeed],eax
          call    GetMinMaxHDDTransfer
          add     [TotallReadSpeed],eax

          mov     eax,[TotallReadSpeed]
          xor     edx,edx
          mov     ebx,[HDDKolichProxodov]
          inc     ebx
          div     ebx
          mov     [AverageSpeed],eax
          mov     cx,6
          mov     di,offset WriteSpeedHDD
          call    BinToAscDecH
          call    NZInMes
          mov     si,offset ResultWriteHDD
          call    ColorStr6x8

          mov     bx,[MashtabHddRead]
          mov     [MashtabHdd],bx
          mov     bp,7
          call    BuildGraph

          call    WaitingAndGetCh
          cmp     al,1Bh
          jz      short HDDLinearWriteSpeedTestSkipped
          cmp     al,' '
          jnz     short HDDLinearWriteSpeedTestNotSkipped
HDDLinearWriteSpeedTestSkipped:
          mov     si,offset MesSkipped
          mov     [dword ds:si],20004E16h
          mov     al,[LineCorrect5]
          mov     [byte ds:si+2],al
          call    ColorStr6x8

          cmp     al,1Bh
          jz      short ExitFromHardDriveTest
          jmp     short SkipLinearWriteHDDSpeedTest

HDDLinearWriteSpeedTestNotSkipped:
          sub     edx,edx
          mov     eax,[Tracks]

          mul     [HDDKolichProxodov]
          div     [CounterHDDFastTest]
          mov     [RealTrack],eax
          mov     eax,[HDDKolichProxodov]
          cmp     eax,[CounterHDDFastTest]
          jb      NextTestingTrackInHDDWrite

          mov     si,offset HDDResBuff
          mov     al,17*4
          mul     [DefaultDrive]
          add     si,ax
          mov     eax,[AverageSpeed]
          mov     [dword ds:si+53],eax
          mov     eax,[MinHDDTransfer]
          mov     [dword ds:si+57],eax
          mov     eax,[MaxHDDTransfer]
          mov     [dword ds:si+61],eax

SkipLinearWriteHDDSpeedTest:

IntNextTrackHdd:
ExitFromHardDriveTest:

          ret
ENDP HardDriveTest

PROC GetCounterTracksHDD
          mov     eax,[Tracks]
          cmp     [Method],1
          jz      short DetectFullHDDTest
          cmp     eax,50*5
          jbe     short DetectFullHDDTest
          mov     eax,50
DetectFullHDDTest:
          mov     [CounterHDDFastTest],eax
          ret
ENDP GetCounterTracksHDD

PROC GetCounterTracksHDDForSeek
          mov     eax,[Tracks]
          cmp     [Method],1
          jz      short DetectFullHDDTestForSeek
          cmp     eax,299
          jbe     short DetectFullHDDTestForSeek
          mov     eax,298
DetectFullHDDTestForSeek:
          mov     [CounterHDDFastTest],eax
          ret
ENDP GetCounterTracksHDDForSeek

PROC GetMinMaxHDDTransfer
          or      eax,eax
          jz      short ErrorInGetHDDSpeed
          cmp     [MaxHDDtransfer],eax
          ja      short NotMaxHDDTransfer
          mov     [MaxHDDtransfer],eax
NotMaxHDDTransfer:
          cmp     [RealTrack],0
          jnz     short NoNulTrackForGetMinMax
          mov     [MinHDDtransfer],eax
NoNulTrackForGetMinMax:
          cmp     [MinHDDtransfer],eax
          jb      short NotMinHDDTransfer
          mov     [MinHDDtransfer],eax
NotMinHDDTransfer:
ErrorInGetHDDSpeed:
          ret
ENDP GetMinMaxHDDTransfer

PROC PrnMesSkipped
          push    ax
          mov     [HDDTestComplite],3
          mov     si,offset MesSkipped
          mov     [dword ds:si],20004D16h
          mov     al,[LineCorrect1]
          mov     [byte ds:si+2],al
          call    ColorStr6x8
          mov     si,offset MesSkipped
          mov     [dword ds:si],20350216h
          call    ColorStr6x8
          pop     ax
          ret
ENDP PrnMesSkipped

PROC PrnMesSkippedForLinearVerifySpeed
          push    ax
          mov     si,offset MesSkipped
          mov     [dword ds:si],20004E16h
          mov     al,[LineCorrect2]
          mov     [byte ds:si+2],al
          call    ColorStr6x8
          cmp     [SkipVerify],1
          jz      short SkipPrnMesSkippedForHDDBench
          mov     [HDDTestComplite],3
          mov     si,offset MesSkipped
          mov     [dword ds:si],20350216h
          call    ColorStr6x8
SkipPrnMesSkippedForHDDBench:
          pop     ax
          ret
ENDP PrnMesSkippedForLinearVerifySpeed

PROC PrnMesSkippedForLinearReadSpeed
          push    ax
          mov     si,offset MesSkipped
          mov     [dword ds:si],20004E16h
          mov     al,[LineCorrect]
          mov     [byte ds:si+2],al
          call    ColorStr6x8
          cmp     [SkipVerify],1
          jnz     short SkipPrnMesSkippedForHDDBenchViaRead
          mov     [HDDTestComplite],3
          mov     si,offset MesSkipped
          mov     [dword ds:si],20350216h
          call    ColorStr6x8
SkipPrnMesSkippedForHDDBenchViaRead:
          pop     ax
          ret
ENDP PrnMesSkippedForLinearReadSpeed

PROC CompareRes
          cmp     [HDDTestComplite],2
          jnz     short SkipCompareResultsHDD

TestHDDComplite:
          mov     eax,3467
          mul     [AverageSpeed]

          mov     ebx,[AverageRNDAccess]
          or      ebx,ebx
          jz      short SkipCompareResultsHDD
          div     ebx
          push    eax
          mov     si,offset HDDResBuff
          mov     al,17*4
          mul     [DefaultDrive]
          add     si,ax
          pop     eax
          mov     [dword ds:si+24],eax
          mov     di,offset NumHDDSpeedH
          mov     cx,4
          call    BinToAscDec2
          xor     edx,edx
          mov     ebx,100
          div     ebx
          or      eax,eax
          jnz     short NotZeroInHDDspeed
          inc     eax
NotZeroInHDDspeed:

          call    Skale
          mov     [CompareGraph],ax
          call    PrnCompareWindow

          mov     si,offset NumHDDSpeed
          call    ColorStr6x8
          mov     si,offset MesHDDTest
          call    ColorStr6x8
          call    PrintSravnenieHDD

SkipCompareResultsHDD:
          ret
ENDP CompareRes

PROC PrnMesHddNumAndInt13Ext

          mov     si,offset MesHddNum
          call    colorstr6x8

          call    GetNameTestingHDD
          jc      short HDDNameNotDetectForInfoForGraph
          push    si
          mov     si,offset MesLTreugScob
          call    colorstr6x8
          pop     si

          mov     al,[byte ds:si+27]
          mov     [byte ds:si+27],0
          call    colorstr6x8
          mov     [byte ds:si+27],al

          mov     si,offset MesRTreugScob
          call    colorstr6x8

HDDNameNotDetectForInfoForGraph:

          cmp     [Int13ExtSup],1
          jnz     short Int13ExtSupNotSup
          mov     si,offset MesInt13Ex
          call    colorstr6x8
Int13ExtSupNotSup:

          cmp     [Method],1
          mov     si, offset MesHDDFullTest
          jz      short HDDFullTestForRepit
          mov     si, offset MesHDDFastTest
HDDFullTestForRepit:
          call    colorstr6x8

          mov     si,offset MesTestingTrack
          call    colorstr6x8
          ret
ENDP PrnMesHddNumAndInt13Ext

PROC PrnATAFutures
          mov     dl,[TestingHDDnumber]
          inc     dl
          or      dl,80h
          mov     bp, offset NumDriveName0
          cmp     [byte ds:bp+41],dl
          jz      short TestingHardDriveFound
          mov     bp, offset NumDriveName1
          cmp     [byte ds:bp+41],dl
          jz      short TestingHardDriveFound
          mov     bp, offset NumDriveName2
          cmp     [byte ds:bp+41],dl
          jz      short TestingHardDriveFound
          mov     bp, offset NumDriveName3
          cmp     [byte ds:bp+41],dl
          jz      short TestingHardDriveFound
          mov     bp, offset NumDriveName4
          cmp     [byte ds:bp+41],dl
          jz      short TestingHardDriveFound
          mov     bp, offset NumDriveName5
          cmp     [byte ds:bp+41],dl
          jz      short TestingHardDriveFound
          mov     bp, offset NumDriveName6
          cmp     [byte ds:bp+41],dl
          jz      short TestingHardDriveFound
          mov     bp, offset NumDriveName7
          cmp     [byte ds:bp+41],dl
          jnz     TestingHardDriveNotFound
TestingHardDriveFound:
       mov     si,offset MesPrnAtaFuture
       call    ColorStr6x8
       mov     al,[byte ds:bp+46+8] ;PIO
       or      al,al
       jz      short PIONotPresent
       dec     al
       and     ax,111b
       mov     cx,1
       mov     di,offset NumPIO
       call    BinToAscDec
       mov     si,offset MesPIO
       call    ColorStr6x8
PIONotPresent:

       mov     al,[byte ds:bp+47+8] ;UDMA bit 0-3, DMA bit 4-7
       or      al,al
       jz      short DMANotPresentForPrn
       and     ax,1111b
       or      al,al
       jz      short UDMANotSupportForPrn
       dec     al
       mov     cx,1
       mov     di,offset NumUDMA
       call    BinToAscHex
       mov     si,offset MesUDMA
       call    ColorStr6x8

       mov     al,[byte ds:bp+96] ;Selected UDMA bit 0-3, DMA bit 4-7
       or      al,al
       jz      short DMANotPresentForPrn
       and     ax,1111b
       or      al,al
       jz      short DMANotPresentForPrn
       dec     al
       mov     cx,1
       mov     di,offset NumSelectedDMA
       call    BinToAscHex
       mov     si,offset MesSelectedDMA
       call    ColorStr6x8

       jmp     short DMANotPresentForPrn
UDMANotSupportForPrn:
       mov     al,[byte ds:bp+47+8]
       shr     al,4
       dec     al
       mov     cx,1
       and     ax,1111b
       mov     di,offset NumDMA
       call    BinToAscHex
       mov     si,offset MesDMA
       call    ColorStr6x8
       mov     al,[byte ds:bp+96]
       shr     al,4
       or      al,al
       jz      short DMANotPresentForPrn
       dec     al
       mov     cx,1
       and     ax,1111b
       mov     di,offset NumSelectedDMA
       call    BinToAscHex
       mov     si,offset MesSelectedDMA
       call    ColorStr6x8


DMANotPresentForPrn:
       mov     si,offset MesSpace
       call    ColorStr6x8

       mov     ax,[word ds:bp+44+8] ;Cache Buffer Size
       or      ax,ax
       jz      short CacheBufferSizeNotPresent
       mov     cx,5
       mov     di,offset NumCacheBufferSize
       call    BinToAscDec
       mov     si,offset MesCacheBufferSize
       call    ColorStr6x8
       mov     si,offset NumCacheBufferSize
       call    NonZeroPrn
       call    ColorStr6x8
CacheBufferSizeNotPresent:
       mov     ax,[word ds:bp+42+8]

       or      ax,ax
       jz      short HDDRPMNotPresent
       mov     cx,5
       mov     di,offset NumRPM
       call    BinToAscDec
       mov     si,offset MesRPM
       call    ColorStr6x8
       mov     si,offset NumRPM
       call    NonZeroPrn
       call    ColorStr6x8
HDDRPMNotPresent:

TestingHardDriveNotFound:
          ret
ENDP PrnATAFutures

PROC MashtabSpeed
          mov     eax,[Heads]
          mul     [Sectors]
          mov     ebx,586161
          mul     ebx
          div     [ZamerSpeedEAX]

          mov     ebx,5
          sub     edx,edx
          div     ebx

          mov     ebx,100
          sub     edx,edx
          div     ebx
          mul     ebx
          add     eax,ebx

          mov     si,ax
          mov     ebx,10000
          mul     ebx
          mov     ebx,31746
          div     ebx
          mov     ebx,10
          sub     edx,edx
          div     ebx
          cmp     dl,5
          jb      short NotCorForHDmastab
          inc     ax
NotCorForHDmastab:
          mov     bx,ax
          mov     [MashtabHddRead],bx
          call    GetSpeedMashtab
          mov     si,offset MesKbsec
          call    ColorStr6x8
          ret
ENDP MashtabSpeed

PROC MashtabSeek
          cmp     [SeekProblem],1
          jz      short MashtabSeekErr
          movzx   eax,[SeekZamer]
          sub     edx,edx
          mov     ebx,456
          div     ebx
          mov     ebx,2
          sub     edx,edx
          div     ebx
          mul     ebx
          add     eax,ebx
          mov     si,ax
          push    eax
          mov     ebx,1192
          mul     ebx
          sub     edx,edx
          mov     ebx,10
          div     ebx
          mov     cx,ax
          pop     eax
          mov     ebx,752
          mul     ebx
          sub     edx,edx
          mov     ebx,10
          div     ebx
          mov     bx,ax
          mov     [MashtabHddSeek],bx
          mov     [MashtabHddSeekTT],cx
          call    GetSeekMashtab
          mov     si,offset MesMs
          call    ColorStr6x8
MashtabSeekErr:
          ret
ENDP MashtabSeek

PROC DetectHDDATAparams

          mov     ax,[word ds:si+34]
          push    si
          mov     di,offset NumTracks
          mov     cx,5
          call    BinToAscDec
          pop     si
          push    si
          mov     ax,[word ds:si+36]
          mov     di,offset NumHeads
          call    BinToAscDec
          pop     si
          mov     ax,[word ds:si+38]
          mov     di,offset NumSectors
          call    BinToAscDec
          jmp     short GoToPrnHDDparam
PROC DetectHDDnumbers
          mov     eax,[Tracks]
          mov     di,offset NumTracks
          mov     cx,6
          call    BinToAscDecH
          mov     eax,[Heads]
          mov     di,offset NumHeads
          call    BinToAscDecH
          mov     eax,[Sectors]
          mov     di,offset NumSectors
          call    BinToAscDecH
GoToPrnHDDparam:
          mov     ax,[TotalAllDrive]
          add     ax,30h
          mov     [byte ds:DiskNumber],al
          mov     si,offset AllParam
          call    colorstr6x8
          mov     si,offset NumTracks
          call    NonZeroPrn
          call    colorstr6x8
          mov     si,offset MesCelinders
          call    colorstr6x8
          mov     si,offset NumHeads
          call    NonZeroPrn
          call    colorstr6x8
          mov     si,offset MesHeads
          call    colorstr6x8
          mov     si,offset NumSectors
          call    NonZeroPrn
          call    colorstr6x8
          mov     si,offset MesSectors
          call    colorstr6x8
          inc     [ForBaseFrame]
          ret
ENDP DetectHDDnumbers
ENDP DetectHDDATAparams

PROC DetectHDDnumbersForRep
          mov     eax,[Tracks]
          mov     di,offset NumTracks
          mov     cx,6
          call    BinToAscDecH
          mov     eax,[Heads]
          mov     di,offset NumHeads
          call    BinToAscDecH
          mov     eax,[Sectors]
          mov     di,offset NumSectors
          call    BinToAscDecH
          mov     ax,[TotalAllDrive]
          add     ax,30h
          mov     [byte ds:DiskNumberForRep],al
          mov     si,offset AllParamForRep
          call     PutToReportBuf
          mov     si,offset NumTracks
          call    NonZeroPrn
          call     PutToReportBuf
          mov     si,offset MesCelinders
          call     PutToReportBuf
          mov     si,offset NumHeads
          call    NonZeroPrn
          call     PutToReportBuf
          mov     si,offset MesHeads
          call     PutToReportBuf
          mov     si,offset NumSectors
          call    NonZeroPrn
          call     PutToReportBuf
          mov     si,offset MesSectors
          call     PutToReportBuf
          ret
ENDP DetectHDDnumbersForRep

PROC DetectRealAtaName

          or      dx,dx
          jz      short NotThisDriveCheck
          push    dx
          cmp     [word ds:si],8000h
          jnz     short NotThisDriveCheck
          mov     [Int13Error],0
          call    ReadHDD5
          jc      short ErrorReadInDetectRealName

          add     dx,6
          in      al,dx
          and     al,0EFh
          or      al,bl
          out     dx,al
          add     dx,200h
          mov     al,8
          out     dx,al
          sub     dx,205h
          sub     al,al
          out     dx,al
          add     dx,2

          call    WaitingBusy
          jc      short NotThisDriveCheck

          in      al,dx
          call    ReadHDD1
          jc      short ErrorReadInDetectRealName
          and     al,0FEh
          cmp     al,4
          jne     short NotThisDriveCheck
          mov     bh,[TestingHDDnumber]
          inc     bh
          or      [byte ds:si+1],bh
          clc
          jmp     short DriveCheckOK
ErrorReadInDetectRealName:
NotThisDriveCheck:
          stc
DriveCheckOK:
          pop     dx
          ret
ENDP DetectRealAtaName

PROC GetRealATAName
          cmp     [MultiTask],1
          jz      DetectRealAtaNameOk
          mov     si,offset AtaAtapiPM
          mov     dx,[IDE0BaseIO]
          sub     bl,bl
          call    DetectRealAtaName
          jnc     DetectRealAtaNameOk
          cmp     [Int13Error],1
          jz      short ErorReadInGetRealName

          mov     si,offset AtaAtapiPS
          mov     bl,10000b
          call    DetectRealAtaName
          jnc     short DetectRealAtaNameOk
          cmp     [Int13Error],1
          jz      short ErorReadInGetRealName

          mov     si,offset AtaAtapiSM
          mov     dx,[IDE1BaseIO]            ;Second
          sub     bl,bl
          call    DetectRealAtaName
          jnc     short DetectRealAtaNameOk
          cmp     [Int13Error],1
          jz      short ErorReadInGetRealName

          mov     si,offset AtaAtapiSS
          mov     bl,10000b
          call    DetectRealAtaName
          jnc     short DetectRealAtaNameOk
          cmp     [Int13Error],1
          jz      short ErorReadInGetRealName

          mov     si,offset AtaAtapiTM
          mov     dx,[IDE2BaseIO]            ;T
          sub     bl,bl
          call    DetectRealAtaName
          jnc     short DetectRealAtaNameOk
          cmp     [Int13Error],1
          jz      short ErorReadInGetRealName

          mov     si,offset AtaAtapiTS
          mov     bl,10000b
          call    DetectRealAtaName
          jnc     short DetectRealAtaNameOk
          cmp     [Int13Error],1
          jz      short ErorReadInGetRealName

          mov     si,offset AtaAtapiQM
          mov     dx,[IDE3BaseIO]            ;Q
          sub     bl,bl
          call    DetectRealAtaName
          jnc     short DetectRealAtaNameOk
          cmp     [Int13Error],1
          jz      short ErorReadInGetRealName

          mov     si,offset AtaAtapiQS
          mov     bl,10000b
          call    DetectRealAtaName

DetectRealAtaNameOk:
ErorReadInGetRealName:
          ret
ENDP GetRealATAName

PROC GetDriveNameFromWin32
          cmp     [MultiTask],1
          jnz     short NotWinForGetRealATAName
          cmp     [SSTLabel],'_TSS'
          jnz     short NotWinForGetRealATAName
          cmp     dl,[ATAdrive]
          jnz     short NotWinForGetRealATAName
          mov     al,1
          mov     si,offset AtaAtapiPM
          call    CmpDriveNameFromWin32
          mov     si,offset AtaAtapiPS
          call    CmpDriveNameFromWin32
          mov     si,offset AtaAtapiSM
          call    CmpDriveNameFromWin32
          mov     si,offset AtaAtapiSS
          call    CmpDriveNameFromWin32
          mov     si,offset AtaAtapiTM
          call    CmpDriveNameFromWin32
          mov     si,offset AtaAtapiTS
          call    CmpDriveNameFromWin32
          mov     si,offset AtaAtapiQM
          call    CmpDriveNameFromWin32
          mov     si,offset AtaAtapiQS
          call    CmpDriveNameFromWin32

NotWinForGetRealATAName:
          ret
ENDP GetDriveNameFromWin32

PROC CmpDriveNameFromWin32
          cmp     [word ds:si],8000h
          jnz     short NotATADriveFound
          or      [byte ds:si+1],al
          inc     al
NotATADriveFound:
          ret
ENDP CmpDriveNameFromWin32

PROC PrnATADev0
          mov     [NumATADev],'0'
          jmp     short PrnATAPort
PROC PrnATADev1
          mov     [NumATADev],'1'
PrnATAPort:
          mov     di,offset NumPortATA
          mov     cx,4
          mov     ax,dx
          call    BinToAscHex
          mov     si,offset MesDetATADrive
          call    ColorStr6x8
          ret
ENDP PrnATADev1
ENDP PrnATADev0

PROC DetectIDEDriveName
          sub     bp,bp
          mov     dx,[IDE0BaseIO]            ;P
          call    PrnATADev0
          mov     si,offset NumDriveName0
          call    DetectAtaDevice
          call    PrnATADev1
          mov     si,offset NumDriveName1
          call    DetectAtaDevice
          mov     dx,[IDE1BaseIO]            ;S
          call    PrnATADev0
          mov     si,offset NumDriveName2
          call    DetectAtaDevice
          call    PrnATADev1
          mov     si,offset NumDriveName3
          call    DetectAtaDevice
          mov     dx,[IDE2BaseIO]            ;T
          call    PrnATADev0
          mov     si,offset NumDriveName4
          call    DetectAtaDevice
          call    PrnATADev1
          mov     si,offset NumDriveName5
          call    DetectAtaDevice             ;Q
          mov     dx,[IDE3BaseIO]
          or      dx,dx
          jz      short NotFoundIDE3BaseIO
          call    PrnATADev0
          mov     si,offset NumDriveName6
          call    DetectAtaDevice
          call    PrnATADev1
          mov     si,offset NumDriveName7
          call    DetectAtaDevice
NotFoundIDE3BaseIO:
          ret
ENDP DetectIDEDriveName

PROC DetectAtaDevice      ;получаем ATA параметры

          push    ax
          push    dx
          push    es

          or      dx,dx
          jz      ATAdriveNotFound

          push    [EndProgram]
          pop     es

          add     dx,6
          in      al,dx
          and     al,0EFh
          mov     bx,bp
          and     bl,1
          shl     bl,4
          or      al,bl
          out     dx,al
          add     dx,200h
          mov     al,8
          out     dx,al
          sub     dx,205h
          sub     al,al
          out     dx,al
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
          out     dx,al

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

          sub     di,di
          test    [byte es:di+1],80h
          jne     ATAdriveNotFound

          push    dx
          movzx   eax,[word es:di+2]        ;Определяем
          movzx   ebx,[word es:di+6]        ;размер
          mul     ebx                       ;жесткого
          movzx   ebx,[word es:di+12]       ;диска
          mul     ebx                       ;в MB.
          pop     dx
          shr     eax,11
          cmp     eax,819200
          ja      ATAdriveNotFound    ;Error если больше 800 GB

          call    GetATAScecInfo

          call    GetAtaAtapiDriveName
          jc      ATAdriveNotFound

          call    GetRPM

          inc     [AtaDrive]
          mov     [word ds:si+32+8],8000h ; признак ATA устройства
          clc
          jmp     ATAdriveIsFound

FaindATAPIDevices:

          mov     ax,200h
          call    SetATABlockSize
          mov     al,0A1h ;ATAPI Identify Device
          out     dx,al

          call    WaitBusyAndDataRequest
          jc      ATAdriveNotFound

          mov     cx,100h
          call    AtaAtapiGetParam
          jc      ATAdriveNotFound

          sub     di,di
          mov     al,[byte es:di+1]
          and     al,11011111b ;Bit 15,14=10-ATAPI; Bit 12-8=5-CDROM
          and     al,11000000b ;Bit 15,14=10-ATAPI
          cmp     al,80h
          jnz     short ATAdriveNotFound

          call    GetATAPIScecInfo

          call    GetAtaAtapiDriveName
          jc      short ATAdriveNotFound;CDdriveNotFound
          inc     [AtapiCDROM]
          mov     ah,20h
          sub     di,di
          mov     al,[byte es:di+1]
          and     al,11111b ; Bit 12-8=5-CDROM
          mov     [word ds:si+40],ax; признак ATAPI устройства

          call    GetATAPIDevParam
          jc      short ATAPIDevParamErrorInGet
          sub     di,di
          cmp     [byte es:di+8],02Ah
          jz      short ATAPIDevParamOK
          call    GetATAPIDevParam
          jc      short ATAPIDevParamErrorInGet
          sub     di,di
          cmp     [byte es:di+8],02Ah
          jnz     short ATAPIDevParamErrorInGet

ATAPIDevParamOK:
          cmp     [byte es:di+9],10h
          jl      short ATAPIDevParamErrorInGet
          mov     ax,[word es:di+10h] ;Max.Transfer Speed
          xchg    ah,al
          mov     [word ds:si+88],ax
          mov     ax,[word es:di+14h] ;Buffer Size
          xchg    ah,al
          mov     [word ds:si+52],ax
          mov     ax,[word es:di+16h] ;Current Transfer Speed
          xchg    ah,al
          mov     [word ds:si+90],ax
          test    [byte es:di+11],11b
          jz      short NotCDRWDrive
          mov     ax,[word es:di+1Ah] ;Max. Write Speed
          xchg    ah,al
          mov     [word ds:si+92],ax
          mov     ax,[word es:di+1Ch] ;Current Write Speed
          xchg    ah,al
          mov     [word ds:si+94],ax
NotCDRWDrive:

ATAPIDevParamErrorInGet:
          clc
          jmp     short ATAdriveIsFound

ATAdriveNotFound:

          stc
ATAdriveIsFound:
          inc     bp
          pop     es
          pop     dx
          pop     ax
          ret
ENDP DetectAtaDevice

PROC GetATAPIDevParam

          mov     bx,4
CanNotGetATAPIPageAccess:
          call    WaitingBusyAndDRQClear
          jc      short ATAPIdriveNotReadyForPacked

          sub     dx,6
          mov     al,2
          out     dx,al
          add     dx,6

          mov     ax,180h
          call    SetATABlockSize

          mov     al,0A0h ;ATAPI Packet
          out     dx,al

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
          sub     di,di
          mov     bx,16
NextATAPIPageToGet:
          call    GetATABlockSize
          shr     cx,1
          jcxz    short ATAPIdriveNotReadyForPacked
          sub     dx,7
          cld
          rep insw
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
ENDP GetATAPIDevParam

PROC SendAtapiPacket
          push    si
          sub     dx,7
          mov     si, offset ATAPIPacket
          cld
          cli
          rep outsw
          sti
          pop     si
          add     dx,7
          out     0EDh,al
          in      al,dx
          test    al,1 ;Error is Set?
          je      short ATAPISendPacketNoError
          stc
ATAPISendPacketNoError:
          ret
ENDP SendAtapiPacket

PROC DetectPCIBus
          mov     ax,0B101h
          sub     edi,edi
          int     1Ah
          jc      short DetectPCIBusNotPresent
          or      ah,ah
          jnz     short DetectPCIBusNotPresent
          cmp     edx,' ICP'
          jz      short PCIBusPresent

DetectPCIBusNotPresent:
          stc
          ret
PCIBusPresent:
          mov     [PCIBusIsPresent],1
          mov     [NumberLastPCIBus],cl
          ret
ENDP DetectPCIBus

PROC Wait4Tics
          mov     [LongTimerL],0
Wait2ticsNotSet:
          cmp     [LongTimerL],4
          jnz     short Wait2ticsNotSet
          ret
ENDP Wait4Tics

PROC GetATAScecInfo
          mov     ax,[word es:di+2]  ;celinders
          mov     [word ds:si+34+8],ax
          mov     ax,[word es:di+6]  ;heads
          mov     [word ds:si+36+8],ax
          mov     ax,[word es:di+12] ;sectors
          mov     [word ds:si+38+8],ax
          call    DetectIDELBA
          mov     ax,[word es:di+160];revision
          mov     [word ds:si+40+8],ax
          mov     ax,[word es:di+42] ;Cache Buffer Size
          shr     ax,1
          mov     [word ds:si+44+8],ax
          call    GetATAATAPITransferMode
          ret
ENDP GetATAScecInfo

PROC GetATAPIScecInfo

          call    GetATAATAPITransferMode
          ret
ENDP GetATAPIScecInfo

PROC GetATAATAPITransferMode
          test    [byte es:di+106],10b
          jz      short Word6470NotValid
          mov     al,4
          test    [byte es:di+128],010b;PIO-4 support?
          jnz     short PIOModeDetected
          mov     al,3
          test    [byte es:di+128],01b;PIO-3 support?
          jnz     short PIOModeDetected
Word6470NotValid:
          mov     al,[byte es:di+103];PIO
          and     al,11b
          or      al,al
          jz      short PIOModeDetected
          inc     al
PIOModeDetected:
          inc     al   ; for not support detection
          mov     [byte ds:si+46+8],al   ;PIO

          mov     al,3
          mov     bl,[byte es:di+63*2]
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
          mov     [byte ds:si+47+8],al

          mov     al,3
          mov     bl,[byte es:di+63*2+1]
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
          mov     [byte ds:si+96],al ;selected DMA

          test    [byte es:di+106],100b
          jz      short Word70xxNotValid
          mov     al,[byte es:di+88*2]
          or      al,al
          jz      short UDMANotSupport
          mov     bl,9
NextUDMABitCheck:
          shl     al,1
          dec     bl
          jnc     short NextUDMABitCheck
          or      [byte ds:si+47+8],bl   ;UDMA

          mov     al,[byte es:di+88*2+1]
          or      al,al
          jz      short UDMANotSupport
          mov     bl,9
NextSelectedUDMABitCheck:
          shl     al,1
          dec     bl
          jnc     short NextSelectedUDMABitCheck
          or      [byte ds:si+96],bl   ;Selected UDMA

UDMANotSupport:
Word70xxNotValid:
          ret
ENDP GetATAATAPITransferMode

PROC DetectIDELBA
          cmp     [word ds:si+34+8],03FFFh
          jz      short GoToDetectLBA
          cmp     [word ds:si+34+8],07FFFh
          jz      short GoToDetectLBA
          cmp     [word ds:si+34+8],0FFFFh
          jnz     short ExitFromDetectLBA
GoToDetectLBA:
          test    [byte es:di+106],10b
          jz      short ExitFromDetectLBA

          mov     eax,[dword es:di+60*2]
          mov      [TotalNumSectL],eax

          cmp     eax,66059280
          jb      short Heads16InLBA
          mov     [word ds:si+36+8],0FFh
Heads16InLBA:
          sub     edx,edx
          movzx   ebx,[word ds:si+36+8]   ;503 GB max
          div     ebx
          movzx   ebx,[word ds:si+38+8]
          sub     edx,edx
          div     ebx
          mov     [word ds:si+34+8],ax
ExitFromDetectLBA:
          ret
ENDP DetectIDELBA


PROC GetAtaAtapiDriveName
          mov     ax,[word es:di+54]
          cmp     ax,2020h
          jz      short DetectSpace
          cmp     [word es:di+56],ax
          jz      short ErrorInDriveName
DetectSpace:
          push    si
          push    di
          push    ds
          push    es

          push    es
          push    ds
          pop     es
          pop     ds

          mov     di,si
          mov     si,54
          mov     cx,20
          cld
          cmp     [dword ds:si],2D524353h
          jz      short NextAtaAtapiNameWordForSCR630
          call    GetIDString
          jmp     short EndAtaAtapiNameWord
NextAtaAtapiNameWordForSCR630:
          rep movsw
EndAtaAtapiNameWord:

          add     di,18
          mov     si,20 ;Serial num
          mov     cx,10
          call    GetIDString
          inc     di
          mov     si,46 ;Firmware
          mov     cx,4
          call    GetIDString
          pop     es
          pop     ds
          pop     di
          pop     si

          mov    bx,40
NextByteDriveModelToCorrect:
          cmp    [byte ds:si+bx-1],32
          ja     short EndCorrectDriveModel
          mov    [byte ds:si+bx-1],0
          dec    bx
          jnz    short NextByteDriveModelToCorrect
EndCorrectDriveModel:
          mov    bx,20
NextByteSerialNumToCorrect:
          cmp    [byte ds:si+bx+57],32
          ja     short EndCorrectSerialNum
          mov    [byte ds:si+bx+57],0
          dec    bx
          jnz    short NextByteSerialNumToCorrect
EndCorrectSerialNum:
          mov    bx,8
NextByteRevisionToCorrect:
          cmp    [byte ds:si+bx+78],32
          ja     short EndCorrectRevision
          mov    [byte ds:si+bx+78],0
          dec    bx
          jnz    short NextByteRevisionToCorrect
EndCorrectRevision:
          clc
          ret
ErrorInDriveName:
          stc
          ret
ENDP GetAtaAtapiDriveName

PROC GetIDEBaseIOPort

          sub      ch,ch
          mov      cl,[NumPCIStr]
          or       cx,cx
          jz       IDEControllerNotFound
          mov      [PCIDevRepOfs],0
FaindPCIIDEControllerForRep:
          call     GetPCIDeviceFromBuffer

          mov     si,offset PCIIDEDevList
NextPCIIDENameCheck:
          cld
          lodsd
          or      eax,eax
          jz      short EndOfPCIIDEDevName
          cmp     eax,[dword ds:PCIVEN]
          jz      short GetIOBase
          jmp     short NextPCIIDENameCheck
EndOfPCIIDEDevName:
          loop     short FaindPCIIDEControllerForRep

          mov      [PCIDevRepOfs],0
          mov      cl,[NumPCIStr]
FaindPCIIDEControllerStorageForRep:
          call     GetPCIDeviceFromBuffer
          cmp      [word ds:SubClass],0104h
          jz       short GetIOBase
          cmp      [word ds:SubClass],0180h
          jz       short GetIOBase
          loop     short FaindPCIIDEControllerStorageForRep
          jmp      short IDEControllerNotFound

GetIOBase:

          mov     ecx,[MemBase0]
          jcxz    short IDEControllerNotFound
          test    cl,1
          jz      short IDEControllerNotFound
          and     cl,0FCh
          cmp     cx,1F0h
          jz      short DetectedPrimStandardPort
          mov     eax,[MemBaseRange0]
          inc     eax
          sub     eax,ecx
          cmp     eax,8
          jnz     short DetectedPrimStandardPort
          mov     [IDE2BaseIO],cx
          sub     cx,cx
          mov     [IDE3BaseIO],cx
DetectedPrimStandardPort:

          mov     ecx,[MemBase2]
          jcxz    short IDEControllerNotFound
          test    cl,1
          jz      short IDEControllerNotFound
          and     cl,0FCh
          cmp     cx,1F0h
          jz      short DetectedSecondStandardPort
          mov     eax,[MemBaseRange2]
          inc     eax
          sub     eax,ecx
          cmp     eax,8
          jnz     short DetectedSecondStandardPort
          mov     [IDE3BaseIO],cx
DetectedSecondStandardPort:
IDEControllerNotFound:
NoPCIBusFoundForGetPCIIDE:
          ret
ENDP GetIDEBaseIOPort

PROC GetPCIDeviceFromBuffer
          push     cx
          push     ds
          mov      di,offset NumberPCIBus
          mov      si,[PCIDevRepOfs]
          push     [PCIDevRepSeg]
          pop      ds
          mov      cx,PCIDevLength
          cld
          rep movsb
          pop      ds
          mov      [PCIDevRepOfs],si
          pop      cx
          ret
ENDP GetPCIDeviceFromBuffer

PROC ReadHDD5
          push    ax
          mov     al,5
          jmp     short GoTOHDDRead
PROC ReadHDD1
          push    ax
          mov     al,1
GoTOHDDRead:
          push    bx
          push    cx
          push    dx
          push    si
          mov     dl,[TestingHDDnumber]
          or      dl,80h
          sub     dh,dh
          mov     cx,01h
          mov     ah,02h
          call    ExecINT13
          pop     si
          pop     dx
          pop     cx
          pop     bx
          pop     ax
          ret
ENDP ReadHDD1
ENDP ReadHDD5

PROC SetIDEPM
          mov     si,offset NumDriveName0
          mov     bx,'MP'
          jmp     short PutIDEdev
PROC SetIDEPS
          mov     si,offset NumDriveName1
          mov     bx,'SP'
          jmp     short PutIDEdev
PROC SetIDESM
          mov     si,offset NumDriveName2
          mov     bx,'MS'
          jmp     short PutIDEdev
PROC SetIDESS
          mov     si,offset NumDriveName3
          mov     bx,'SS'
          jmp     short PutIDEdev
PROC SetIDETM
          mov     si,offset NumDriveName4
          mov     bx,'MT'
          jmp     short PutIDEdev
PROC SetIDETS
          mov     si,offset NumDriveName5
          mov     bx,'ST'
          jmp     short PutIDEdev
PROC SetIDEQM
          mov     si,offset NumDriveName6
          mov     bx,'MQ'
          jmp     short PutIDEdev
PROC SetIDEQS
          mov     si,offset NumDriveName7
          mov     bx,'SQ'
PutIDEdev:
          mov     [word ds:IDEATAdevices],bx
          cmp     [word ds:si+32+8],ax
          ret
ENDP SetIDEQS
ENDP SetIDEQM
ENDP SetIDETS
ENDP SetIDETM
ENDP SetIDESS
ENDP SetIDESM
ENDP SetIDEPS
ENDP SetIDEPM

PROC SpeedTrackCDROM
          call    ReadSectorsCDROM
          jnc     short NoErrSectors
          inc     [TotalError]
          inc     [ErrorRead]
          call    VTOC
          jc      CDErrExit
VTOCNormal:
          jmp     short FoundErr
NoErrSectors:
          mov     [ErrorRead],0
FoundErr:
          ret
ENDP SpeedTrackCDROM

          ALIGN 2
PROC SeekTrack
          push    eax
          push    ecx
          push    ebx
          push    edx
          mov     [Int13Error],0
          cmp     [Int13ExtSup],1
          jnz     short NotSupportInt13ExtForSeek

          mul     [Heads]
          mul     [Sectors]
          mov     [AbsNumBlockL],eax
          mov     [AbsNumBlockH],edx

          mov     si,offset DiskAdrPack
          mov     dl,[DefaultDrive]
          mov     ah,47h ;Extended Seek
          jmp     short GoInt13ExtSeek

          ALIGN 2
NotSupportInt13ExtForSeek:
          mov     cl,ah
          shl     cl,6h
          mov     ch,al
          or      cl,1
          sub     dh,dh
          mov     dl,[DefaultDrive]
          mov     ah,0Ch
GoInt13ExtSeek:
          or      dl,80h
          int     13h
          jnc      short SeekPassed
          mov     [Int13Error],1
SeekPassed:
          pop     edx
          pop     ebx
          pop     ecx
          pop     eax
          ret
ENDP SeekTrack

ALIGN 2
PROC ExecINT13
          push    es
          mov     bx,[EndProgram]
          mov     es,bx
          xor     bx,bx
          int     13h
          jnc     short ExecINT13Error
          mov     [Int13Error],1
ExecINT13Error:
          pop     es
          ret
ENDP ExecINT13

ALIGN 2
PROC GetHDDCacheSpeed
          mov     [Int13Error],0
          push    cx
          mov     al,cl
          mov     cl,1
          mov     ch,[HeadNumber]
          mov     dh,ch
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ah,02h
          call    ExecINT13

          pop     cx
          mov     al,cl
          push    cx
          call    StartNewTimer
          mov     cx,16
NextBlockReadForHDDCache:
          push    ax
          push    cx
          mov     cl,1
          mov     ch,[HeadNumber]
          mov     dh,ch
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ah,02h
          call    ExecINT13
          pop     cx
          pop     ax
          loop    NextBlockReadForHDDCache
          call    StopNewTimer
          cmp     [Int13Error],1
          jnz     short NoErrorsInGetHDDCacheSpeed
          sub     eax,eax
NoErrorsInGetHDDCacheSpeed:
          pop     cx
          ret
ENDP GetHDDCacheSpeed

          ALIGN 2
PROC SpeedTrack
          mov     [Int13Error],0
          cmp     [Int13extSup],1
          jz      short GoGetSpeedTrackForInt13Ext
          push    dx
          xor     dh,dh
          ALIGN 2
VerifyFromNextHead:
          push    ax
          push    cx
          push    bx
          push    dx
          mov     cl,ah
          shl     cl,6h
          mov     ch,al
          inc     cx
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ah,04h ;Verify
          mov     al,[byte ds:Sectors]
          call    ExecINT13
          pop     dx
          pop     bx
          pop     cx
          pop     ax
          inc     dh
          cmp     dh,[byte ds:Heads]
          jb     short VerifyFromNextHead
          pop     dx
          ret
          ALIGN 2
GoGetSpeedTrackForInt13Ext:
          push    eax
          push    ecx
          push    ebx
          push    edx

          mul     [Heads]
          mov     ebx,[Sectors]
          mov     [NumTransferBlock],bx
          mul     ebx
          mov     [AbsNumBlockL],eax
          mov     [AbsNumBlockH],edx

          mov     ecx,[Heads]
          ALIGN 2
VerifyFromNextHeadInt13ext:

          mov     si,offset DiskAdrPack
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ah,44h ;Extended Verify
          int     13h
          jnc     short VerifyFromNextHeadInt13extPassed
          mov     [Int13Error],1
VerifyFromNextHeadInt13extPassed:
          mov     ebx,[Sectors]
          add     [AbsNumBlockL],ebx
          adc     [AbsNumBlockH],0
          dec     ecx
          jnz     short VerifyFromNextHeadInt13ext

          pop     edx
          pop     ebx
          pop     ecx
          pop     eax
          ret
ENDP SpeedTrack

          ALIGN 2
PROC ReadTrack
          mov     [Int13Error],0
          cmp     [Int13extSup],1
          jz      short GoGetReadTrackForInt13Ext
          push    dx
          xor     dh,dh
          ALIGN 2
ReadFromNextHead:
          push    ax
          push    cx
          push    bx
          push    dx
          mov     cl,ah
          shl     cl,6h
          mov     ch,al
          inc     cx
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ah,02h
          mov     al,[byte ds:Sectors]
          call    ExecINT13
          pop     dx
          pop     bx
          pop     cx
          pop     ax
          inc     dh
          cmp     dh,[byte ds:Heads]
          jb     short ReadFromNextHead
          pop     dx
          ret
          ALIGN 2
GoGetReadTrackForInt13Ext:
          push    eax
          push    ecx
          push    ebx
          push    edx

          mul     [Heads]
          mov     ebx,[Sectors]
          mov     [NumTransferBlock],bx
          mul     ebx
          mov     [AbsNumBlockL],eax
          mov     [AbsNumBlockH],edx

          mov     ecx,[Heads]
          ALIGN 2
ReadFromNextHeadInt13ext:

          mov     si,offset DiskAdrPack
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ah,42h ;Extended Read
          int     13h
          jnc     short ReadFromNextHeadInt13extPassed
          mov     [Int13Error],1
ReadFromNextHeadInt13extPassed:
          mov     ebx,[Sectors]
          add     [AbsNumBlockL],ebx
          adc     [AbsNumBlockH],0

          dec     ecx
          jnz     short ReadFromNextHeadInt13ext

          pop     edx
          pop     ebx
          pop     ecx
          pop     eax

          ret
ENDP ReadTrack

          ALIGN 2
PROC WriteTrack
          mov     [Int13Error],0
          cmp     [Int13extSup],1
          jz      short GoGetWriteTrackForInt13Ext
          push    dx
          xor     dh,dh
          ALIGN 2
WriteFromNextHead:
          push    ax
          push    cx
          push    bx
          push    dx

          mov     cl,ah
          shl     cl,6h
          mov     ch,al
          inc     cx
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ah,03h    ;Write
          mov     al,[byte ds:Sectors]
          call    ExecINT13
          pop     dx
          pop     bx
          pop     cx
          pop     ax
          inc     dh
          cmp     dh,[byte ds:Heads]
          jb      short WriteFromNextHead
          pop     dx
          ret
          ALIGN 2
GoGetWriteTrackForInt13Ext:
          push    eax
          push    ecx
          push    ebx
          push    edx

          mul     [Heads]
          mov     ebx,[Sectors]
          mov     [NumTransferBlock],bx
          mul     ebx

          mov     [AbsNumBlockL],eax
          mov     [AbsNumBlockH],edx

          mov     ecx,[Heads]
          ALIGN 2

WriteFromNextHeadInt13ext:

          mov     si,offset DiskAdrPack
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ah,43h ;Extended Write
          int     13h
          jnc     short WriteFromNextHeadInt13extPassed
          mov     [Int13Error],1
WriteFromNextHeadInt13extPassed:
          mov     ebx,[Sectors]
          add     [AbsNumBlockL],ebx
          adc     [AbsNumBlockH],0

          dec     ecx
          jnz     short WriteFromNextHeadInt13ext

          pop     edx
          pop     ebx
          pop     ecx
          pop     eax

          ret
ENDP WriteTrack

          ALIGN 2
PROC RandomAccessTrack
          mov     [Int13Error],0
          cmp     [Int13extSup],1
          jz      short GoGetRandomAccessTrackForInt13Ext
          push    dx
          mov     eax,[Heads]
          call    Rnd
          mov     dh,al
          mov     eax,[Tracks]
          call    Rnd
          push    cx
          push    bx
          mov     cl,ah
          shl     cl,6h
          mov     ch,al
          inc     cx
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ax,0201h
          call    ExecINT13
          pop     bx
          pop     cx
          pop     dx
          ret
          ALIGN 2
GoGetRandomAccessTrackForInt13Ext:
          push    dx
          mov     eax,[TotalNumSectL]
          call    Rnd
          mov     [AbsNumBlockL],eax
;          mov     eax,[TotalNumSectH]
;          call    Rnd
;          mov     [AbsNumBlockH],eax
          mov     [NumTransferBlock],1
          mov     si,offset DiskAdrPack
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ah,42h ;Extended Read
          int     13h
          jnc     short RandomAccessTrackPassedInt13Ext
          mov     [Int13Error],1
RandomAccessTrackPassedInt13Ext:
          pop     dx
          ret
ENDP RandomAccessTrack

          ALIGN 2
PROC SeekToTrack0
          mov     [Int13Error],0
          cmp     [Int13extSup],1
          jz      short SeekToTrack0ForInt13Ext
          push    dx
          sub     dh,dh
          push    cx
          push    bx
          mov     cx,1
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ax,0201h
          call    ExecINT13
          pop     bx
          pop     cx
          pop     dx
          ret
          ALIGN 2
SeekToTrack0ForInt13Ext:
          push    dx
          mov     [AbsNumBlockL],1
          mov     [NumTransferBlock],1
          mov     si,offset DiskAdrPack
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ah,42h ;Extended Read
          int     13h
          jnc     short SeekToTrack0PassedInt13Ext
          mov     [Int13Error],1
SeekToTrack0PassedInt13Ext:
          pop     dx
          ret
ENDP SeekToTrack0

          ALIGN 2
PROC SeekToCentre
          mov     [Int13Error],0
          cmp     [Int13extSup],1
          jz      short GoGetRandomAccessTrackForInt13ExtSeekToCentre
          push    dx
          sub     dh,dh
          mov     eax,[Tracks]
          shr     eax,1
          push    cx
          push    bx
          mov     cl,ah
          shl     cl,6h
          mov     ch,al
          inc     cx
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ax,0201h
          call    ExecINT13
          pop     bx
          pop     cx
          pop     dx
          ret
          ALIGN 2
GoGetRandomAccessTrackForInt13ExtSeekToCentre:
          push    dx
          mov     eax,[TotalNumSectL]
          shr     eax,1
          mov     [AbsNumBlockL],eax
;          mov     eax,[TotalNumSectH]
;          call    Rnd
;          mov     [AbsNumBlockH],eax
          mov     [NumTransferBlock],1
          mov     si,offset DiskAdrPack
          mov     dl,[DefaultDrive]
          or      dl,80h
          mov     ah,42h ;Extended Read
          int     13h
          jnc     short RandomAccessTrackPassedInt13ExtSeekToCentre
          mov     [Int13Error],1
RandomAccessTrackPassedInt13ExtSeekToCentre:
          pop     dx
          ret
ENDP SeekToCentre

          ALIGN 2
PROC ReadVTOC
          call    VTOC
          mov     bx,50h
          push    es
          mov     ax,[EndProgram]
          mov     es,ax
          mov     eax,[dword es:bx]
          mov     [AllSectorCDROM],eax
          mov     bx,80h
          mov     ax,[word es:bx]
          mov     [SectorSize],ax
          pop     es
          ret
ENDP ReadVTOC

          ALIGN 2
PROC VTOC
          push    ax
          push    cx
          push    bx
          push    dx
          call    RestoreTimerInterrupt
          push    es
          xor     cx,cx
          mov     cl,[ForvCDROM]
          mov     ax,[EndProgram]
          mov     es,ax
          xor     dx,dx
          xor     bx,bx
          mov     ax,1505h
          int     2Fh
          pop     es
          call    SetTimerInterrupt
          pop     dx
          pop     bx
          pop     cx
          pop     ax
          ret
ENDP VTOC

          ALIGN 2
PROC ReadyDrive
          call    VTOC
          jnc     short DriveReady
          mov     al,[DefaultDrive]
          add     al,48
          mov     [NumCDdrive],al
          mov     si,offset DriveCDROMNotReady
          call    ClearWindowMesages
          call    ColorStr6x8
NotReadyCDROM:
          call    VTOC
          jnc     short DriveReady
          call    KeyWaiting
          jz      short NotReadyCDROM
          call    GetCh
          cmp     al,27
          jz      CDErrExit
          jmp     short NotReadyCDROM
DriveReady:
          call    ClearWindowMesages
          mov     si,offset MesESC
          call    ColorStr6x8
          ret
ENDP ReadyDrive

PROC HDDSpeedCorrectCoord
          add     ax,313
          mov     bx,271
          sub     bx,[PointVert]
          or      cx,cx
          jnz     short LineNotPresent
          inc     cx
LineNotPresent:
          ret
ENDP HDDSpeedCorrectCoord

          ALIGN 2
PROC ZamerCDROMSpeed
          call    StartNewTimer
          mov     eax,[TekSectorCDROM]

          mov     [SectorsCounter],8

Next32BlockRead:
          push    eax
          push    eax
          pop     di
          pop     si
          push    es
          mov     ax,[EndProgram]
          mov     es,ax
          xor     bx,bx
          mov     ax,1508h
          xor     cx,cx
          mov     cl,[ForvCDROM]
          mov     dx,31
          int     2Fh
          pop     es
          pop     eax
          jc      short ErrSectorsRead
          add     eax,31
          dec     [SectorsCounter]
          cmp     [SectorsCounter],0
          jnz     short Next32BlockRead
          call    StopNewTimer
          jmp     NoErrSectorsRead

ErrSectorsRead:
          call    StopNewTimer
          inc     [TotalError]
          inc     [ErrorRead]
          call    VTOC
          jc      CDErrExit

          jmp     short FoundErr1
NoErrSectorsRead:
          mov     [ErrorRead],0
FoundErr1:
          mov     ebx,[BasicDivadeL]
          mov     edx,[BasicDivadeH]
          mov     [BasicDivadeG],eax
          xchg    eax,ebx
          div     ebx
          ret
ENDP ZamerCDROMSpeed

          ALIGN 2
PROC SeekToSector0
          push    [TekSectorCDROM]
          push    [SectorsRead]
          mov     [SectorsRead],1
          sub     eax,eax
          mov     [TekSectorCDROM],eax
          call    ReadSectorsCDROM
          pop     [SectorsRead]
          pop     [TekSectorCDROM]
          ret
ENDP SeekToSector0

          ALIGN 2
PROC ZamerCDROMSeekForMashtab
          mov     eax,[TekSectorCDROMH]
          mov     [TekSectorCDROM],eax
          call    SpeedTrackCDROM
          call    StartNewTimer
          mov     eax,[TekSectorCDROML]
          mov     [TekSectorCDROM],eax
          call    SpeedTrackCDROM
          call    StopNewTimer
          xor     edx,edx
          div     [BasicDivadeL]
          ret
ENDP ZamerCDROMSeekForMashtab

          ALIGN 2
PROC ZamerCDROMSeek
          mov     eax,[TekSectorCDROMH]
          mov     [TekSectorCDROM],eax
          mov     cx,6
          mov     di,offset NumTekSectorCDROML
          call    BinToAscDecH
          call    NZInMes
          call    ReadSectorsCDROM
          call    StartNewTimer
          mov     eax,[TekSectorCDROML]
          mov     [TekSectorCDROM],eax
          mov     cx,6
          mov     di,offset NumTekSectorCDROMH
          call    BinToAscDecH
          call    NZInMes
          call    ReadSectorsCDROM
          jnc     short NoErrSectors2
          inc     [TotalError]
          inc     [ErrorRead]
          call    StopNewTimer
          call    VTOC
          jc      CDErrExit
          jmp     short FoundErr2
          ALIGN 2
NoErrSectors2:
          call    StopNewTimer
          mov     [ErrorRead],0
FoundErr2:
          mov     si,offset MesSectorCDROMSeek
          call    colorStr6x8
          ret
ENDP ZamerCDROMSeek

          ALIGN 2
PROC ZamerCDROMRandomAccessTime
          mov     eax,[TekSectorCDROM]

          mov     cx,6
          mov     di,offset NumTekSectorCDROMH
          call    BinToAscDecH
          call    NZInMes
          mov     si,offset MesSectorCDROMSeek
          call    colorStr6x8
          call    StartNewTimer
          call    ReadSectorsCDROM
          jnc     short NoErrSectors2ForRandomAccessTime
          inc     [TotalError]
          inc     [ErrorRead]
          call    StopNewTimer
          call    VTOC
          jc      CDErrExit
          jmp     short FoundErr2ForRandomAccessTime
          ALIGN 2
NoErrSectors2ForRandomAccessTime:
          call    StopNewTimer
          mov     [ErrorRead],0
FoundErr2ForRandomAccessTime:
          ret
ENDP ZamerCDROMRandomAccessTime

          ALIGN 2
PROC ReadSectorsCDROM
          push    [TekSectorCDROM]
          pop     di
          pop     si
          push    es
          mov     ax,[EndProgram]
          mov     es,ax
          xor     bx,bx
          mov     ax,1508h
          xor     cx,cx
          mov     cl,[ForvCDROM]
          mov     dx,[SectorsRead]
          int     2Fh
          pop     es
          ret
ENDP ReadSectorsCDROM

          ALIGN 2
PROC GrafikCDROM
          cmp     [ErrorRead],0
          jz      short NormalReadTracks
          mov     ax,[TotalError]
          mov     di,offset NumTotalError
          mov     cx,3
          call    BinToAscDec
          call    NZInMes
          inc     cx
          xor     ax,ax
          jmp     short NonError
          ALIGN 2
NormalReadTracks:

          mov     eax,[RealResultSpeed]
          xor     edx,edx
          div     [DivMastabCDROM]
          mov     dx,[OldReadUnstab]
          shr     dx,1
          cmp     ax,dx
          mov     [UnstabRead],0
          ja      short NonUnstab
          cmp     [KolihProhodov],3
          jbe     short NoFixUnstab

          inc     [TotalUnstab]
          mov     [UnstabRead],1
NoFixUnstab:
          push    ax
          mov     ax,[TotalUnstab]
          mov     di,offset NumTotalUnstab
          mov     cx,3
          call    BinToAscDec
          call    NZInMes
          pop     ax
NonUnstab:
          mov     [OldReadUnstab],ax
NonError:
          cmp     ax,254
          jbe     short NormalPointCDROM
          mov     ax,254
NormalPointCDROM:
          mov     [TekuhPointVert],ax
          cmp     [KolihProhodov],1
          ja      short NoNulTrackCDROM
          mov     [OldTekuhPointVert],ax
NoNulTrackCDROM:

          mov     [TekuhPointVert],ax
          mov     cx,[OldTekuhPointVert]
          cmp     ax,cx
          jbe     short TekuhPointVertNoBigCDROM
          mov     [PointVert],ax
          sub     ax,cx
          mov     cx,ax
          jmp     short LineGraphCDROM
TekuhPointVertNoBigCDROM:
          mov     [PointVert],cx
          sub     cx,ax
LineGraphCDROM:

          mov     bp,4+8
          cmp     [ErrorRead],0
          push    ax
          mov     al,[ErrorRead]
          mov     [OldErrorRead],al
          pop     ax
          jnz     short ErrorCDROMRead
          cmp     [OldErrorRead],0
          push    ax
          mov     al,[ErrorRead]
          mov     [OldErrorRead],al
          pop     ax
          jnz     short ErrorCDROMRead
          mov     bp,6+8
          cmp     [UnstabRead],0
          jnz     short ErrorCDROMRead
          push    bx
          mov     ebx,[MaxResultSpeed]
          shr     ebx,1
          cmp     ebx,[RealResultSpeed]
          pop     bx
          ja      short ErrorCDROMRead
          cmp     [OldUnstab],0
          push    ax
          mov     al,[UnstabRead]
          mov     [OldUnstab],al
          pop     ax
          jnz     short ErrorCDROMRead
          cmp     [Method],1
          jnz     short DetectedFastTestForSkipLine
          xor     bp,bp
          cmp     [KolihProhodov],1
          jz      short ErrorCDROMRead
DetectedFastTestForSkipLine:
          mov     bp,2+8
ErrorCDROMRead:

          cmp     [Method],1
          jz      short DetectedFullTestForCDReadGraph
          mov     eax,[KolihProhodov]
          cmp     eax,1
          jz      short SkipPrnFirstLineForCDReadGraph
          shl     ax,2
          add     ax,313-4-4
          mov     bx,271
          mov     dx,bx
          sub     bx,[TekuhPointVert]
          sub     dx,[OldTekuhPointVert]
          mov     cx,ax
          add     cx,4
          xchg    ax,cx
          call    ColorLine
SkipPrnFirstLineForCDReadGraph:
          ret
DetectedFullTestForCDReadGraph:
          or      cx,cx
          jnz     short LineNotPresentCDROM
          inc     cx
LineNotPresentCDROM:
          mov     eax,[TekSectorCDROM]
          mov     ebx,[OsnovnDivade]
FastMethod:
          xor     edx,edx
          div     ebx
          mov     bx,[HorKoord]
          cmp     ax,bx
          jbe     short HorKoordNeIzmenilas
          inc     bx
HorKoordNeIzmenilas:
          mov     [HorKoord],bx
KoordDetect:
          mov     bx,[HorKoord]
          mov     ax,313
          add     ax,bx
          mov     bx,271
          sub     bx,[PointVert]
          call    ColorVerLine
          ret
ENDP GrafikCDROM

          ALIGN 2
PROC GrafikCDROMSeek
          mov     eax,[RealResultSpeed]
          xor     edx,edx
          div     [DivMastabCDROM]
          xor     edx,edx
          div     [BasicDivadeL]

          cmp     ax,254
          jbe     short NormalPointCDROMSeek
          mov     ax,254
NormalPointCDROMSeek:
          mov     [TekuhPointVert],ax
          cmp     [KolihProhodov],1
          ja      short NoNulTrackCDROMSeek
          mov     [OldTekuhPointVert],ax
NoNulTrackCDROMSeek:

          mov     [TekuhPointVert],ax
          mov     cx,[OldTekuhPointVert]
          cmp     ax,cx
          jbe     short TekuhPointVertNoBigCDROMSeek
          mov     [PointVert],ax
          sub     ax,cx
          mov     cx,ax
          jmp     short LineGraphCDROMSeek
TekuhPointVertNoBigCDROMSeek:
          mov     [PointVert],cx
          sub     cx,ax
LineGraphCDROMSeek:

          inc     [HorKoord]
          mov     bx,[HorKoord]
          mov     ax,313
          add     ax,bx

          mov     bx,271
          sub     bx,[PointVert]
          or      cx,cx
          jnz     short LineNotPresentCDROMSeek
          inc     cx
LineNotPresentCDROMSeek:
          mov     bp,[CDROMSeekColor]
          call    ColorVerLine
          ret
ENDP GrafikCDROMSeek

PROC PrnTekSector
          mov     eax,[TekSectorCDROM]
          mov     cx,6
          mov     di,offset NumTekSectorCDROM
          call    BinToAscDecH
          call    NZInMes
          mov     eax,[KolihProhodov]
          movzx   ebx,[SectorsRead]
          mul     ebx
          movzx   ebx,[SectorSize]
          mul     ebx
          shr     eax,20
          mov     cx,4
          mov     di,offset NumTotalRead
          call    BinToAscDecH
          call    NZInMes
          mov     si,offset MesSectorCDROM
          call    ColorStr6x8
          ret
ENDP PrnTekSector

PROC MastabSpeedCDROM
          mov     eax,[MaxResSpeedMashtab]

          mov     ebx,280
          sub     edx,edx
          div     ebx
          mov     ebx,150
          sub     edx,edx
          div     ebx
          mul     ebx
          add     eax,ebx
          mov     si,ax
          mov     ebx,314
          mul     ebx
          sub     edx,edx
          mov     ebx,100
          div     ebx
          mov     bx,ax

          mov     [NumSDxSpeed],23
          call    GetSpeedMashtab
          mov     [NumSDxSpeed],0
          mov     si,offset MesKbsec
          call    ColorStr6x8
          ret
ENDP MastabSpeedCDROM

PROC PrintHDD
          cmp     [word ds:si+32+8],8000h
          jnz     short AtapiNotFound
          push    si
          mov     si,offset MesHDDforInfo
          call    colorstr6x8
          pop     si
          jmp     short PrintHDDModel

PROC PrintCDROM

          cmp     [byte ds:si+32+8+1],20h
          jnz     short AtapiNotFound
          push    si
          cmp     [byte ds:si+32+8],5h
          mov     si,offset MesCDROMforInfo
          jz      short DetectCDROMforInfo
          mov     si,offset MesATAPIforInfo
DetectCDROMforInfo:
          call    colorstr6x8
          mov     si,offset IDEATAPIdevices
          call    colorstr6x8
          pop     si
PrintHDDModel:
          push    [dword ds:si+31]

          cmp     [byte ds:si+32],0
          jz      short NotNidedCorrectForModelStrLength
          mov     [dword ds:si+31],01019h
NotNidedCorrectForModelStrLength:

          call    colorstr6x8
          pop     [dword ds:si+31]
          cmp     [byte ds:si+32-6],0
          jnz     short CanNotPrnXspeed
          cmp     [byte ds:si+32+8],5h
          jnz     short CanNotPrnXspeed
          mov     ax,[word ds:si+88]
          mov     bx,176
          cmp     ax,bx
          jb      short CanNotPrnXspeed
          sub     dx,dx
          div     bx
          mov     cx,3
          mov     di,offset NumRepXSpeed
          call    BinToAscDec
          push    si
          mov     si,offset MesRepXSpeed
          call    colorstr6x8
          mov     si,offset NumRepXSpeed
          call    NonZeroPrn
          call    colorstr6x8
          pop     si
CanNotPrnXspeed:
          inc     [ForBaseFrame]
AtapiNotFound:
          ret
ENDP PrintCDROM
ENDP PrintHDD

PROC GetPnPBios
          push    es
          mov     ax,0F000h
          mov     es,ax
          sub     di,di
NextSearchPnP:
          cmp     [dword es:di],'PnP$'
          jz      short SearhPnPComplite
          inc     di
          cmp     di,65530
          jnz     short NextSearchPnP
          jmp     short PnPBiosNotSupport
SearhPnPComplite:
          sub     cx,cx
          mov     bp,cx
          mov     al,cl

          mov     cl,[byte es:di+5]
VerifyChecksum:
          add     al,[byte es:di+bp]
          inc     bp
          loop    short VerifyChecksum
          or      al,al
          jnz     short PnPBiosNotSupport
          mov     eax,[dword es:di+0Dh]
          mov     [PnPCall],eax
          mov     ax,[word es:di+1Bh]
          mov     [BiosSelector],ax
          mov     ax,[BiosSelector]
          push    ax
          push    ds
          mov     si,offset DMIstorageSize
          push    si
          push    ds
          mov     si,offset DMIstorageBase
          push    si
          push    ds
          mov     si,offset StructureSize
          push    si
          push    ds
          mov     si,offset NumStructures
          push    si
          push    ds
          mov     si,offset DMIBiosRevision
          push    si
          push    50h
          call    [PnpCall]
          add     sp,24
          or      ax,ax
          jnz     short PnPBiosNotSupport
          cmp     [NumStructures],0
          jz      short PnPBiosNotSupport
          mov     [PnPBiosSupport],1
PnPBiosNotSupport:
          pop     es
          ret
ENDP GetPnPBios

PROC GetPnPBiosStructure
          push    cx
          push    es
          mov     ax,[EndProgram]
          mov     es,ax
          sub     di,di
          mov     ax,di
          mov     cx,256
          cld
          rep stosw
          mov     ax,[BiosSelector]
          push    ax          ;push BiosSelector
          mov     eax,[DMIstorageBase]
          shr     eax,4
          push    ax          ;push dmiSelector
          push    es          ;push segment/selector of dmiStrucBuffer
          push    0           ;push offset of dmiStrucBuffer
          push    ds          ;push segment/selector of Structure
          mov     si,offset Structure
          push    si          ;push offset of Structure
          push    51h         ;push GET_ DMI_STRUCTURE
          call    [PnpCall]
          add     sp,14
          or      ax,ax
          jnz     short StructureError
          clc
          jmp     short StructureOk
StructureError:
          stc
StructureOk:
          pop     es
          pop     cx
          ret
ENDP GetPnPBiosStructure

PROC GetSPDInfo
          cmp     [DisableSPDread],1
          jz      SPDReadDisabledByCommandLine

          mov     [SMBusHost],1
;mov cx,0E480h
;mov     [SISSMBusHost],1
;jmp CheckSMBUSAdr
          mov     cx,7113h        ; Intel PIIX4 Power Management Controller
          mov     dx,8086h
          call    FaindPCIDevice
          jnc     SMBus7113Faund

          mov     [SMBusHost],28
          mov     cx,719Bh        ; Intel 82440MX Power Management Controller
          mov     dx,8086h
          call    FaindPCIDevice
          jnc     SMBus7113Faund

          mov     [SMBusHost],2
          mov     cx,2410h        ; Intel 82801AA Chipset SMBus Controller
          mov     dx,8086h
          call    FaindPCIDevice
          mov     cx,2413h        ; Intel 82801AA Chipset SMBus Controller
          jnc     GetICHSMBus

          mov     [SMBusHost],3
          mov     cx,2420h        ; Intel 82801AB Chipset SMBus Controller
          mov     dx,8086h
          call    FaindPCIDevice
          mov     cx,2423h        ; Intel 82801AA Chipset SMBus Controller
          jnc     GetICHSMBus

          mov     [SMBusHost],4
          mov     cx,2440h        ; 82801BA (ICH2) LPC Interface Controller
          mov     dx,8086h
          call    FaindPCIDevice
          mov     cx,2443h        ; 82801BA (ICH2) SMBus Controller
          jnc     GetICHSMBus

          mov     [SMBusHost],5
          mov     cx,244Ch        ; 82801BA (ICH2M) LPC Interface Controller
          mov     dx,8086h
          call    FaindPCIDevice
          mov     cx,2443h        ; 82801BA (ICH2M) SMBus Controller
          jnc     GetICHSMBus

          mov     [SMBusHost],6
          mov     cx,2450h        ; 82801E (ICH3E) LPC Interface Controller
          mov     dx,8086h
          call    FaindPCIDevice
          mov     cx,2453h        ; 82801E (ICH3E) SMBus Controller
          jnc     GetICHSMBus

          mov     [SMBusHost],7
          mov     cx,2480h        ; (ICH3) LPC Interface Controller
          mov     dx,8086h
          call    FaindPCIDevice
          mov     cx,2483h        ; (ICH3) SMBus Controller
          jnc     GetICHSMBus
          mov     cx,248Ch        ; 82801CAM (ICH3-M) LPC Interface
          mov     dx,8086h
          call    FaindPCIDevice
          mov     cx,2483h        ; (ICH3) SMBus Controller
          jnc     GetICHSMBus

          mov     [SMBusHost],8
          mov     cx,24C0h        ; ICH4 LPC Interface
          mov     dx,8086h
          call    FaindPCIDevice
          mov     cx,24C3h        ; ICH4 SMBus Controller
          jnc     GetICHSMBus
          mov     cx,24CCh        ; ICH4 LPC Interface
          mov     dx,8086h
          call    FaindPCIDevice
          mov     cx,24C3h        ; ICH4 SMBus Controller
          jnc     GetICHSMBus

          mov     [SMBusHost],31
          mov     cx,24D0h        ; ICH5 LPC Interface
          mov     dx,8086h
          call    FaindPCIDevice
          mov     cx,24D3h        ; ICH5 SMBus Controller
          jnc     GetICHSMBus
          mov     cx,24DCh        ; ICH5 LPC Interface
          mov     dx,8086h
          call    FaindPCIDevice
          mov     cx,24D3h        ; ICH5 SMBus Controller
          jnc     GetICHSMBus

          mov     [SMBusHost],9
          mov     cx,3050h        ; VIA 596B Power Management Controller
          mov     dx,1106h
          call    FaindPCIDevice
          jnc     SMBusHostFaundVIA596

          mov     [SMBusHost],10
          mov     cx,3057h        ; VIA 686A Power Management Controller
          mov     dx,1106h
          call    FaindPCIDevice
          mov     di,90h
          jnc     SMBusHostFaundVIA686A

          mov     [SMBusHost],29
          mov     cx,7403h        ; AMD-755 Power Management Controller
          mov     dx,1022h
          call    FaindPCIDevice
          mov     di,58h
          jnc     AMD756SMbus

          mov     [SMBusHost],11
          mov     cx,740Bh        ; AMD-756 Power Management Controller
          mov     dx,1022h
          call    FaindPCIDevice
          mov     di,58h
          jnc     AMD756SMbus

          mov     [SMBusHost],12
          mov     cx,7413h        ; AMD-766
          mov     dx,1022h
          call    FaindPCIDevice
          mov     di,58h
          jnc     AMD766SMbus

          mov     [SMBusHost],13
          mov     cx,7443h        ; AMD-768
          mov     dx,1022h
          call    FaindPCIDevice
          mov     di,58h
          jnc     AMD768SMbus

          mov     [SMBusHost],14
          mov     cx,1533h        ; ALI M1533 Aladdin IV/V ISA South Bridge
          mov     dx,10B9h
          call    FaindPCIDevice

          jc      short GoTodetectALI7101
          mov     di,5Dh
          call    ReadCfgByte
          and     cl,0BFh
          call    WriteCfgByte
          mov     di,5Fh
          call    ReadCfgByte
          and     cl,0FBh
          call    WriteCfgByte
GoTodetectALI7101:
          mov     cx,7101h        ; ALI M7101 Power Management Controller
          mov     dx,10B9h
          call    FaindPCIDevice
          jnc     GetALISMBusAccess

          mov     [SMBusHost],15
          mov     cx,3051h        ; VIA 686 Power Management Controller
          mov     dx,1106h
          call    FaindPCIDevice
          jnc     SMBusHostFaundVIA686

          mov     [SMBusHost],16
          mov     cx,8235h        ; VIA VT8235
          mov     dx,1106h
          call    FaindPCIDevice
          mov     di,090h
          jnc     SMBusHostFaundVIAVT8235

          mov     [SMBusHost],17
          mov     cx,8231h        ; VIA VT8231
          mov     dx,1106h
          call    FaindPCIDevice
          mov     di,0B0h
          jnc     SMBusHostFaundVIAVT8231

          mov     [SMBusHost],18
          mov     cx,3074h        ; VIA VT8233
          mov     dx,1106h
          call    FaindPCIDevice
          mov     di,0D0h
          jnc     SMBusHostFaundVIAVT8233

          mov     [SMBusHost],19
          mov     cx,3109h        ; VIA VT8233C
          mov     dx,1106h
          call    FaindPCIDevice
          mov     di,0D0h
          jnc     SMBusHostFaundVIAVT8233

          mov     [SMBusHost],20
          mov     cx,3147h        ; VIA VT8233?
          mov     dx,1106h
          call    FaindPCIDevice
          mov     di,0D0h
          jnc     SMBusHostFaundVIAVT8233

          mov     [SMBusHost],21
          mov     cx,3177h        ; VIA VT8235
          mov     dx,1106h
          call    FaindPCIDevice
          mov     di,0D0h
          jnc     SMBusHostFaundVIAVT8233

          mov     [SMBusHost],32
          mov     cx,3227h        ; VIA VT8237
          mov     dx,1106h
          call    FaindPCIDevice
          mov     di,0D0h
          jnc     SMBusHostFaundVIAVT8233


          mov     [SMBusHost],22
          mov     cx,0200h         ; Reliance OSB4
          mov     dx,1166h
          call    FaindPCIDevice
          mov     di,090h
          jnc     SMBusHostFaundRelianceOSB4

          mov     [SMBusHost],24

          mov     cx,0016h         ; SiS SMBus
          mov     dx,1039h
          call    FaindPCIDevice
          jc      short SiS0016SMBusHostNotFound

          jmp     GetAndCorrectSiSSMBA2
SiS0016SMBusHostNotFound:

          mov     cx,0018h         ; SiS SMBus
          mov     dx,1039h
          call    FaindPCIDevice
          jc      short SiS0018SMBusHostNotFound
          jmp     short SiS0008SMBusRevZero

SiS0018SMBusHostNotFound:
          mov     cx,0961h         ; SiS SMBus
          mov     dx,1039h
          call    FaindPCIDevice
          jc      short SiS0961SMBusHostNotFound
          jmp     short SiS0008SMBusRevZero
SiS0961SMBusHostNotFound:

          mov     cx,5513h         ; SiS SMBus
          mov     dx,1039h
          call    FaindPCIDevice
          jc      short SiS5513SMBusHostNotFound
          jmp     short SiS0008SMBusRevZero
SiS5513SMBusHostNotFound:

          mov     [SMBusHost],23

          mov     cx,0008h         ; SiS SMBus
          mov     dx,1039h
          call    FaindPCIDevice
          jc      short SiS0008SMBusHostNotFound
          mov     di,8
          call    ReadCfgByte
          or      cl,cl
          jz      short SiS0008SMBusRevZero
          cmp     al,0B0h
          jb      short ExitFromGetSiSSMBA

          mov     [SMBusHost],23
          mov     di,90h
          jmp     GetAndCorrectSiSSMBA1

SiS0008SMBusRevZero:

          mov     di,77h
          call    ReadCfgByte
          and     cl,0EFh
          call    WriteCfgByte
          mov     cx,0016h         ; SiS SMBus
          mov     dx,1039h
          call    FaindPCIDevice
          jc      short ExitFromGetSiSSMBA
          mov     [SMBusHost],24
          jmp     GetAndCorrectSiSSMBA2

SiS0008SMBusHostNotFound:



ExitFromGetSiSSMBA:

          mov     [SMBusHost],25
          mov     cx,01B4h         ; nForce SMBus Controller
          mov     dx,10DEh
          call    FaindPCIDevice
          mov     di,10h
          jnc     GetnForceSMBusAddr

          mov     [SMBusHost],26
          mov     cx,0064h         ; nForce MCP-T SMBus Controller
          mov     dx,10DEh
          call    FaindPCIDevice
          mov     di,50h
          jnc     GetnForceMCPTSMBusAddr
;          mov     [SMBusHost],27
;          mov     cx,00D4h         ; nForce MCP3 SMBus Controller
;          mov     dx,10DEh
;          call    FaindPCIDevice
;          mov     di,10h
;          jnc     GetnForceSMBusAddr


          mov     [SMBusHost],30
          mov     cx,0227h         ; Reliance OSB4 Checked ????
          mov     dx,1166h
          call    FaindPCIDevice
          mov     di,090h
          jnc     SMBusHostFaundRelianceOSB4


SPDReadDisabledByCommandLine:
          mov     [SMBusHost],0
          jmp     ExitFromGetSPDInfo

GetICHSMBus:
          push    cx
          call    EnableICHAccess
          pop     cx
          mov     dx,8086h
          call    FaindPCIDevice
          jnc     short ICHReady
          jmp     ExitFromGetSPDInfo

SMBusHostFaundVIA686:
          mov     cx,5000h
          jmp     CheckSMBUSAdr

GetALISMBusAccess:
          mov    [AliSMBusHost],1
          mov     di,5Bh
          call    ReadCfgByte
          and     cl,0FBh
          call    WriteCfgByte
          mov     di,4
          call    ReadCfgByte
          or      cl,1
          call    WriteCfgByte
          mov     di,14h
          call    ReadCfgWord
          test    cl,1
          jnz     SMBusHostFaundNotIntel
          mov     di,4
          call    ReadCfgByte
          and     cl,0FEh
          call    WriteCfgByte
          mov     cx,0DF80h
          mov     di,14h
          call    WriteCfgWord
          mov     di,0E0h
          mov     cl,1
          call    WriteCfgByte
          mov     di,0E2h
          mov     cl,20h
          call    WriteCfgByte
          mov     di,4
          call    ReadCfgByte
          or      cl,1
          call    WriteCfgByte
          mov     di,14h
          jmp     SMBusHostFaundNotIntel

SMBus7113Faund:
          mov     di,0D2h
          push    di
          call    ReadCfgByte
          pop     di
          or      cl,1
          call    WriteCfgByte
          mov     di,90h
          jmp     short GetAndCorrectSMBUSAdr
ICHReady:
          mov     di,040h
          push    di
          call    ReadCfgByte
          pop     di
          or      cl,1
          call    WriteCfgByte
          mov     di,20h

SMBusHostFaundRelianceOSB4:
GetAndCorrectSMBUSAdr:
          call    ReadCfgWord
          and     cx,0FFFEh
          jmp     short CheckSMBUSAdr

GetAndCorrectSiSSMBA2:
          mov     [SISSMBusHost],2
          jmp     short ICHReady
GetAndCorrectSiSSMBA1:
          mov     [SISSMBusHost],1
          jmp     GetAndCorrectSMBUSAdr


SMBusHostFaundVIA596:
          mov     di,8
          call    ReadCfgByte
          cmp     cl,20h
          jae     short VIA596NotReady
          mov     di,80h
          jmp     short SMBusHostFaundNotIntel
VIA596NotReady:
          mov     di,0D2h
          push    di
          call    ReadCfgByte
          pop     di
          test    cl,1
          jnz     short VIA596ReadSMBA
          or      cl,1
          call    WriteCfgByte
VIA596ReadSMBA:
          mov     di,90h
          jmp     short SMBusHostFaundNotIntel

GetnForceMCPTSMBusAddr:
          mov    [nForceMCPTSMBusHost],1
          call    ReadCfgWord
          and     cx,0FFFEh
          jmp     short CheckSMBUSAdr


GetnForceSMBusAddr:
          mov    [AMD756SMBusHost],1
          call    ReadCfgWord
          and     cx,0FFFEh
          jmp     short CheckSMBUSAdr

AMD766SMbus:
AMD756SMbus:
AMD768SMbus:
          mov    [AMD756SMBusHost],1
          call    ReadCfgWord

SMBusHostFaundVIAVT8235:
SMBusHostFaundVIAVT8233:
SMBusHostFaundVIAVT8231:
SMBusHostFaundVIA686A:
SMBusHostFaundNotIntel:
          call    ReadCfgWord
CorrectIOAdr:
          and     cx,0FFF0h
CheckSMBUSAdr:
          jcxz    ExitFromGetSPDInfo
          mov     [BaseAdrSMBus],cx

          cmp     [MainBoardForSpd],7 ;A7A133 A7A266
          jnz     short NotA7AEnableAccess
          mov     cl,40h
          call    EnDisSPDAccessOnA7A
NotA7AEnableAccess:

          cmp     [MainBoardForSpd],8 ;P4B
          jnz     short Notp4BEnableAccess
          mov     cl,2h
          call    EnDisSPDAccessOnP4B
Notp4BEnableAccess:

          cmp     [MainBoardForSpd],4
          jnz      short NotCUV4XEnableAccess
          mov     dx,0E44Ch ; Enable access to SPD for ASUS CUV4X
          in      eax,dx
          and     eax,0FFFFF6FFh
          or      eax,100h
          out     dx,eax
NotCUV4XEnableAccess:

          cmp     [MainBoardForSpd],3
          jnz      short NotP2IIX4EnableAccess
          mov     dx,0E437h ; Enable access to SPD for ASUS P3B/CUBX
          in      al,dx
          and     al,0E7h
          or      al,8h
          out     dx,al
NotP2IIX4EnableAccess:

          cmp     [MainBoardForSpd],2
          jnz     short NotASUSK7VForSPD
          mov     dx,0E44Dh ; Enable access to SPD for ASUS K7V/A7V/A7M/A7P
          in      al,dx
          and     al,0F6h
          or      al,1h
          out     dx,al
NotASUSK7VForSPD:

          cmp     [MainBoardForSpd],1
          jnz     short NotASUSP3V4XForSPD
          mov     dx,0E44Ch ; Enable access to SPD for ASUS P3V4X
          in      eax,dx
          and     eax,0E7FFFFFFh
          or      eax,8000000h
          out     dx,eax
NotASUSP3V4XForSPD:

          cmp     [MainBoardForSpd],5
          jnz     short NotASUSCUSL2ForSPD ;Enable access to SPD for ASUS CUSL2
          mov     cl,10h
          call    EnDisSPDAccessOnCUSL2
NotASUSCUSL2ForSPD:

          cmp     [MainBoardForSpd],6
          jnz     short NotASUSCURForSPD ;Enable access to SPD for ASUS CUR
          mov     cl,30h
          call    EnDisSPDAccessOnCUR
NotASUSCURForSPD:

          call    GetSPDData

          clc
          ret
ExitFromGetSPDInfo:
          stc
          ret
ENDP GetSPDInfo

PROC EnableICHAccess
          mov     di,0F2h
          push    di
          call    ReadCfgByte
          and     cl,0F7h
          pop     di
          call    WriteCfgByte
          ret
ENDP EnableICHAccess

PROC GetSPDData
          mov     [SPDSocket],50h
          mov     [NumberDIMMModules],4

          push    [SPDDataSeg]
          pop     es
          sub     di,di
GetingNextBankInfo:
          mov     [NumByteSPD],0
          mov     cx,080h
GetingNextByteSPD:
          cmp     cx,80h-2
          jnz     short Not2FirstBytesSPDRead
          cmp     [word es:di-2],0FFFFh
          jz      short ErrorFirstBytesSPDRead
          cmp     [word es:di-2],0h
          jnz     short Not2FirstBytesSPDRead
          mov     [word es:di-2],0FFFFh
ErrorFirstBytesSPDRead:
          add     di,80h-2
          dec     [NumberDIMMModules]
          jmp     short MemModulesNotFaund
Not2FirstBytesSPDRead:
          push    cx
          cmp    [SISSMBusHost],1
          jz     short GoToSISProc
          cmp    [SISSMBusHost],2
          jz     short GoToSISProc2
           cmp    [AliSMBusHost],1
           jz     short GoToALIProc
           cmp    [AMD756SMBusHost],1
           jz     short GoToAMD756Proc
           cmp    [nForceMCPTSMBusHost],1
           jz     short GoTonForceMCPTProc


           call   GetIntelSPDByte
           jmp    short GoStosbSPDbyte
GoToSISProc:
           call   GetSISSPDByte
           jmp    short GoStosbSPDbyte
GoToSISProc2:
           call   GetSISSPDByte2
           jmp    short GoStosbSPDbyte

GoToAMD756Proc:
           call   GetAMD756SPDByte
           jmp    short GoStosbSPDbyte
GoTonForceMCPTProc:
           call   GetnForceMCPTByte
           jmp    short GoStosbSPDbyte

GoToALIProc:
           call   GetALISPDByte
GoStosbSPDbyte:
           cld
           stosb
           inc    [NumByteSPD]
           pop    cx
           loop   short GetingNextByteSPD
MemModulesNotFaund:
           inc    [SPDSocket]
           cmp    [SPDSocket],54h ;Scaning 4 -Banks
           jnz    short GetingNextBankInfo

;     mov    si, offset RIMMSPDDump

;     mov    si, offset DDRSPDDump
;     sub    di,di
;     mov    cx,128
;     rep movsb
;     mov    si, offset DDRSPDDump
;     mov    cx,128
;     rep movsb
;     mov    si, offset DDRSPDDump
;     mov    cx,128
;     rep movsb
;     mov    [NumberDIMMModules],3
           ret
ENDP GetSPDData

PROC GetSPDMemType
          push    es
          mov     ax,0FFFFh
          push    [SPDDataSeg]
          pop     es
          sub     di,di
          mov     cx,1024
          cld
          rep stosw
          pop     es
          call    GetSPDInfo
          jc      short DIMMNotFoundExit
          call    CheckMemModulesInfo
          sub     di,di
          mov     cx,8
NextFaindFullMemBank:
          cmp     [word es:di],0FFFFh
          jz      short FullMemBankOkNotFound
          call    GetMemTypeFromSPD
          and     ebx,0FFF3FC00h ;Save only mem type
          or      [SPDAllMemType],ebx
FullMemBankOkNotFound:
          add     di,80h
          loop    short NextFaindFullMemBank
DIMMNotFoundExit:
          push    ds
          pop     es
          ret
ENDP GetSPDMemType

PROC CheckMemModulesInfo
          push    di
          sub     di,di
          mov     cx,8

NextMemModulesCheck:
          cmp     [byte es:di],80h
          jz      short FaundDIMMMemModules
          add     di,80h
          loop    short NextMemModulesCheck

          sub     di,di
          mov     cx,8
NextRIMMMemRowCheck:
          cmp     [word es:di],0FFFFh
          jz      short NotPresentRIMMMemModules
          cmp     [byte es:di],01h
          jz      short FaundRIMM
          cmp     [byte es:di],02h
          jz      short FaundRIMM
          cmp     [byte es:di],03h
          jnz     short MemRIMMRowCheckError
FaundRIMM:

          cmp     [byte es:di+51],90h
          jz      short FoundRIMMCheckPass
          cmp     [byte es:di+51],2Ch
          jz      short FoundRIMMCheckPass


          call    GetSPDCheckSum
          jc      short MemRIMMRowCheckError
FoundRIMMCheckPass:
          inc     [NumberRIMMModules]
          jmp     short MemRIMMRowCheckOK

MemRIMMRowCheckError:
          mov     [word es:di],0FFFFh
          mov     al,[NumberDIMMModules]
          or      al,al
          jz      short NotPresentRIMMMemModules
          dec     [NumberDIMMModules]
NotPresentRIMMMemModules:
MemRIMMRowCheckOK:
          add     di,80h
          loop    short NextRIMMMemRowCheck

          jmp     short ExitFromCheckMemModules

FaundDIMMMemModules:
          sub     di,di
          mov     cx,8
NextDIMMMemRowCheck:

          cmp     [word es:di],0FFFFh
          jz      short NotPresentMemModules
          call    GetSPDCheckSum
          jnc     short MemRowCheckOK
          call    CalkMemModuleSize
          cmp     ax,8               ; Memory module size > 8MB
          jb      short MemRowCheckError
          cmp     ax,2048            ; Memory module size < 2GB
          ja      short MemRowCheckError
          mov     al,[byte es:di+2]   ;Memory Type

          cmp     al,1   ;FPM
          jz      short MemRowCheckOK
          cmp     al,2   ;EDO
          jz      short MemRowCheckOK
          cmp     al,4   ;SDRAM
          jz      short MemRowCheckOK
          cmp     al,6   ;DDR SGRAM
          jz      short MemRowCheckOK
          cmp     al,7   ;DDR SDRAM
          jz      short MemRowCheckOK

MemRowCheckError:
          mov     [word es:di],0FFFFh
          mov     al,[NumberDIMMModules]
          or      al,al
          jz      short NotPresentMemModules
          dec     [NumberDIMMModules]
          jmp     short NextMemModuleCheck
NotPresentMemModules:
MemRowCheckOK:
          cmp     [byte es:di+2],6   ;Memory Type
          jnz     short NotDDRSGRAM
          inc     [NumberDDRModules]
NotDDRSGRAM:
          cmp     [byte es:di+2],7   ;Memory Type
          jnz     short NotDDRSDRAM
          inc     [NumberDDRModules]
NotDDRSDRAM:
NextMemModuleCheck:
          add     di,80h
          loop    short NextDIMMMemRowCheck
ExitFromCheckMemModules:
          pop    di
          ret
ENDP CheckMemModulesInfo

PROC GetMemTypeFromSPD
          xor     ebx,ebx
          mov     [SPDMemInfo],ebx

          cmp     [NumberRIMMModules],0
          jz      short NotRIMMmemoryModules
          mov     al,[byte es:di+2]      ;Memory Type
          cmp     al,1
          jnz     short NotDRDRAM
          or      ebx,800h
NotDRDRAM:
          mov     al,[byte es:di+3]      ;Module Type
          cmp     al,1
          jnz     short NotRIMM
          or      ebx,100000b
NotRIMM:
          cmp     al,2
          jnz     short NotSORIMM
          or      ebx,1000000b
NotSORIMM:
          cmp     al,3
          jnz     short NotEmbedded
          or      ebx,10000000b
NotEmbedded:
          mov     al,[byte es:di+100]      ;Module Data Width
          cmp     al,12h
          jnz     short Not18bits
          or      ebx,80000h    ;ECC
Not18bits:
          mov     al,[byte es:di+51]      ;Fras
          cmp     al,90h
          jnz     short Not800Mhz
          or      ebx,40000000h
Not800Mhz:
          cmp     al,64h
          jnz     short Not700Mhz
          or      ebx,20000000h
Not700Mhz:
          cmp     al,2Ch
          jnz     short Not600Mhz
          or      ebx,10000000h
Not600Mhz:
          jmp     SaveMemModulesType

NotRIMMmemoryModules:
          cmp     [word es:di],0880h
          jnz     short NotDIMMmemoryModules
          or      ebx,10h       ; DIMM
NotDIMMmemoryModules:
          mov     al,[byte es:di+2]      ;Memory Type
          cmp     al,2
          jnz     short NotEDODIMM
          or      ebx,200h      ;EDO
          jmp     short GoToGetSPDMemIspec
NotEDODIMM:
          cmp     al,4
          jnz     short NotSDRAMDIMM
          or      ebx,400h      ;SDRAM
          jmp     short GoToGetSPDMemIspec
NotSDRAMDIMM:

          cmp     al,3
          jnz     short NotPN     ;Pipelined Nibble
          or      ebx,1000h
          jmp     short GoToGetSPDMemIspec
NotPN:
          cmp     al,5
          jnz     short NotROM    ;ROM
          or      ebx,2000h
          jmp     short GoToGetSPDMemIspec
NotROM:
          cmp     al,6
          jnz     short NotSGDDR  ;DDR SGRAM
          or      ebx,4000h
          jmp     short GoToGetSPDMemIspec
NotSGDDR:
          cmp     al,7            ;DDR SDRAM
          jnz     short NotSDDDR
          or      ebx,8000h
          jmp     short GoToGetSPDMemIspec
NotSDDDR:
          cmp     al,8            ;VCSDRAM
          jnz     short NotVCSDRAM
          or      ebx,10000h
          jmp     short GoToGetSPDMemIspec
NotVCSDRAM:
          or      ebx,100h      ;Unknown
GoToGetSPDMemIspec:
          cmp     [NumberDDRModules],0
          jz      short NotDDRMemoryModules
          cmp     [byte es:di+9],50h     ;5.0ns
          ja      short NotPC400DDR
          or      ebx,800000h
          jmp     short SkipDetectionIspec
NotPC400DDR:
          cmp     [byte es:di+9],60h     ;6.0ns
          ja      short NotPC333DDR
          or      ebx,400000h
          jmp     short SkipDetectionIspec
NotPC333DDR:
          cmp     [byte es:di+9],75h     ;8.0ns
          ja      short NotPC266DDR
          or      ebx,200000h
          jmp     short SkipDetectionIspec
NotPC266DDR:
          or      ebx,100000h
          jmp     short SkipDetectionIspec

NotDDRMemoryModules:

          mov     al,[byte es:di+9]
          cmp     al,75h
          ja      short GoToGetISpec
          mov     al,[byte es:di+10]
          cmp     al,54h
          ja      short GoToGetISpec
          or      ebx,4000000h  ;PC133
          jmp     short SkipDetectionIspec

GoToGetISpec:
          mov     al,[byte es:di+126]     ;Memory I-spec
          cmp     al,66h
          jnz     short NotPC66DIMM
          or      ebx,1000000h  ;PC66
NotPC66DIMM:
          cmp     al,64h
          jnz     short NotPC100DIMM
          or      ebx,2000000h  ;PC100
NotPC100DIMM:
          cmp     al,85h
          jnz     short NotPC133DIMM
          or      ebx,4000000h  ;PC133
NotPC133DIMM:
SkipDetectionIspec:

          mov     al,[byte es:di+11];Module Configuration Type
          cmp     al,1
          jnz     short NotECDIMM
          or      ebx,40000h    ;EC (Parity)
NotECDIMM:
          cmp     al,2
          jnz     short NotECCDIMM
          or      ebx,80000h    ;ECC
NotECCDIMM:

SaveMemModulesType:
          mov     [SPDMemInfo],ebx
          ret
ENDP GetMemTypeFromSPD

PROC CalkMemModuleSize
          push    cx
          push    ebx

          cmp     [NumberRIMMModules],0
          jz      short NoRIMMMemModules
          sub     ah,ah
          mov     al,[byte es:di+99]
          shl     ax,4
          jmp     short SaveRIMMMemModulesSize

NoRIMMMemModules:
          mov     cl,[byte es:di+3]
          add     cl,[byte es:di+4]
          mov     eax,1
          shl     eax,cl
          movzx   ebx,[byte es:di+5]
          mul     ebx
          movzx   ebx,[byte es:di+17]
          mul     ebx
          shr     eax,17

SaveRIMMMemModulesSize:
          mov     [MemModuleSize],ax
          pop     ebx
          pop     cx
          ret
ENDP CalkMemModuleSize

PROC GetSPDCheckSum
          push    ax
          push    cx
          push    di
          mov     cx,63
          sub     al,al
NextSPDByteForCheckSum:
          add     al,[byte es:di]
          inc     di
          loop    short NextSPDByteForCheckSum
          sub     al,[byte es:di]
          pop     di
          pop     cx
          pop     ax
          jnz     short SPDCheckSumErr
          mov     [SPDCheckSum],0
          clc
          ret
SPDCheckSumErr:
          mov     [SPDCheckSum],1
          stc
          ret
ENDP GetSPDCheckSum

PROC GetISAPnPInfoFromPnPBIOS
          push    es
          mov     ax,[BiosSelector]
          push    ax
          mov     ax,[EndProgram]
          push    ax
          push    0
          push    40h ;GET_ISA_CONFIG_STRUC
          call    [PnpCall]
          add     sp,8
          or      ax,ax
          jnz     short GetISAConfigStrucNotSupport
          mov     ax,[EndProgram]  ; Сегмент конца программы в памяти
          mov     es,ax
          sub     di,di
          cmp     [byte es:di],1
          jnz     short GetISAConfigStrucNotSupport
          mov     al,[byte es:di+1]
          cmp     al,0FFh
          jnz     short Not0FFhCSN
          inc     al
Not0FFhCSN:
          cmp     al,16
          ja      short GetISAConfigStrucNotSupport
          mov     [CSNFromISAConfigStruc],al
          mov     ax,[word es:di+2]
          shr     ax,2
          mov     [pnprdr],al
          mov     [ISAConfigStrucSupport],1
GetISAConfigStrucNotSupport:
          pop     es
          ret
ENDP GetISAPnPInfoFromPnPBIOS

PROC GetMemMap
          push    ecx
          push    es
          mov     ax,[EndProgram]
          mov     es,ax
          mov     eax,0E820h
          mov     edx,'SMAP'
          mov     ecx,20
          sub     di,di
          int     15h
          jc      short NotSupportMemMap
          cmp     eax,'SMAP'
          jnz     short NotSupportMemMap
          cmp     ecx,20
          jnz     short NotSupportMemMap
          mov     di,4
          sub     eax,eax
          cmp     [es:di],eax
          jnz     short NotSupportMemMap
          cmp     [es:di+8h],eax
          jnz     short NotSupportMemMap
          clc
          mov     eax,[es:di-4]
          mov     [AdrFromMemMap],eax
          mov     eax,[es:di+4]
          mov     [SizeFromMemMap],eax
          mov     edx,[es:di+0Ch]
          mov     [TypeFromMemMap],edx
          jmp     short OkMemMap
NotSupportMemMap:
          stc
          mov     [ErrorInMemMap],1
OkMemMap:
          pop     es
          pop     ecx
          ret
ENDP GetMemMap

PROC PrintMemMap
          call    ClearDownScreen
          cmp     [ErrorInMemMap],1
          jz      NotSupportMemMapDetectForPrn
          mov     bx,8*36-1+4
          mov     dx,8*5-8
          mov     al,8
          mul     [NumMemMapBlocks]
          add     dx,ax
          mov     ax,8
          mov     cx,6*34
          mov     bp,3+8
          call    ColorFrame
          mov     si,offset MesNewMemMap
          call    ColorStr6x8
          sub     ebx,ebx
GetNextMemMapForPrn:
          call    GetMemMap
          jc      short NotSupportMemMapDetectForPrn
          push    ebx
          mov     eax,[AdrFromMemMap]
          mov     di,offset NumAdrMemMap+4
          mov     cx,4
          call    BinToAscHex
          shr     eax,16
          mov     di,offset NumAdrMemMap
          call    BinToAscHex
          call    NZInMes
          mov     eax,[SizeFromMemMap]
          shr     eax,10
          mov     di,offset NumSizeMemMap
          mov     cx,7
          call    BinToAscDecH
          call    NZInMes

          mov     si,offset MesMemMap
          call    ColorStr6x8
          mov     eax,[TypeFromMemMap]
          mov     si,offset MesAvailableToOS
          cmp     al,1
          jz      short PrnMemType
          mov     si,offset MesReserved
          cmp     al,2
          jz      short PrnMemType
          mov     si,offset MesACPIReclaim
          cmp     al,3
          jz      short PrnMemType
          mov     si,offset MesACPINVS
          cmp     al,4
          jnz     short NotPrnMemType
PrnMemType:
          call    ColorStr6x8
NotPrnMemType:
          pop     ebx
          or      ebx,ebx
          jnz     short GetNextMemMapForPrn
          jmp     short GoDetectSPDInfo
NotSupportMemMapDetectForPrn:
          call    ClearDownScreen
GoDetectSPDInfo:

          cmp     [NumberDIMMModules],0
          jnz     short DIMMmodulesPresent
          mov     [CacheBenchLabel],1
          jmp     short GoToDetectInfoMem
DIMMmodulesPresent:
          cmp     [ErrConfig],1
          jnz     short GoToDetectInfoMem
          mov     [CacheBenchLabel],0

GoToDetectInfoMem:

          cmp     [CacheBenchLabel],0
          jz      CanNotDetectMemAndCacheBench

          cmp     [ErrConfig],1
          jz      ExitMemBenchNotPresent
          mov     [CacheBenchLabel],0

          mov     al,[AllCache]
          sub     ah,ah
          mov     bx,291
          mov     cx,8
          mul     cx
          mov     dx,24+16
          add     dx,ax
          mov     ax,218
          mov     cx,6*64+6*4
          mov     bp,3+8
          call    ColorFrame

          mov     si,offset MesCacheMemBench
          call    ColorStr6x8

          mov     si,offset ResultsNew
          mov     di,offset ResCacheSpeedRepl

          call    TableMemBench

          mov     si,offset MesMemBench
          call    ColorStr6x8
          call    MemBench
          mov     si,offset NumCacheMemBench
          call    ColorStr6x8

          cmp     [FeatureFlagMMX],1
          jnz     short NotMMXCPUForCacheTable

          mov     [CacheBenchLabel],0

          mov     al,[AllCache]
          sub     ah,ah
          mov     bx,387
          mov     cx,8
          mul     cx
          mov     dx,40
          add     dx,ax
          mov     ax,218
          mov     cx,408
          mov     bp,3+8
          call    ColorFrame

          mov     si,offset MesMMXCacheMemBench
          call    ColorStr6x8

          mov     si,offset ResultsNew
          mov     di,offset ResCacheSpeedMovsq
          call    TableMemBench

          mov     si,offset MesMemBench
          call    ColorStr6x8
          call    MemBench
          mov     si,offset NumCacheMemBench
          call    ColorStr6x8

NotMMXCPUForCacheTable:
          jmp     ExitMemBenchNotPresent

CanNotDetectMemAndCachebench:

          mov     al,[NumberDIMMModules]
          or      al,al
          jz      NotSPDDIMMmodulesPresent
          mov     [CacheBenchLabel],1

          mov     ax,[SPDDataSeg]
          mov     es,ax
          mov     al,[NumberDIMMModules]
          sub     ah,ah
          mov     bx,291
          mov     dx,24
          mul     dl
          add     dx,ax
          mov     ax,218
          mov     cx,6*69
          mov     bp,3+8
          call    ColorFrame
          mov     si,offset MesMemInfo
          call    ColorStr6x8

          sub     di,di
          mov     cx,8
          mov     [NumMemSocket],'0'

NextMemSocket:
          push    cx
          push    di
          push    es
          cmp     [word es:di],0FFFFh
          jz      NotFaundFullMemSocket
          call    GetSPDCheckSum
          call    GetMemTypeFromSPD
          call    CalkMemModuleSize


          cmp     [NumberRIMMModules],0
          jz      short GoToGetDIMMMemModulesParam
          call    GetRDRAMInfo
          mov     eax,[dword es:di+64] ;JEDEC ID
          mov     [JEDECID],eax
          mov     eax,[dword es:di+64+4] ;JEDEC ID
          mov     [JEDECID2],eax
          mov     al,[byte es:di+10]
          mov     [MinPrToRASTime],al
          mov     al,[byte es:di+35]
          and     ax,11110000b
          shl     ax,4
          mov     al,[byte es:di+36]
          mov     [RDRAMFmin],ax
          mov     al,[byte es:di+35]
          and     ax,1111b
          shl     ax,8
          mov     al,[byte es:di+37]
          mov     [RDRAMFmax],ax

          ;Определение параметров RIMM модуля
          jmp     short GetNumManufPartNum
GoToGetDIMMMemModulesParam:

          call    GetSDRAMInfo

GetNumManufPartNum:
          add     di,73
          mov     si,offset NumManufPartNum
          push    es
          push    ds
          pop     es
          pop     ds
          xchg    si,di
          cld
          mov     cx,17
          rep movsb
          push    es
          pop     ds

          mov     si,offset MesMemSocket
          call    ColorStr6x8
          mov     bx,offset NumAdrSPDMemBuf
          mov     cx,32
          mov     eax,[SPDMemInfo]
          and     eax,0FFFFFFEFh
NextBitMemTypeForMemInfo:
          shr     eax,1
          jnc     short MemTypeBitNotSetForMemInfo
          mov     si,[word ds:bx]
          call    ColorStr6x8
MemTypeBitNotSetForMemInfo:
          add     bx,2
          loop    short NextBitMemTypeForMemInfo

          cmp     [NumberRIMMModules],0
          jz      short GoToGetSDRAMCycleTime
           ;Оределени скорости работы RIMM модуля

          jmp     short SkippDetectSDRAMCycleTime

GoToGetSDRAMCycleTime:
          call    GetSDRAMCycleTime
SkippDetectSDRAMCycleTime:

          mov     ax,[MemModuleSize]
          mov     di,offset NumMemModSize
          mov     cx,5
          call    BinToAscDec
          mov     si,offset MesMemModSize
          call    ColorStr6x8
          mov     si,offset NumMemModSize
          call    NonZeroPrn
          call    ColorStr6x8
          cmp     [SPDCheckSum],1
          jnz     short SPDCheckSumOkGoToDetectManufInfo
          mov     si,offset MesSPDCheckSumErr
          call    ColorStr6x8
          jmp     SPDCheckSumErrSkipManufInfo

SPDCheckSumOkGoToDetectManufInfo:

          call    GetManufacturerName
          jc      short ManufacturerNameNotDetect
          call    ColorStr6x8
          jmp     short GoPrnManufPartNum
ManufacturerNameNotDetect:
          cmp     cl,1
          jz      short UnknownMemManuf
          call    ColorStr6x8
          jmp     short GoPrnManufPartNum
UnknownMemManuf:
          call    ColorStr6x8
          sub     ah,ah
          mov     al,bl
          mov     cx,2
          mov     di,offset NumJEDECID
          call    BinToAscHex
          mov     si,offset NumJEDECID
          call    ColorStr6x8
GoPrnManufPartNum:
          call    CheckManufPartNum
          jnz     short ManufPartNumPresent
          mov     [byte ds:si-17],196
ManufPartNumPresent:

          mov     si,offset MesManufPartNum
          call    ColorStr6x8

SPDCheckSumErrSkipManufInfo:

          cmp     [NumberDDRModules],0
          jnz     GetDDRFutures
          cmp     [NumberRIMMModules],0
          jz      short GetSDRAMCASlat

;Оределени дополнительных параметров RIMM модуля
          sub     ah,ah
          mov     al,[MinPrToRASTime]
          mov     cx,2
          mov     di,offset NumMinPrToRASTime
          call    BinToAscDec
          call    NzInMes
          mov     si,offset MesMinPrToRASTime
          call    ColorStr6x8
          mov     ax,[RDRAMFmin]
          mov     cx,4
          mov     di,offset NumFMin
          call    BinToAscDec
          call    NzInMes
          mov     ax,[RDRAMFmax]
          mov     di,offset NumFMax
          call    BinToAscDec
          call    NzInMes
          mov     si,offset MesFMinMax
          call    ColorStr6x8
          jmp     SkippSDRAMCASlat

GetSDRAMCASlat:
          mov     si,offset MesSupCASlat
          call    ColorStr6x8
          mov     ax,1
          mov     bl,[SupCASlat]
NextBitCASlat:
          shr     bl,1
          jnc     short ThisCASlatNotPresent
          push    ax
          mov     di,offset NumSupCASlat
          mov     cx,1
          call    BinToAscDec
          mov     si,offset NumSupCASlat
          call    PrnMesCASLat
          pop     ax
ThisCASlatNotPresent:
          inc     ax
          cmp     al,8
          jnz     short NextBitCASlat

          mov     al,[TRAS]
          mov     di,offset NumTRAS
          call    BinToAscDec
          call    NzInMes
          mov     si,offset MesTRAS
          mov     [byte ds:si+1],52
          call    ColorStr6x8
          mov     si,offset MesNSonly
          call    ColorStr6x8

          mov     si,offset MesSDRAMLabel
          call    ColorStr6x8

          mov     di,offset MesPCxxx+2
          call    GetMHzFromCycleTime
          call    CorrectSPDSpeedToStd
          mov     cx,3
          call    BinToAscDec
          mov     si,offset MesPCxxx

          call    ColorStr6x8
          mov     si,offset MesUnbuffered+1
          mov     ebx,[SPDMemInfo]
          test    ebx,04000000h ;PC133
          jz      short SkippDetectionBufferedSDRAM
          test    [SDRAMModAttrib],01b
          jnz     short SkippDetectionBufferedSDRAM

          dec     si
SkippDetectionBufferedSDRAM:

          call    ColorStr6x8

          call    GetCASForLabel
          call    ColorStr6x8

          mov     al,[SDRAMAccess]
          sub     ah,ah
          or      al,al
          jz      short SDRAMAcesseNotPresentForLabel
          push    ax
          shr     al,4
          mov     cx,1
          mov     di,offset NumTacAndSPDRev
          call    BinToAscDec
          pop     ax
          and     al,01111b
          mov     cx,1
          mov     di,offset NumTacAndSPDRev+1
          call    BinToAscDec
          mov     al,[SPDRevision]
          test    al,11110000b
          jz      short NotIntelSPDRevSpec
          shr     al,4
NotIntelSPDRevSpec:
          mov     di,offset NumTacAndSPDRev+2
          call    BinToAscDec
SDRAMAcesseNotPresentForLabel:
          mov     si,offset NumTacAndSPDRev
          call    ColorStr6x8


          jmp     SkippDDRmem

GetDDRFutures:
          mov     si,offset MesSupCASlat
          call    ColorStr6x8
          mov     bl,[SupCASlat]
          shr     bl,1
          jnc     short CASlat1NotSup
          mov     si,offset MesCASLat1
          call    PrnMesCASLat
CASlat1NotSup:
          shr     bl,1
          jnc     short CASlat15NotSup
          mov     si,offset MesCASLat15
          call    PrnMesCASLat
CASlat15NotSup:
          shr     bl,1
          jnc     short CASlat2NotSup
          mov     si,offset MesCASLat2
          call    PrnMesCASLat
CASlat2NotSup:
          shr     bl,1
          jnc     short CASlat25NotSup
          mov     si,offset MesCASLat25
          call    PrnMesCASLat
CASlat25NotSup:
          shr     bl,1
          jnc     short CASlat3NotSup
          mov     si,offset MesCASLat3
          call    PrnMesCASLat
CASlat3NotSup:
          shr     bl,1
          jnc     short CASlat35NotSup
          mov     si,offset MesCASLat35
          call    PrnMesCASLat
CASlat35NotSup:

          mov     si,offset MesSDRAMLabel
          call    ColorStr6x8

          call    GetDDRLabel

          mov     si,offset MesPCxxxx
          call    ColorStr6x8
          mov     si,offset MesUnbuffered
          call    ColorStr6x8
          mov     si,offset MesXxxxx
          call    ColorStr6x8

SkippDDRmem:

          mov     si,offset MesSpace
          call    ColorStr6x8

          mov     ax,[ModDataWidth]     ;b6-7
          mul     [NumPhysicBanks]
          sub     bh,bh
          mov     bl,[SDRAMDeviceWidth] ;b13
          sub     dx,dx
          div     bx

          mov     di,offset NumRepNumberChips
          mov     cx,3
          call    BinToAscDec
          mov     si,offset NumRepNumberChips
          call    NonZeroPrn
          call    ColorStr6x8

          mov     cl,[NumRowAddrBits]
          add     cl,[NumColumnAddrBits]
          mov     eax,1
          shl     eax,cl
          movzx   ebx,[NumLogicBanks] ;b17
          mul     ebx
          shr     eax,20

          mov     di,offset NumRepSDRAMBanks
          mov     cx,3
          call    BinToAscDec
          mov     si,offset NumRepSDRAMBanks
          call    NonZeroPrn
          call    ColorStr6x8
          sub     ah,ah
          mov     al,[SDRAMDeviceWidth]
          mov     di,offset NumRepSDRAMWidth
          call    BinToAscDec
          mov     si,offset NumRepSDRAMWidth
          call    NonZeroPrn
          call    ColorStr6x8
          mov     cl,[NumRowAddrBits]
          add     cl,[NumColumnAddrBits]
          mov     eax,1
          shl     eax,cl
          movzx   ebx,[NumLogicBanks] ;b17
          mul     ebx
          shr     eax,20
          sub     bh,bh
          mov     bl,[SDRAMDeviceWidth] ;b13
          mul     bx
          mov     di,offset NumRepChipMbit
          mov     cx,4
          call    BinToAscDec
          mov     si,offset NumRepChipMbit
          call    NonZeroPrn
          call    ColorStr6x8

SkippSDRAMCASlat:
NotFaundFullMemSocket:
          pop     es
          pop     di
          pop     cx
          inc     [NumMemSocket]
          add     di,80h
          loop    NextMemSocket
          push    ds
          pop     es
NotSPDDIMMmodulesPresent:
ExitMemBenchNotPresent:
          ret
ENDP PrintMemMap

PROC PrnMesCASLat
          call    ColorStr6x8
          or      bl,bl
          jz      short NotPrnZpt
          mov     si,offset PrnZpt
          call    ColorStr6x8
NotPrnZpt:
          ret
ENDP PrnMesCASLat

PROC GetManufacturerName
          mov     ebx,[JEDECID]
          mov     di, offset MemManufacturerList
          mov     cx,4
NextMemVendorIDBlock14:
          mov     si,offset MesMinus
          or      bl,bl
          jz      short GoPrnMesMinus
          cmp     bl,0FFh
          jz      short GoPrnMesMinus
          mov     si,[word ds:di]
          cmp     bl,7Fh
          jnz     short GoToFaindMemManuf
          add     di,2
          shr     ebx,8
          loop    short NextMemVendorIDBlock14

          mov     ebx,[JEDECID2]
          mov     cl,4
NextMemVendorIDBlock58:
          mov     si,offset MesMinus
          or      bl,bl
          jz      short GoPrnMesMinus
          cmp     bl,0FFh
          jz      short GoPrnMesMinus
          mov     si,[word ds:di]
          cmp     bl,7Fh
          jnz     short GoToFaindMemManuf
          add     di,2
          shr     ebx,8
          loop    short NextMemVendorIDBlock58

GoToFaindMemManuf:
          cld
NextManufForCheck:
          lodsb
          cmp     al,bl
          jz      short FaundMemManuf
          cmp     al,0FFh
          jz      short FaundEndMemManuf
NonEndStrInMemManuf:
          lodsb
          or     al,al
          jnz    short NonEndStrInMemManuf
          jmp    short NextManufForCheck

FaundMemManuf:
          clc
          ret
FaundEndMemManuf:
          mov    cl,1
          stc
          ret
GoPrnMesMinus:
          sub    cl,cl
          stc
          ret
ENDP GetManufacturerName

PROC CheckManufPartNum
          mov     si,offset NumManufPartNum
          mov     cx,17
          mov     bl,cl
NextCheckManufPartNum:
          lodsb
          cmp     al,32
          jbe     short DetectUprSimvolInManufPartNum
          cmp     al,128
          jb      short SimvolInManufPartNumOk
DetectUprSimvolInManufPartNum:
          mov     [byte ds:si-1],32
          dec     bl
SimvolInManufPartNumOk:
          loop    short NextCheckManufPartNum
          or      bl,bl
          ret
ENDP CheckManufPartNum

PROC GetRDRAMInfo
          mov     al,[byte es:di+10]
          mov     [MinPrToRASTime],al
          mov     al,[byte es:di+35]
          and     ax,11110000b
          shl     ax,4
          mov     al,[byte es:di+36]
          mov     [RDRAMFmin],ax
          mov     al,[byte es:di+35]
          and     ax,1111b
          shl     ax,8
          mov     al,[byte es:di+37]
          mov     [RDRAMFmax],ax
          mov     eax,[dword es:di+95] ;Serial Number
          mov     [ModuleSN],eax
          mov     eax,[dword es:di+64] ;JEDEC ID
          mov     [JEDECID],eax
          mov     eax,[dword es:di+64+4] ;JEDEC ID
          mov     [JEDECID2],eax
          ret
ENDP GetRDRAMInfo

PROC GetSDRAMInfo
          mov     al,[byte es:di+9]
          mov     [SDRAMCycleTime],al;SDRAM Cycle time (Tcyc)
          mov     al,[byte es:di+18] ;CAS# Latencies Supported
          mov     [SupCASlat],al
          mov     al,[byte es:di+10] ;SDRAM Access time (Tac)
          mov     [SDRAMAccess],al
          mov     al,[byte es:di+27] ;Min Row Precharge Time (Trp)
          mov     [MinRowPRecTime],al
          mov     al,[byte es:di+29] ;Minimum RAS to CAS del (Trcd)
          mov     [TRCD],al
          mov     al,[byte es:di+30] ;Minimum RAS Pulse Width (Tras)
          mov     [TRAS],al
          mov     al,[byte es:di+62] ;SPDRevision
          mov     [SPDRevision],al
          mov     al,[byte es:di+21] ;SDRAM Module Attributes
          mov     [SDRAMModAttrib],al
          mov     al,[byte es:di+23]; 2nd Tcyc
          mov     [SDRAMCycleTime2nd],al
          mov     al,[byte es:di+25]; 3nd Tcyc
          mov     [SDRAMCycleTime3nd],al
          mov     eax,[dword es:di+95] ;Serial Number
          mov     [ModuleSN],eax
          mov     eax,[dword es:di+64] ;JEDEC ID
          mov     [JEDECID],eax
          mov     eax,[dword es:di+64+4] ;JEDEC ID2
          mov     [JEDECID2],eax
          mov     al,[byte es:di+3] ; Number of Row Address Bits
          mov     [NumRowAddrBits],al
          mov     al,[byte es:di+4] ; Number of Column Address Bits
          mov     [NumColumnAddrBits],al
          mov     al,[byte es:di+5] ; Number of Physical Banks
          mov     [NumPhysicBanks],al
          mov     ax,[word es:di+6] ; Module Data Width
          mov     [ModDataWidth],ax
          mov     al,[byte es:di+13] ; SDRAM Device Width
          mov     [SDRAMDeviceWidth],al
          mov     al,[byte es:di+17] ; Number of Logical Banks
          mov     [NumLogicBanks],al
          ret
ENDP GetSDRAMInfo

PROC TableMemBench
          mov     [AllCache],0
          sub     cl,cl
NextByteCacheSpeedBenchPrn:
          lodsb
          or      al,al
          jz      short NextCacheForSpeedBench
          inc     [AllCache]
          cmp     [AllCache],4
          jz      short CacheForSpeedBenchNotFound
          push    si
          push    di
          push    cx
          mov     al,[AllCache]
          add     al,48
          mov     [NumberCacheBench],al
          mov     si,offset MesCacheLevel
          call    ColorStr6x8

          call    MemBench

          mov     si,offset NumCacheMemBench
          call    ColorStr6x8

          pop     cx
          pop     di
          pop     si
NextCacheForSpeedBench:
          add     di,4
          inc     cl
          mov     al,[byte cs:MemSizePriznak]
          add     al,10
          cmp     cl,al
          jnz     NextByteCacheSpeedBenchPrn
CacheForSpeedBenchNotFound:
          ret
ENDP TableMemBench

PROC GetSDRAMCycleTime
          sub     ah,ah
          mov     al,[SDRAMCycleTime]
          or      al,al
          jz      short SDRAMCycleTimeNotPresent
          push    ax
          shr     al,4
          mov     cx,2
          mov     di,offset NumSDRAMCThigh
          call    BinToAscDec
          call    NzInMes
          pop     ax
          and     al,01111b
          mov     cx,1
          mov     di,offset NumSDRAMCTLow
          call    BinToAscDec
          mov     si,offset MesSDRAMCT
          call    ColorStr6x8
          mov     si,offset NumSDRAMCTHigh
          call    NonZeroPrn
          call    ColorStr6x8
SDRAMCycleTimeNotPresent:
          ret
ENDP GetSDRAMCycleTime

PROC MemBench
          mov     si,di
          mov     eax,[dword ds:si]
          call    CalcResMem
          mov     di,offset NumReplMemBench
          call    BinToAscDec2
          mov     eax,[dword ds:si+13*4]
          call    CalcResMem
          mov     di,offset NumReadMemBench
          call    BinToAscDec2
          mov     eax,[dword ds:si+13*2*4]
          call    CalcResMem
          mov     di,offset NumWriteMemBench
          call    BinToAscDec2
          call    GetAverageMemBench
          mov     di,offset NumAverageMemBench
          call    BinToAscDec2
          ret
ENDP MemBench

PROC MemBenchRep
          mov     si,di
          mov     eax,[dword ds:si]
          call    CalcResMem
          mov     di,offset NumRepReplMemBench
          call    BinToAscDec2
          mov     eax,[dword ds:si+13*4]
          call    CalcResMem
          mov     di,offset NumRepReadMemBench
          call    BinToAscDec2
          mov     eax,[dword ds:si+13*2*4]
          call    CalcResMem
          mov     di,offset NumRepWriteMemBench
          call    BinToAscDec2
          call    GetAverageMemBench
          mov     di,offset NumRepAverageMemBench
          call    BinToAscDec2
          ret
ENDP MemBenchRep

PROC GetAverageMemBench
          mov     eax,[dword ds:si]
          add     eax,[dword ds:si+13*4]
          add     eax,[dword ds:si+13*2*4]
          jmp     short AbsentMMXTransferRes
PROC GetAverageMemBenchForGraphs
          mov     eax,[dword ds:si]
          add     eax,[dword ds:si+13*4]
          add     eax,[dword ds:si+13*2*4]
          cmp     [FeatureFlagMMX],1
          jnz     short AbsentMMXTransferRes
          mov     ebx,[dword ds:si+13*4*3]
          add     ebx,[dword ds:si+13*4*4]
          add     ebx,[dword ds:si+13*4*5]
          cmp     eax,ebx
          ja      short AbsentMMXTransferRes
          mov     eax,ebx
AbsentMMXTransferRes:
          mov     ebx,3
          xor     edx,edx
          div     ebx
          call    CalcResMem
          ret
ENDP GetAverageMemBenchForGraphs
ENDP GetAverageMemBench

PROC PCIList

          mov     [YPosPCIList],0
          cmp     [PCICounter],1
          jnz     short PciBiosNotInstalled
          call    ClearDownScreen

          call    GetPCIInfo

          cmp     [GetPCIInfoOK],1
          jnz     ISAPnPCardNotPresent

          cmp     [PCICounter],1
          jz      short PciBiosInstalledSkipClear
          call    ClearDownScreen
PciBiosInstalledSkipClear:

          mov     [PCIcorrection],36

          add     [YPosPCIList],5
PciBiosNotInstalled:
          mov     [NumISAPnPCard],'0'
          cmp     [YPosPCIList],0
          jnz     short NotClearDownScreen
          call    ClearDownScreen
NotClearDownScreen:
          mov     cl,[CurrCSN]
          sub     ch,ch
          or      cl,cl
          jz      ISAPnPCardNotPresent

          mov     al,[YPosPCIList]
          add     [PCIcorrection],al
          mov     si,offset MesISAPnP
          call    ColorStr6x8

          mov     di,offset AdrNameISAPnP
          sub     bp,bp
NextISACard:
          inc     [NumISAPnPCard]
          mov     si,offset MesISAPnPCard
          call    ColorStr6x8
          call    UnpackVendorIDISAPnP
          mov     si,offset VendorIDISAPnP
          call    ColorStr6x8

          mov     si,[word ds:di+bp]
          add     bp,2
          mov     ax,[word ds:di+bp]
          sub     ax,si
          cmp     ax,39+37
          jbe     short ANSIIDStringSizeOK
          mov     al,39+37
          mov     [dword ds:si+35+37],00001019h
ANSIIDStringSizeOK:
          cmp     [XPosISAPnP],al
          jae     short XPosISAPnPNoBig
          mov     [XPosISAPnP],al
XPosISAPnPNoBig:

          call    ColorStr6x8
          loop    short NextISACard
          mov     al,[XPosISAPnP]
          mov     bl,6
          mul     bl
          mov     cx,ax
          add     cx,27*6
          mov     al,[CurrCSN]
          mov     bx,8
          mul     bl
          mov     dx,ax
          add     dx,33
          push    bx
          mov     bx,291
          sub     ah,ah
          mov     al,[YPosPCIList]
          shl     ax,3
          add     bx,ax
          pop     ax
          mov     bp,3+8
          call    ColorFrame
          mov     si,offset MesISAPnP
          call    ColorStr6x8

          cmp     [YPosPCIList],0
          jz      short ISAPnPCardNotPresent
          sub     [YPosPCIList],5

ISAPnPCardNotPresent:
          ret
ENDP PCIList

PROC GetPCIInfo
          mov     ax,0B101h
          sub     edi,edi
          int     1Ah
          mov     al,bh
          mov     cx,1
          mov     di,offset  NumMajorPciVersion
          call    BinToAscHex
          call    NZInMes
          mov     al,bl
          mov     cx,2
          mov     di,offset  NumMinorPciVersion
          call    BinToAscHex

          cmp     [PCIRepInfoGeting],0
          jz      short SkipGetPCIInfo

          mov     si,offset MesPciInstalled
          call    ColorStr6x8

          mov     si,offset MesPCITitle1
          cmp     [GetPCIInfoOK],1
          jz      short GetingDitailedInfoInMes
          mov     si,offset MesPCITitle
GetingDitailedInfoInMes:
          call    ColorStr6x8

SkipGetPCIInfo:
          mov     [NumberPCIBus],0
          mov     [XPosPCIList],0
          mov     [YPosPCIList],0
          mov     [PCIDevRepOfs],0

NextPCIBusScan:
          mov     [NextBusScanOK],0
          sub     bx,bx

          ALIGN 2
NextPCIDeviceFunction:

          push    es
          pop     ds

          push    bx
          mov     [NumRepPCIDev],bh
          mov     [NumRepPCIFun],bl
          mov     [NumPCISeg],0
          mov     [NumPCIDevVendor],0
          mov     [NumPCIDevName],0

          mov     cx,4
          mov     di,offset NumNumberPCIBus
          sub     ah,ah
          mov     al,[NumberPCIBus]
          call    BinToAscDec
          call    NzInMes
          mov     di,offset NumNumberPCIDevice
          sub     ah,ah
          mov     al,bh
          call    BinToAscDec
          call    NzInMes
          mov     di,offset NumNumberPCIFunct
          sub     ah,ah
          mov     al,bl
          call    BinToAscDec
          call    NzInMes

          call    GetFullPCIConfig
          jc      ReadPCIerror
          mov     cx,[PCIVEN]
          jcxz    VendorNotFoundForDevice
          cmp     cx,0FFFFh
          jz      VendorNotFoundForDevice
          mov     [NextBusScanOK],1
          cld
          mov     [StringPos],0

          mov     si,offset PCIDevData1
          mov     [word cs:PCIDeviceList],si
          mov     ax,PCIDataSeg1
          mov     [word cs:PCIData],ax
          mov     ds,ax
          mov     [byte cs:PCIDeviceListChenged],0

; начало поиска производителя в ds:si
          ALIGN 2
PCIVendorNotFound:
          lodsb
          test     al,11111000b
          jnz      short PCIVendorNotFound
          call    AccessToPCIList2
          jz      UnknownPCIVendorID
          or      al,al
          jnz     short DeviceNameForVendor
          add     si,2
          jmp     short PCIVendorNotFound
DeviceNameForVendor:
          cmp     al,3
          jnz     short NotDevRev
          inc     si
          jmp     short PCIVendorNotFound
NotDevRev:
          cmp     al,4
          jnz     short NotSubSysRev
          add     si,4
          jmp     short PCIVendorNotFound
NotSubSysRev:

          lodsw
          cmp     ax,cx
          jnz     short PCIVendorNotFound
          call    GetStringLength
          mov     [word es:NumPCIDevVendor],si
          mov     ax,[word cs:PCIData]
          mov     [word es:NumPCISeg],ax
          mov     di,offset NumPCIVendor
          rep movsb
          mov     al,' '
          stosb
          push    es
          pop     ds

          mov     [StringPos],di
          mov     cx,[PCIDEV]

          cmp     cx,[OldPCIDevice]
          jz      PCIDeviceExists
          mov     [OldPCIDevice],cx

; начало поиска устройства в ds:si
          mov     ax,[word cs:PCIData]
          mov     ds,ax

          ALIGN 2
PCIDeviceNotFound:
          lodsb
          or       al,al
          jz       short FoundEndOfPCIDevStr
          call    AccessToPCIList2
          jz      short UnknownPCIVendorID
          cmp     al,2
          jz      UnknownPCIDeviceID
          cmp     al,3
          jnz     short NotSkipRev
          inc     si
          jmp     short PCIDeviceNotFound
NotSkipRev:
          cmp     al,4
          jnz     short NotSkipSubSys
          add     si,4
NotSkipSubSys:
          jmp     short PCIDeviceNotFound

FoundEndOfPCIDevStr:
          lodsw
          cmp     ax,cx
          jnz     short PCIDeviceNotFound
          lodsb
          cmp     al,3
          jnz     short NotRevInDataBase
          lodsb
          cmp     al,[byte es:PCIREV]
          jnz     short PCIDeviceNotFound
          lodsb

NotRevInDataBase:
          cmp     al,4
          jnz     short NotSubSysInDataBase
          lodsd
          cmp     eax,[dword es:PCISUBSYSVEN]
          jz      short PCIExtendedInfoFaundedSkipVendor
          jmp     short PCIDeviceNotFound

PCIExtendedInfoFaundedSkipVendor:
          mov     di,offset NumPCIVendor
          mov     [word es:StringPos],di
          mov     [word es:NumPCIDevVendor],0FFFFh
          jmp     short PCIExtendedInfoFaunded

NotSubSysInDataBase:
          dec     si
PCIExtendedInfoFaunded:
          call    CorrectNullStrDev
          call    GetStringLength
          mov     [word es:NumPCIDevName],si
          mov     di,[word es:StringPos]

          push    di

          rep movsb
          sub al,al
          stosb

          push    es
          pop     ds

          pop     si

          call     UnpackPCIString

          mov     di,si
          mov     cx,256
          sub al,al
          cld
          repnz scasb

          jmp     short CopyPCIDeviceString
UnknownPCIVendorID:
          push    es
          pop     ds

          mov     di,offset NumPCIDeviceID
          mov     ax,cx
          mov     cx,4
          call    BinToAscHex
          mov     si,offset NumPCIDeviceID
          mov     di,offset NumPCIVendor
          mov     cx,5
          rep movsb
          mov     al,' '
          stosb
          mov     [word es:StringPos],di
          mov     cx,[PCIDEV]
          cmp     cx,[OldPCIDevice]
          jz      PCIDeviceExists
          mov     [OldPCIDevice],cx
UnknownPCIDeviceID:
          push    es
          pop     ds
          mov     di,offset NumPCIDeviceID
          mov     ax,cx
          mov     cx,4
          call    BinToAscHex
          mov     si,offset NumPCIDeviceID
          mov     di,[StringPos]
          mov     cx,6
          rep movsb
CopyPCIDeviceString:

          cmp     [GetPCIInfoOK],1
          jz      short NotGetingDitailedInfoForXPos

          mov     ax,di
          mov     di,offset MesNumberPCIBus
          sub     ax,di
          cmp     al,[XPosPCIList]
          jbe     short StringNotLong
          cmp     al,107
          jbe     short StringNotLong1
          mov     al,107
StringNotLong1:
          mov     [XPosPCIList],al
StringNotLong:
          mov     [byte es:di+107],0
NotGetingDitailedInfoForXPos:

          mov     di,60 ;IRQ
          call    ReadPCIConfig
          mov     [dword ds:NumIRQPCIDevice],'A/N '
          or      cl,cl
          jz      short IRQNotUsed
          cmp     cl,0FFh
          jz      short IRQNotUsed
          mov     al,cl
          sub     ah,ah
          mov     cx,4
          mov     di,offset NumIRQPCIDevice
          call    BinToAscDec
          call    NzInMes
IRQNotUsed:
          cmp     [PCIRepInfoGeting],1
          jnz     short NoSkipGetPCIInfo1

          mov     si,offset MesNumberPCIBus
          call    ColorStr6x8
NoSkipGetPCIInfo1:
          mov     si,offset NumPCIVendor
          cmp     [GetPCIInfoOK],1
          jnz     NotGetingDitailedInfo
          mov     cx,4
          mov     ax,[PCIVEN]
          mov     di,offset NumPCIVen
          call    BinToAscHex
          mov     ax,[PCIDEV]
          mov     di,offset NumPCIDev
          call    BinToAscHex
          mov     al,[PCIREV]
          sub     ah,ah
          mov     cx,2
          mov     di,offset NumPCIRev
          call    BinToAscHex

          mov     cx,4
          mov     ax,[PCISUBSYSDEV]
          mov     di,offset NumPCISUBSYSVen
          call    BinToAscHex
          mov     ax,[PCISUBSYSVEN]
          mov     di,offset NumPCISUBSYSDev
          call    BinToAscHex
          cmp     [HeaderType],1
          jnz     short NotHeaderType1
          mov     [dword ds:NumPCISUBSYSVen],0C4202020h
          mov     [dword ds:NumPCISUBSYSDev],'    '
NotHeaderType1:
          mov     si,offset MesDitailedInfo

          call    ColorStr6x8

          mov      di,offset NumRepClassCode
          mov      cx,4
          mov      ax,[word ds:SubClass]
          call     BinToAscHex
          mov      di,offset NumRepClassCode+4
          mov      cx,2
          sub      ah,ah
          mov      al,[PIClass]
          call     BinToAscHex
          mov      si,offset NumRepClassCode
          call     ColorStr6x8

          call     GetClassCodeName
          call     GetStringLength
          add      cl,58
          cmp      cl,[XPosPCIList]
          jb       short NotGetingDitailedInfo
          mov      [XPosPCIList],cl

NotGetingDitailedInfo:

          cmp     [PCIRepInfoGeting],1
          jnz     short NoSkipGetPCIInfo2

          call    ColorStr6x8

NoSkipGetPCIInfo2:
GetingDitailedInfoOK:
          inc     [YPosPCIList]

          cmp      [PCIRepInfoGeting],1
          jz       short PCIDeviceExists
          mov      si,offset NumberPCIBus
          mov      di,[PCIDevRepOfs]
          push     [PCIDevRepSeg]
          pop      es
          mov      cx,PCIDevLength
          rep movsb
          mov      [PCIDevRepOfs],di
          push     ds
          pop      es
          inc      [NumPCIStr]

PCIDeviceExists:
VendorNotFoundForDevice:
ReadPCIerror:
          pop     bx
          inc     bl
          cmp     bl,7
          jnz     NextPCIDeviceFunction
          sub     bl,bl
          mov     [OldPCIDevice],0
          inc     bh
          cmp     bh,32
          jnz     NextPCIDeviceFunction

          mov     cl,[NumberPCIBus]
          inc     [NumberPCIBus]
          cmp     cl,[NumberLastPCIBus]
          jz      short EndPCIBusScan

          cmp     [NextBusScanOK],0
          jz      short NotNodedPerevodStrokiForNextBus
          inc     [YPosPCIList]
          mov     si,offset PerevodStroki
          call    colorStr6x8
NotNodedPerevodStrokiForNextBus:
          jmp     NextPCIBusScan

EndPCIBusScan:
          cmp     [PCIRepInfoGeting],0
          jz      short NoSkipGetPCIInfo3

          mov     al,6
          mul     [XPosPCIList]
          mov     cx,ax
          cmp     cx,24
          ja      short NotNidedCorrectXPosSizePCIList
          add     cx,256
NotNidedCorrectXPosSizePCIList:
          sub     cx,24
          mov     al,[YPosPCIList]
          mov     bx,8
          mul     bl
          mov     dx,ax
          add     dx,33
          mov     ax,bx
          mov     bx,291
          mov     bp,3+8
          call    ColorFrame
          mov     ax,cx
          sub     ax,4*6
          mov     bx,dx
          add     bx,37*8-5
          mov     cx,25
          sub     bp,bp
          call    ColorHorLine

NoSkipGetPCIInfo3:

          call     FaundAGPVerInDataBase ; Return al - AGP version
          or       al,al
          jz       short NoAGPBus

          sub     ah,ah
          shr     al,4
          mov     cx,1
          mov     di,offset  NumMajorAGPVersion
          call    BinToAscHex
          call    NZInMes
          mov     al,[VerAGP]
          and     al,1111b
          mov     di,offset  NumMinorAGPVersion
          call    BinToAscHex
          mov     al,[YPosPCIList]
          add     al,40
          mov     ah,[XPosPCIList]
          sub     ah,9+8+6
          cmp     [PCIRepInfoGeting],0
          jz      short NoSkipGetPCIInfo5

          call    CursorPos
          mov     si,offset MesAGPVersion
          call    ColorStr6x8
NoSkipGetPCIInfo5:
          mov     al,[SupAGPRate]
          or      al,al
          jz      short SupAGPBusRateNotPresent
          sub     ah,ah
          mov     di,offset NumSupAGPRate
          mov     cx,1
          call    BinToAscHex

          cmp     [PCIRepInfoGeting],0
          jz      short NoSkipGetPCIInfo4

          mov     si,offset MesSupAGPRate
          call    ColorStr6x8
SupAGPBusRateNotPresent:
NoAGPBus:

          cmp     [PCIRepInfoGeting],0
          jz      short NoSkipGetPCIInfo4

          mov     al,[YPosPCIList]
          add     al,40
          mov     ah,[XPosPCIList]
          sub     ah,9+2
          call    CursorPos
          mov     si,offset MesPCIBIOSVersion
          call    ColorStr6x8

          mov     si,offset MesPciInstalled
          call    ColorStr6x8

          cmp     [GetPCIInfoOK],1
          jz      short DitailedInfoGeting
          mov     [GetPCIInfoOK],1
          jmp     short DitailedInfoNotGet
DitailedInfoGeting:
          mov     [GetPCIInfoOK],0
DitailedInfoNotGet:
NoSkipGetPCIInfo4:
          mov     [PCIRepInfoGeting],1

          ret
PCIDeviceList DW 0
PCIData       DW 0
ENDP GetPCIInfo

          ALIGN 2
PROC FaundAGPVerInDataBase
          sub      ch,ch
          mov      cl,[NumPCIStr]
          or       cx,cx
          jz       short NoAGPBusFound
          mov      [PCIDevRepOfs],0

FaindAGPBusInDataBase:

          call     GetPCIDeviceFromBuffer

          mov      al,[VerAGP]
          or       al,al
          jnz      short FaundAGPVerOK
          loop     short FaindAGPBusInDataBase
NoAGPBusFound:
          sub      al,al
FaundAGPVerOK:
          ret
ENDP FaundAGPVerInDataBase

PROC GetFullPCIConfig

          mov     di,offset NumPCIVideoDev
          mov     cx,ClearedPCIDevLength
          sub     al,al
          cld
          rep stosb

          sub     di,di    ;Vendor ID
          call    ReadPCIConfig
          mov     [PCIVEN],cx
          jc      GetFullPCIConfigErr
          jcxz    GetFullPCIConfigErr
          cmp     cx,0FFFFh
          jz      GetFullPCIConfigErr

          mov     di,2     ;Device ID
          call    ReadPCIConfig
          mov     [PCIDEV],cx
          mov     di,8     ;Revision and programing interface
          call    ReadPCIConfig
          mov     [PCIREV],cl
          mov     [PIClass],ch
          mov     di,0Ah   ;Sub-class and Class
          call    ReadPCIConfig
          mov     [word ds:SubClass],cx
          mov     di,0Eh   ;HeaderType
          call    ReadPCIConfig

          and     cl,01111111b

          mov     [HeaderType],cl
          or      cl,cl
          jz      short HeaderType0
          cmp     cl,1
          jz      short HeaderType1
          cmp     cl,2
          jz      short HeaderType2
          jmp     ExitGetFullPCIConfig

HeaderType1:

          mov     di,010h
          call    GetPCIBaseMemoryRange
          mov     [MemBase0],ecx
          mov     [MemBaseRange0],eax
          mov     di,014h
          call    GetPCIBaseMemoryRange
          mov     [MemBase1],ecx
          mov     [MemBaseRange1],eax

          jmp     ExitGetFullPCIConfig
HeaderType2:
          mov     di,01Ch
          call    GetPCIBaseMemoryRange
          mov     [MemBase0],ecx
          mov     [MemBaseRange0],eax
          mov     di,024h
          call    GetPCIBaseMemoryRange
          mov     [MemBase1],ecx
          mov     [MemBaseRange1],eax
          mov     di,040h  ;SUBSYS Vendor ID
          call    ReadPCIConfig
          mov     [PCISUBSYSVEN],cx
          mov     di,040h+2;SUBSYS Device ID
          call    ReadPCIConfig
          mov     [PCISUBSYSDEV],cx
          jmp     ExitGetFullPCIConfig

HeaderType0:
          mov     di,010h
          call    GetPCIBaseMemoryRange
          mov     [MemBase0],ecx
          mov     [MemBaseRange0],eax
          mov     di,014h
          call    GetPCIBaseMemoryRange
          mov     [MemBase1],ecx
          mov     [MemBaseRange1],eax
          mov     di,018h
          call    GetPCIBaseMemoryRange
          mov     [MemBase2],ecx
          mov     [MemBaseRange2],eax
          mov     di,01Ch
          call    GetPCIBaseMemoryRange
          mov     [MemBase3],ecx
          mov     [MemBaseRange3],eax
          mov     di,020h
          call    GetPCIBaseMemoryRange
          mov     [MemBase4],ecx
          mov     [MemBaseRange4],eax
          mov     di,024h
          call    GetPCIBaseMemoryRange
          mov     [MemBase5],ecx
          mov     [MemBaseRange5],eax

          mov     di,02Ch  ;SUBSYS Vendor ID
          call    ReadPCIConfig
          mov     [PCISUBSYSVEN],cx
          mov     di,02Ch+2;SUBSYS Device ID
          call    ReadPCIConfig
          mov     [PCISUBSYSDEV],cx

          mov     di,0Ah
          call    ReadPCIConfig
          cmp     cx,0300h
          jz      short VideoDevDetected
          cmp     cx,0301h
          jz      short VideoDevDetected
          cmp     cx,0302h
          jnz     short NotVideoDev
VideoDevDetected:
          mov     [NumPCIVideoDev],1
NotVideoDev:

          mov     di,06h  ;Status Register
          call    ReadPCIConfig
          jc      GetFullPCIConfigErr
          test    cx,10000b
          jz      GetFullPCIConfigErr
          mov     di,34h  ;Offset of capabilities list
          call    ReadPCIConfig
          sub     ch,ch
          mov     di,cx
NextCapDev:
          push    di                 ; (Offset = CAP_PTR)
          call    ReadPCIConfigDword ; Capability ID Reg
          pop     di
          jc      GetFullPCIConfigErr
          mov     [AGPCapIdReg],ecx
          cmp     cl,2 ; Faind AGP cap.
          jz      short FaundAGPcap
          sub     cl,cl
          xchg    ch,cl
          mov     di,cx
          or      di,di
          jnz     short NextCapDev
          jmp     ExitGetFullPCIConfig
FaundAGPcap:
          shr     ecx,16
          mov     [VerAGP],cl
          add     di,4        ;Status Register (Offset CAP_PTR + 4)
          push    di
          call    ReadPCIConfigDword
          jc      short GetFullPCIConfigErr
          mov     [FoundAGPController],1
          mov     [AGPStatusReg],ecx
          pop     di
          mov     al,8
          test    cl,1000b
          jnz     short SupportAGP8x
          mov     al,4
          test    cl,100b
          jnz     short SupportAGP4x
          mov     al,2
          test    cl,10b
          jnz     short SupportAGP2x
          dec     al
          test    cl,1b
          jnz     short SupportAGP1x
          mov     [SupAGPRate],0
          jmp     short ExitGetFullPCIConfig
SupportAGP8x:
SupportAGP4x:
SupportAGP2x:
SupportAGP1x:
          mov     [SupAGPRate],al
          add     di,4       ;Command Register - (Offset CAP_PTR + 8)
          call    ReadPCIConfigDword
          jc      short GetFullPCIConfigErr
          mov     [AGPCommandReg],ecx
          mov     al,8
          test    cl,1000b
          jnz     short AGP4xDataRate
          mov     al,4
          test    cl,100b
          jnz     short AGP4xDataRate
          mov     al,2
          test    cl,10b
          jnz     short AGP2xDataRate
          dec     al
          test    cl,1b
          jnz     short AGP1xDataRate
          sub     al,al
AGP4xDataRate:
AGP4xDataRate:
AGP2xDataRate:
AGP1xDataRate:
          mov     [AGPDataRate],al
          test    cx,100000000b
          jz      short ExitGetFullPCIConfig
          mov     [AGPEnable],1
ExitGetFullPCIConfig:

GetFullPCIConfigErr:
          ret
ENDP GetFullPCIConfig

PROC GetPCIBaseMemoryRange
          call    ReadPCIConfigDword
          push    ecx

          test    ecx,1
          mov     ecx,0FFFFFFFCh
          jnz     short DetectIOForMemRange
          and      cl,0F0h
DetectIOForMemRange:
          push    ecx
          call    WritePCIConfigDword
          call    ReadPCIConfigDword
          pop     eax
          mov     ebp,ecx

          pop     ecx

          push    eax
          push    ecx
          push    ebp
          call    WritePCIConfigDword
          pop     ebp
          pop     ecx
          pop     eax

          cmp     ebp,ecx
          jz      short ErrorInMemRange
          cmp     ebp,eax
          jnz     short NoErrorInMemRange
ErrorInMemRange:
          sub     eax,eax
          jmp     short ErrorInMemRangeEnd
NoErrorInMemRange:
          mov     eax,ebp
          not     eax
          add     eax,ecx
          cmp     ecx,0FFFFh
          ja      short ErrorInMemRangeEnd
          movzx   eax,ax
ErrorInMemRangeEnd:
          ret
ENDP GetPCIBaseMemoryRange

PROC PCIDisplayAdapter

          sub      ch,ch
          mov      cl,[NumPCIStr]
          or       cx,cx
          jz       NoPCIBusFoundForPrnPCIDisplayAdapter
          mov      [PCIDevRepOfs],0
FaindPCIDevInDataBase:
          push     cx

          call     GetPCIDeviceFromBuffer

          cmp      [NumPCIDevVendor],0
          jz       NotFaundPCIVideoDev
          cmp      [NumPCIDevName],0
          jz       short NotFaundPCIVideoDev

          cmp      [NumPCIVideoDev],1
          jnz      short NotFaundPCIVideoDev
          inc      [ForBaseFrame]
          mov      [PCIVideoDetected],1

          cmp      [FoundAGPController],0
          jz       short NotPresentAGPBus
          cmp      [NumberPCIBus],0
          jnz      short FaundAGPVideo

NotPresentAGPBus:
          mov      si,offset MesPCIVideo
          call     ColorStr6x8
          mov      bx,39
          jmp      short PrnVideoDevName
FaundAGPVideo:
          mov      al,[AGPDataRate]
          or       al,al
          jz       short AGPDataRateNotPresent
          sub      ah,ah
          mov      cx,1
          mov      di,offset NumSupAGPVideoRate
          call     BinToAscDec
          cmp      [AGPEnable],1
          jnz      short AGPIsDisabled
          mov      [NumAGPColorRate],2+8
AGPIsDisabled:
          mov      si,offset MesAGPVideo
          call     ColorStr6x8
          mov      bx,38
          jmp      short PrnVideoDevName

AGPDataRateNotPresent:
          mov      si,offset MesAGPVideoNotRate
          call     ColorStr6x8
          mov      bx,41
          jmp      short PrnVideoDevName
PrnVideoDevName:
          call     CreateVideoName
          mov      si,offset NumPCIVendor

          call UnpackPCIString

          cmp      [byte ds:si+bx+1],0
          jz       short NotPrnPerenos
          cmp      [byte ds:si+bx],0
          jz       short NotPrnPerenos
          mov      [dword ds:si+bx],01019h
NotPrnPerenos:
          call     ColorStr6x8

          call     GetVideoMem

NotFaundPCIVideoDev:
          pop      cx
          dec      cx
          jnz      FaindPCIDevInDataBase

NoPCIBusFoundForPrnPCIDisplayAdapter:
          ret
ENDP PCIDisplayAdapter

PROC GetVideoMem
          cmp     [ErrConfig],1
          jz      EndOfNvidiaDevName

          mov     si,offset PCIVideoDevList
          cld
NextPCIVideoNameCheck:
          lodsd
          cmp     eax,[dword ds:PCIVEN]
          jz      short GoToGetVideoMemBase
          or      eax,eax
          jnz     short NextPCIVideoNameCheck

          cmp     [PCIVEN],10DEh
          jz      short FaindVendorNVidia
          cmp     [PCIVEN],12D2h
          jnz     EndOfNvidiaDevName
          cmp     [PCIDEV],20h ;TNT+...
          jb      EndOfNvidiaDevName

GoToGetVideoMemBase:
FaindVendorNVidia:

          mov     esi,[MemBase1]
          test    si,1
          jnz     EndOfNvidiaDevName
          and     esi,0FFFFFFF0h
          or      esi,esi
          jz      EndOfNvidiaDevName
          mov     eax,[MemBaseRange1]
          or      eax,eax
          jz      EndOfNvidiaDevName
          inc     eax
          sub     eax,esi
          cmp     eax,2*1024*1024
          jb      EndOfNvidiaDevName
          cmp     eax,512*1024*1024
          ja      EndOfNvidiaDevName
          mov     [VideoMemRange],eax

          push    es
          sub     ax,ax
          mov     es,ax

          add     esi,1*1024*1024;10000h

          mov     eax,cr0
          push    eax
          or      eax,60000000h
          mov     cr0,eax
          P586
          wbinvd
          p386

          xor     [dword es:esi],'SST_'
          mov     eax,[dword es:esi]
          mov     ebx,eax
          xor     eax,5A5AA5A5h
          mov     edx,2*1024*1024

NextTestVmemSizeMethod1:

          cmp     ebx,[dword es:esi+edx]
          jnz     short NotFoundSignatire
          xor     [dword es:esi],5A5AA5A5h
          cmp     eax,[dword es:esi+edx]
          pushf
          xor     [dword es:esi],5A5AA5A5h
          popf
          jnz     short NotFoundSignatire
          xor     [dword es:esi],'SST_'
          jmp     short FaindEndOffVmem
NotFoundSignatire:
          shl     edx,1
          cmp     edx,[VideoMemRange]
          jb      short NextTestVmemSizeMethod1
          xor     [dword es:esi],'SST_'

          mov     edx,2*1024*1024
NextTestVmemSizeMethod2:
          mov     eax,[dword es:esi+edx]
          xor     [dword es:esi+edx],5A5AA5A5h
          cmp     eax,[dword es:esi+edx]
          pushf
          xor     [dword es:esi+edx],5A5AA5A5h
          popf
          je      short FaindEndOffVmem
          shl     edx,1
          cmp     edx,[VideoMemRange]
          jb      short NextTestVmemSizeMethod2
          jz      short FaindEndOffVmem
          mov     edx,2*1024*1024 ; for error mem detect
FaindEndOffVmem:

          pop     eax
          mov     cr0,eax
          shr     edx,14h
          pop     es
          cmp     dx,2
          jz      short VideoMemoryNotDetected
          cmp     dx,256
          jz      short VideoMemoryNotDetected
          mov      [NvidiaMem],dx
VideoMemNotAcesseble:
VideoMemoryNotDetected:
EndOfNvidiaDevName:
          ret
ENDP GetVideoMem

          ALIGN 2
PROC AccessToPCIList2
          cmp     al,1
          jnz     short EndPCIList2
          cmp     [byte cs:PCIDeviceListChenged],1
          jz      short EndPCIList2
          mov     si,offset PCIDevData2
          mov     [word cs:PCIDeviceList],si
          mov     ax,PCIDataSeg2
          mov     [word cs:PCIData],ax
          mov     ds,ax
          mov     [byte cs:PCIDeviceListChenged],1
EndPCIList2:
          ret
PCIDeviceListChenged DB 0
ENDP AccessToPCIList2

          ALIGN 2
PROC CorrectNullStrDev
NullStrDev:
          cmp     [byte ds:si],0
          jnz     short NotNullStrDev
          add     si,3
          cmp     [byte ds:si],0
          jz      short NullStrDev
          cmp     [byte ds:si],3
          jnz     short TestSybSysStrDev
          add     si,2
TestSybSysStrDev:
          cmp     [byte ds:si],4
          jnz     short NotNullStrDev
          add     si,5
          jmp     short NullStrDev
NotNullStrDev:
          ret
ENDP CorrectNullStrDev

PROC TestBug2000
NotOKResuts:
          call    GetRealDateAndTime
          jc      short RealDateTimeError
          mov     al,[RealSeconds]
          cmp     al,59h
          jz      short NotOKResuts
          add     al,1
          daa
          mov     [RealSeconds],al
          call    SetDateAndTimeBug2000Test1
          jc      short DateTimeError

WiteSecond:
          call    GetDateAndTime
          jc      short DateTimeError
          cmp     [Seconds],59h
          jz      short WiteSecond
          mov     eax,[dword ds:Year]
          cmp     [dword ds:Bug2000Test1NormalYear],eax
          jz      short Bug2000Test1Complite
          mov     [Bug2000Test1],1
          mov     [Test1WithBugDate],eax
Bug2000Test1Complite:
DateTimeError:
          call    SetRealDateAndTime
RealDateTimeError:
          ret
ENDP TestBug2000

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

PROC PrintDateTime
          mov     al,[Day]
          mov     di,offset NumDay
          call    TimePrn
          mov     al,[Month]
          mov     di,offset NumMonth
          call    TimePrn
          mov     ax,[Year]
          mov     di,offset NumYear
          call    YearPrn
          mov     al,[Hour]
          mov     di,offset NumHour
          call    TimePrn
          mov     al,[Minutes]
          mov     di,offset NumMinutes
          call    TimePrn
          mov     al,[Seconds]
          mov     di,offset NumSeconds
          call    TimePrn
          ret
ENDP PrintDateTime

PROC GetRealDateAndTime
          mov     ah,2
          int     1Ah
          jc      short GetRealDateTimeError
          mov     [word ds:RealMinutes],cx
          mov     [word ds:RealDayLight],dx
          mov     ah,4
          int     1Ah
          jc      short GetRealDateTimeError
          mov     [word ds:RealDay],dx
          mov     [RealYear],cx
GetRealDateTimeError:
          ret
ENDP GetRealDateAndTime

PROC SetRealDateAndTime
          mov     cx,[word ds:RealMinutes]
          mov     dx,[word ds:RealDayLight]
          mov     ah,3
          int     1Ah
          jc      short SetRealTimeError
          mov     dx,[word ds:RealDay]
          mov     cx,[RealYear]
          mov     ah,5
          int     1Ah
SetRealTimeError:
          ret
ENDP SetRealDateAndTime

PROC GetDateAndTime
          mov     ah,2
          int     1Ah
          jc      short GetTimeError
          mov     [word ds:Minutes],cx
          mov     [word ds:DayLight],dx
          mov     ah,4
          int     1Ah
          jc      short GetTimeError
          mov     [word ds:Day],dx
          mov     [Year],cx
GetTimeError:
          ret
ENDP GetDateAndTime

PROC SetDateAndTimeBug2000Test1
          mov     cx,[word ds:Bug2000Test1Minutes]
          mov     dx,[word ds:Bug2000Test1DayLight]
          mov     ah,3
          int     1Ah
          jc      short SetBug2000Test1TimeError
          mov     dx,[word ds:Bug2000Test1Day]
          mov     cx,[Bug2000Test1Year]
          mov     ah,5
          int     1Ah
SetBug2000Test1TimeError:
          ret
ENDP SetDateAndTimeBug2000Test1

PROC DetectISAPnP
          cmp     [ISAConfigStrucSupport],1 ;Сканируем все возможные RD порты
          jnz     short BIOSNotSupportISAConfigStruc ;если BIOS не поддерживает ISA PnP
          cmp     [CSNFromISAConfigStruc],0
          jz      ISAPnPCardNotFound ; BIOS не нашел ISA PnP карты

BIOSNotSupportISAConfigStruc:
          call    ISAPnPKey     ; Инициализация ключем PnP
          mov     ax,206h       ; Fallout to 'Wait_key' state
          call    OutPnPReg
NextAdrForScan:
          mov     al,[pnprdr]
          sub     ah,ah
          push    ax
          shl     ax,2
          or      ax,11b
          mov     di,offset NumISAPnPPort
          mov     cx,3
          call    BinToAscHex
          mov     si,offset MesDetISAPnPPort
          call    ColorStr6x8

          call    ISAPnPKey    ; Инициализация ключем PnP
          mov     ax,300h      ; Wake[0]
          call    OutPnPReg
          pop     ax
          call    OutPnPReg
NextCardIsolate:
          call    GetSerIDAdr
          call    IsolatingISAPnPCard
          jc      short ErrInIsolate  ;jc
          inc     [CurrCSN]
          mov     al,[CurrCSN]
          mov     ah,6       ; Write CSN
          call    OutPnPReg  ; пpисвоим ей номеp Card Serial Number
; Анализ Resource Block и вывод некотоpых сведений о PnP плате
          sub     bp,bp         ; на всякий случай Length RB<=65536
          call    ISAPnPKey
          mov     al,[CurrCSN]  ; 'pазбудить' плату
          mov     ah,3          ; Wake [CSN]
          call    OutPnPReg
          call    GetSerIDAdr   ; For strange card f.e.: "Turtle Beach Tropez Plus"
          sub     bx,9          ; With:
          call    ReadByteOfResourceData ; no Serial Vendor_ID in Resourse Data !
          cmp     al,[byte ds:bx]
          jnz     short rd_rdb
          mov     cx,8            ; Read & Skip Vendor_ID
rd_id0:
          call    ReadByteOfResourceData
          loop    short rd_id0
rdres0:
          call    ReadByteOfResourceData    ; Read one byte of resourse data
rd_rdb:
          mov     cl,al
          test    al,080h         ; Small or Large Item Tag ?
          jnz     short rd_rdb00
          call    GetSmallItemName
          jmp     short rd_rdb01
rd_rdb00:
          call    GetLargeItemName
rd_rdb01:
          jc      short rdres1     ; End Of Resource Block or some error
          dec     bp
          jnz     short rdres0
rdres1:
          call    ISAPnPKey        ; Инициализация ключем PnP
          mov     ax,300h          ; Wake [0]
          call    OutPnPReg
          mov     [ANSIIDstring],0
          jmp     short NextCardIsolate
ErrInIsolate:
          cmp     [CurrCSN],0 ; каpта не 1 - значит все каpты выявили
          jnz     short AllCardFound
          inc     [pnprdr]   ; Следующий адpес READ_DATA port
          mov     al,[pnprdr]
          cmp     al,0C0h    ; Не совсем по спецификации !!! (до 0FFh надо)
          jz      short ISAPnPCardNotFound   ; Все адpеса опpобованы
          call    WaitingAndGetCh
          cmp     al,' '
          jz      short ISAPnPCardNotFound

          jmp     NextAdrForScan
AllCardFound:
          mov     ax,202h     ; all card to Wait for Key state
          call    OutPnPReg
          mov     [ISAPnPCounter],1
ISAPnPCardNotFound:
          ret
ENDP DetectISAPnP

PROC GetLargeItemName
          and     al,07Fh        ; Large Item Name (Code)
          push    ax
          call    ReadByteOfResourceData  ; CX = length of Item Data
          mov     cl,al
          call    ReadByteOfResourceData
          mov     ch,al
          pop     ax
          cmp     al,02h         ; 'ANSI Identifier string'(02h) ?
          jnz     short NotANSIIDstring
          cmp     [ANSIIDstring],1
          jz      short NotANSIIDstring

          inc     [ANSIIDstring]
          mov     di,[PosNameISAPnPBuf]
          cld
NextByteOfANSIIDSring:
          call    ReadByteOfResourceData
          or      al,al
          jz      short EndOfANSIIDstring
          stosb
          loop    short NextByteOfANSIIDSring
EndOfANSIIDstring:
          sub     eax,eax
          stosd
          mov     [PosNameISAPnPBuf],di
          mov     ax,di
          mov     di,[PosAdrNamePnPCard]
          stosw
          mov     [PosAdrNamePnPCard],di
          jmp     short ExitFromGetLargeItemName
NotANSIIDstring:
          jcxz     short ExitFromGetLargeItemName
NextByteOfLargeItemName:
          call    ReadByteOfResourceData     ; Read whole Item
          loop    short NextByteOfLargeItemName
ExitFromGetLargeItemName:
          clc
          ret
ENDP GetLargeItemName

PROC GetSmallItemName
          shr     al,3           ; Small Item Name (Code)
          cmp     al,0Fh         ; 'End Tag'(0fh) ?
          jnz     short NotEndSmallItemTag
          stc
          ret
NotEndSmallItemTag:
          xor     ch,ch          ; Read whole Item
          and     cl,07h
          jz      short GetSmallItemTagOK
NullGetSmallItemTag:
          call    ReadByteOfResourceData
          loop    short NullGetSmallItemTag
GetSmallItemTagOK:
          clc
          ret
ENDP GetSmallItemName

PROC ReadByteOfResourceData
          push    cx
          sub     cx,cx
          mov     ah,5
WaitResponseISAPnPcard:
          call    InPnPReg
          test    al,01b
          loopz   short WaitResponseISAPnPcard
          cmp     al,0FFh
          jnz     short ResponseISAPnPcardOK
          inc     cx
ResponseISAPnPcardOK:
          stc
          jcxz    short NotResponseISAPnPcard
          mov     ah,4   ; п/п чтения 1 байта RDB
          call    InPnPReg
          clc
NotResponseISAPnPcard:
          pop     cx
          ret
ENDP ReadByteOfResourceData

PROC GetSerIDAdr
; pасчет текущего адpеса Serial ID в SerialIDbuff
          mov     al,[CurrCSN]
PROC GetSerIDAdrForVendor
          mov     bl,9
          mul     bl
          mov     bx,offset SerialIDbuff
          add     bx,ax
          ret
ENDP GetSerIDAdrForVendor
ENDP GetSerIDAdr

PROC UnpackVendorIDISAPnP
          push    cx
          push    di
          mov     al,[CurrCSN]
          sub     al,cl
          call    GetSerIDAdrForVendor
          mov     eax,[dword ds:bx+4]
          push    eax
          mov     ax,[word ds:bx+2]
          push    ax
          mov     dx,[word ds:bx]
          xchg    dl,dh
          mov     di,offset VendorIDISAPnP
          rcl     dx,1
          mov     ch,3
          cld
NextVendorSimvolUnpack:
          xor     al,al
          mov     cl,5
unpid00:  rcl     dx,1
          rcl     al,1
          dec     cl
          jnz     short unpid00
          add     al,'@'
          stosb
          dec     ch
          jnz     short NextVendorSimvolUnpack
          pop     ax
          xchg    ah,al
          mov     cl,4
          call    BinToAscHex
          pop     eax
          cmp     eax,0FFFFFFFFh
          jz      short NotSupportSerialNoIDISAPnP
          push    eax
          pop     ax
          mov     di,offset SerialNoIDISAPnP+4
          call    BinToAscHex
          pop     ax
          mov     di,offset SerialNoIDISAPnP
          call    BinToAscHex
          jmp     short ExitUnpackVendorIDISAPnP
NotSupportSerialNoIDISAPnP:
           mov    di,offset SerialNoIDISAPnP
           mov    [dword ds:di+4],202020C4h
           mov    [dword ds:di],20202020h

ExitUnpackVendorIDISAPnP:
           pop    di
           pop    cx
           ret
ENDP UnpackVendorIDISAPnP

PROC IsolatingISAPnPCard
; Вход:  DS:BX=адpес поля 72 bit serial identifier, + адpеса pегистpов
; Выход: CF=0  -> Ok! + заполненное поле
;        CF=1  -> Error
          push    dx
          push    cx
          push    ax
          push    bx
          xor     dl,dl
          mov     ah,1
          mov     cx,072  ; 72 pair of I/O for Serial_Identifier
isolat00:
          call    InPnPReg
          mov     dh,al
          call    InPnPReg
          cmp     al,055h
          jz      short isolat01
          cmp     al,0AAh
          jz      short isolat01
          xor     al,al
          jmp     short isolat04
isolat01:
          or      dl,01h
          xor     dh,al
          inc     dh
          jnz     short ErrorInIsolating
isolat04:
          push    cx
          mov     si,cx
          mov     cx,72
          sub     cx,si
          call    InBitMap ; заносим в каpту бит[CX]=al(!=0->'1')
          pop     cx
          loop    short isolat00
          test    dl,01
          jz      short ErrorInIsolating

          pop     si
          push    si
          mov     cx,8
          call    ISAPnPCheckSum
          lodsb
          cmp     dl,al
          jz      short IsolatingOK
ErrorInIsolating:
          stc
IsolatingOK:
          pop     bx
          pop     ax
          mov     al,cl
          pop     cx
          pop     dx
          ret
ENDP IsolatingISAPnPCard

PROC OutPnPReg
; Вывод байта=AL в pегистp PnP=AH
          push    dx
          mov     dx,0279h
          xchg    ah,al
          out     dx,al
          call    ISAPnPDelay
          mov     dx,0A79h
          xchg    ah,al
          out     dx,al
          call    ISAPnPDelay
          pop     dx
          ret
ENDP OutPnPReg

PROC InPnPReg
; Ввод байта=AL из pегистpа PnP=AH
          push    dx
          mov     dx,0279h
          mov     al,ah
          out     dx,al
          call    ISAPnPDelay
          mov     dl,[pnprdr]
          sub     dh,dh
          shl     dx,2
          or      dx,11b
          in      al,dx
          pop     dx
          ret
ENDP InPnPReg

PROC PosDMIString
          or      cl,cl
          jz      short FailedPosDMIString
          mov     al,[byte ds:si+1]
          sub     ah,ah
          add     si,ax
          cld
NextDMIstring:
          sub     bx,bx
NextNoZeroByte:
          lodsb
          inc     bx
          or      al,al
          jnz     short NextNoZeroByte
          dec     cl
          jnz     short NextDMIstring
          sub     si,bx
          mov     cx,bx
          cmp     [byte ds:si],32
          jz      short FailedPosDMIString
          cmp     [byte ds:si],0
          jz      short FailedPosDMIString
          inc     [byte cs:DMIStringCounter]
          clc
          ret
FailedPosDMIString:
          stc
          ret
DMIStringCounter DB 0
ENDP PosDMIString

PROC PutMesHelp
          mov     dx,offset MesHelp
PROC PutCSMesage
          call    PutDOSStr
          ret
ENDP PutCSMesage
ENDP PutMesHelp

PROC GetMaxAveraging5
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
ENDP GetMaxAveraging5

PROC AddCommentsToReport
        call    ClearWindowMesages2
        mov     [CommentsCursorPos],0
        mov     si, offset NumCommentsBuf
        mov     [byte ds:si],'_'
        mov     [byte ds:si+1],0
        cmp     [NumMaxChars],8
        jz      short DetectPrnFileName
        mov     si, offset MesComments
        call    ColorStr6x8
        jmp     PrnNumCommentsBuf
DetectPrnFileName:
        mov     si, offset MesFileName
        call    ColorStr6x8
PrnNumCommentsBuf:
        mov     si, offset NumCommentsBufPrn
        call    ColorStr6x8

AddCommentsLoop:
        call    GetCh
        cmp     al,0Dh
        jz      EndAddComments
        cmp     al,1Bh
        jz      EndAddComments
        cmp     al,8h
        jnz     GetCommentsSymbol

        cmp     [CommentsCursorPos],0
        jbe     short AddCommentsLoop
        dec     [CommentsCursorPos]
        mov     si, offset NumCommentsBuf
        add     si,[CommentsCursorPos]
        mov     [byte ds:si],al
        mov     [byte ds:si],'_'
        mov     [byte ds:si+1],32
        mov     [byte ds:si+2],0
        jmp     short GoToPrnMesComments


GetCommentsSymbol:
        sub     bx,bx
        mov     bl,[NumMaxChars]
        cmp     [CommentsCursorPos],bx
        jae     short AddCommentsLoop
        cmp     al,' '
        jb      short AddCommentsLoop

        mov     si, offset NumCommentsBuf
        add     si,[CommentsCursorPos]
        mov     [byte ds:si],al
        mov     [byte ds:si+1],'_'
        mov     [byte ds:si+2],0
        inc     [CommentsCursorPos]

GoToPrnMesComments:
        cmp     [NumMaxChars],8
        jz      short DetectPrnFileName1
        mov     si, offset MesComments
        call    ColorStr6x8
        jmp     PrnNumCommentsBuf1
DetectPrnFileName1:
        mov     si, offset MesFileName
        call    ColorStr6x8
PrnNumCommentsBuf1:
        mov     si, offset NumCommentsBufPrn
        call    ColorStr6x8
        jmp     short AddCommentsLoop

EndAddComments:
        mov     si, offset NumCommentsBuf
        add     si,[CommentsCursorPos]
        mov     [byte ds:si],' '
        cmp     [NumMaxChars],8
        jz      short DetectPrnFileName2
        mov     si, offset MesComments
        call    ColorStr6x8
        jmp     PrnNumCommentsBuf2
DetectPrnFileName2:
        mov     si, offset MesFileName
        call    ColorStr6x8
PrnNumCommentsBuf2:
        mov     si, offset NumCommentsBufPrn
        call    ColorStr6x8
        call    ClearWindowMesages
        mov     si,offset MesPressC
        call    ColorStr6x8

        ret
ENDP AddCommentsToReport



          ENDS Cseg

          SEGMENT EndPrgSeg Page Public 'CODE'
          DB 'EndPrgSeg'
          ENDS EndPrgSeg

          END     Start
