          %TITLE "NewLib Ver 1.39 Coded by Vladimir Afanasiev 24-Jun-2003"
                ; For SST Compressing Versions

                   IDEAL
                   P386
ASCnull            EQU   0
mkm                EQU   250,'m'

                   SEGMENT Dseg Page Public 'DATA'
                   ASSUME  ds:Dseg, es:Dseg
                   EXTRN MultiTask:byte,ReportDataSeg:word,CounterRepBuf:word,RepStrCounter:byte
                   EXTRN FileHandle:word,EndProgram:word,SkaleProc:byte
                   EXTRN BrandID:byte,CPUstepping:byte,CPUmodel:byte,CPUfamily:byte
                   EXTRN CPUtype:byte,RegEDXCPUIDlevel2:dword,ClockRatio:word
                   EXTRN DataCacheL1:word,CacheL1:word,CacheL2:word,CacheL3:word
                   EXTRN SPDSocket:byte,BaseAdrSMBus:word,NumByteSPD:byte,IntelExtendedFamily:byte
                   EXTRN IntelProcessor:byte,CorrectFrec:word,NumberPCIBus:byte

         PUBLIC MesHelp,BIOSVendors

          DB 13,10,'Needed sources? Email me! только с конкретными вопросами!',13,10,13,10
MesHelp   DB 13,10,10,'Usage: SPEEDSYS {[<HD[drive#] [WT]> or <CD[drive#]>] [T#] [SM] [SP] [L]'
          DB 13,10,   '                 [SP] [L] [PCX:filename] [<REP:filename> or <R>]'
          DB 13,10,   '                 [DI13E] [DIDEC] [DSPDR]}'
          DB 13,10,   '                 {[BIOS]} {[CLCMOS]} {[ERHDD drive#]}'
          DB 13,10,   'Where:'
          DB 13,10,   '       HD          : Directly start Hard Drive benchmarking.'
          DB 13,10,   '       CD          : Directly start CD Drive benchmarking.'
          DB 13,10,   '       drive#      : Number of drive to test, 0(default), 1, 2, etc.'
          DB 13,10,   '       T#          : Type of HD/CD Drive test.'
          DB 13,10,   '                     T1(default) - Fast Test.'
          DB 13,10,   '                     T2 - Full Test'
          DB 13,10,   '       WT          : Perform HDD write speed testing (destructive!).'
          DB 13,10,   '       SM          : Skip memory benchmark.'
          DB 13,10,   '       SP          : Skip ISA/PnP devices detection.'
          DB 13,10,   '       L           : Loop memory test (continuous).'
          DB 13,10,   '       PCX:filename: After tests save screen image into PCX file.'
          DB 13,10,   '       REP:filename: After tests create text report file.'
          DB 13,10,   '       R           : Automatically create report and exit.'
          DB 13,10,   '       DI13E       : Disable support for hard drives larger than 8.4GB.'
          DB 13,10,   '       EI13E       : Force testing HDD < 8.4GB through INT13 Extentions.'
          DB 13,10,   '       DIDEC       : Disable support for add-on PCI IDE controllers.'
          DB 13,10,   '       DSPDR       : Disable reading SPD (memory type detection).'
;          DB 13,10,   '       D21AA       : Disable 2:1 antialiasing for some graphics.'
          DB 13,10,   '       BIOS        : Dump system BIOS into file.'
          DB 13,10,   '       CLCMOS      : Clear CMOS.'
          DB 13,10,   '       ERHDD       : Erase first 128 sectors of Hard Drive.$'

BIOSVendors        DB 'Award Software, Inc.',0
                   DB 'American Megatrends, Inc.',0
                   DB 'Phoenix Technologies, Ltd.',0
                   DB 'SystemSoft Corporation',0
                   DB 'AST Research, Inc.',0
                   DB 'Toshiba America, Inc.',0
                   DB 'Toshiba Corporation',0
                   DB 'NEC Technologies, Inc.',0
                   DB 'Acer Incorporated',0
                   DB 'Acer America Corporation',0
                   DB 'Dell Computer Corporation',0
                   DB 'Elitegroup Computer Systems',0
                   DB 'Gateway 2000',0
                   DB 'Micron Electronics, Inc.',0
                   DB 'Packard Bell',0
                   DB 'IBM Corporation',0
                   DB 'Iwill Corporation',0
                   DB 'Intel Corporation',0
                   DB 'Siemens Nixdorf',0
                   DB 'Compaq Computer Corporation',0,1


Mes1738            DB 17,3+8,0
CPUam5x86133       DB 18,'Am5x86-133',0
CPUi386dx40        DB 18,'386DX-40',0
CPUi486dx250       DB 18,'i486DX2-50',0
CPUp54c133         DB 18,'Pentium-133',0
CPUp55c233         DB 18,'P55C-233',0
CPUp6200           DB 18,'P6-200',0
CPUMII233          DB 18,'Cx6x86-233',0
CPUpII233          DB 18,'PentiumII-233',0
CPUCeleron333      DB 18,'Celeron-333',0
CPUCeleron500      DB 18,'Celeron-500',0
CPUCeleron1200     DB 18,'Celeron-1200',0
CPUpII300          DB 18,'PentiumII-300',0
CPUpII400          DB 18,'PentiumII-400',0
CPUpII450          DB 18,'PentiumII-450',0
CPUK62266          DB 18,'K6-2-266',0
CPUK63500          DB 18,'K6-III-500',0
CPUAthlon600       DB 18,'Athlon-600',0
CPUDuron600        DB 18,'Duron-600',0
CPUpIII600         DB 18,'PentiumIII-600',0
CPUpIII933         DB 18,'PentiumIII-933',0
CPUAthlon800       DB 18,'Athlon-800',0
CPUAthlon1400      DB 18,'Athlon-1400',0
CPUAthlon2000      DB 18,'Athlon-2000',0
CPUP42400          DB 18,'Pentium4-2400',0

HDDWDC21600        DB 18,'WDCAC31600H(1.51',32,31,'GB)',30,0
HDDQFBEX32Asm      DB 18,31,'QFB EX3.2A(3',32,31,'GB)',30,0
HDDQFBEX32A        DB 18,'QFB EX3.2A(3.00',32,31,'GB)',30,0
HDDQFBSE3530       DB 18,'QFB SE3.2A(3.00',32,31,'GB)',30,0
HDDQFBEL51A        DB 18,'QFB EL5.1A(4.76',32,31,'GB)',30,0
HDDQFBLCT10        DB 18,'QFB lct10(13.99',32,31,'GB)',30,0
HDDQFBLCT1507      DB 18,'QFB lct15 07',0
HDDQFBLM957        DB 18,'QFB LM(9.57',32,31,'GB)',30,0
HDDIBMDTLA307030   DB 18,'IBM DTLA 307030(28.63',32,31,'GB)',30,0
HDDMPE3064AT       DB 18,'MPE3064AT(6.04',32,31,'GB)',30,0
HDDST3491A         DB 18,'ST3491(407',32,31,'MB)',30,0
HDDST32122A        DB 18,'ST32122A(1.96',32,31,'GB)',30,0
HDDMPA3026         DB 18,'MPA3026ATU(2.43',32,31,'GB)',30,0
HDDSHD3062A        DB 18,'SHD3062(115',32,31,'MB)',30,0
HDDPLS31274A       DB 18,'PLS31274A(1.18',32,31,'GB)',30,0
HDDMaxtor90651U2   DB 18,'Maxtor 90651U2(6.00',32,31,'GB)',30,0
HDDMaxtor6L040J2   DB 18,'Maxtor D740X(37.28',32,31,'GB)',30,0

CDP584             DB 18,'Matsushita CR-584 12X',0
HPCDW7100          DB 18,'HP CD-WR+7200 6X',0
TEAC540E           DB 18,'TEAC CD-540E 40Xmax',0
CDP585             DB 18,'Matsushita CR-585 24Xmax',0
CD2421E            DB 18,'Creative CD2421E 24Xmax',0
SonyCDU311         DB 18,'SONY CDU311 8X',0
LG8400B            DB 18,'LG CDR-8400B 40Xmax',0
SamSCR830          DB 18,'Samsung SCR-830 8X',0
SamSCR630          DB 18,'Samsung630 4X',0
SonyCDU701         DB 18,'SONY CDU701 32Xmax',0
SonyCDU4821        DB 18,'SONY CDU4821 48Xmax',0
AsusCDS450A        DB 18,'ASUS CD-S450/A 45Xmax',0

MesAMDP24          DB 'P24 (0.50',mkm,')',0
MesAMDP24C         DB 'P24C (0.50',mkm,')',0
MesAMDX5           DB 'X5 (0.35',mkm,')',0
MesAMDSSA5         DB 'SSA5 (0.5-0.35',mkm,')',0
MesAMD5k86         DB '5k86 (0.35',mkm,')',0
MesAMDK6030        DB 'K6 (0.30',mkm,')',0
MesAMDK6025        DB 'LittleFoot(0.25',mkm,')',0
MesAMDChomper      DB 'Chomper (0.25',mkm,')',0
MesAMDChomperXT    DB 'ChomperXT (0.25',mkm,')',0
MesAMDSharptooth   DB 'Sharptooth(0.25',mkm,')',0
MesAMDk63plus      DB 'Sharptooth(0.18',mkm,')',0
MesAMDK7ES         DB 'K7ES Argon(0.25',mkm,')',0
MesAMDK7           DB 'K7 Argon (0.25',mkm,')',0
MesAMDK75          DB 'K75 Argon (0.18',mkm,')',0
MesAMDSpitfire     DB 'Spitfire (0.18',mkm,')',0
MesAMDMorgan       DB 'Morgan (0.18',mkm,')',0
MesAMDThunderbird  DB 'Thunderbird (0.18)',0
MesAMDPalomino     DB 'Palomino (0.18',mkm,')',0
MesAMDThoroughbred DB 'Thoroughbred(0.13)',0
MesAMDBarton       DB 'Barton (0.13',mkm,')',0
MesAMDSledgeHammer DB 'SledgeHammer(0.13)',0

MesIntelP4100      DB 'P4 (1.00',mkm,')',0
MesIntelP4080      DB 'P4 (0.80',mkm,')',0
MesIntelP4S        DB 'P4S (1.00',mkm,')',0
MesIntelP24        DB 'P24 (0.80',mkm,')',0
MesIntelP23        DB 'P23 (0.80',mkm,')',0
MesIntelP24C       DB 'P24C (0.60',mkm,')',0
MesIntelP5         DB 'P5 (0.80',mkm,')',0
MesIntelP54C       DB 'P54C (0.35',mkm,')',0
MesIntelP24T       DB 'P24T (0.60-0.35',mkm,')',0
MesIntelP55C       DB 'P55C (0.28',mkm,')',0
MesIntelTilamook   DB 'Tilamook (0.25',mkm,')',0
MesIntelP6         DB 'P6 (0.50',mkm,')',0
MesIntelP6035      DB 'P6 (0.50-0.35',mkm,')',0
MesIntelKlamath    DB 'Klamath (0.35',mkm,')',0
MesIntelP6T        DB 'P6T (0.25',mkm,')',0
MesIntelCovington  DB 'Covington (0.25',mkm,')',0
MesIntelDeshutes   DB 'Deshutes (0.25',mkm,')',0
MesIntelMendocino  DB 'Mendocino (0.25',mkm,')',0
MesIntelDixon      DB 'Dixon (0.25',mkm,')',0
MesIntelKatmai     DB 'Katmai (0.25',mkm,')',0
MesIntelTanner     DB 'Tanner (0.25',mkm,')',0
MesIntelCoppermine DB 'Coppermine(0.18',mkm,')',0
MesIntelCascades   DB 'Cascades (0.18',mkm,')',0
MesIntelCascadesA  DB 'Cascades? (0.18',mkm,')',0
MesIntelTualatin   DB 'Tualatin (0.13',mkm,')',0
MesIntelMerced     DB 'Merced (0.18 ',mkm,')',0
MesIntelWillamette DB 'Willamette(0.18',mkm,')',0
MesIntelNorthwood  DB 'Northwood (0.13',mkm,')',0
MesIntelMcKinley   DB 'McKinley (0.13 ',mkm,')',0
MesIntelPrescott   DB 'Prescott (0.09 ',mkm,')',0

MesCyrixM1SC       DB 'M1sc (0.65',mkm,')',0
MesCyrixGX86       DB 'GX86 (0.65',mkm,')',0
MesCyrixM1         DB 'M1/1L(0.65-0.35',mkm,')',0
MesCyrixM2         DB 'M2 (0.35-0.25',mkm,')',0
MesCyrixIIIJoshua  DB 'Joshua (0.18',mkm,')',0
MesCyrixIIISamuel  DB 'Samuel (0.18',mkm,')',0
MesCyrixIIISamuel2 DB 'Samuel 2 (0.15',mkm,')',0
MesCyrixIIIEzra    DB 'Ezra (0.15',mkm,')',0
MesCyrixIIIEzraT   DB 'Ezra-T (0.15',mkm,')',0
MesCyrixIIINehemiah DB 'Nehemiah (0.13',mkm,')',0

MesIDTC6           DB 'C6 (0.35',mkm,')',0
MesIDTW2           DB 'W2 (0.35-0.25',mkm,')',0
MesIDTW3           DB 'W3 (0.25',mkm,')',0

MesRiseMP6         DB 'mP6 (0.25',mkm,')',0
MesRiseMP6018      DB 'mP6 (0.18',mkm,')',0

Sign               DW 050Ah
Encod              DB 1
BitPix             DB 1
Left               DW 0
Top                DW 0
WidthX             DW 639
HeightY            DW 479
hRes               DW 640
vRes               DW 480
Pal                DB 48 DUP(0)
vMode              DB 0
nPlanes            DB 4
bplin              DW 80
PalInfo            DW 1
shRes              DW 0
svRes              DW 0
xtra               DB 54 DUP(0)

;         PUBLIC MemManufacturerB1,MemManufacturerB2,MemManufacturerB3,MemManufacturerB4
;         PUBLIC MemManufacturerB5,MemManufacturerB6,MemManufacturerB7,MemManufacturerB8
          PUBLIC MemManufacturerList

MemManufacturerList DW offset MemManufacturerB1,offset MemManufacturerB2
                    DW offset MemManufacturerB3,offset MemManufacturerB4
                    DW offset MemManufacturerB5,offset MemManufacturerB6
                    DW offset MemManufacturerB7,offset MemManufacturerB8

MemManufacturerB1  DB 001h,'AMD',0
                   DB 002h,'AMI',0
                   DB 083h,'Fairchild',0
                   DB 004h,'Fujitsu',0
                   DB 085h,'GTE',0
                   DB 086h,'Harris',0
                   DB 007h,'Hitachi',0
                   DB 008h,'Inmos',0
                   DB 089h,'Intel',0
                   DB 08Ah,'I.T.T.',0
                   DB 00Bh,'Intersil',0
                   DB 08Ch,'Monolithic',0
                   DB 00Dh,'Mostek',0
                   DB 00Eh,'Motorola',0
                   DB 08Fh,'National',0
                   DB 010h,'NEC',0
                   DB 091h,'RCA',0
                   DB 092h,'Raytheon',0
                   DB 013h,'Conexant',0
                   DB 094h,'Seeq',0
                   DB 015h,'Philips',0
                   DB 016h,'Synertek',0
                   DB 097h,'TI',0
                   DB 098h,'Toshiba',0
                   DB 019h,'Xicor',0
                   DB 01Ah,'Zilog',0
                   DB 09Bh,'Eurotechnique',0
                   DB 01Ch,'Mitsubishi',0
                   DB 09Dh,'Lucent (AT&T)',0
                   DB 09Eh,'Exel',0
                   DB 01Fh,'Atmel',0
                   DB 020h,'SGS/Thomson',0
                   DB 0A1h,'Lattice',0
                   DB 0A2h,'NCR',0
                   DB 023h,'Wafer Scale',0
                   DB 0A4h,'IBM',0
                   DB 025h,'Tristar',0
                   DB 026h,'Visic',0
                   DB 0A7h,'Intl. CMOS',0
                   DB 0A8h,'SSSI',0
                   DB 029h,'Microchip',0
                   DB 02Ah,'Ricoh',0
                   DB 0ABh,'VLSI',0
                   DB 02Ch,'Micron',0
                   DB 0ADh,'Hyundai',0
                   DB 0AEh,'OKI',0
                   DB 02Fh,'ACTEL',0
                   DB 0B0h,'Sharp',0
                   DB 031h,'Catalyst',0
                   DB 032h,'Panasonic',0
                   DB 0B3h,'IDT',0
                   DB 034h,'Cypress',0
                   DB 0B5h,'DEC',0
                   DB 0B6h,'LSI Logic',0
                   DB 037h,'Plessey',0
                   DB 038h,'UTMC',0
                   DB 0B9h,'Thinking',0
                   DB 0BAh,'Thomson',0
                   DB 03Bh,'Int. CMOS',0
                   DB 0BCh,'Honeywell',0
                   DB 03Dh,'Tektronix',0
                   DB 03Eh,'Sun',0
                   DB 0BFh,'SST',0
                   DB 040h,'Mosel Vitelic',0
                   DB 0C1h,'Infineon(Siemens)',0
                   DB 0C2h,'Macronix',0
                   DB 043h,'Xerox',0
                   DB 0C4h,'Plus Logic',0
                   DB 045h,'SunDisk',0
                   DB 046h,'Elan Circuit',0
                   DB 0C7h,'Euro Silicon',0
                   DB 0C8h,'Apple',0
                   DB 0C9h,'Xilinx',0
                   DB 04Ah,'Compaq',0
                   DB 0CBh,'PE',0
                   DB 04Ch,'SCI',0
                   DB 0CDh,'Seiko',0
                   DB 0CEh,'Samsung',0
                   DB 04Fh,'I3 Design',0
                   DB 0D0h,'Klic',0
                   DB 051h,'Crosspoint',0
                   DB 052h,'Alliance',0
                   DB 0D3h,'Tandem',0
                   DB 054h,'HP',0
                   DB 0D5h,'IS',0
                   DB 0D6h,'Brooktree',0
                   DB 057h,'New Media',0
                   DB 058h,'MHS',0
                   DB 0D9h,'Performance',0
                   DB 0DAh,'Winbond',0
                   DB 05Bh,'Kawasaki',0
                   DB 0DCh,'Bright Micro',0
                   DB 05Dh,'TECMAR',0
                   DB 05Eh,'Exar',0
                   DB 0DFh,'PCMCIA',0
                   DB 0E0h,'LG',0
                   DB 061h,'Northern',0
                   DB 062h,'Sanyo',0
                   DB 0E3h,'Array',0
                   DB 064h,'Crystal',0
                   DB 0E5h,'Analog Devices',0
                   DB 0E6h,'PMC-Sierra',0
                   DB 067h,'Asparix',0
                   DB 068h,'Convex',0
                   DB 0E9h,'Quality',0
                   DB 0EAh,'Nimbus',0
                   DB 06Bh,'Transwitch',0
                   DB 0ECh,'ITTI',0
                   DB 06Dh,'Cannon',0
                   DB 06Eh,'Altera',0
                   DB 0EFh,'NEXCOM',0
                   DB 070h,'QUALCOMM',0
                   DB 0F1h,'Sony',0
                   DB 0F2h,'Cray',0
                   DB 073h,'AMS',0
                   DB 0F4h,'Vitesse',0
                   DB 075h,'Aster',0
                   DB 076h,'Bay Networks',0
                   DB 0F7h,'Zentrum',0
                   DB 0F8h,'TRW',0
                   DB 079h,'Thesys',0
                   DB 07Ah,'Solbourne',0
                   DB 0FBh,'Allied-Signal',0
                   DB 07Ch,'Dialog',0
                   DB 0FDh,'Media Vision',0
                   DB 0FEh,'Level One',0
                   DB 0FFh,'Unknown B1 ',0

MemManufacturerB2  DB 001h,'Cirrus Logic',0
                   DB 002h,'National',0
                   DB 083h,'ILC',0
                   DB 004h,'Alcatel',0
                   DB 085h,'Micro Linear',0
                   DB 086h,'Univ. of NC',0
                   DB 007h,'JTAG',0
                   DB 008h,'Loral',0
                   DB 089h,'Nchip',0
                   DB 08Ah,'Galileo',0
                   DB 00Bh,'Bestlink',0
                   DB 08Ch,'Graychip',0
                   DB 00Dh,'GENNUM',0
                   DB 00Eh,'VideoLogic',0
                   DB 08Fh,'Robert Bosch',0
                   DB 010h,'Chip Express',0
                   DB 091h,'DATARAM',0
                   DB 092h,'UMC',0
                   DB 013h,'TCSI',0
                   DB 094h,'Smart Modular',0
                   DB 015h,'HA',0
                   DB 016h,'Lanstar',0
                   DB 097h,'Qlogic',0
                   DB 098h,'Kingston',0
                   DB 019h,'Music',0
                   DB 01Ah,'Ericsson',0
                   DB 09Bh,'SpaSE',0
                   DB 01Ch,'Eon Silicon',0
                   DB 09Dh,'PMC',0
                   DB 09Eh,'DoD',0
                   DB 01Fh,'IMT',0
                   DB 020h,'Corollary',0
                   DB 0A1h,'Dallas',0
                   DB 0A2h,'Omnivision',0
                   DB 023h,'EIV',0
                   DB 0A4h,'NW',0
                   DB 025h,'Mitel',0
                   DB 026h,'Clearpoint',0
                   DB 0A7h,'Cabletron',0
                   DB 0A8h,'Simple',0
                   DB 029h,'Vanguard',0
                   DB 02Ah,'Hagiwara',0
                   DB 0ABh,'Vantis',0
                   DB 02Ch,'Celestica',0
                   DB 0ADh,'Century',0
                   DB 0AEh,'Hal',0
                   DB 02Fh,'Rohm',0
                   DB 0B0h,'Juniper',0
                   DB 031h,'LSP',0
                   DB 032h,'EMS',0
                   DB 0B3h,'Tundra',0
                   DB 034h,'Adaptec',0
                   DB 0B5h,'LightSpeed',0
                   DB 0B6h,'ZSP',0
                   DB 037h,'AMIC',0
                   DB 038h,'Adobe Systems',0
                   DB 0B9h,'Dynachip',0
                   DB 0BAh,'PNY',0
                   DB 03Bh,'Newport',0
                   DB 0BCh,'MMC Networks',0
                   DB 03Dh,'T Square',0
                   DB 03Eh,'Seiko Epson',0
                   DB 0BFh,'Broadcom',0
                   DB 040h,'Viking',0
                   DB 0C1h,'V3',0
                   DB 0C2h,'Orbit',0
                   DB 043h,'Suwa',0
                   DB 0C4h,'Transmeta',0
                   DB 045h,'Micron CMS',0
                   DB 046h,'American Comp.',0
                   DB 0C7h,'Enhance 3000',0
                   DB 0C8h,'Tower',0
                   DB 049h,'CPU Design',0
                   DB 04Ah,'Price Point',0
                   DB 0CBh,'MIP',0
                   DB 04Ch,'Tellabs',0
                   DB 0CDh,'Centaur',0
                   DB 0CEh,'Unigen',0
                   DB 04Fh,'Transcend Info',0
                   DB 0D0h,'MCT',0
                   DB 051h,'CKD',0
                   DB 052h,'Capital',0
                   DB 0D3h,'Aica Kogyo',0
                   DB 054h,'Linvex',0
                   DB 0D5h,'MSC Vertriebs',0
                   DB 0D6h,'AKM',0
                   DB 057h,'Dynamem',0
                   DB 058h,'NERA ASA',0
                   DB 0D9h,'GSI',0
                   DB 0DAh,'C Memory',0
                   DB 05Bh,'Acorn',0
                   DB 0DCh,'Lara',0
                   DB 05Dh,'Oak',0
                   DB 05Eh,'Itec Memory',0
                   DB 0DFh,'Tanisys',0
                   DB 0E0h,'Truevision',0
                   DB 061h,'Wintec',0
                   DB 062h,'Super PC',0
                   DB 0E3h,'MGV Memory',0
                   DB 064h,'Galvantech',0
                   DB 0E5h,'Gadzoox',0
                   DB 0E6h,'MDC',0
                   DB 067h,'GateField',0
                   DB 068h,'IMS',0
                   DB 0E9h,'Triscend',0
                   DB 0EAh,'XaQti',0
                   DB 06Bh,'Goldenram',0
                   DB 0ECh,'Clear Logic',0
                   DB 06Dh,'Cimaron',0
                   DB 06Eh,'NPNX',0
                   DB 0EFh,'Advantage',0
                   DB 070h,'AMCC',0
                   DB 0F1h,'LeCroy',0
                   DB 0F2h,'Yamaha',0
                   DB 073h,'DM',0
                   DB 0F4h,'NetLogic',0
                   DB 075h,'MIMOS',0
                   DB 076h,'AF',0
                   DB 0F7h,'BFGD',0
                   DB 0F8h,'Epigram',0
                   DB 079h,'Acbel',0
                   DB 07Ah,'Apacer',0
                   DB 0FBh,'Admor',0
                   DB 07Ch,'FOXCONN',0
                   DB 0FDh,'Quadratics',0
                   DB 0FEh,'3COM',0
                   DB 0FFh,'Unknown B2 ',0

MemManufacturerB3  DB 001h,'Camintonn',0
                   DB 002h,'ISOA',0
                   DB 083h,'Agate',0
                   DB 004h,'ADMtek',0
                   DB 085h,'HYPERTEC',0
                   DB 086h,'Adhoc',0
                   DB 007h,'MOSAID',0
                   DB 008h,'Ardent',0
                   DB 089h,'Switchcore',0
                   DB 08Ah,'Cisco Systems',0
                   DB 00Bh,'Allayer',0
                   DB 08Ch,'Wichmann WorkX',0
                   DB 00Dh,'Oasis',0
                   DB 00Eh,'Novanet',0
                   DB 08Fh,'E-M Solutions',0
                   DB 010h,'Power General',0
                   DB 091h,'Advanced Hardware',0
                   DB 092h,'Inova',0
                   DB 013h,'Telocity',0
                   DB 094h,'Delkin',0
                   DB 015h,'Symagery',0
                   DB 016h,'C-Port',0
                   DB 097h,'SiberCore',0
                   DB 098h,'Southland',0
                   DB 019h,'Malleable',0
                   DB 01Ah,'Kendin',0
                   DB 09Bh,'Great Tech',0
                   DB 01Ch,'Sanmina',0
                   DB 09Dh,'HADCO',0
                   DB 09Eh,'Corsair',0
                   DB 01Fh,'Actrans System',0
                   DB 020h,'ALPHA Tech',0
                   DB 0A1h,'Cygnal',0
                   DB 0A2h,'Artesyn Tech',0
                   DB 023h,'Align',0
                   DB 0A4h,'Peregrine',0
                   DB 025h,'Chameleon',0
                   DB 026h,'Aplus Flash',0
                   DB 0A7h,'MIPS Tech',0
                   DB 0A8h,'Chrysalis',0
                   DB 029h,'ADTEC',0
                   DB 02Ah,'Kentron',0
                   DB 0ABh,'Win Tech',0
                   DB 02Ch,'ASIC Designs',0
                   DB 0ADh,'Extreme Packet',0
                   DB 0AEh,'RF Micro',0
                   DB 02Fh,'Siemens',0
                   DB 0B0h,'Sarnoff',0
                   DB 031h,'Itautec Philco',0
                   DB 032h,'Radiata',0
                   DB 0B3h,'AVEX',0
                   DB 034h,'Legend',0
                   DB 0B5h,'SpecTek',0
                   DB 0B6h,'Hi/fn',0
                   DB 037h,'Enikia',0
                   DB 038h,'SwitchOn',0
                   DB 0B9h,'AANetcom',0
                   DB 0BAh,'Micro Memory Bank',0
                   DB 03Bh,'ESS Tech',0
                   DB 0BCh,'Virata',0
                   DB 03Dh,'Excess Bandwidth',0
                   DB 03Eh,'West bay Semicon',0
                   DB 0BFh,'DSP Group',0
                   DB 040h,'Newport',0
                   DB 0C1h,'Chip2Chip',0
                   DB 0C2h,'Phobos',0
                   DB 043h,'Intellitech',0
                   DB 0C4h,'Nordic VLSI ASA',0
                   DB 045h,'Ishoni Networks',0
                   DB 046h,'Silicon Spice',0
                   DB 0C7h,'Alchemy Semicon',0
                   DB 0C8h,'Agilent Tech',0
                   DB 049h,'Centillium',0
                   DB 04Ah,'W.L. Gore',0
                   DB 0CBh,'HanBit',0
                   DB 04Ch,'GlobeSpan',0
                   DB 0CDh,'Element',0
                   DB 0CEh,'Pycon',0
                   DB 04Fh,'Saifun Semicon',0
                   DB 0D0h,'Sibyte',0
                   DB 051h,'MetaLink Tech',0
                   DB 052h,'Feiya Tech',0
                   DB 0D3h,'I & C Tech',0
                   DB 054h,'Shikatronics',0
                   DB 0D5h,'Elektrobit',0
                   DB 0D6h,'Megic',0
                   DB 057h,'Com-Tier',0
                   DB 058h,'MMS',0
                   DB 0D9h,'Hyperchip',0
                   DB 0DAh,'Gemstone',0
                   DB 05Bh,'Anadyne',0
                   DB 0DCh,'3ParData',0
                   DB 05Bh,'Mellanox',0
                   DB 05Eh,'Tenx Tech',0
                   DB 0DFh,'Helix AG',0
                   DB 0E0h,'Domosys',0
                   DB 061h,'Skyup Tech',0
                   DB 062h,'HiNT Corp',0
                   DB 0E3h,'Chiaro',0
                   DB 064h,'MCI',0
                   DB 0E5h,'Exbit Tech',0
                   DB 0E6h,'ITE',0
                   DB 067h,'AVED Memory',0
                   DB 068h,'Legerity',0
                   DB 0E9h,'Jasmine',0
                   DB 0EAh,'Caspian',0
                   DB 06Bh,'nCUBE',0
                   DB 0ECh,'Silicon Access',0
                   DB 06Dh,'FDK Corp',0
                   DB 06Eh,'HBA',0
                   DB 0EFh,'MultiLink',0
                   DB 070h,'BRECIS',0
                   DB 0F1h,'WWP',0
                   DB 0F2h,'APW',0
                   DB 073h,'Chicory Systems',0
                   DB 0F4h,'Xstream Logic',0
                   DB 075h,'Fast-Chip',0
                   DB 076h,'Zucotto',0
                   DB 0F7h,'Realchip',0
                   DB 0F8h,'Galaxy Power',0
                   DB 079h,'eSilicon',0
                   DB 07Ah,'Morphics Tech',0
                   DB 0FBh,'Accelerant',0
                   DB 07Ch,'Silicon Wave',0
                   DB 0FDh,'SandCraft',0
                   DB 0FEh,'Elpida',0
                   DB 0FFh,'Unknown B3 ',0

MemManufacturerB4  DB 001h,'Solectron',0
                   DB 002h,'Optosys Tech',0
                   DB 083h,'Melco',0
                   DB 004h,'TriMedia Tech',0
                   DB 085h,'Cyan Tech',0
                   DB 086h,'Global Locate',0
                   DB 007h,'Optillion',0
                   DB 008h,'Terago',0
                   DB 089h,'Ikanos',0
                   DB 08Ah,'Princeton Tech',0
                   DB 00Bh,'Nanya Tech',0
                   DB 08Ch,'Elite Flash',0
                   DB 00Dh,'Mysticom',0
                   DB 00Eh,'LightSand',0
                   DB 08Fh,'ATI Tech',0
                   DB 010h,'Agere Systems',0
                   DB 091h,'NeoMagic',0
                   DB 092h,'AuroraNetics',0
                   DB 013h,'Golden Empire',0
                   DB 094h,'Muskin',0
                   DB 015h,'Tioga Tech',0
                   DB 016h,'Netlist',0
                   DB 097h,'TeraLogic',0
                   DB 098h,'Cicada Semicon',0
                   DB 019h,'Centon',0
                   DB 01Ah,'Tyco',0
                   DB 09Bh,'Magis Works',0
                   DB 01Ch,'Zettacom',0
                   DB 09Dh,'Cogency Semicon',0
                   DB 09Eh,'Chipcon AS',0
                   DB 01Fh,'Aspex Tech',0
                   DB 020h,'F5 Networks',0
                   DB 0A1h,'PSS',0
                   DB 0A2h,'ChipWrights',0
                   DB 023h,'Acorn Networks',0
                   DB 0A4h,'Quicklogic',0
                   DB 025h,'Kingmax Semicon',0
                   DB 026h,'BOPS',0
                   DB 0A7h,'Flasys',0
                   DB 0A8h,'BitBlitz',0
                   DB 029h,'eMemory Tech',0
                   DB 02Ah,'Procket Networks',0
                   DB 0ABh,'Purple Ray',0
                   DB 02Ch,'Trebia Networks',0
                   DB 0ADh,'Delta Electronics',0
                   DB 0AEh,'Onex Communications',0
                   DB 02Fh,'Ample Communications',0
                   DB 0B0h,'Memory Experts Intl',0
                   DB 031h,'Astute Networks',0
                   DB 032h,'Azanda Network',0
                   DB 0B3h,'Dibcom',0
                   DB 034h,'Tekmos',0
                   DB 0B5h,'API NetWorks',0
                   DB 0B6h,'Bay Microsystems',0
                   DB 037h,'Firecron Ltd',0
                   DB 038h,'Resonext',0
                   DB 0B9h,'Tachys Tech',0
                   DB 0BAh,'Equator Tech',0
                   DB 03Bh,'Concept Computer',0
                   DB 0BCh,'SILCOM',0
                   DB 03Dh,'3Dlabs',0
                   DB 06Eh,'c''t Magazine',0
                   DB 0BFh,'Sanera Systems',0
                   DB 040h,'Silicon Packets',0
                   DB 0C1h,'Viasystems Group',0
                   DB 0C2h,'Simtek',0
                   DB 043h,'Semicon Devices',0
                   DB 0C4h,'Satron Handelsges',0
                   DB 045h,'Improv Systems',0
                   DB 046h,'INDUSYS GmbH',0
                   DB 0C7h,'Corrent',0
                   DB 0C8h,'Infrant Tech',0
                   DB 0FFh,'Unknown B4 ',0
MemManufacturerB5  DB 0FFh,'Unknown B5 ',0
MemManufacturerB6  DB 0FFh,'Unknown B6 ',0
MemManufacturerB7  DB 0FFh,'Unknown B7 ',0
MemManufacturerB8  DB 0FFh,'Unknown B8 ',0

                   ALIGN 16
font6x8   DB 000h,000h,000h,000h,000h,000h,000h,000h,038h,044h,06Ch,044h,054h,044h,038h,000h
    DB       038h,07Ch,054h,07Ch,044h,07Ch,038h,000h,000h,028h,07Ch,07Ch,07Ch,038h,010h,000h
    DB       000h,010h,038h,07Ch,07Ch,038h,010h,000h,010h,038h,038h,010h,07Ch,07Ch,010h,000h
    DB       000h,010h,038h,07Ch,07Ch,010h,038h,000h,000h,000h,000h,030h,030h,000h,000h,000h
    DB       0FCh,0FCh,0FCh,0CCh,0CCh,0FCh,0FCh,0FCh,000h,000h,078h,048h,048h,078h,000h,000h
    DB       0FCh,0FCh,084h,0B4h,0B4h,084h,0FCh,0FCh,000h,01Ch,00Ch,034h,048h,048h,030h,000h
    DB       038h,044h,044h,038h,010h,038h,010h,000h,010h,018h,014h,010h,030h,070h,060h,000h
    DB       00Ch,034h,02Ch,034h,02Ch,06Ch,060h,000h,000h,054h,038h,06Ch,038h,054h,000h,000h
    DB       020h,030h,038h,03Ch,038h,030h,020h,000h,008h,018h,038h,078h,038h,018h,008h,000h
    DB       010h,038h,07Ch,010h,07Ch,038h,010h,000h,028h,028h,028h,028h,028h,000h,028h,000h
    DB       03Ch,054h,054h,034h,014h,014h,014h,000h,038h,044h,030h,028h,018h,044h,038h,000h
    DB       000h,000h,000h,000h,000h,078h,078h,000h,010h,038h,07Ch,010h,07Ch,038h,010h,038h
    DB       010h,038h,07Ch,010h,010h,010h,010h,000h,010h,010h,010h,010h,07Ch,038h,010h,000h
    DB       000h,010h,018h,07Ch,018h,010h,000h,000h,000h,010h,030h,07Ch,030h,010h,000h,000h
    DB       000h,000h,000h,040h,040h,040h,07Ch,000h,000h,028h,028h,07Ch,028h,028h,000h,000h
    DB       010h,010h,038h,038h,07Ch,07Ch,000h,000h,07Ch,07Ch,038h,038h,010h,010h,000h,000h
    DB       000h,000h,000h,000h,000h,000h,000h,000h,010h,038h,038h,010h,010h,000h,010h,000h
    DB       06Ch,06Ch,048h,000h,000h,000h,000h,000h,000h,028h,07Ch,028h,028h,07Ch,028h,000h
    DB       020h,038h,040h,030h,008h,070h,010h,000h,064h,064h,008h,010h,020h,04Ch,04Ch,000h
    DB       020h,050h,050h,020h,054h,048h,034h,000h,030h,030h,020h,000h,000h,000h,000h,000h
    DB       010h,020h,020h,020h,020h,020h,010h,000h,020h,010h,010h,010h,010h,010h,020h,000h
    DB       000h,028h,038h,07Ch,038h,028h,000h,000h,000h,010h,010h,07Ch,010h,010h,000h,000h
    DB       000h,000h,000h,000h,000h,030h,030h,020h,000h,000h,000h,07Ch,000h,000h,000h,000h
    DB       000h,000h,000h,000h,000h,030h,030h,000h,000h,004h,008h,010h,020h,040h,000h,000h
    DB       038h,044h,04Ch,054h,064h,044h,038h,000h,010h,030h,010h,010h,010h,010h,038h,000h
    DB       038h,044h,004h,018h,020h,040h,07Ch,000h,038h,044h,004h,038h,004h,044h,038h,000h
    DB       008h,018h,028h,048h,07Ch,008h,008h,000h,07Ch,040h,040h,078h,004h,044h,038h,000h
    DB       018h,020h,040h,078h,044h,044h,038h,000h,07Ch,004h,008h,010h,020h,020h,020h,000h
    DB       038h,044h,044h,038h,044h,044h,038h,000h,038h,044h,044h,03Ch,004h,008h,030h,000h
    DB       000h,000h,030h,030h,000h,030h,030h,000h,000h,000h,030h,030h,000h,030h,030h,020h
    DB       008h,010h,020h,040h,020h,010h,008h,000h,000h,000h,07Ch,000h,000h,07Ch,000h,000h
    DB       020h,010h,008h,004h,008h,010h,020h,000h,038h,044h,004h,018h,010h,000h,010h,000h
    DB       038h,044h,05Ch,054h,05Ch,040h,038h,000h,038h,044h,044h,044h,07Ch,044h,044h,000h
    DB       078h,044h,044h,078h,044h,044h,078h,000h,038h,044h,040h,040h,040h,044h,038h,000h
    DB       078h,044h,044h,044h,044h,044h,078h,000h,07Ch,040h,040h,078h,040h,040h,07Ch,000h
    DB       07Ch,040h,040h,078h,040h,040h,040h,000h,038h,044h,040h,05Ch,044h,044h,03Ch,000h
    DB       044h,044h,044h,07Ch,044h,044h,044h,000h,038h,010h,010h,010h,010h,010h,038h,000h
    DB       004h,004h,004h,004h,044h,044h,038h,000h,044h,048h,050h,060h,050h,048h,044h,000h
    DB       040h,040h,040h,040h,040h,040h,07Ch,000h,044h,06Ch,054h,044h,044h,044h,044h,000h
    DB       044h,064h,054h,04Ch,044h,044h,044h,000h,038h,044h,044h,044h,044h,044h,038h,000h
    DB       078h,044h,044h,078h,040h,040h,040h,000h,038h,044h,044h,044h,054h,048h,034h,000h
    DB       078h,044h,044h,078h,048h,044h,044h,000h,038h,044h,040h,038h,004h,044h,038h,000h
    DB       07Ch,010h,010h,010h,010h,010h,010h,000h,044h,044h,044h,044h,044h,044h,038h,000h
    DB       044h,044h,044h,044h,044h,028h,010h,000h,044h,044h,054h,054h,054h,054h,028h,000h
    DB       044h,044h,028h,010h,028h,044h,044h,000h,044h,044h,044h,028h,010h,010h,010h,000h
    DB       078h,008h,010h,020h,040h,040h,078h,000h,038h,020h,020h,020h,020h,020h,038h,000h
    DB       000h,040h,020h,010h,008h,004h,000h,000h,038h,008h,008h,008h,008h,008h,038h,000h
    DB       010h,028h,044h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0FCh
    DB       030h,030h,010h,000h,000h,000h,000h,000h,000h,000h,038h,004h,03Ch,044h,03Ch,000h
    DB       040h,040h,078h,044h,044h,044h,078h,000h,000h,000h,038h,044h,040h,044h,038h,000h
    DB       004h,004h,03Ch,044h,044h,044h,03Ch,000h,000h,000h,038h,044h,078h,040h,038h,000h
    DB       018h,020h,020h,078h,020h,020h,020h,000h,000h,000h,03Ch,044h,044h,03Ch,004h,038h
    DB       040h,040h,070h,048h,048h,048h,048h,000h,010h,000h,010h,010h,010h,010h,018h,000h
    DB       008h,000h,018h,008h,008h,008h,048h,030h,040h,040h,048h,050h,060h,050h,048h,000h
    DB       010h,010h,010h,010h,010h,010h,018h,000h,000h,000h,068h,054h,054h,044h,044h,000h
    DB       000h,000h,070h,048h,048h,048h,048h,000h,000h,000h,038h,044h,044h,044h,038h,000h
    DB       000h,000h,078h,044h,044h,044h,078h,040h,000h,000h,03Ch,044h,044h,044h,03Ch,004h
    DB       000h,000h,058h,024h,020h,020h,070h,000h,000h,000h,038h,040h,038h,004h,038h,000h
    DB       000h,020h,078h,020h,020h,028h,010h,000h,000h,000h,048h,048h,048h,058h,028h,000h
    DB       000h,000h,044h,044h,044h,028h,010h,000h,000h,000h,044h,044h,054h,07Ch,028h,000h
    DB       000h,000h,048h,048h,030h,048h,048h,000h,000h,000h,048h,048h,048h,038h,010h,060h
    DB       000h,000h,078h,008h,030h,040h,078h,000h,018h,020h,020h,060h,020h,020h,018h,000h
    DB       010h,010h,010h,000h,010h,010h,010h,000h,030h,008h,008h,00Ch,008h,008h,030h,000h
    DB       028h,050h,000h,000h,000h,000h,000h,000h,010h,038h,06Ch,044h,044h,07Ch,000h,000h
    DB       038h,044h,044h,044h,07Ch,044h,044h,000h,07Ch,040h,040h,078h,044h,044h,078h,000h
    DB       078h,044h,044h,078h,044h,044h,078h,000h,07Ch,040h,040h,040h,040h,040h,040h,000h
    DB       038h,048h,048h,048h,048h,048h,0FCh,084h,07Ch,040h,040h,078h,040h,040h,07Ch,000h
    DB       054h,054h,054h,038h,054h,054h,054h,000h,070h,088h,008h,070h,008h,088h,070h,000h
    DB       044h,044h,044h,04Ch,054h,064h,044h,000h,038h,044h,044h,04Ch,054h,064h,044h,000h
    DB       044h,048h,050h,060h,050h,048h,044h,000h,01Ch,024h,024h,024h,024h,024h,064h,000h
    DB       044h,06Ch,054h,044h,044h,044h,044h,000h,044h,044h,044h,07Ch,044h,044h,044h,000h
    DB       038h,044h,044h,044h,044h,044h,038h,000h,07Ch,044h,044h,044h,044h,044h,044h,000h
    DB       078h,044h,044h,078h,040h,040h,040h,000h,038h,044h,040h,040h,040h,044h,038h,000h
    DB       07Ch,010h,010h,010h,010h,010h,010h,000h,044h,044h,044h,03Ch,004h,044h,038h,000h
    DB       038h,054h,054h,054h,038h,010h,010h,000h,044h,044h,028h,010h,028h,044h,044h,000h
    DB       048h,048h,048h,048h,048h,048h,07Ch,004h,044h,044h,044h,03Ch,004h,004h,004h,000h
    DB       054h,054h,054h,054h,054h,054h,07Ch,000h,054h,054h,054h,054h,054h,054h,07Ch,004h
    DB       0E0h,0A0h,020h,038h,024h,024h,038h,000h,044h,044h,044h,074h,04Ch,04Ch,074h,000h
    DB       040h,040h,040h,078h,044h,044h,078h,000h,038h,044h,004h,01Ch,004h,044h,038h,000h
    DB       048h,054h,054h,074h,054h,054h,048h,000h,03Ch,044h,044h,03Ch,024h,044h,044h,000h
    DB       000h,000h,038h,004h,03Ch,044h,03Ch,000h,004h,038h,040h,078h,044h,044h,038h,000h
    DB       000h,000h,078h,044h,078h,044h,078h,000h,000h,000h,078h,048h,040h,040h,040h,000h
    DB       000h,000h,038h,048h,048h,048h,0FCh,084h,000h,000h,038h,044h,078h,040h,038h,000h
    DB       000h,000h,054h,054h,038h,054h,054h,000h,000h,000h,038h,044h,018h,044h,038h,000h
    DB       000h,000h,044h,04Ch,054h,064h,044h,000h,000h,018h,044h,04Ch,054h,064h,044h,000h
    DB       000h,000h,048h,050h,060h,050h,048h,000h,000h,000h,038h,048h,048h,048h,088h,000h
    DB       000h,000h,044h,06Ch,054h,044h,044h,000h,000h,000h,044h,044h,07Ch,044h,044h,000h
    DB       000h,000h,038h,044h,044h,044h,038h,000h,000h,000h,07Ch,044h,044h,044h,044h,000h
    DB       054h,000h,0A8h,000h,054h,000h,0A8h,000h,054h,0A8h,054h,0A8h,054h,0A8h,054h,0A8h
    DB       0A8h,0FCh,054h,0FCh,0A8h,0FCh,054h,0FCh,010h,010h,010h,010h,010h,010h,010h,010h
    DB       010h,010h,010h,0F0h,010h,010h,010h,010h,010h,0F0h,010h,0F0h,010h,010h,010h,010h
    DB       050h,050h,050h,0D0h,050h,050h,050h,050h,000h,000h,000h,0F0h,050h,050h,050h,050h
    DB       000h,0F0h,010h,0F0h,010h,010h,010h,010h,050h,0D0h,010h,0D0h,050h,050h,050h,050h
    DB       050h,050h,050h,050h,050h,050h,050h,050h,000h,0F0h,010h,0D0h,050h,050h,050h,050h
    DB       050h,0D0h,010h,0F0h,000h,000h,000h,000h,050h,050h,050h,0F0h,000h,000h,000h,000h
    DB       010h,0F0h,010h,0F0h,000h,000h,000h,000h,000h,000h,000h,0F0h,010h,010h,010h,010h
    DB       010h,010h,010h,01Ch,000h,000h,000h,000h,010h,010h,010h,0FCh,000h,000h,000h,000h
    DB       000h,000h,000h,0FCh,010h,010h,010h,010h,010h,010h,010h,01Ch,010h,010h,010h,010h
    DB       000h,000h,000h,0FCh,000h,000h,000h,000h,010h,010h,010h,0FCh,010h,010h,010h,010h
    DB       010h,01Ch,010h,01Ch,010h,010h,010h,010h,050h,050h,050h,05Ch,050h,050h,050h,050h
    DB       050h,05Ch,040h,07Ch,000h,000h,000h,000h,000h,07Ch,040h,05Ch,050h,050h,050h,050h
    DB       050h,0DCh,000h,0FCh,000h,000h,000h,000h,000h,0FCh,000h,0DCh,050h,050h,050h,050h
    DB       050h,05Ch,040h,05Ch,050h,050h,050h,050h,000h,0FCh,000h,0FCh,000h,000h,000h,000h
    DB       050h,0DCh,000h,0DCh,050h,050h,050h,050h,010h,0FCh,000h,0FCh,000h,000h,000h,000h
    DB       050h,050h,050h,0FCh,000h,000h,000h,000h,000h,0FCh,000h,0FCh,010h,010h,010h,010h
    DB       000h,000h,000h,0FCh,050h,050h,050h,050h,050h,050h,050h,07Ch,000h,000h,000h,000h
    DB       010h,01Ch,010h,01Ch,000h,000h,000h,000h,000h,01Ch,010h,01Ch,010h,010h,010h,010h
    DB       000h,000h,000h,07Ch,050h,050h,050h,050h,050h,050h,050h,0FCh,050h,050h,050h,050h
    DB       010h,0FCh,010h,0FCh,010h,010h,010h,010h,010h,010h,010h,0F0h,000h,000h,000h,000h
    DB       000h,000h,000h,01Ch,010h,010h,010h,010h,0FCh,0FCh,0FCh,0FCh,0FCh,0FCh,0FCh,0FCh
    DB       000h,000h,000h,000h,0FCh,0FCh,0FCh,0FCh,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h
    DB       01Ch,01Ch,01Ch,01Ch,01Ch,01Ch,01Ch,01Ch,0FCh,0FCh,0FCh,0FCh,000h,000h,000h,000h
    DB       000h,000h,078h,044h,044h,044h,078h,040h,000h,000h,038h,044h,040h,044h,038h,000h
    DB       000h,000h,07Ch,010h,010h,010h,010h,000h,000h,000h,048h,048h,048h,038h,010h,060h
    DB       000h,000h,038h,054h,054h,038h,010h,000h,000h,000h,048h,048h,030h,048h,048h,000h
    DB       000h,000h,048h,048h,048h,048h,07Ch,004h,000h,000h,044h,044h,03Ch,004h,004h,000h
    DB       000h,000h,054h,054h,054h,054h,07Ch,000h,000h,000h,054h,054h,054h,054h,07Ch,004h
    DB       000h,000h,0E0h,0A0h,038h,024h,038h,000h,000h,000h,044h,044h,074h,04Ch,074h,000h
    DB       000h,000h,040h,040h,078h,044h,078h,000h,000h,000h,038h,044h,01Ch,044h,038h,000h
    DB       000h,000h,048h,054h,074h,054h,048h,000h,000h,000h,03Ch,044h,03Ch,024h,044h,000h
    DB       028h,07Ch,040h,078h,040h,040h,07Ch,000h,028h,000h,038h,044h,078h,040h,038h,000h
    DB       038h,044h,040h,070h,040h,044h,038h,000h,000h,000h,038h,044h,070h,044h,038h,000h
    DB       044h,010h,010h,010h,010h,010h,038h,000h,028h,000h,010h,010h,010h,010h,018h,000h
    DB       054h,054h,044h,03Ch,004h,044h,038h,000h,048h,030h,048h,048h,048h,038h,010h,060h
    DB       030h,048h,048h,030h,000h,000h,000h,000h,000h,000h,000h,030h,030h,000h,000h,000h
    DB       000h,000h,72,72,72,72,116,64,000h,01Ch,010h,010h,050h,050h,020h,000h
    DB       44,72,76,40,0,0,0,0,32,144,16,160,0,0,0,0
    DB       120,44,40,40,0,0,0,0,128,128,128,128,0,0,0,0
Ypos6x8            DB 0
Xpos6x8            DB 0
Xpos6x8Space       DW 0
Prizn              DB 0
color              DB 7

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
DeCompressedMes80   DB ' 256',0
DeCompressedMes81   DB ' 128',0

          ENDS Dseg

          SEGMENT Cseg Page Public 'CODE'
          ASSUME cs:Cseg

          PUBLIC AscToBin

          ALIGN 16
PROC AscToBin
          push  bx
          push  cx
          push  dx
          push  si
          call  StrUpper
          call  StrLength
          xor   ax,ax
          jcxz  short @@99
          mov   si,di
          add   si,cx
          cmp   [byte di],'-'
          pushf
          jne   short @@10
          inc   di
@@10:
          call  ChToBase
          call  AscToNum
          rcl   bx,1
          popf
          jne   short @@20
          neg  ax
          dec  di
@@20:
          rcr   bx,1
@@99:
          pop   si
          pop   dx
          pop   cx
          pop   bx
          ret
ENDP AscToBin

          PUBLIC  StrUpper

          ALIGN 16
PROC StrUpper ; Преобразовать символы строки в прописные
          push  ax
          push  cx
          push  di
          push  si
          call  StrLength
          jcxz  short @@99
          cld
          mov   si,di
@@10:     lodsb
          cmp   al,'a'
          jb    short @@20
          cmp   al,'z'
          ja    short @@20
          sub   al,20h
@@20:     stosb
          loop  short @@10
@@99:     pop   si
          pop  di
          pop   cx
          pop   ax
          ret
ENDP StrUpper

          PUBLIC  StrLength

          ALIGN 16
PROC StrLength ; Подсчитать в строке кол-во ненулевых символов (длинна строки)
          push   ax
          push   di

          xor   al,al
          mov   cx,0FFFFh
          cld
          repnz scasb
          not   cx
          dec   cx

          pop   di
          pop   ax
          ret
ENDP StrLength

          PUBLIC HexDigit

          ALIGN 16
PROC HexDigit
              cmp       dl,10
              jb        short @@10
              add       dl,'A'-10
              ret
          ALIGN 16

@@10:         or        dl,'0'
              ret
ENDP HexDigit

          PUBLIC AscToNum

              ALIGN 16
PROC AscToNum
          mov   cx,1
@@10:     cmp   si,di
          je    short @@99
          dec   si
          mov   dl,[byte si]
          call  ValCh
          jc    short @@99
          push  cx
          xchg  ax,cx
          mul   dx
          add   cx,ax
          pop   ax
          mul   bx
          xchg  ax,cx
          jmp   short @@10
@@99:
          ret
ENDP AscToNum

          PUBLIC ValCh

           ALIGN 16
PROC ValCh
           cmp  dl,'9'
           jbe  short @@10
           sub  dl,7
@@10:      Sub  dl,'0'
           test dl,0f0h
           jnz  short @@99

           xor  dh,dh
           cmp  dx,bx
@@99:      cmc
           ret
ENDP ValCh

          PUBLIC NumToASCII

          ALIGN 16
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

          PUBLIC ChToBase

          ALIGN 16
PROC ChToBase
          mov   dl,[byte si-1]
          mov   bx,16
          cmp   dl,'H'
          je    short @@10
          mov   bx,2
          cmp   dl,'B'
          je    short @@10
          mov   bx,10
          cmp   dl,'D'
          jne   short @@20
@@10:     dec   si
@@20:
          ret
ENDP ChToBase

          PUBLIC BinToAscHex,BinToAscDecH,BinToAscDec,BinToAscDec2

          ALIGN 16
PROC BinToAscHex ; в шеснадцатиричные ASCII строки
          push   ax
          push   bx
          mov    bx,16
          call   NumToASCII
          pop    bx
          pop    ax
          ret
ENDP BinToAscHex

          ALIGN 16
PROC BinToAscDec ; в десятичные ASCII строки
          push   ax
          push   bx
          mov    bx,10
          call   NumToASCII
          pop    bx
          pop    ax
          ret
ENDP BinToAscDec

          ALIGN 16
PROC BinToAscDecH
          push     eax
          push     ebx
          push     edx
          push     cx
          push     si
          push     di
          cmp      cx,4
          jae      short NidedHighBinToAscDec
          call     BinToAscDec
          jmp      short ExitFromBinToAscDec
NidedHighBinToAscDec:
          mov      ebx,10000
          xor      edx,edx
          div      ebx
          push     ax
          sub      cx,4
          push     cx
          push     di
          add      di,cx
          mov      cx,4
          mov      ax,dx
          call     BinToAscDec
          mov      dh,[byte ds:di]
          mov      [byte ds:di],0
          mov      si,di
          pop      di
          pop      cx
          pop      ax
          call     BinToAscDec
          mov      di,si
          mov      [byte ds:di],dh
ExitFromBinToAscDec:
          pop      di
          pop      si
          pop      cx
          pop      edx
          pop      ebx
          pop      eax
          ret
ENDP BinToAscDecH

ALIGN 16
PROC BinToAscDec2
          push    eax
          push    si
          push    di
          inc     di
          inc     cx
          inc     cx
          call    BinToAscDecH
          dec     cx
          dec     cx
          mov     si,di
          dec     di
          push    di
          cld
          rep movsb
          mov     [byte ds:di],'.'
          pop     di
          call    NZInMes
          pop     di
          pop     si
          pop     eax
          ret
ENDP BinToAscDec2

        PUBLIC KeyWaiting,GetCh

          ALIGN 16
PROC keywaiting
        push    ax
        mov     ah,1
        int     16h
        pop     ax
        ret
ENDP keywaiting

PROC GetCh

        xor     ah,ah
        int     16h
        or      al,al
        jnz     short @@10
        xchg    ah,al
        add     al,32
        jmp     short @@20
@@10:
        xor     ah,ah
        cmp     al,32
        jb      short @@20
        inc     ah
@@20:
        or      ah,ah
        ret
ENDP getch


          EXTRN ErrorDiv:proc

          PUBLIC LongTimerL
          PUBLIC StartNewTimer,StopNewTimer
          PUBLIC SetNewInterrupt,RestoreInterrupt
          PUBLIC SetTimerInterrupt,RestoreTimerInterrupt

PROC SetNewInterrupt
          push    ds
          push    es
          mov     ax,3500h
          int     21h
          mov     [word cs:DivSeg],es
          mov     [word cs:DivOfs],bx
          push    cs
          pop     ds
          mov     ax,2500h
          mov     dx,offset ErrorDiv
          int     21h
          pop     es
          pop     ds

PROC SetTimerInterrupt
          pushf
          push    ax
          push    bx
          push    dx
          push    ds
          push    es
          mov     ax,3508h
          int     21h
;          mov     [word cs:TimerOfs],bx
;          mov     [word cs:TimerSeg],es

          mov     [word cs:TimerInt],bx
          mov     [word cs:TimerInt+2],es

          mov     ax,2508h
          push    cs
          pop     ds
          mov     dx,offset CounterClock
          int     21h
          pop     es
          pop     ds
          pop     dx
          pop     bx
          pop     ax
          popf
          ret
TimerInt  DD ?
;TimerOfs  DW ?
;TimerSeg  DW ?
DivOfs    DW ?
DivSeg    DW ?
ENDP SetTimerInterrupt
ENDP SetNewInterrupt

PROC RestoreInterrupt
          push    ds
          mov     ax,2500h
          mov     dx,[word cs:DivOfs]
          mov     ds,[word cs:DivSeg]
          int     21h
          pop     ds
PROC RestoreTimerInterrupt
          pushf
          push    ax
          push    dx
          push    ds
          mov     ax,2508h
;          mov     dx,[word cs:TimerOfs]
;          mov     ds,[word cs:TimerSeg]

          mov     dx,[word cs:TimerInt]
          mov     ds,[word cs:TimerInt+2]


          int     21h
          pop     ds
          pop     dx
          pop     ax
          popf
          ret
ENDP RestoreTimerInterrupt
ENDP RestoreInterrupt

          ALIGN 16
PROC CounterClock
          pushf
          call    [dword cs:TimerInt]
          inc     [word cs:LongTimerL]
;          push    ax
;          mov     al,20h
;          out     20h,al
;          pop     ax
          iret
          ALIGN 16
LongTimerL DW ?
ENDP CounterClock

          ALIGN 16
PROC StartNewTimer
          push     ax
          cmp      [MultiTask],1
          jnz      short NotMultytaskSystem
          hlt
NotMultytaskSystem:
          in      al,61h
          and     al,0FCh
          out     61h,al
          mov     al,36h
          out     43h,al
          xor     al,al
          out     40h,al
          jmp     $+2
          out     40h,al
          mov     al,0B4h
          out     43h,al
          xor     al,al
          out     42h,al
          jmp     $+2
          out     42h,al
          in      al,61h
          or      al,01
          out     61h,al
          xor     ax,ax
          mov     [word cs:LongTimerL],ax
          pop     ax
          ret
ENDP StartNewTimer

          ALIGN 16
PROC StopNewTimer
          cli
          mov     ax,[word cs:LongTimerL]
          push    ax
          in     al,061h
          and    al,0FCh
          out    061h,al

          in      al,42h
          xchg    ah,al
          in      al,42h
          xchg    ah,al
          neg     ax
          push    ax
          sti
          pop      eax
          ret
ENDP StopNewTimer


           PUBLIC InitXMSAccess
masm

InitXMSAccess PROC

           push   ds
           push   es
           push   fs
           push   gs

           smsw   ax
           shr    ax,01h
           jc     short ErrorVM  ;Exit if we're in VM
           call   Set4GB
           call   EnableA20
;          jc     ErrorA20 ;Cannot enable A20
;ErrorA20:
ErrorVM:

           pop gs
           pop fs
           pop es
           pop ds

           ret

InitXMSAccess ENDP

GDT        label qword
           dw    nGDTs*8-1,?,?,?
g4GB       dd    0000FFFFh,008F9300h
nGDTs    = ($-GDT)/8
Set4GB:
           xor    eax,eax
           mov    ax,cs
           shl    eax,04h
           add    eax,large offset GDT
           mov    dword ptr GDT+2,eax
           pushf
           cli
           mov    eax,cr0
           inc    ax
           mov    cr0,eax
           jmp    $+2
           lgdt   fword ptr GDT

           mov    cx,g4GB-GDT
           mov    es,cx
           mov    ds,cx
           mov    fs,cx
           mov    gs,cx
           dec    ax
           mov    cr0,eax
           jmp    $+2
           popf
           retn

;In: GS    0 and 4GB limit
;    IF=0
IsA20Disabled:
           mov    ebx,00100000h    ;BX=0, EBX=1MB
           mov    al,gs:[bx]
           mov    byte ptr gs:[bx],55h
           cmp    byte ptr gs:[ebx],55h
           jne    short IA20DRetn
           mov    byte ptr gs:[bx],0AAh
           cmp    byte ptr gs:[ebx],0AAh
IA20DRetn:
           mov    gs:[bx],al
           retn

EnableA20:
           pushf
           cli
           call    IsA20Disabled
           jne     short EA20Clc
           call    WaitKBInputEmpty
           jnz     short EA20Stc
           mov     al,0D1h
           out     64h,al
           call    WaitKBInputEmpty
           jnz     short EA20Stc
           mov     al,0DFh
           out     60h,al
           call    WaitKBInputEmpty
           jnz     short EA20Stc
           mov     al,0FFh
           out     64h,al
           call    WaitKBInputEmpty
           jnz     short EA20Stc
           xor     cx,cx
           call    IsA20Disabled
           loope   $-3
           loope   short EA20Stc

EA20Clc:
           popf
           clc
           retn
EA20Stc:
           popf
           stc
           retn

WaitKBInputEmpty:
           xor    cx,cx
WKBILoop:
           in    al,21h
           in    al,64h
           and   al,02h
           loopnz short WKBILoop
           retn
ideal
          PUBLIC Rnd, SetRnd

          ALIGN 16
PROC Rnd  ; Вход EAX - Диапозон генерации. Выход EAX - случайное число
          or       eax,eax
          jz       short NotGeneratedRandomNum
          push     esi
          push     ebx
          push     edx

          mov      esi,eax

          mov      ebx,eax
          sub      eax,eax
          mov      edx,eax
          dec      eax
          div      ebx

          mov      ebx,eax
RndNumIsTheBig:
          mov      eax,[dword cs:RndNum0]
          mov      edx,[dword cs:RndNum2]
          xor      eax,edx
          add      [dword cs:RndNum0],eax
          mov      edx,[dword cs:RndNum1]
          xor      eax,edx
          add      [dword cs:RndNum1],eax
          mov      edx,[dword cs:RndNum2]
          xor      eax,edx
          add      [dword cs:RndNum2],eax
          sub      edx,edx
          div      ebx
          cmp      eax,esi
          ja       short RndNumIsTheBig

          pop      edx
          pop      ebx
          pop      esi
NotGeneratedRandomNum:
          ret
ALIGN 4
RndNum0   DD      0698B1E04h
RndNum1   DD      011B720FEh
RndNum2   DD      01C6A0068h
ENDP Rnd
PROC SetRnd
          mov     [RndNum0],0698B1E04h
          mov     [RndNum1],011B720FEh
          mov     [RndNum2],01C6A0068h
          ret
ENDP SetRnd


          PUBLIC NZInMes

          ALIGN 16
PROC NZInMes
          mov     si,di
          push    si
NewZero:
          cmp     [byte si+1],'0'
          jb      short exitMesNoZero
          cmp     [byte si+1],'9'
          ja      short exitMesNoZero
          cmp     [byte si],'0'
          jnz     short exitMesNoZero
          mov     [byte si],' '
          inc     si
          jmp     short NewZero
exitMesNoZero:
          pop     si
          ret
ENDP NZInMes


          PUBLIC CreatePCXfile

PROC CreatePCXfile
          push     ds
          push     es
          mov      bp,[FileHandle]
          sub      bl,bl
          mov      si, offset Pal
NextPaleteColor:
          push     bx
          mov      ax,1007h
          int      10h
          mov      bl,bh        ;Reg.BL := Reg.BH; { Узнаем pеальный номеp pегистpа палитpы }
          mov      ax,1015h     ;Reg.AH := $10;                { Узнаем 3 составляющие цвета }
          int      10h          ;intr($10, Reg);
          pop      bx
          shl      dh,2
          shl      ch,2
          shl      cl,2
          mov      [byte ds:si],dh
          mov      [byte ds:si+1],ch
          mov      [byte ds:si+2],cl
          add      si,3
          inc      bl
          cmp      bl,16
          jnz      short NextPaleteColor

          mov      ax,[EndProgram]
          mov      es,ax
          sub      di,di
          mov      si,offset Sign
          mov      cx,64
          rep movsw
          mov      ax,0A000h
          mov      ds,ax
          sub      ax,ax
NextCompressedSTR:
          push     ax
          mov      bx,80
          mul      bx
          mov      si,ax
          sub      cl,cl
NextPloskost:
          mov      dx,03CEh
          mov      al,4
          out      dx,al
          mov      dx,03CFh
          mov      al,cl
          out      dx,al
          xor      dl,dl
          mov      ch,80

NextRepitSimvol:
          lodsb
          inc      dl
          dec      ch
          cmp      al,[byte ds:si]
          jnz      short NextSimvolDrugoy
          cmp      dl,63
          jz       short CounterFull
          or       ch,ch
          jz       short NextSimvolDrugoy
          jmp      short NextRepitSimvol

NextSimvolDrugoy:
          cmp      dl,1
          jz       short NotRepitSimvol
CounterFull:
          mov      ah,al
          mov      al,0C0h
          or       al,dl
UnNormalIsxod:
          stosb
          call     SaveBuffer
          jc       short BufferWriteError1
          mov      al,ah
NormalIsxod:
          stosb
          call     SaveBuffer
          jc       short BufferWriteError1
          sub      dl,dl
          or       ch,ch ;Счетчик строки
          jz       short EndOffLine
          jmp      short NextRepitSimvol
NotRepitSimvol:
          cmp      al,0C0h
          jb       short NormalIsxod
          mov      ah,al
          mov      al,0C1h
          jmp      short UnNormalIsxod

EndOffLine:
          sub      si,80
          inc      cl
          cmp      cl,4
          jnz      short NextPloskost

          pop      ax
          inc      ax
          cmp      ax,480
          jnz      NextCompressedSTR
          call     WriteFile
          jc       short BufferWriteError
          mov      bx,bp
          mov      ah,3Eh
          int      21h
          jmp      short BufferWriteError

BufferWriteError1:
          pop      ax
BufferWriteError:
          pop      es
          pop      ds
          ret
ENDP CreatePCXfile

PROC SaveBuffer
          cmp      di,16384
          clc
          jnz      short BufferNoFull
          push     ds
          push     ax
          push     bx
          push     dx
          push     cx
          call     WriteFile
          pop      cx
          pop      dx
          pop      bx
          pop      ax
          pop      ds
          jc       short Write16384BufferError
          sub      di,di
Write16384BufferError:
BufferNoFull:
          ret
ENDP SaveBuffer

                   PUBLIC WriteFile

PROC WriteFile               ; Подпрограмма для чтения или записи файла
          push   es
          pop    ds
          mov    ah,40h      ; Запись
          mov    bx,bp
          mov    cx,di
          push   cx
          sub    dx,dx
          int    21h
          pop    cx
          jc     short ErrorInWriteFile
          cmp    ax,cx
          jz     short NoErrorInWriteFile
ErrorInWriteFile:
          stc
NoErrorInWriteFile:
          ret
ENDP WriteFile

          PUBLIC CursorPos,ColorFrame,Rectangle
          PUBLIC ColorHorLine,ColorVerLine,ColorStr6x8,ColorLine

          ALIGN 16
PROC Rectangle
          push  bx
          push  dx
          jcxz  short NotPutRectangle
          jmp NextHorLine
          ALIGN 16
NextHorLine:
          call ColorHorLine
          inc   bx
          dec   dx
          jnz  short NextHorLine
NotPutRectangle:
          pop   dx
          pop   bx
          ret
ENDP Rectangle
          ALIGN 16

PROC ColorFrame
          call  ColorHorLine
          xchg  cx,dx
          call  ColorVerLine
          add   ax,dx
          call  ColorVerLine
          sub   ax,dx
          xchg  cx,dx
          add   bx,dx
          inc   cx
          call  ColorHorLine
          dec   cx
          sub   bx,dx
          ret
ENDP ColorFrame

          ALIGN 16

PROC ColorLine
                pusha

                push   ax
                push   cx
                push   dx
                pop    di
                pop    si
                pop    cx

                cmp     cx,si
                jle     short loc_1
                xchg    cx,si
                xchg    di,bx
loc_1:
                sub     si,cx

                mov     dx,3CEh
                mov     ax,bp
                xchg    ah,al
                out     dx,ax

                mov     ah,0A0h
                mov     gs,ax
                mov     ax,0F01h
                out     dx,ax

                mov     ax,8008h
                ror     ah,cl
                shr     cx,3
                imul    bp,bx,50h
                add     bp,cx
                mov     cl,50h
                sub     di,bx
                jge     short loc_2
                neg     cx
                neg     di
loc_2:
                cmp     di,si
                jge     short loc_3
                add     al,80h
                xchg    di,si
loc_3:
                mov     bx,di
                mov     [word cs:data_2e],di

                sar     di,1
loc_4:
                out     dx,ax
                or      [gs:bp],al

                sub     di,si

                jl      short loc_5
                cmp     al,0
                jge     short loc_7
                ror     ah,1
                adc     bp,0
                jmp     short loc_6
loc_5:
                add     di,[word cs:data_2e]
                ror     ah,1
loc_7:
                adc     bp,cx
loc_6:
                dec     bx
                jge     short loc_4

                popa
                ret
data_2e DW ?
ENDP ColorLine



          ALIGN 16
proc ColorHorLine
          push      ax
          push      bx
          push      cx
          push      dx
          push      di
          push      bp

          jcxz      short NotNidedPutHorLine

          call      InitPutLine

          push      cx
          mov       cl,al
          and       cx,7
          mov       bp,cx
          shr       ax,3
          mov       di,ax
          mov       ax,80
          mul       bx
          add       di,ax
          mov       bx,8000h
          ror       bx,cl

          pop       dx
          push      dx
          mov       ax,8
          cmp       dx,ax
          jb        short NoNidetBitCorrect
          and       dl,7
          add       cl,dl
          test      cl,al
          jnz        short NoNidetBitCorrect
          or        dl,al
NoNidetBitCorrect:
          mov       cl,dl
          mov       dx,bx
          jcxz      short RoteteOk
Rotate:
          or        bx,dx
          ror       dx,1
          loop      short Rotate
RoteteOk:
          mov       ah,bh
          mov       dx,03CEh
          out       dx,ax
          or        [gs:di],al
          inc       di

          pop       cx
          mov       ax,cx
          shr       cx,3
          jcxz      short NotNidedPutFullByte
          and       ax,7
          add       ax,bp
          test      al,8
          jnz       short CorrectVstavka
          dec       cx
CorrectVstavka:
          jcxz      short NotNidedPutFullByte
          mov       ax,0FF08h
PutFullByte:
          out       dx,ax
          or        [gs:di],al
          inc       di
          loop     short PutFullByte
NotNidedPutFullByte:
          mov       ah,bl
          mov       al,8
          out       dx,ax
          or        [gs:di],al
NotNidedPutHorLine:

          pop       bp
          pop       di
          pop       dx
          pop       cx
          pop       bx
          pop       ax
          ret
ENDP ColorHorLine
          ALIGN 16

PROC InitPutLine
          push      ax
          mov       ax,bp
          shl       ax,8
          mov       dx,03CEh
          out       dx,ax
          mov       ax,0A000h
          mov       gs,ax
          mov       ax,0F01h
          out       dx,ax
          pop       ax
          ret
ENDP InitPutLine

          ALIGN 16
PROC ColorVerLine
          push      ax
          push      bx
          push      cx
          push      dx
          push      di

          jcxz      short NotNidedPutVerLine

          mov       di,ax
          shr       di,3
          push      cx
          mov       cl,al
          mov       ax,8008h
          ror       ah,cl
          pop       cx

          push      ax
          mov       ax,80
          mul       bx
          add       di,ax
          call      InitPutLine
          pop       ax

          mov       bx,50h
@@10:
          out       dx,ax
          or        [gs:di],al
          add       di,bx
          loop      @@10
NotNidedPutVerLine:
          pop       di
          pop       dx
          pop       cx
          pop       bx
          pop       ax
          ret
ENDP ColorVerLine

          ALIGN 16
PROC CursorPos
          mov  [word ds:Ypos6x8],ax
          ret
ENDP CursorPos

          ALIGN 16
PROC ColorStr6x8
          push     ax
          push     bx
          push     cx
          push     dx
          push     di
          push     si
          push     bp

          mov       ax,0A000h
          mov       [Prizn],al
          mov       gs,ax
          mov       dx,03CEh
          mov       ax,0F01h
          out       dx,ax

          ALIGN 8
NextSimvol6x8:
          cld
          lodsb
          or       al,al
          jne      short TestingUprSimv17

          pop      bp
          pop      si
          pop      di
          pop      dx
          pop      cx
          pop      bx
          pop      ax
          ret
          ALIGN 8
TestingUprSimv17:
          test     al,11100000b
          jnz      short NotUprSimv25

          cmp      al,17
          jnz      short NotUprSimv17
          lodsb
          mov      [color],al
          jmp      short NextSimvol6x8
                   ALIGN 8
NotUprSimv17:
          cmp      al,22
          jnz      short NotUprSimv22
          lodsw
          mov      [Xpos6x8],al

          mov      al,[Ypos6x8]
          cmp      al,ah
          jz       short YposNotChanged
          mov      [Xpos6x8Space],0
YposNotChanged:
          mov      [Ypos6x8],ah
          jmp      short NextSimvol6x8
                   ALIGN 8
NotUprSimv22:
          cmp      al,13
          jnz      short NotUprSimv13
          inc      [Ypos6x8]
          sub      ax,ax
          mov      [Xpos6x8],al
          mov      [Xpos6x8Space],ax
          jmp      short nextsimvol6x8
NotUprSimv13:
          cmp      al,18
          jnz      short NotUprSimv18
          mov      [Prizn],1
          jmp      short nextsimvol6x8
NotUprSimv18:
          cmp      al,19
          jnz      short NotUprSimv19
          mov      [Prizn],al
          jmp      short nextsimvol6x8
NotUprSimv19:
          cmp      al,23
          jnz      short NotUprSimv23
          lodsb
          mov      [Xpos6x8],al
          jmp      short NextSimvol6x8
NotUprSimv23:
          cmp      al,31
          jnz      short NotUprSimv31
          add      [Xpos6x8Space],3
          jmp      short NextSimvol6x8
NotUprSimv31:
          cmp      al,30
          jnz      short NotUprSimv30
          mov      [Xpos6x8Space],0
          jmp      NextSimvol6x8
NotUprSimv30:
          cmp      al,25
          jnz      short NotUprSimv25
          lodsb

NotUprSimv25:

          push     si
          sub      ah,ah
          shl      ax,3
          mov      si,offset font6x8
          add      si,ax
          xor      ah,ah
          mov      al,[Ypos6x8]      ;В DI адрес вывода на экран
          mov      bx,640            ;В DX остаток в битах
          mul      bx
          push     ax

          mov      al,[Xpos6x8]
          mov      bl,6
          mul      bl
          sub      ax,[Xpos6x8Space]

          mov      bx,8
          div      bx
          pop      di

          add      di,ax
          mov      cl,dl
          mov      bp,bx

          mov      ch,[color]
          mov      dx,03CEh

          ALIGN 8
NextByte6x8:
          lodsb

          mov      bh,[Prizn]
          or       bh,bh
          jz       short NullByte
          dec      bh
          jz       short NoNullByte
          or       al,al
          jz       short NullByte
NoNullByte:

          push     ax
          mov      ax,0FC00h
          ror      ax,cl
          mov      bh,al
          mov      al,bl
          out      dx,ax
          sub      ax,ax       ; програмируем цвет
          out      dx,ax       ;
          or       [gs:di],al
          mov      ax,bx
          out      dx,ax
          or       [gs:di+1],al
          pop      ax

NullByte:
          shl      ax,8
          ror      ax,cl
          mov      bh,al

          mov      al,bl
          out      dx,ax
          sub      al,al
          mov      ah,ch     ; програмируем цвет
          out      dx,ax     ;
          or       [gs:di],al
          mov      ax,bx
          out      dx,ax
          or       [gs:di+1],al

          add      di,80
          dec      bp
          jnz      short NextByte6x8
          inc      [Xpos6x8]
          pop      si
          jmp      NextSimvol6x8
ENDP ColorStr6x8

PUBLIC StopMotor

PROC StopMotor
          mov     bx,40h         ; Остановка мотора дисковода
          mov     gs,bx          ; на случай запуска с дискеты
          mov     si,bx
          mov     bl,[byte gs:si]
          or      bl,bl
          jz      short MotorStoped
          mov     [byte gs:si],1
          mov     ecx,01FFFFFFFh
WaitingMotorStop:
          mov     bl,[byte gs:si]
          or      bl,bl
          jz      short MotorStoped
          dec     ecx
          jnz     short WaitingMotorStop
MotorStoped:
          ret
ENDP StopMotor

PUBLIC  HkalaMash,HkalaMashMSB,HkalaMashCDROM

PROC HkalaMash
          mov     bp,3
          mov     si,19*16
          mov     cx,5
NextLineHkala:
          push    cx
          mov     ax,12
          xor     bx,bx
          add     bx,si
          mov     cx,123-52
LinMashtabaCpuSpeed1:
          push    cx
          mov     cx,1
          call    colorverline
          add     ax,5
          pop     cx
          loop    short LinMashtabaCpuSpeed1
          add     si,32
          pop     cx
          loop    short NextLineHkala

          mov     ax,12
          mov     cx,7
NextMashtabStroka:
          push    cx
          add     ax,50
          mov     cx,40
          mov     bx,304
NextMashtabStolobec:
          push    cx
          add     bx,4
          mov     cx,1
          call    colorverline
          pop     cx
          loop    short NextMashtabStolobec
          pop     cx
          loop    short NextMashtabStroka
          mov     bp,3+8
          mov     ax,12
          mov     bx,304
          mov     cx,160
          call    colorVerLine
          mov     bx,464
          mov     cx,351
          call    ColorHorLine
          mov     ax,363
          mov     bx,304
          mov     cx,8
          mov     dx,161
          xor     bp,bp
          call    rectangle
          ret
ENDP HkalaMash

PROC HkalaMashMSB
          push    ax
          push    si
          mov     bp,3
          mov     si,280
          mov     cx,6
NextLineHkalaMSB:
          push    cx
          mov     ax,372
          xor     bx,bx
          add     bx,si
          mov     cx, 51
LinMashtabaCpuSpeed1MSB:
          push    cx
          mov     cx,1
          call    colorverline
          add     ax,5
          pop     cx
          loop    short LinMashtabaCpuSpeed1MSB
          add     si,32
          pop     cx
          loop    short NextLineHkalaMSB

          mov     ax,372
          mov     cx,5
NextMashtabStrokaMSB:
          push    cx
          add     ax,50
          mov     cx,40+8
          mov     bx,280
NextMashtabStolobecMSB:
          push    cx
          add     bx,4
          mov     cx,1
          call    colorverline
          pop     cx
          loop    short NextMashtabStolobecMSB
          pop     cx
          loop    short NextMashtabStrokaMSB

          mov     bp,3+8
          mov     ax,372
          mov     bx,280
          mov     cx,192
          call    colorVerLine
          mov     bx,472
          mov     cx,251
          call    ColorHorLine
          pop     si
          pop     ax
          ret
ENDP HkalaMashMSB

PROC HkalaMashCDROM
          mov     bp,3
          mov     si,336
          mov     cx,4
NextLineHkalaCDROM:
          push    cx
          mov     ax,20-8
          mov     bx,si
          mov     cx,70
LinMashtabaCpuSpeed1CDROM:
          push    cx
          mov     cx,1
          call    colorverline
          add     ax,5
          pop     cx
          loop    short LinMashtabaCpuSpeed1CDROM
          add     si,32
          pop     cx
          loop    short NextLineHkalaCDROM

          mov     ax,20-8
          mov     cx,7
NextMashtabStrokaCDROM:
          push    cx
          add     ax,50
          mov     cx,32
          mov     bx,332
NextMashtabStolobecCDROM:
          push    cx
          add     bx,4
          mov     cx,1
          call    colorverline
          pop     cx
          loop    short NextMashtabStolobecCDROM
          pop     cx
          loop    short NextMashtabStrokaCDROM
          mov     bp,3+8
          mov     ax,12
          mov     bx,336
          mov     cx,128
          call    colorVerLine
          mov     bx,464
          mov     cx,351
          call    ColorHorLine
          ret
ENDP HkalaMashCDROM

PUBLIC ClearWindowMesages3,ClearWindowMesages2,ClearWindowMesages

PROC ClearWindowMesages3
          push    ax
          push    bx
          push    cx
          push    dx
          mov     bx,264
          mov     dx,11
          mov     cx,294
          mov     ax,9
          jmp     short GoClearWin
PROC ClearWindowMesages2
          push    ax
          push    bx
          push    cx
          push    dx
          mov     bx,256
          mov     dx,8
          mov     cx,294
          mov     ax,9
          jmp     short GoClearWin
PROC ClearWindowMesages
          push    ax
          push    bx
          push    cx
          push    dx
          mov     bx,245
          mov     dx,30
          mov     cx,294
          mov     ax,9
GoClearWin:
          push    bp
          xor     bp,bp
          call    Rectangle
          pop     bp
          pop     dx
          pop     cx
          pop     bx
          pop     ax
          ret
ENDP ClearWindowMesages
ENDP ClearWindowMesages2
ENDP ClearWindowMesages3

PUBLIC FaindPCIDevice,ReadCfgByte,WriteCfgByte
PUBLIC ReadCfgWord,WriteCfgWord,ReadCfgDWord,WriteCfgDWord

PROC FaindPCIDevice
          mov     ax,0B102h
          xor     si,si
          int     1Ah
          ret
ENDP FaindPCIDevice

PROC ReadCfgByte
          mov     ax,0B108h
          jmp     short GoToInt1A
PROC WriteCfgByte
          mov     ax,0B10Bh
          jmp     short GoToInt1A
PROC ReadCfgWord
          mov     ax,0B109h
          jmp     short GoToInt1A
PROC WriteCfgWord
          mov     ax,0B10Ch
          jmp     short GoToInt1A
PROC ReadCfgDWord
          mov     ax,0B10Ah
          jmp     short GoToInt1A
PROC WriteCfgDWord
          mov     ax,0B10Dh

GoToInt1A:
          push    bx
          int     1Ah
          pop     bx
          ret
ENDP WriteCfgDWord
ENDP ReadCfgDWord
ENDP WriteCfgWord
ENDP ReadCfgWord
ENDP WriteCfgByte
ENDP ReadCfgByte

PUBLIC ReadPCIConfig,ReadPCIConfigDword,WritePCIConfigDword

          ALIGN 2
PROC ReadPCIConfig  ;Bh-device Bl-Function ;Return CX-ConfWord
          push    di
          push    bx
          shl     bh,3
          or      bl,bh
          mov     bh,[NumberPCIBus]
          call    ReadCfgWord
          pop     bx
          pop     di
          ret
ENDP ReadPCIConfig

          ALIGN 2
PROC ReadPCIConfigDword  ;Bh-device Bl-Function ;Return ECX-ConfDword
          push    di
          push    bx
          mov     ax,0B10Ah
          shl     bh,3
          or      bl,bh
          mov     bh,[NumberPCIBus]
          int     1Ah
          pop     bx
          pop     di
          ret
ENDP ReadPCIConfigDword

          ALIGN 2
PROC WritePCIConfigDword  ;Bh-device Bl-Function ; ECX-Dword To Write
          push    di
          push    bx
          mov     ax,0B10Dh
          shl     bh,3
          or      bl,bh
          mov     bh,[NumberPCIBus]
          int     1Ah
          pop     bx
          pop     di
          ret
ENDP WritePCIConfigDword



PUBLIC ClearRightScreen,ClearDownScreen

PROC ClearRightScreen
          mov     ax,310
          mov     bx,16
          mov     cx,327
          mov     dx,260
          sub     bp,bp
          call    Rectangle
          ret
ENDP ClearRightScreen

PROC ClearDownScreen
          mov     ax,8
          mov     bx,278
          mov     cx,626
          mov     dx,196
          sub     bp,bp
          call    Rectangle
          ret
ENDP ClearDownScreen

PROC UpUgol
          cmp     cl,25h
          mov     bx,307-8
          mov     dx,12+8
          jz      short UpUgolGo
          cmp     cl,32h
          mov     bx,411-8
          jz      short UpUgolGo
          cmp     cl,26h
          mov     dx,12
          mov     bx,307
          jz      short UpUgolGo
          mov     bx,411
UpUgolGo:
          push    cx
          mov     cx,10
          add     ax,12
          mov     bp,3+8
          call    colorHorLine
          mov     cx,dx
          call    ColorVerLine
          pop     ax
          call    CursorPos
          push    si
          mov     si,offset Mes1738
          call    ColorStr6x8
          pop     si
          call    ColorStr6x8
          ret
ENDP UpUgol

PROC DownUgol
          mov     bx,339
          mov     dx,12+8
          mov     bp,8
          cmp     cl,2Bh
          jz      short DownUgolGo
          mov     bx,443
          cmp     cl,38h
          jz      short DownUgolGo
          sub     bp,bp
          mov     bx,339
          mov     dx,12
          cmp     cl,2Ah
          jz      short DownUgolGo
          mov     bx,443
DownUgolGo:
          push    cx
          mov     cx,10
          add     ax,12
          add     bx,bp
          push    bp
          mov     bp,3+8
          call    ColorHorLine
          pop     bp
          sub     bx,bp
          mov     bp,3+8
          sub     bx,cx
          dec     bx
          mov     cx,dx
          call    ColorVerLine
          pop     ax
          call    CursorPos
          push    si
          mov     si,offset Mes1738
          call    ColorStr6x8
          pop     si
          call    ColorStr6x8
          ret
ENDP DownUgol

PUBLIC Skale,PrintSravnenieCPU,PrintSravnenieHDD,PrintSravnenieCD

PROC Skale      ;Выбор масштаба 1:1, 1:4 или 1:16 по макс. значению
          mov     cx,2
          mov     [SkaleProc],1
NextLoopSkaleProc:
          cmp     ax,335
          jb      short PrnScale
          shr     ax,2
          inc     [SkaleProc]
          loop    short NextLoopSkaleProc
          mov     ax,350
PrnScale:
          ret
ENDP Skale


PROC PrintSravnenieCPU
          mov     bp,3+8
          cmp     [SkaleProc],1
          jnz     Not1x1CPU

          mov     ax,273/2
          mov     cx,01A25h
          mov     si,offset CPUpII233  ;273%
          call    UpUgol

          mov     ax,676/2
          mov     cx,322Ah
          mov     si,offset CPUAthlon600  ;678%
          call    DownUgol

          mov     ax,563/2
          mov     cx,322Bh
          mov     si,offset CPUK63500  ;563%
          call    DownUgol

          mov     ax,383/2
          mov     cx,232Ah
          mov     si,offset CPUCeleron333  ;383%
          call    DownUgol

          mov     ax,351/2
          mov     cx,0202Bh
          mov     si,offset CPUpII300  ;351
          call    DownUgol

          mov     ax,464/2
          mov     cx,2A25h
          mov     si,offset CPUpII400 ;464
          call    UpUgol

          mov     ax,582/2
          mov     cx,2E26h
          mov     si,offset CPUCeleron500 ;582
          call    UpUgol

          mov     ax,100/2
          mov     cx,0726h
          mov     si,offset CPUp54c133  ;100
          call    UpUgol

          mov     ax,169/2
          mov     cx,0112Bh
          mov     si,offset CPUMII233  ;169
          call    DownUgol

          mov     ax,178/2
          mov     cx,0122Ah
          mov     si,offset CPUp55c233  ;178
          call    DownUgol

          mov     ax,307/2
          mov     cx,01D26h
          mov     si,offset CPUK62266  ;308
          call    UpUgol

          mov     ax,20/2
          mov     cx,052Ah
          mov     si,offset CPUi486dx250  ;20
          call    DownUgol

          mov     ax,44/2
          mov     cx,0725h   ;0725
          mov     si,offset CPUam5x86133  ;44
          call    UpUgol

          mov     ax,3/2+1
          mov     cx,032Bh
          mov     si,offset CPUi386dx40 ;3
          call    DownUgol

          mov     ax,206/2
          mov     cx,1225h   ;0725
          mov     si,offset CPUp6200  ;206
          call    UpUgol

          ret
Not1x1CPU:
          cmp     [SkaleProc],2
          jnz     Not1x4CPU

          mov     ax,716/2/4
          mov     cx,122Bh
          mov     si,offset CPUDuron600  ;716%
          call    DownUgol

          mov     ax,1084/2/4
          mov     cx,192Ah
          mov     si,offset CPUpIII933  ;1084%
          call    DownUgol

          mov     ax,351/2/4
          mov     cx,0A2Ah
          mov     si,offset CPUpII300  ;351
          call    DownUgol

          mov     ax,1377/2/4
          mov     cx,2025h
          mov     si,offset CPUCeleron1200 ;1377
          call    UpUgol

          mov     ax,966/2/4
          mov     cx,1726h
          mov     si,offset CPUAthlon800 ;966
          call    UpUgol

          mov     ax,1669/2/4
          mov     cx,2626h
          mov     si,offset CPUAthlon1400 ;1669
          call    UpUgol

          mov     ax,692/2/4
          mov     cx,0F25h
          mov     si,offset CPUpIII600 ;692
          call    UpUgol

          mov     ax,178/2/4
          mov     cx,0325h
          mov     si,offset CPUp55c233  ;178%
          call    UpUgol

          mov     ax,100/2/4
          mov     cx,052Bh
          mov     si,offset CPUp54c133  ;100%
          call    DownUgol

          mov     ax,2340/2/4
          mov     cx,2E2Ah
          mov     si,offset CPUAthlon2000  ;2340%
          call    DownUgol


          mov     ax,1884/2/4
          mov     cx,2A2Bh
          mov     si,offset CPUP42400  ;1885%
          call    DownUgol

          mov     ax,518/2/4
          mov     cx,0726h
          mov     si,offset CPUpII450 ;518
          call    UpUgol
          ret
Not1x4CPU:

          mov     ax,1669/2/16
          mov     cx,0C2Ah
          mov     si,offset CPUAthlon1400
          call    DownUgol

          mov     ax,518/2/16
          mov     cx,062Bh
          mov     si,offset CPUpII450
          call    DownUgol


          mov     ax,1377/2/16
          mov     cx,0A26h
          mov     si,offset CPUCeleron1200 ;1377
          call    UpUgol

          mov     ax,307/2/16
          mov     cx,0425h
          mov     si,offset CPUK62266  ;307% /16
          call    UpUgol
          ret
ENDP PrintSravnenieCPU

PROC PrintSravnenieHDD
          mov     bp,3+8
          cmp     [SkaleProc],1
          jnz     short Not1x1HDD

          mov     ax,141
          mov     cx,01A33h
          mov     si,offset HDDMPA3026  ;141%
          call    UpUgol

          mov     ax,200
          mov     cx,02438h
          mov     si,offset HDDQFBSE3530  ;200
          call    DownUgol

          mov     ax,214
          mov     cx,02637h
          mov     si,offset HDDQFBEL51A  ;214
          call    DownUgol

          mov     ax,92
          mov     cx,01237h
          mov     si,offset HDDST32122A  ;92
          call    DownUgol

          mov     ax,56
          mov     cx,00C38h
          mov     si,offset HDDPLS31274A  ;56
          call    DownUgol

          mov     ax,100
          mov     cx,01432h
          mov     si,offset HDDWDC21600  ;100%
          call    UpUgol

          mov     ax,256
          mov     cx,02E32h
          mov     si,offset HDDQFBEX32Asm  ;256%
          call    UpUgol

          mov     ax,308
          mov     cx,03033h
          mov     si,offset HDDQFBlct1507  ;308%
          call    UpUgol

          mov     ax,16
          mov     cx,0533h
          mov     si,offset HDDST3491A  ;16%
          call    UpUgol

          mov     ax,3
          mov     cx,0332h
          mov     si,offset HDDSHD3062A ;3%
          call    UpUgol
          ret
Not1x1HDD:
          cmp     [SkaleProc],2
          jnz     short Not1x4HDD

          mov     ax,238
          mov     cx,2533h
          mov     si,offset HDDMaxtor6L040J2  ;950/4%
          call    UpUgol

          mov     ax,137
          mov     cx,1A32h
          mov     si,offset HDDMaxtor90651U2  ;547/4%
          call    UpUgol

          mov     ax,54
          mov     cx,0C38h
          mov     si,offset HDDQFBEL51A  ;214/4
          call    DownUgol

          mov     ax,197
          mov     cx,2437h
          mov     si,offset HDDIBMDTLA307030  ;788/4
          call    DownUgol

          mov     ax,90
          mov     cx,0D37h
          mov     si,offset HDDMPE3064AT  ;360/4
          call    DownUgol

          mov     ax,173
          mov     cx,2038h
          mov     si,offset HDDQFBLM957  ;692/4
          call    DownUgol

          mov     ax,110
          mov     cx,0C33h
          mov     si,offset HDDQFBLCT10  ;440/4%
          call    UpUgol

          mov     ax,25
          mov     cx,0332h
          mov     si,offset HDDWDC21600  ;100/4%
          call    UpUgol

          ret
Not1x4HDD:

          mov     ax,118
          mov     cx,1632h
          mov     si,offset HDDMaxtor6L040J2  ;950/8
          call    UpUgol

          mov     ax,97
          mov     cx,1337h
          mov     si,offset HDDIBMDTLA307030  ;778/8
          call    DownUgol

          mov     ax,12
          mov     cx,0232h
          mov     si,offset HDDQFBSE3530  ;200/8
          call    UpUgol

          mov     ax,45
          mov     cx,0B38h
          mov     si,offset HDDMPE3064AT  ;360/8
          call    DownUgol

          mov     ax,55
          mov     cx,0C33h
          mov     si,offset HDDQFBLCT10  ;440/8
          call    UpUgol

          ret
ENDP PrintSravnenieHDD

PROC PrintSravnenieCD
          mov     bp,3+8
          cmp     [SkaleProc],1
          jnz     short Not1x1CD

          mov     ax,52
          mov     cx,0C38h
          mov     si,offset SamSCR830  ;52
          call    DownUgol

          mov     ax,54
          mov     cx,0C33h
          mov     si,offset SonyCDU311  ;53
          call    UpUgol

          mov     ax,261
          mov     cx,2833h
          mov     si,offset SonyCDU701  ;261
          call    UpUgol

          mov     ax,150
          mov     cx,01C32h
          mov     si,offset CD2421E  ;150
          call    UpUgol

          mov     ax,315
          mov     cx,2A37h
          mov     si,offset TEAC540E  ;315
          call    DownUgol

          mov     ax,183
          mov     cx,02238h
          mov     si,offset CDP585  ;183%
          call    DownUgol

          mov     ax,12
          mov     cx,0537h
          mov     si,offset SamSCR630  ;12%
          call    DownUgol

          mov     ax,104
          mov     cx,1437h
          mov     si,offset CDP584  ;104%
          call    DownUgol

          mov     ax,17
          mov     cx,0632h
          mov     si,offset HPCDW7100 ;17%
          call    UpUgol
          ret
Not1x1CD:
          cmp     [SkaleProc],2
          jnz     short Not1x4CD

          mov     ax,261/4
          mov     cx,0232h
          mov     si,offset SonyCDU701  ;261
          call    UpUgol

          mov     ax,183/4
          mov     cx,0A38h
          mov     si,offset CDP585  ;183
          call    DownUgol

          mov     ax,392/4
          mov     cx,1337h
          mov     si,offset LG8400B ;392
          call    DownUgol

          mov     ax,453/4
          mov     cx,1632h
          mov     si,offset SonyCDU4821    ;453
          call    UpUgol

          mov     ax,508/4
          mov     cx,1833h
          mov     si,offset AsusCDS450A
          call    UpUgol

Not1x4CD:
          ret
ENDP PrintSravnenieCD

PUBLIC DetectRiseCodeName,DetectIDTCodeName
PUBLIC DetectCyrixCodeName,DetectIntelCodeName,DetectAMDCodeName

PROC DetectRiseCodeName
          mov     si,offset MesRiseMP6
          cmp     ax,5*256+0
          jz      short DetectedRiseCodeName
          mov     si,offset MesRiseMP6018
          cmp     ax,5*256+2
          jz      short DetectedRiseCodeName
          stc
          ret
DetectedRiseCodeName:
          clc
          ret
ENDP DetectRiseCodeName

PROC DetectIDTCodeName
          mov     si,offset MesIDTC6
          cmp     ax,5*256+4
          jz      short DetectedIDTCodeName
          mov     si,offset MesIDTW2
          cmp     ax,5*256+8
          jz      short DetectedIDTCodeName
          mov     si,offset MesIDTW3
          cmp     ax,5*256+9
          jz      short DetectedIDTCodeName
          mov     si,offset MesCyrixIIISamuel
          cmp     ax,6*256+6
          jz      short DetectedCyrixCodeName
          mov     si,offset MesCyrixIIISamuel2
          cmp     ax,6*256+7
          jnz     short NotSamuel2OrEzraCodeName
          mov     esi,offset MesCyrixIIISamuel2
          cmp     [CPUStepping],7
          jbe     short DetectedIDTCodeName
          mov     esi,offset MesCyrixIIIEzra
          jmp     DetectedIDTCodeName
NotSamuel2OrEzraCodeName:
          mov     esi,offset MesCyrixIIIEzraT
          cmp     ax,6*256+8
          jz      short DetectedIDTCodeName
          mov     esi,offset MesCyrixIIINehemiah
          cmp     ax,6*256+9
          jz      short DetectedIDTCodeName
          stc
          ret
DetectedIDTCodeName:
          clc
          ret
ENDP DetectIDTCodeName

PROC DetectCyrixCodeName
          mov     si,offset MesCyrixM1SC
          cmp     ax,4*256+9
          jz      short DetectedCyrixCodeName
          mov     si,offset MesCyrixGX86
          cmp     ax,4*256+4
          jz      short DetectedCyrixCodeName
          mov     si,offset MesCyrixM1
          cmp     ax,5*256+2
          jz      short DetectedCyrixCodeName
          mov     si,offset MesCyrixM2
          cmp     ax,6*256+0
          jz      short DetectedCyrixCodeName
          mov     si,offset MesCyrixIIIJoshua
          cmp     ax,6*256+5
          jz      short DetectedCyrixCodeName

          stc
          ret
DetectedCyrixCodeName:
          clc
          ret
ENDP DetectCyrixCodeName

PROC DetectIntelCodeName
          mov     si,offset MesIntelP4100
          cmp     ax,4*256+0
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelP4080
          cmp     ax,4*256+1
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelP4S
          cmp     ax,4*256+2
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelP24
          cmp     ax,4*256+3
          jz      DetectedIntelCodeName
          cmp     ax,4*256+7
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelP23
          cmp     ax,4*256+5
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelP24C
          cmp     ax,4*256+8
          jz      DetectedIntelCodeName
          cmp     ax,4*256+9
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelP5
          cmp     ax,5*256+0
          jz      DetectedIntelCodeName
          cmp     ax,5*256+1
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelP54C
          cmp     ax,5*256+2
          jz      DetectedIntelCodeName
          cmp     ax,5*256+7
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelP24T
          cmp     ax,5*256+3
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelP55C
          cmp     ax,5*256+4
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelTilamook
          cmp     ax,5*256+8
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelP6
          cmp     ax,6*256+0
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelP6035
          cmp     ax,6*256+1
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelKlamath
          cmp     ax,6*256+3
          jnz     short NoIntelKlamathOrP6T
          cmp     [CPUtype],0
          jz      DetectedIntelCodeName
          mov     si,offset MesIntelP6T
          jmp     DetectedIntelCodeName

NoIntelKlamathOrP6T:
          mov     si,offset MesIntelDeshutes
          cmp     ax,6*256+5
          jnz     short NoIntelCovingtonDeshutes
          cmp     [byte ds:RegEDXCPUIDlevel2],40h
          jnz     DetectedIntelCodeName
          mov     si,offset MesIntelCovington
          jmp     DetectedIntelCodeName

NoIntelCovingtonDeshutes:

          mov     si,offset MesIntelMendocino
          cmp     ax,6*256+6
          jnz     short NoIntelMendocinoDixon
          cmp     [byte ds:RegEDXCPUIDlevel2],42h
          jnz     short DetectedIntelCodeName
          mov     si,offset MesIntelDixon
          jmp     short DetectedIntelCodeName

NoIntelMendocinoDixon:

          mov     si,offset MesIntelKatmai
          cmp     ax,6*256+7
          jnz     short NoIntelKatmaiTanner
          cmp     [byte ds:RegEDXCPUIDlevel2],43h
          jbe     short DetectedIntelCodeName
          mov     si,offset MesIntelTanner
          jmp     short DetectedIntelCodeName

NoIntelKatmaiTanner:
          mov     si,offset MesIntelCoppermine
          cmp     ax,6*256+8
          jnz     short NoIntelCoppermineCascades
          cmp     [BrandID],3
          jnz     short DetectedIntelCodeName
          mov     si,offset MesIntelCascades
          jmp     short DetectedIntelCodeName

NoIntelCoppermineCascades:
          cmp     ax,6*256+0Ah
          jnz     short NoIntelCascadesA
          mov     si,offset MesIntelCascadesA
          cmp     [BrandID],3
          jz      short DetectedIntelCodeName
NoIntelCascadesA:
          mov     si,offset MesIntelTualatin
          cmp     ax,6*256+0Bh
          jz      short DetectedIntelCodeName

          mov     si,offset MesIntelMerced
          cmp     ah,7
          jz      short DetectedIntelCodeName

          cmp     ah,0Fh
          jnz     NoIntelExtendFamily
          cmp     [IntelExtendedFamily],0
          jnz     NoIntelP4core

          mov     si,offset MesIntelWillamette
          or      al,al
          jz      short DetectedIntelCodeName
          cmp     al,1
          jz      short DetectedIntelCodeName
          mov     si,offset MesIntelNorthwood
          cmp     al,2
          jz      short DetectedIntelCodeName
          mov     si,offset MesIntelPrescott
          cmp     al,3
          jz      short DetectedIntelCodeName
NoIntelP4core:
          cmp     [IntelExtendedFamily],1
          mov     si,offset MesIntelMcKinley
          jz      short DetectedIntelCodeName

NoIntelMcKinley:
NoIntelExtendFamily:

          stc
          ret
DetectedIntelCodeName:
          clc
          ret
ENDP DetectIntelCodeName

PROC DetectAMDCodeName
          mov     si,offset MesAMDP24
          cmp     ax,4*256+3
          jz      DetectedAMDCodeName
          cmp     ax,4*256+7
          jz      DetectedAMDCodeName
          mov     si,offset MesAMDP24C
          cmp     ax,4*256+8
          jz      DetectedAMDCodeName
          cmp     ax,4*256+9
          jz      DetectedAMDCodeName
          mov     si,offset MesAMDX5
          cmp     ax,4*256+0Eh
          jz      DetectedAMDCodeName
          cmp     ax,4*256+0Fh
          jz      DetectedAMDCodeName
          mov     si,offset MesAMDSSA5
          cmp     ax,5*256+0
          jz      DetectedAMDCodeName
          mov     si,offset MesAMD5k86
          cmp     ax,5*256+1
          jz      DetectedAMDCodeName
          cmp     ax,5*256+2
          jz      DetectedAMDCodeName
          cmp     ax,5*256+3
          jz      DetectedAMDCodeName
          mov     si,offset MesAMDK6030
          cmp     ax,5*256+6
          jz      DetectedAMDCodeName
          mov     si,offset MesAMDK6025
          cmp     ax,5*256+7
          jz      DetectedAMDCodeName
          mov     si,offset MesAMDChomper
          cmp     ax,5*256+8
          jnz     short DetectedAMDSharptooth

          cmp     [CPUstepping],8
          jb      short AMDChomperDetected
          mov     si,offset MesAMDChomperXT
AMDChomperDetected:
          jmp     short DetectedAMDCodeName

DetectedAMDSharptooth:
          mov     si,offset MesAMDSharptooth
          cmp     ax,5*256+9
          jz      short DetectedAMDCodeName
          mov     si,offset MesAMDk63plus
          cmp     ax,5*256+0Dh
          jz      short DetectedAMDCodeName
          mov     si,offset MesAMDK7ES
          cmp     ax,6*256+0
          jz      short DetectedAMDCodeName
          mov     si,offset MesAMDK7
          cmp     ax,6*256+1
          jz      short DetectedAMDCodeName
          mov     si,offset MesAMDK75
          cmp     ax,6*256+2
          jz      short DetectedAMDCodeName
          mov     si,offset MesAMDSpitfire
          cmp     ax,6*256+3
          jz      short DetectedAMDCodeName
          mov     si,offset MesAMDThunderbird
          cmp     ax,6*256+4
          jz      short DetectedAMDCodeName
          mov     si,offset MesAMDPalomino
          cmp     ax,6*256+6
          jz      short DetectedAMDCodeName
          mov     si,offset MesAMDMorgan
          cmp     ax,6*256+7
          jz      short DetectedAMDCodeName
          mov     si,offset MesAMDThoroughbred
          cmp     ax,6*256+8
          jz      short DetectedAMDCodeName
          mov     si,offset MesAMDBarton
          cmp     ax,6*256+10
          jz      short DetectedAMDCodeName
          cmp     ah,0Fh
          jnz     short NoAMDExtendedFam
          cmp     [IntelExtendedFamily],0
          jnz     short NotK8Fam
          mov     si,offset MesAMDSledgeHammer
          cmp     al,5
          jz      short DetectedAMDCodeName
NotK8Fam:


NoAMDExtendedFam:


NotAMDmodel6364:
          stc
          ret
DetectedAMDCodeName:
          clc
          ret
ENDP DetectAMDCodeName

PUBLIC GetIntelClockRatio,GetK6ClockRatio,GetK7ClockRatio,GetCyrixIIIClockRatio,GetSamuelClockRatio

PROC GetIntelClockRatio

          cmp     [CPUfamily],0Fh
          jnz     short NotIntelP4ProcesorForGetClockMult
          cmp     [IntelExtendedFamily],0
          jnz     short NotIntelP4ProcesorForGetClockMult
          cmp     [CPUModel],2
          ja      short NotIntelP4ProcesorForGetClockMult
          jz      short IntelP4NortwoodProcesorForGetClockMult

          shr     eax,8
          and     eax,0Fh
          cmp     al,8
          jae     short @@01
          add     al,16
@@01:
          cmp     al,12
          jae     short @@02
          sub     al,al
@@02:
          mov     bl,100
          mul     bl

          mov     bx,ax
          jmp     DetectClockRatio

IntelP4NortwoodProcesorForGetClockMult:
          shr     eax,24
          and     al,11111b
          mov     bl,100
          mul     bl
          mov     bx,ax
          jmp     DetectClockRatio

NotIntelP4ProcesorForGetClockMult:
          cmp     [CPUfamily],06h
          jnz     NotIntelP6Core
          shr     eax,22
          cmp     [CPUmodel],8
          jb      short GetOldMultiplier
          jnz     short Non683ClockRatio
          cmp     [CPUstepping],3
          jb      short GetOldMultiplier
Non683ClockRatio:
          cmp     [CPUmodel],0Bh
          jz      DetectedTualatin

          test    eax,100000b
          jz      short GetOldMultiplier
DetectedTualatin:
          and     al,0Fh
          mov     bx,850
          cmp     al,0110b
          jz      short Detect683ClockRatio
          mov     bx,900
          cmp     al,0000b
          jz      short Detect683ClockRatio
          mov     bx,950
          cmp     al,0100b
          jz      short Detect683ClockRatio
          mov     bx,1000
          cmp     al,1011b
          jz      short Detect683ClockRatio
          mov     bx,1050
          cmp     al,1111b
          jz      short Detect683ClockRatio
          mov     bx,1100
          cmp     al,0001b
          jz      short Detect683ClockRatio
          mov     bx,1150
          cmp     al,0101b
          jz      short Detect683ClockRatio
          mov     bx,1200
          cmp     al,0010b
          jz      short Detect683ClockRatio
          sub     bx,bx
Detect683ClockRatio:
          jmp     short DetectClockRatio
GetOldMultiplier:
          and     al,0Fh
          mov     bx,200
          cmp     al,0011b
          jz      short DetectClockRatio
          mov     bx,250
          cmp     al,0111b
          jz      short DetectClockRatio
          mov     bx,300
          cmp     al,0001b
          jz      short DetectClockRatio
          mov     bx,350
          cmp     al,0101b
          jz      short DetectClockRatio
          mov     bx,400
          cmp     al,0010b
          jz      short DetectClockRatio
          mov     bx,450
          cmp     al,0110b
          jz      short DetectClockRatio
          mov     bx,500
          cmp     al,0000b
          jz      short DetectClockRatio
          mov     bx,550
          cmp     al,0100b
          jz      short DetectClockRatio
          mov     bx,600
          cmp     al,1011b
          jz      short DetectClockRatio
          mov     bx,650
          cmp     al,1111b
          jz      short DetectClockRatio
          mov     bx,700
          cmp     al,1001b
          jz      short DetectClockRatio
          mov     bx,750
          cmp     al,1101b
          jz      short DetectClockRatio
          mov     bx,800
          cmp     al,1010b
          jz      short DetectClockRatio
          mov     bx,850
          cmp     al,1110b
          jz      short DetectClockRatio
          mov     bx,900
          cmp     al,1000b
          jz      short DetectClockRatio
          mov     bx,950
DetectClockRatio:
          mov     [ClockRatio],bx
NotIntelP6Core:
          ret
ENDP GetIntelClockRatio

PROC GetK6ClockRatio
          and     al,07h
          mov     bx,250
          cmp     [CPUmodel],0Dh
          jnz     short AMD018detect ;0,18mkm 2.5=2.0
          mov     bx,200
AMD018detect:
          cmp     al,100b
          jz      short DetectAMDClockRatio
          mov     bx,300
          cmp     al,101b
          jz      short DetectAMDClockRatio
          mov     bx,600
          cmp     al,110b
          jz      short DetectAMDClockRatio
          mov     bx,350
          cmp     al,111b
          jz      short DetectAMDClockRatio
          mov     bx,450
          cmp     al,000b
          jz      short DetectAMDClockRatio
          mov     bx,500
          cmp     al,001b
          jz      short DetectAMDClockRatio
          mov     bx,400
          cmp     al,010b
          jz      short DetectAMDClockRatio
          mov     bx,550
DetectAMDClockRatio:
          mov     [ClockRatio],bx
          ret
ENDP GetK6ClockRatio

PROC GetK7ClockRatio

          shr     eax,18h
          cmp     [CPUmodel],6
          jb      short NoPalominoOrMorgan
          and     ax,1Fh

          mov     bx,300
          cmp     al,10000b
          jz      short DetectAMDPalominoOrMorganMultOK
          mov     bx,350
          cmp     al,10001b
          jz      short DetectAMDPalominoOrMorganMultOK
          mov     bx,400
          cmp     al,10010b
          jz      short DetectAMDPalominoOrMorganMultOK
          mov     bx,450
          cmp     al,10011b
          jz      short DetectAMDPalominoOrMorganMultOK
          test    al,10000b
          jnz     short GetPalominoOrMorganNewMult

NoPalominoOrMorgan:
          and     ax,0Fh
GetPalominoOrMorganNewMult:
          inc     ax
          mov     cx,ax
          mov     bx,250
NextK7MultiplierDetect:
          add     bx,50
          loop    short NextK7MultiplierDetect
          cmp     [CPUmodel],2
          jbe     short NotAMDDuronOrTBird

          cmp     [CPUmodel],7
          jbe     short NotAMDTBred
          add     bx,800
          jmp     short DetectAMDTBredOK

NotAMDTBred:
          cmp     bx,300
          jnz     short NotAMD11x
          mov     bx,1100
          jmp     short DetectAMDDuronOrTBirdOK
NotAMD11x:
          cmp     bx,350
          jnz     short NotAMD115x
          mov     bx,1150
          jmp     short DetectAMDDuronOrTBirdOK
NotAMD115x:
          cmp     bx,400
          jnz     short NotAMD12x
          mov     bx,1200
          jmp     short DetectAMDDuronOrTBirdOK
NotAMD12x:
          cmp     bx,450
          jnz     short NotAMD125x
          mov     bx,1250
NotAMD125x:

NotAMDDuronOrTBird:

DetectAMDTBredOK:
DetectAMDDuronOrTBirdOK:
DetectAMDPalominoOrMorganMultOK:

          mov     [ClockRatio],bx
NotDetectK7Multiplier:
          ret
ENDP GetK7ClockRatio

PROC GetCyrixIIIClockRatio
          shr     eax,22
          and     al,1111b
          mov     bx,300
          cmp     al,0001b
          jz      short DetectCyrixIIIClockRatio
          mov     bx,400
          cmp     al,0010b
          jz      short DetectCyrixIIIClockRatio
          mov     bx,500
          cmp     al,0011b
          jz      short DetectCyrixIIIClockRatio
          mov     bx,250
          cmp     al,0100b
          jz      short DetectCyrixIIIClockRatio
          mov     bx,350
          cmp     al,0101b
          jz      short DetectCyrixIIIClockRatio
          mov     bx,450
          cmp     al,0110b
          jz      short DetectCyrixIIIClockRatio
          mov     bx,550
          cmp     al,0111b
          jz      short DetectCyrixIIIClockRatio
          mov     bx,600
          cmp     al,1000b
          jz      short DetectCyrixIIIClockRatio
          mov     bx,700
          cmp     al,1001b
          jz      short DetectCyrixIIIClockRatio
          mov     bx,650
          cmp     al,1010b
          jz      short DetectCyrixIIIClockRatio
          cmp     al,1100b
          jz      short DetectCyrixIIIClockRatio
          mov     bx,750
          cmp     al,1011b
          jz      short DetectCyrixIIIClockRatio
          cmp     al,1101b
          jnz     short NotDetectCyrixIIIMultiplier

DetectCyrixIIIClockRatio:
          mov     [ClockRatio],bx
NotDetectCyrixIIIMultiplier:
          ret
ENDP GetCyrixIIIClockRatio

PROC GetSamuelClockRatio
          shr     eax,22
          and     al,1111b
          cmp     [CPUmodel],07h
          jnz     short NotSamuel2Detected
          mov     bx,1000
          cmp     al,0011b
          jz      short DetectSamuelClockRatio
          mov     bx,1100
          cmp     al,0111b
          jz      short DetectSamuelClockRatio
          mov     bx,900
          cmp     al,1000b
          jz      short DetectSamuelClockRatio
          mov     bx,1200
          cmp     al,1100b
          jz      short DetectSamuelClockRatio
          mov     bx,1300
          cmp     al,1110b
          jz      short DetectSamuelClockRatio
NotSamuel2Detected:

          mov     bx,500
          cmp     al,0000b
          jz      short DetectSamuelClockRatio
          cmp     al,1000b
          jz      short DetectSamuelClockRatio
          mov     bx,300
          cmp     al,0001b
          jz      short DetectSamuelClockRatio
          cmp     al,0011b
          jz      short DetectSamuelClockRatio
          cmp     al,0111b
          jz      short DetectSamuelClockRatio
          cmp     al,1100b
          jz      short DetectSamuelClockRatio
          cmp     al,1110b
          jz      short DetectSamuelClockRatio
          mov     bx,400
          cmp     al,0010b
          jz      short DetectSamuelClockRatio
          mov     bx,550
          cmp     al,0100b
          jz      short DetectSamuelClockRatio
          mov     bx,350
          cmp     al,0101b
          jz      short DetectSamuelClockRatio
          mov     bx,450
          cmp     al,0110b
          jz      short DetectSamuelClockRatio
          mov     bx,700
          cmp     al,1001b
          jz      short DetectSamuelClockRatio
          mov     bx,800
          cmp     al,1010b
          jz      short DetectSamuelClockRatio
          mov     bx,600
          cmp     al,1011b
          jz      short DetectSamuelClockRatio
          mov     bx,750
          cmp     al,1101b
          jz      short DetectSamuelClockRatio
          mov     bx,650
          cmp     al,1111b
          jnz     short NotDetectSamuelClockRatio
DetectSamuelClockRatio:
          mov     [ClockRatio],bx
NotDetectSamuelClockRatio:
          ret
ENDP GetSamuelClockRatio

PUBLIC MemSpeedBlockRepl,MemSpeedBlockForZamerRepl
PUBLIC MemSpeedBlockLodsd,MemSpeedBlockForZamerLodsd
PUBLIC MemSpeedBlockStosd,MemSpeedBlockForZamerStosd
PUBLIC MemSpeedBlockLodsq,MemSpeedBlockForZamerLodsq
PUBLIC MemSpeedBlockLodsqPrg
PUBLIC MemSpeedBlockStosq,MemSpeedBlockForZamerStosq
PUBLIC MemSpeedBlockStosqPrg
PUBLIC MemSpeedBlockMovsq,MemSpeedBlockForZamerMovsq
PUBLIC MemSpeedBlockMovsqPrg
PUBLIC MemSpeedBlockMovsdPrg
PUBLIC MemSpeedBlockStosdPrg
PUBLIC MemSpeedBlockLodsdPrg
;PUBLIC MemIDX
PUBLIC GetMemPeakBandwidth32,GetMemPeakBandwidth64,GetMemPeakBandwidth128
PUBLIC ClearHMSblock

EXTRN AdrHMS:dword,MemSizePriznak:byte

ALIGN 2
PROC MemSpeedBlockRepl        ; 1182  ;Вход AX 0-250 Выход AX Mb/s *10
          call    DetectMemSize
PROC MemSpeedBlockForZamerRepl

          push    ds
          push    es

          sub     ax,ax
          mov     es,ax
          mov     ds,ax

          call    CalkNumBlockForMemTests
          push    ebp
          mov     eax,[dword cs:AdrHMS]
          push    edi
          call    StartNewTimer
          cld
          push    edx
          mov     edx,ecx
          jmp     short NextMemSpeedBlock

          ALIGN 16

NextMemSpeedBlock:
          mov     ecx,edx
          mov     esi,eax
          mov     edi,eax

          DB      0F3h,66h,67h,0A5h   ;repe movsd
          dec     bx
          jnz     short NextMemSpeedBlock
          pop     ecx
          jecxz   short SkipDohistka
          mov     esi,eax
          mov     edi,eax
          DB      0F3h,66h,67h,0A5h   ;repe movsd
SkipDohistka:
          call    StopNewTimer
          pop     edi
          pop     ebp

          pop     es
          pop     ds

          jmp     CalcSpeed
ENDP MemSpeedBlockForZamerRepl
ENDP MemSpeedBlockRepl

ALIGN 16

PROC GetMemPeakBandwidth32

          push    ebx
          push    cx
          mov     ax,cx

          call    DetectMemSize

          push    ds
          push    es

          sub     ax,ax
          mov     es,ax
          mov     ds,ax

          call    CalkNumBlockForMemTests

        mov     esi,[dword cs:AdrHMS]

        shr     ecx,1
        lea     esi,[esi+ecx*8]
        neg     ecx
        mov     edx,ecx

        call    StartNewTimer
        jmp     short NextMemPeakSpeedBlockLodsD32

        ALIGN 16

NextMemPeakSpeedBlockLodsD32:
LodsDBytesPeakBlock32:
        mov     eax,[esi+ecx*8+000h]
        mov     eax,[esi+ecx*8+020h]
        mov     eax,[esi+ecx*8+040h]
        mov     eax,[esi+ecx*8+060h]
        add     ecx,16
        jnz     short LodsDBytesPeakBlock32

        mov     ecx,edx

        dec     bx
        jnz     short NextMemPeakSpeedBlockLodsD32


          call    StopNewTimer

          pop     es
          pop     ds

          pop     cx
          pop     ebx

          jmp     CalcSpeed
ENDP GetMemPeakBandwidth32

ALIGN 16

PROC GetMemPeakBandwidth64

          push    ebx
          push    cx
          mov     ax,cx

          call    DetectMemSize

          push    ds
          push    es

          sub     ax,ax
          mov     es,ax
          mov     ds,ax

          call    CalkNumBlockForMemTests

        mov     esi,[dword cs:AdrHMS]

        shr     ecx,1
        lea     esi,[esi+ecx*8]
        neg     ecx
        mov     edx,ecx

        call    StartNewTimer
        jmp     short NextMemPeakSpeedBlockLodsD64

        ALIGN 16

NextMemPeakSpeedBlockLodsD64:
LodsDBytesPeakBlock64:
        mov     eax,[esi+ecx*8+000h]
        mov     eax,[esi+ecx*8+040h]
        add     ecx,16
        jnz     short LodsDBytesPeakBlock64

        mov     ecx,edx

        dec     bx
        jnz     short NextMemPeakSpeedBlockLodsD64


          call    StopNewTimer

          pop     es
          pop     ds

          pop     cx
          pop     ebx

          jmp     CalcSpeed
ENDP GetMemPeakBandwidth64

ALIGN 16

PROC GetMemPeakBandwidth128

          push    ebx
          push    cx
          mov     ax,cx

          call    DetectMemSize

          push    ds
          push    es

          sub     ax,ax
          mov     es,ax
          mov     ds,ax

          call    CalkNumBlockForMemTests

        mov     esi,[dword cs:AdrHMS]

        shr     ecx,1
        lea     esi,[esi+ecx*8]
        add     esi,64
        neg     ecx
        mov     edx,ecx

        call    StartNewTimer
        jmp     short NextMemPeakSpeedBlockLodsD128

        ALIGN 16

NextMemPeakSpeedBlockLodsD128:
LodsDBytesPeakBlock128:
        mov     eax,[esi+ecx*8-040h]
        mov     eax,[esi+ecx*8+040h]
        add     ecx,32
        jnz     short LodsDBytesPeakBlock128

        mov     ecx,edx

        dec     bx
        jnz     short NextMemPeakSpeedBlockLodsD128


          call    StopNewTimer

          pop     es
          pop     ds

          pop     cx
          pop     ebx

          jmp     short CalcSpeed
ENDP GetMemPeakBandwidth128

ALIGN 2

PROC MemSpeedBlockLodsd        ; 1182  ;Вход AX 0-200 Выход AX Mb/s *10
          call    DetectMemSize
PROC MemSpeedBlockForZamerLodsd

          push    ds
          push    es

          sub     ax,ax
          mov     es,ax
          mov     ds,ax

          call    CalkNumBlockForMemTests
          push    ebp

;        mov     ebp,[dword cs:AdrHMS]
;
;        shr     edx,3
;        push    edx
;
;        shr     ecx,3
;        mov     edx,ecx
;        mov     esi,ebp
;
;        call    StartNewTimer
;        jmp     NextMemSpeedBlockLodsD
;
;        ALIGN 16
;
;NextMemSpeedBlockLodsD:
;LodsDBytesBlock:
;        add     esi,32
;        mov     eax,[esi-32]
;        mov     eax,[esi-28]
;        mov     eax,[esi-24]
;        mov     eax,[esi-20]
;        mov     eax,[esi-16]
;        mov     eax,[esi-12]
;        mov     eax,[esi-8]
;        mov     eax,[esi-4]
;        dec     ecx
;        jnz     LodsDBytesBlock
;        mov     esi,ebp
;        mov     ecx,edx
;
;        dec     bx
;        cmp     bh,0FFh
;        jz      SkipDohistkaLodsD
;        or      bx,bx
;        jnz     NextMemSpeedBlockLodsD
;
;        pop     ecx
;        or      ecx,ecx
;        jnz     NextMemSpeedBlockLodsD
;SkipDohistkaLodsD:

          mov     ebp,[dword cs:AdrHMS]
          call    StartNewTimer
          cld
          push    edx
          mov     edx,ecx
          jmp     short NextMemSpeedBlockLodsd
          ALIGN 16
NextMemSpeedBlockLodsd:
          mov     ecx,edx
          mov     esi,ebp

          DB      0F3h,66h,67h,0ADh   ;repe Lodsd
          dec     bx
          jnz     short NextMemSpeedBlockLodsd

          pop     ecx
          jecxz   short SkipDohistkaLodsd
          mov     esi,ebp
          DB      0F3h,66h,67h,0ADh   ;repe lodsd
SkipDohistkaLodsd:

          call    StopNewTimer

          pop     ebp
          pop     es
          pop     ds

CalcSpeed:

          push    ebx
          push    cx
          mov     ebx,eax
          mov     eax,620800520
          mov     edx,1
          div     ebx
          mov     cl,[byte cs:MemSizePriznak]
          shl     eax,cl
          pop     cx
          pop     ebx
          ret
ENDP MemSpeedBlockForZamerLodsd
ENDP MemSpeedBlockLodsd


ALIGN 2
PROC MemSpeedBlockStosd        ; 1182  ;Вход AX 0-200 Выход AX Mb/s *10
          call    DetectMemSize
PROC MemSpeedBlockForZamerStosd

          push    ds
          push    es

          sub     ax,ax
          mov     es,ax
          mov     ds,ax

          call    CalkNumBlockForMemTests

          push    ebp
          mov     eax,[dword cs:AdrHMS]
          push    edi
          call    StartNewTimer
          cld
          push    edx
          mov     edx,ecx
          jmp     short NextMemSpeedBlockStosd

          ALIGN 16

NextMemSpeedBlockStosd:
          mov     ecx,edx
          mov     edi,eax

          DB      0F3h,66h,67h,0ABh   ;repe stosd
          dec     bx
          jnz     short NextMemSpeedBlockStosd

          pop     ecx
          jecxz   short SkipDohistkaStosd
          mov     edi,eax
          DB      0F3h,66h,67h,0ABh   ;repe stosd
SkipDohistkaStosd:

          call    StopNewTimer

          pop     edi
          pop     ebp

          pop     es
          pop     ds

          jmp     short CalcSpeed
ENDP MemSpeedBlockForZamerStosd
ENDP MemSpeedBlockStosd


ALIGN 2
PROC MemSpeedBlockLodsq        ; 1182  ;Вход AX 0-200 Выход AX Mb/s *10
          call    DetectMemSize
PROC MemSpeedBlockForZamerLodsq
          push    ds
          push    es

          sub     ax,ax
          mov     es,ax
          mov     ds,ax

          call    CalkNumBlockForMemTests
          push    ebp
          mov     ebp,[dword cs:AdrHMS]
          call    StartNewTimer
          push    edx
          mov     edx,ecx
          jmp     short NextMemSpeedBlockLodsq
          ALIGN 16

NextMemSpeedBlockLodsq:

          mov     ecx,edx
          mov     esi,ebp
          shr     ecx,5
          jmp     short LodsqBytesBlock1
          ALIGN 16

LodsqBytesBlock1:
          DB 67h,0Fh,6Fh,46h,00;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,08;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,16;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,24;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,32;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,40;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,48;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,56;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+08;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+16;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+24;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+32;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+40;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+48;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+56;movq mm0,[eax+00]
          add     esi,128
          dec     ecx
          jnz     short LodsqBytesBlock1
          dec     bx
          cmp     bh,0FFh
          jz      short SkipDohistkaLodsq
          or      bx,bx
          jnz     short NextMemSpeedBlockLodsq

          pop     ecx
          shr     ecx,5
          mov     esi,ebp
          or      ecx,ecx
          jnz     short LodsqBytesBlock1

SkipDohistkaLodsq:

          call    StopNewTimer
          DB 0Fh,77h;emms

          pop     ebp

          pop     es
          pop     ds

          jmp     CalcSpeed

ENDP MemSpeedBlockForZamerLodsq
ENDP MemSpeedBlockLodsq


          ALIGN 16
PROC MemSpeedBlockLodsqPrg
          push    ds
          push    es

          sub     ax,ax
          mov     es,ax
          mov     ds,ax
          jmp     short LodsqBytesBlock
          ALIGN 16

LodsqBytesBlock:
          DB 67h,0Fh,6Fh,46h,00;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,08;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,16;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,24;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,32;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,40;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,48;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,56;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+08;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+16;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+24;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+32;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+40;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+48;movq mm0,[eax+00]
          DB 67h,0Fh,6Fh,46h,64+56;movq mm0,[eax+00]
          add     esi,128
          dec     ecx
          jnz     short LodsqBytesBlock
          pop     es
          pop     ds
          ret
ENDP MemSpeedBlockLodsqPrg


ALIGN 2
PROC MemSpeedBlockStosq        ; 1182  ;Вход AX 0-200 Выход AX Mb/s *10
          call    DetectMemSize
PROC MemSpeedBlockForZamerStosq

          push    ds
          push    es

          sub     ax,ax
          mov     es,ax
          mov     ds,ax

          call    CalkNumBlockForMemTests
          push    ebp
          mov     ebp,[dword cs:AdrHMS]
          call    StartNewTimer
          push    edx
          mov     edx,ecx
          jmp     short NextMemSpeedBlockStosq

          ALIGN 16

NextMemSpeedBlockStosq:
          mov     ecx,edx
          mov     esi,ebp
          shr     ecx,5
          jmp     short Stosq64bytesBlock1

          ALIGN 16

Stosq64bytesBlock1:
           DB 67h,0Fh,7Fh,46h,00;movq mm0,[esi]
           DB 67h,0Fh,7Fh,46h,08;movq mm0,[esi+08]
           DB 67h,0Fh,7Fh,46h,16;movq mm0,[esi+16]
           DB 67h,0Fh,7Fh,46h,24;movq mm0,[esi+24]
           DB 67h,0Fh,7Fh,46h,32;movq mm0,[esi+32]
           DB 67h,0Fh,7Fh,46h,40;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+8;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+16;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+24;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+32;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+40;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+48;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+56;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+64;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,48+64;movq mm0,[esi+48]
           DB 67h,0Fh,7Fh,46h,56+64;movq mm0,[esi+56]
          add     esi,128
          dec     ecx
          jnz     short Stosq64bytesBlock1

          dec     bx
          cmp     bh,0FFh
          jz      short SkipDohistkaStosq
          or      bx,bx
          jnz     short NextMemSpeedBlockStosq

          pop     ecx
          shr     ecx,5
          mov     esi,ebp
          or      ecx,ecx
          jnz     short Stosq64bytesBlock1

SkipDohistkaStosq:

          call    StopNewTimer
          DB 0Fh,77h;emms

          pop     ebp

          pop     es
          pop     ds

          jmp     CalcSpeed
ENDP MemSpeedBlockForZamerStosq
ENDP MemSpeedBlockStosq


          ALIGN 16
PROC MemSpeedBlockStosqPrg
          push    ds
          push    es

          sub     ax,ax
          mov     es,ax
          mov     ds,ax
          jmp     Stosq64bytesBlock

          ALIGN 16

Stosq64bytesBlock:
           DB 67h,0Fh,7Fh,46h,00;movq mm0,[esi]
           DB 67h,0Fh,7Fh,46h,08;movq mm0,[esi+08]
           DB 67h,0Fh,7Fh,46h,16;movq mm0,[esi+16]
           DB 67h,0Fh,7Fh,46h,24;movq mm0,[esi+24]
           DB 67h,0Fh,7Fh,46h,32;movq mm0,[esi+32]
           DB 67h,0Fh,7Fh,46h,40;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+8;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+16;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+24;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+32;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+40;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+48;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+56;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,40+64;movq mm0,[esi+40]
           DB 67h,0Fh,7Fh,46h,48+64;movq mm0,[esi+48]
           DB 67h,0Fh,7Fh,46h,56+64;movq mm0,[esi+56]
          add     esi,128
          dec     ecx
          jnz     short Stosq64bytesBlock
          pop     es
          pop     ds
          ret
ENDP MemSpeedBlockStosqPrg

ALIGN 2
PROC MemSpeedBlockMovsq        ; 1182  ;Вход AX 0-200 Выход AX Mb/s *10
          call    DetectMemSize
PROC MemSpeedBlockForZamerMovsq

          push    ds
          push    es

          sub     ax,ax
          mov     es,ax
          mov     ds,ax

          call    CalkNumBlockForMemTests
          push    ebp
          mov     eax,[dword cs:AdrHMS]
          push    edi
          call    StartNewTimer
          push    edx
          mov     edx,ecx
          jmp     short NextMemSpeedBlockMovsq

          ALIGN 16

NextMemSpeedBlockMovsq:
          mov     ecx,edx
          mov     esi,eax
          mov     edi,eax
          shr     ecx,5
          jmp     short Movsq64bytesBlock1

          ALIGN 16

Movsq64bytesBlock1:
           DB 67h,0Fh,6Fh,46h,00;movq mm0,[esi+00]
           add edi,128
           DB 67h,0Fh,6Fh,4Eh,08;movq mm1,[esi+08]
           add esi,128
           DB 67h,0Fh,6Fh,56h,256-48-64;movq mm2,[esi-48]
           DB 67h,0Fh,7Fh,47h,256-64-64;movq [edi-64],mm0
           DB 67h,0Fh,6Fh,46h,256-40-64;movq mm0,[esi-40]
           DB 67h,0Fh,7Fh,4Fh,256-56-64;movq [edi-56],mm1
           DB 67h,0Fh,6Fh,4Eh,256-32-64;movq mm1,[esi-32]
           DB 67h,0Fh,7Fh,57h,256-48-64;movq [edi-48],mm2
           DB 67h,0Fh,6Fh,56h,256-24-64;movq mm2,[esi-24]
           DB 67h,0Fh,7Fh,47h,256-40-64;movq [edi-40],mm0
           DB 67h,0Fh,6Fh,46h,256-16-64;movq mm0,[esi-16]
           DB 67h,0Fh,7Fh,4Fh,256-32-64;movq [edi-32],mm1
           DB 67h,0Fh,6Fh,4Eh,256-08-64;movq mm1,[esi-08]
           DB 67h,0Fh,7Fh,57h,256-24-64;movq [edi-24],mm2
           DB 67h,0Fh,7Fh,47h,256-16-64;movq [edi-16],mm0
           DB 67h,0Fh,6Fh,46h,256-00-64;movq mm0,[esi+00]
           DB 67h,0Fh,7Fh,4Fh,256-08-64;movq [edi-08],mm1
           DB 67h,0Fh,6Fh,4Eh,256+08-64;movq mm1,[esi+08]
           DB 67h,0Fh,6Fh,56h,256-48;movq mm2,[esi-48]
           DB 67h,0Fh,7Fh,47h,256-64;movq [edi-64],mm0
           DB 67h,0Fh,6Fh,46h,256-40;movq mm0,[esi-40]
           DB 67h,0Fh,7Fh,4Fh,256-56;movq [edi-56],mm1
           DB 67h,0Fh,6Fh,4Eh,256-32;movq mm1,[esi-32]
           DB 67h,0Fh,7Fh,57h,256-48;movq [edi-48],mm2
           DB 67h,0Fh,6Fh,56h,256-24;movq mm2,[esi-24]
           DB 67h,0Fh,7Fh,47h,256-40;movq [edi-40],mm0
           DB 67h,0Fh,6Fh,46h,256-16;movq mm0,[esi-16]
           DB 67h,0Fh,7Fh,4Fh,256-32;movq [edi-32],mm1
           DB 67h,0Fh,6Fh,4Eh,256-08;movq mm1,[esi-08]
           DB 67h,0Fh,7Fh,57h,256-24;movq [edi-24],mm2
           DB 67h,0Fh,7Fh,47h,256-16;movq [edi-16],mm0
           dec ecx
           DB 67h,0Fh,7Fh,4Fh,256-08;movq [edi-08],mm1
          jnz     Movsq64bytesBlock1

          dec     bx
          cmp     bh,0FFh
          jz      short SkipDohistkaMovsq
          or      bx,bx
          jnz     NextMemSpeedBlockMovsq

          pop     ecx
          shr     ecx,5
          mov     esi,eax
          mov     edi,eax
          or      ecx,ecx
          jnz     Movsq64bytesBlock1

SkipDohistkaMovsq:
          call    StopNewTimer
          DB 0Fh,77h;emms
          pop     edi
          pop     ebp

          pop     es
          pop     ds

          jmp     CalcSpeed
ENDP MemSpeedBlockForZamerMovsq
ENDP MemSpeedBlockMovsq

          ALIGN 16
PROC MemSpeedBlockMovsqPrg
          push    ds
          push    es

          sub     ax,ax
          mov     es,ax
          mov     ds,ax
          jmp     short Movsq64bytesBlock

          ALIGN 16

Movsq64bytesBlock:
           DB 67h,0Fh,6Fh,46h,00;movq mm0,[esi+00]
           add edi,128
           DB 67h,0Fh,6Fh,4Eh,08;movq mm1,[esi+08]
           add esi,128
           DB 67h,0Fh,6Fh,56h,256-48-64;movq mm2,[esi-48]
           DB 67h,0Fh,7Fh,47h,256-64-64;movq [edi-64],mm0
           DB 67h,0Fh,6Fh,46h,256-40-64;movq mm0,[esi-40]
           DB 67h,0Fh,7Fh,4Fh,256-56-64;movq [edi-56],mm1
           DB 67h,0Fh,6Fh,4Eh,256-32-64;movq mm1,[esi-32]
           DB 67h,0Fh,7Fh,57h,256-48-64;movq [edi-48],mm2
           DB 67h,0Fh,6Fh,56h,256-24-64;movq mm2,[esi-24]
           DB 67h,0Fh,7Fh,47h,256-40-64;movq [edi-40],mm0
           DB 67h,0Fh,6Fh,46h,256-16-64;movq mm0,[esi-16]
           DB 67h,0Fh,7Fh,4Fh,256-32-64;movq [edi-32],mm1
           DB 67h,0Fh,6Fh,4Eh,256-08-64;movq mm1,[esi-08]
           DB 67h,0Fh,7Fh,57h,256-24-64;movq [edi-24],mm2
           DB 67h,0Fh,7Fh,47h,256-16-64;movq [edi-16],mm0
           DB 67h,0Fh,6Fh,46h,256-00-64;movq mm0,[esi+00]
           DB 67h,0Fh,7Fh,4Fh,256-08-64;movq [edi-08],mm1
           DB 67h,0Fh,6Fh,4Eh,256+08-64;movq mm1,[esi+08]
           DB 67h,0Fh,6Fh,56h,256-48;movq mm2,[esi-48]
           DB 67h,0Fh,7Fh,47h,256-64;movq [edi-64],mm0
           DB 67h,0Fh,6Fh,46h,256-40;movq mm0,[esi-40]
           DB 67h,0Fh,7Fh,4Fh,256-56;movq [edi-56],mm1
           DB 67h,0Fh,6Fh,4Eh,256-32;movq mm1,[esi-32]
           DB 67h,0Fh,7Fh,57h,256-48;movq [edi-48],mm2
           DB 67h,0Fh,6Fh,56h,256-24;movq mm2,[esi-24]
           DB 67h,0Fh,7Fh,47h,256-40;movq [edi-40],mm0
           DB 67h,0Fh,6Fh,46h,256-16;movq mm0,[esi-16]
           DB 67h,0Fh,7Fh,4Fh,256-32;movq [edi-32],mm1
           DB 67h,0Fh,6Fh,4Eh,256-08;movq mm1,[esi-08]
           DB 67h,0Fh,7Fh,57h,256-24;movq [edi-24],mm2
           DB 67h,0Fh,7Fh,47h,256-16;movq [edi-16],mm0
           dec ecx
           DB 67h,0Fh,7Fh,4Fh,256-08;movq [edi-08],mm1
          jnz     Movsq64bytesBlock
          pop     es
          pop     ds
          ret
ENDP MemSpeedBlockMovsqPrg


          ALIGN 16
PROC MemSpeedBlockMovsdPrg
          push    ds
          push    es
          sub     ax,ax
          mov     ds,ax
          mov     es,ax
          cld
          mov     esi,[dword cs:AdrHMS]
          mov     edi,esi
          DB      0F3h,66h,67h,0A5h   ;repe movsd
          pop     es
          pop     ds
          ret
ENDP MemSpeedBlockMovsdPrg


          ALIGN 16
PROC MemSpeedBlockStosdPrg
          push    ds
          push    es

          sub     ax,ax
          mov     ds,ax
          mov     es,ax

          cld
          mov     edi,[dword cs:AdrHMS]
          DB      0F3h,66h,67h,0ABh   ;repe stosd
          pop     es
          pop     ds
          ret
ENDP MemSpeedBlockStosdPrg


          ALIGN 16
PROC MemSpeedBlockLodsdPrg
          push    ds
          push    es
          sub     ax,ax
          mov     ds,ax
          mov     es,ax
          cld
          mov     esi,[dword cs:AdrHMS]
          DB      0F3h,66h,67h,0ADh   ;repe Lodsd
          pop     es
          pop     ds
          ret
ENDP MemSpeedBlockLodsdPrg

ALIGN 2
PROC DetectMemSize
          mov     bl,25
          div     bl
          mov     cl,al
          mov     ebx,1024
NextAddForMemTim:
          or      ah,ah
          jz      short EndAddForMemTim
          dec     ah
          add     ebx,41
          jmp     short NextAddForMemTim
EndAddForMemTim:
          shl     ebx,cl
          mov     cl,[byte cs:MemSizePriznak]
          shl     ebx,cl
          and     bl,0E0h
          ret
ENDP DetectMemSize

ALIGN 2
PROC CalkNumBlockForMemTests
          xor     edx,edx
          mov     eax,1048576
          mov     cl,[byte cs:MemSizePriznak]
          shl     eax,cl
          mov     ecx,ebx
          div     ebx
          mov     ebx,eax
          ret
ENDP CalkNumBlockForMemTests

;ALIGN 2
;PROC MemIDX
;          push    ds
;          push    es

;          sub     ax,ax
;          mov     ds,ax
;          mov     es,ax

;          push    edi
;          push    bx
;          push    ecx
;          mov     esi,[dword cs:AdrHMS]
;          mov     edi,esi
;          cld
;          DB      0F3h,66h,67h,0A5h   ;repe movsd
;          pop     ecx
;          call    StartNewTimer
;          mov     bl,4
;NextCacheBlock1:
;          push    ecx
;          mov     esi,[dword cs:AdrHMS]
;          mov     edi,esi
;          DB      0F3h,66h,67h,0A5h   ;repe movsd
;          pop     ecx
;          dec     bl
;          jnz     short NextCacheBlock1
;          call    StopNewTimer
;          pop     bx
;          pop     edi

;          pop     es
;          pop     ds

;          ret
;ENDP MemIDX

ALIGN 2
PROC ClearHMSblock
          mov     eax,100000h
          mov     cl,[byte cs:MemSizePriznak]
          shl     eax,cl
          mov     ecx,eax

          push    ds
          push    es

          mov     ds,ax
          mov     es,ax

          mov     esi,[dword cs:AdrHMS]
          mov     edi,esi
          cld
          DB      0F3h,66h,67h,0A5h   ;repe movsd

          pop     es
          pop     ds
          ret
ENDP ClearHMSblock

PUBLIC PutWordToReportBuf,PrnRepLine,PutByteToReportBuf,PutToReportBuf,PutDOSStr,Encoding

PROC PutWordToReportBuf
          push     es
          push     [ReportDataSeg] ;Сегмент для для файла отчета
          pop      es
          mov      di,[CounterRepBuf]
          cld
          stosw
          mov      [CounterRepBuf],di
          pop      es
          ret
ENDP PutWordToReportBuf

PROC PrnRepLine
          push     ax
          push     cx
          mov      ax,0A0Dh
          call     PutWordToReportBuf
          mov      al,32
          call     PutByteToReportBuf
          mov      cx,75
NextPrnByteForRepLine:
          mov      al,196
          call     PutByteToReportBuf
          loop     short NextPrnByteForRepLine
          pop      cx
          pop      ax
          ret
ENDP PrnRepLine

PROC PutByteToReportBuf
          push     es
          push     [ReportDataSeg] ;Сегмент для для файла отчета
          pop      es
          mov      di,[CounterRepBuf]
          cld
          stosb
          mov      [CounterRepBuf],di
          pop      es
          ret
ENDP PutByteToReportBuf

PROC PutToReportBuf
          push     eax
          push     di
          push     es
          mov      ax,[ReportDataSeg] ;Сегмент для для файла отчета
          mov      es,ax
          mov      di,[CounterRepBuf]
NextByteForRepFile:
          cld
          lodsb
          or       al,al
          jz       EndStrDetectForRepFile

          cmp      al,250
          jnz      short NotMicro
          mov      al,'u'
          jmp      short NotTMLabel
NotMicro:
          cmp      al,26
          jnz      short DetectCommandByte18
          lodsb
          cmp      [RepStrCounter],al
          jae      short NextByteForRepFile
          mov      ah,al
          mov      al,32
NextPutSpaceForRep:
          stosb
          inc      [RepStrCounter]
          cmp      [RepStrCounter],ah
          jb       short NextPutSpaceForRep
          jmp      short NextByteForRepFile

DetectCommandByte18:
          cmp      al,18
          jz       short SkipPutSimv
          cmp      al,19
          jz       short SkipPutSimv
          cmp      al,31
          jz       short SkipPutSimv
          cmp      al,30
          jz       short SkipPutSimv
          cmp      al,23
          jz       short SkipPos
          cmp      al,22
          jz       short SkipAt
          cmp      al,25
          jz       short SkipPutSimv
          cmp      al,17
          jnz      short NoSetColorDetect
SkipPos:
          lodsb
          jmp      short SkipPutSimv
SkipAt:
          lodsw
          jmp      short SkipPutSimv
NoSetColorDetect:
          cmp      al,13
          jnz      short NoNextStrDetect
          mov      [RepStrCounter],0
          mov      ax,0A0Dh
          stosw
          jmp      short SkipPutSimv

NoNextStrDetect:
          cmp      al,252
          jnz      short NotRegistredLabel
          lodsb
          mov      eax,' )r('
          jmp      short PutToBuffDword

NotRegistredLabel:
          cmp      al,254
          jnz      short NotTMLabel
          lodsb
          mov      eax,')mt('
PutToBuffDword:
          stosd
          add      [RepStrCounter],4
          jmp      short SkipPutSimv
NotTMLabel:
          stosb
          inc      [RepStrCounter]
SkipPutSimv:
          jmp      NextByteForRepFile

EndStrDetectForRepFile:
          mov      [CounterRepBuf],di
          pop      es
          pop      di
          pop      eax
          ret
ENDP PutToReportBuf

PROC PutDOSStr
          push    ax
          mov     ah,9
          int     21h
          pop     ax
          ret
ENDP PutDOSStr

PROC Encoding
          mov    di,si
          cld
NextByteIncripting:
          lodsb
          or     al,al
          jz     short NotNidedIncripting
          cmp    al,5Ah
          jz     short NotNidedIncripting
          xor    al,5Ah
NotNidedIncripting:
          stosb
          loop   short NextByteIncripting
          ret
ENDP Encoding

PUBLIC GetIntelCacheSize

PROC GetIntelCacheSize

          test    edx,80000000h
          jnz     NotValidCacheInfo
          sub     ax,ax
          cmp     [CPUfamily],0Fh
          jnz     short NoP4Fam
          cmp     dl,40h
          jz      DetectCacheL3
          jmp     GoToDetectNextIntelCS
NoP4Fam:
          cmp     dl,40h
          jz      DetectCacheL2
GoToDetectNextIntelCS:

          mov     ax,8
          cmp     dl,6h
          jz      DetectCacheL1
          cmp     dl,0Ah
          jz      DetectDataCacheL1
          cmp     dl,66h
          jz      DetectDataCacheL1

          mov     ax,12
          cmp     dl,70h
          jz      DetectCacheL1

          mov     ax,16
          cmp     dl,8h
          jz      DetectCacheL1
          cmp     dl,15h
          jz      DetectCacheL1
          cmp     dl,71h
          jz      DetectCacheL1
          cmp     dl,0Ch
          jz      DetectDataCacheL1
          cmp     dl,10h
          jz      DetectDataCacheL1
          cmp     dl,67h
          jz      DetectDataCacheL1

          mov     ax,32
          cmp     dl,72h
          jz      DetectCacheL1
          cmp     dl,68h
          jz      DetectDataCacheL1

          mov     ax,96
          cmp     dl,1Ah
          jz      DetectCacheL2

          mov     ax,128
          cmp     dl,39h
          jz      DetectCacheL2
          cmp     dl,3Bh
          jz      DetectCacheL2
          cmp     dl,41h
          jz      DetectCacheL2
          cmp     dl,79h
          jz      DetectCacheL2
          cmp     dl,81h
          jz      DetectCacheL2

          mov     ax,256
          cmp     dl,3Ch
          jz      short DetectCacheL2
          cmp     dl,42h
          jz      short DetectCacheL2
          cmp     dl,7Ah
          jz      short DetectCacheL2
          cmp     dl,7Eh
          jz      short DetectCacheL2
          cmp     dl,82h
          jz      short DetectCacheL2

          mov     ax,512
          cmp     dl,22h
          jz      short DetectCacheL3
          cmp     dl,43h
          jz      short DetectCacheL2
          cmp     dl,7Bh
          jz      short DetectCacheL2
          cmp     dl,83h
          jz      short DetectCacheL2

          mov     ax,1024
          cmp     dl,23h
          jz      short DetectCacheL3
          cmp     dl,44h
          jz      short DetectCacheL2
          cmp     dl,7Ch
          jz      short DetectCacheL2
          cmp     dl,84h
          jz      short DetectCacheL2

          mov     ax,2048
          cmp     dl,25h
          jz      short DetectCacheL3
          cmp     dl,45h
          jz      short DetectCacheL2
          cmp     dl,85h
          jz      short DetectCacheL2
          cmp     dl,88h
          jz      short DetectCacheL3

          mov     ax,3096
          cmp     dl,8Dh
          jz      short DetectCacheL3

          mov      ax,4096
          cmp      dl,29h
          jz       short DetectCacheL3
          cmp      dl,89h
          jz       short DetectCacheL3

          mov      ax,8192
          cmp      dl,8Ah
          jz      short DetectCacheL3
          ret
DetectDataCacheL1:
          mov     [DataCacheL1],ax
DetectCacheL1:
          add     [CacheL1],ax
          ret
DetectCacheL2:
          mov     [CacheL2],ax
          ret
DetectCacheL3:
          mov     [CacheL3],ax
NotValidCacheInfo:
          ret
ENDP GetIntelCacheSize

PUBLIC GetALISPDByte,GetAMD756SPDByte,GetIntelSPDByte,GetSiSSPDByte,GetSiSSPDByte2,GetnForceMCPTByte

PROC GetALISPDByte ; Return al- SPD byte

;          sub     cx,cx
;          mov     dx,[BaseAdrSMBus]
;WatingALISMBUSAccess:
;          in      al,dx
;          test    al,8
;          jz      ExitWaitingALISMBUS

;          loop    short WatingALISMBUSAccess
;          push    ax
;          inc     dx
;          mov     al,4
;          out     dx,al
;          dec     dx
;          pop     ax
;ExitWaitingALISMBUS:
;          out     dx,al

          mov     al,[SPDSocket]
          sub     al,50h
          shl     ax,1
          add     ax,0A1h
          mov     ah,al
          mov     dx,[BaseAdrSMBus]
          mov     al,0FFh
          out     dx,al
          sub     cx,cx
loc_322:
          jmp     $+2
          in      al,dx
          test    al,4
          jnz     short loc_3221
          loop    loc_322
loc_3221:
          add     dx,3
          mov     al,ah
          out     dx,al
          sub     dx,2
          mov     al,20h
          out     dx,al
          add     dx,6
          mov     al,[NumByteSPD]
          out     dx,al
          sub     dx,5
          mov     al,0FFh
          out     dx,al
          sub     dx,2
          sub     cx,cx
loc_323:
          jmp     $+2
          in      al,dx
          test    al,60h
          jnz     short loc_324
          test    al,10h
          jnz     short loc_3231
          loop    loc_323
loc_324:
          mov     al,0FFh
          jmp     short loc_321
loc_3231:
          add     dx,4
          in      al,dx
loc_321:
          ret
ENDP GetALISPDByte

PROC GetAMD756SPDByte ; Return al- SPD byte
          mov     dx,[BaseAdrSMBus]
          add     dx,0E0h
          in      ax,dx
          jmp     $+2
          out     dx,ax

          sub     cx,cx
loc_63:
          jmp     $+2
          in      ax,dx
          test    ax,8
          jz      short loc_66
          loop    short loc_63
loc_64:
          add     dx,2
          mov     ax,20h
          out     dx,ax

          sub     cx,cx
loc_65:
          jmp     $+2
          jmp     $+2
          loop    loc_65
loc_66:
          mov     al,[SPDSocket]
          mov     ah,0
          shl     ax,1
          or      ax,1
          mov     dx,[BaseAdrSMBus]
          add     dx,0E4h
          out     dx,ax
          add     dx,4
          mov     al,[NumByteSPD]
          out     dx,al
          sub     dx,6
          mov     ax,0Ah
          out     dx,ax
          sub     dx,2

          sub     cx,cx
loc_43:
          jmp     $+2
          in      ax,dx
          test    ax,8
          jnz     short loc_441
          loop    short loc_43
loc_441:
          sub    cx,cx
loc_45:
          jmp     $+2
          in      ax,dx
          test    ax,8
          jz      short loc_47
          loop    short loc_45
loc_47:
          in      ax,dx
          test    ax,10h
          jnz     short loc_78
          mov     al,0FFh
          jmp     short loc_80
loc_78:
          add     dx,6
          in      al,dx
loc_80:
          ret
ENDP GetAMD756SPDByte


PROC GetIntelSPDByte;  Return al- SPD byte
          sub     cx,cx
WatingSMBUSAccess:
          mov     dx,[BaseAdrSMBus]
          in      al,dx
          or      al,al
          jz      short SMBUSAccessOK
          test    al,1
          jnz     short GoToWaitingResetSPD
          out     dx,al
          loop    short WatingSMBUSAccess
GoToWaitingResetSPD:

          push    cx
          sub     cx,cx
WaitingResetSPD:
          in      al,dx
          test    al,1
          jz      short WaitingResetSPDOk
          loop    short WaitingResetSPD
          add     dx,2
          mov     al,2
          out     dx,al
WaitingResetSPDOk:
          pop     cx
          loop    short WatingSMBUSAccess
SMBUSAccessOK:

          mov     dx,[BaseAdrSMBus]
          add     dx,3
          mov     al,[NumByteSPD]
          out     dx,al
          inc     dx
          mov     al,[SPDSocket]
          shl     al,1
          inc     al
          out     dx,al
          sub     dx,2
          mov     al,48h
          out     dx,al
          sub     dx,2
          sub     cx,cx
WaitingSetSPD:
          in      al,dx
          test    al,1Ch
          jnz     short ErrWatingSMBUS
          test    al,2
          jnz     short GetSPDByteReady
          loop    short WaitingSetSPD
ErrWatingSMBUS:
          mov     al,0FFh
          jmp     short GoToEndGetSPDByte
GetSPDByteReady:
          add     dx,5
          in      al,dx
GoToEndGetSPDByte:
          ret
ENDP GetIntelSPDByte

PROC GetSiSSPDByte
            mov     dx,[BaseAdrSMBus]
            add     dx,38h

            sub     cx,cx
loc_468:
            sub     al,al
            out     dx,al
            inc     dx
            in      al,dx
            jmp     $+2
            dec     dx
            test    al,36h
            jz      short loc_472
            push    ax
            sub     al,al
            out     dx,al
            inc     dx
            pop     ax
            out     dx,al
            dec     dx
            loop    short loc_468
            mov     al,2
            out     dx,al
            inc     dx
            mov     al,20h
            out     dx,al
            dec     dx
loc_472:
            sub     al,al
            out     dx,al
            inc     dx
            in      al,dx
            jmp     $+2
            dec     dx

            push    ax
            sub     al,al
            out     dx,al
            inc     dx
            pop     ax
            out     dx,al
            dec     dx

            mov     al,[SPDSocket]
            shl     al,1                    ; Shift w/zeros fill
            inc     al
            push    ax
            mov     al,4
            out     dx,al
            inc     dx
            pop     ax
            out     dx,al
            dec     dx

            mov     al,[NumByteSPD]
            push    ax
            mov     al,5
            out     dx,al
            inc     dx
            pop     ax
            out     dx,al
            dec     dx

            mov     al,2
            out     dx,al
            inc     dx
            mov     al,14h
            out     dx,al
            dec     dx

            mov     ecx,1000000
WaitSiSSPDByteReady:
            sub     al,al
            out     dx,al
            jmp     $+2
            inc     dx
            in      al,dx
            dec     dx
            test    al,30h
            jnz     short ErrorSiSSPDAccess
            test    al,40h
            jnz     short GoToGetSISSPDByte
            dec     ecx
            or      ecx,ecx
            jnz     short WaitSiSSPDByteReady
            jmp     short ErrorSiSSPDAccess
ErrorSiSSPDAccess:
          mov     al,0FFh
          jmp     short GoToEndGetSISSPDByte

GoToGetSISSPDByte:
            mov     al,8
            out     dx,al
            jmp     $+2
            inc     dx
            in      al,dx
GoToEndGetSISSPDByte:
            ret
ENDP GetSiSSPDByte

PROC GetSiSSPDByte2
            mov     dx,[BaseAdrSMBus]
            add     dx,2

            in      al,dx
            test    al,1h
            jz      short SiSSBBusReadyOK
            inc     dx
            mov     al,20h
            out     dx,al
            dec     dx
SiSSBBusReadyOK:
            sub     dx,2
            in      al,dx
            out     dx,al

            add     dx,4
            mov     al,[SPDSocket]
            shl     al,1                    ; Shift w/zeros fill
            inc     al
            out     dx,al
            inc     dx
            mov     al,[NumByteSPD]
            out     dx,al
            sub     dx,2
            mov     al,12h
            out     dx,al

            sub     dx,3

            mov     ecx,1000000

WaitSiSSPDByteReady2:
            in      al,dx
            test    al,6
            jnz     short WaitErrorInGetSiSSMBusByte
            test    al,8
            jnz     short ReadyToGetSiSSMBusByte
            dec     ecx
            or      ecx,ecx
            jnz     short WaitSiSSPDByteReady2
WaitErrorInGetSiSSMBusByte:
            mov     al,0FFh
            jmp     short ErrorInGetSiSSMBusByte
ReadyToGetSiSSMBusByte:
            add     dx,8
            in      al,dx

ErrorInGetSiSSMBusByte:

            ret
ENDP GetSiSSPDByte2

PROC GetnForceMCPTByte
            mov     dx,[BaseAdrSMBus]
            inc     dx
            mov     al,1Fh
            out     dx,al     ;BaseAdrSMBus+1
            inc     dx

            mov     al,[SPDSocket]
            shl     al,1
            inc     al
            out     dx,al     ;BaseAdrSMBus+2
            inc     dx
            mov     al,[NumByteSPD]
            out     dx,al     ;BaseAdrSMBus+3
            sub     dx,3
            mov     al,7
            out     dx,al     ;BaseAdrSMBus

            inc     dx

            mov     ecx,1000000

WaitMCPTSPDByteReady2:
            in      al,dx     ;BaseAdrSMBus+1
            test    al,80h
            jz      short WaitInGetMCPTSMBusByte
            test    al,1Fh
            jz      short ReadyToGetMCPTSMBusByte
            jmp     short WaitErrorInGetMCPTSMBusByte
WaitInGetMCPTSMBusByte:
            dec     ecx
            or      ecx,ecx
            jnz     short WaitMCPTSPDByteReady2
WaitErrorInGetMCPTSMBusByte:
            mov     al,0FFh
            jmp     short ErrorInGetMCPTSMBusByte
ReadyToGetMCPTSMBusByte:
            add     dx,3      ;BaseAdrSMBus+4
            in      al,dx
ErrorInGetMCPTSMBusByte:
            ret
ENDP GetnForceMCPTByte


PUBLIC Setka

PROC Setka
          mov     bp,3
          mov     cx,8
          mov     bx,16
NextPointLine1:
          push    cx
          mov     ax,312
NextPoint1:
          mov     cx,1
          call    ColorVerLine
          add     ax,5
          cmp     ax,617
          jnz     short NextPoint1
          pop     cx
          add     bx,32
          loop    short NextPointLine1
          mov     cx,6
          mov     ax,362
NextPointLine2:
          push    cx
          mov     bx,16
NextPoint2:
          mov     cx,1
          call    ColorVerLine
          add     bx,4
          cmp     bx,272
          jbe     short NextPoint2
          pop     cx
          add     ax,50
          loop    short NextPointLine2
          mov     ax,312
          mov     bx,272
          mov     cx,301
          mov     bp,3+8
          call    ColorHorLine
          mov     bx,16
          mov     cx,256
          call    ColorVerLine
          ret
ENDP Setka

PUBLIC EnDisSPDAccessOnCUSL2,EnDisSPDAccessOnCUR
PUBLIC EnDisSPDAccessOnP4B,EnDisSPDAccessOnA7A

PROC EnDisSPDAccessOnCUSL2
          mov       dx,0002Eh
          mov       al,087h
          out       dx,al
          out       dx,al
          mov       al,07h
          out       dx,al
          inc       dx
          mov       al,08h
          out       dx,al
          dec       dx
          mov       ah,0F1h
          mov       al,ah
          out       dx,al
          inc       dx
          in        al,dx
          and       al,0E7h
          or        al,cl
          dec       dx
          xchg      ah,al
          out       dx,al
          inc       dx
          mov       al,ah
          out       dx,al
          dec       dx
          mov       al,0AAh
          out       dx,al
          ret
ENDP EnDisSPDAccessOnCUSL2

PROC EnDisSPDAccessOnCUR
          mov       dx,0EC80h
          in        al,dx
          mov       ah,cl
          and       ah,10h
          and       al,0EFh
          or        al,ah
          out       dx,al
          add       dl,4
          in        al,dx
          and       cl,20h
          shr       cl,1
          and       al,0EFh
          or        al,cl
          out       dx,al
          ret
ENDP EnDisSPDAccessOnCUR


PROC EnDisSPDAccessOnP4B   ;cl-1 , cl-2, cl-3
          mov         dx,2Eh
          mov         al,087h
          out         dx,al
          out         dx,al
          mov         al,007
          out         dx,al
          inc         dx
          out         dx,al
          dec         dx
          mov         al,0F2h
          out         dx,al
          inc         dx
          in          al,dx
          and         al,0FCh
          or          al,cl
          out         dx,al
          dec         dx
          mov         al,2
          out         dx,al
          inc         dx
          in          al,dx
          or          al,2
          out         dx,al
          ret
ENDP EnDisSPDAccessOnP4B

PROC EnDisSPDAccessOnA7A ;cl-40h, cl-20h, cl-60h
          mov         eax,0800088B8h
          mov         dx,00CF8h
          out         dx,eax
          mov         dl,0FCh
          in          al,dx
          and         al,09Fh
          or          al,cl
          out         dx,al
          ret
ENDP EnDisSPDAccessOnA7A

PUBLIC UnpackPCIString

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

ALIGN 16
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

ALIGN 16
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

PUBLIC CorrectSPDSpeedToStd,CorrectDDRSPDSpeedToStd,NonZeroPrn,GetStringLength

PROC CorrectSPDSpeedToStd
          push    bx
          mov     bx,ax
          mov     ax,133
          cmp     bx,ax
          jae     short PrnPCxxxSpeedForRep
          mov     ax,100
          cmp     bx,ax
          jae     short PrnPCxxxSpeedForRep
          mov     ax,66
PrnPCxxxSpeedForRep:
          pop     bx
          ret
ENDP CorrectSPDSpeedToStd

PROC CorrectDDRSPDSpeedToStd
          push    bx
          mov     bx,ax
          mov     ax,166
          cmp     bx,ax
          jae     short PrnDDRPCxxxSpeedForRep
          mov     ax,133
          cmp     bx,ax
          jae     short PrnDDRPCxxxSpeedForRep
          mov     ax,100
PrnDDRPCxxxSpeedForRep:
          pop     bx
          ret
ENDP CorrectDDRSPDSpeedToStd

PROC NonZeroPrn
TestNextByteNonZeroPrn:
          cmp     [byte ds:si+1],'.'
          jz      short ExitFromNonZeroPrn
          cmp     [byte ds:si],'0'
          jz      short DetectZeroPrn
          cmp     [byte ds:si],' '
          jnz     short ExitFromNonZeroPrn
DetectZeroPrn:
          inc     si
          jmp     short TestNextByteNonZeroPrn
ExitFromNonZeroPrn:
          cmp     [byte ds:si],0
          jnz     short NotEndStr
          dec     si
NotEndStr:
          ret
ENDP NonZeroPrn

          ALIGN 2
PROC GetStringLength ;cx- string length
          push    ax
          push    si
          ALIGN 2
NextByteofStringForPCI:
          lodsb
          or      al,al
          jz      short FoundEndofStringForPCI
          cmp     al,2
          jz      short FoundEndofStringForPCI
          cmp     al,1
          jz      short FoundEndofStringForPCI
          jmp     short NextByteofStringForPCI
          ALIGN 2
FoundEndofStringForPCI:
          mov     cx,si
          pop     si
          sub     cx,si
          dec     cx
          pop     ax
          ret
ENDP GetStringLength

PUBLIC CheckMSCDEX,GetCorrectFrec,CorrectDMIFSB

PROC CheckMSCDEX
          mov     bx,0DADAh
          push    bx
          mov     ax,1100h
          int     2Fh
          pop     bx
          cmp     bx,0ADADh
          ret
ENDP CheckMSCDEX

PROC GetCorrectFrec
          mov     cx,6
          add     ax,3
NextSearchForCorrectFrec:
          mov     si,offset FaindCorrectFrec
NextCompareFrec:
          mov     bx,[word cs:si]
          cmp     ax,bx
          jz      short FaundCorrectFrec
          add     si,2
          or      bx,bx
          jnz     short NextCompareFrec
          dec     ax
          loop    short NextSearchForCorrectFrec
          add     ax,3
FaundCorrectFrec:
          ret
FaindCorrectFrec DW  40, 50, 66, 75, 83, 90,100,120,133,150
                 DW 166,180,187,190,200,210,225,233,240,262
                 DW 266,280,300,350,333,380,366,400,433,450
                 DW 466,475,500,533,550,566,600,650,667,700
                 DW 733,800,850,866,900,933,950,1000,1130
                 DW 1400,1500,000 ;END
ENDP GetCorrectFrec

PROC CorrectDMIFSB
          mov     bx,ax
          cmp     bx,50h ;Error Corect in AMI BIOS bus 66MHz = 102MHz !?
          mov     ax,50
          jz      short CorrectBusSpeedOk
          cmp     bx,60h
          mov     ax,60
          jz      short CorrectBusSpeedOk
          cmp     bx,66h
          mov     ax,66
          jz      short CorrectBusSpeedOk
          cmp     bx,75h
          mov     ax,75
          jz      short CorrectBusSpeedOk
          cmp     bx,83h
          mov     ax,83
          jz      short CorrectBusSpeedOk
          cmp     bx,100h
          mov     ax,100
          jz      short CorrectBusSpeedOk
          mov     ax,bx
CorrectBusSpeedOk:
          ret
ENDP CorrectDMIFSB

PUBLIC Wait3SecKeyWaiting,DetectPentiumClockRatio,CorrectDMIMainBoardName

PROC Wait3SecKeyWaiting
          mov     [LongTimerL],0
WaitPressAnyKeyPressed:
          xor     al,al
          call    KeyWaiting
          jnz     short KeyForPressAnyKeyPressed
          cmp     [LongTimerL],3*14
          jb      short WaitPressAnyKeyPressed
          jmp     short EndOffTime
KeyForPressAnyKeyPressed:
          call    GetCh
EndOffTime:
          ret
ENDP Wait3SecKeyWaiting

PROC DetectPentiumClockRatio
          cmp     [IntelProcessor],1
          jnz     short NoIntelCPUForPentiumClockRatio
          cmp     [CPUfamily],5
          jnz     short NoIntelCPUForPentiumClockRatio
          mov     ax,[CorrectFrec]
          mov     bx,150
          cmp     ax,100
          jz      short DetectClockRatioForPentiumMMXOK
          mov     bx,200
          cmp     ax,133
          jz      short DetectClockRatioForPentiumMMXOK
          mov     bx,250
          cmp     ax,166
          jz      short DetectClockRatioForPentiumMMXOK
          cmp     ax,150
          jz      short DetectClockRatioForPentiumMMXOK
          cmp     ax,187
          jz      short DetectClockRatioForPentiumMMXOK
          mov     bx,300
          cmp     ax,200
          jz      short DetectClockRatioForPentiumMMXOK
          cmp     ax,180
          jz      short DetectClockRatioForPentiumMMXOK
          cmp     ax,225
          jz      short DetectClockRatioForPentiumMMXOK
          mov     bx,350
          cmp     ax,233
          jz      short DetectClockRatioForPentiumMMXOK
          cmp     ax,262
          jnz     short NoIntelCPUForPentiumClockRatio
DetectClockRatioForPentiumMMXOK:
          mov    [ClockRatio],bx
NoIntelCPUForPentiumClockRatio:
          ret
ENDP DetectPentiumClockRatio

PROC CorrectDMIMainBoardName
          sub     cx,cx
          push    si
NextTestWord32:
          cmp     [byte ds:si],0
          jz      short EndMainBoardVendorFound
          cmp     [word ds:si],'  '
          jz      short EndMainBoardVendorFound
          inc     cx
          inc     si
          cmp     cx,20
          jnz     short NextTestWord32
EndMainBoardVendorFound:
          pop    si
          ret
ENDP CorrectDMIMainBoardName


PUBLIC GetBlockSizeForTesting,MesagesFrame

ALIGN 2
PROC GetBlockSizeForTesting
          mov     al,11
          add     al,[byte cs:MemSizePriznak]
          mov     ecx,400h
          ret
ENDP GetBlockSizeForTesting

PROC MesagesFrame
          mov     ax,8
          mov     bx,244
          mov     cx,296
          mov     dx,31
          mov     bp,3+8
          call    ColorFrame
          ret
ENDP MesagesFrame

PUBLIC GetATABlockSize,SetATABlockSize,AtaAtapiGetParam

PROC GetATABlockSize
          dec     dx
          dec     dx
          in      al,dx
          mov     ah,al
          dec     dx
          in      al,dx
          add     dx,3
          mov     cx,ax
          ret
ENDP GetATABlockSize

PROC SetATABlockSize
          dec     dx
          dec     dx
          xchg    ah,al
          out     dx,al
          dec     dx
          mov     al,ah
          out     dx,al
          add     dx,3
          ret
ENDP SetATABlockSize

PROC AtaAtapiGetParam
          sub     di,di
          sub     dx,7
          cld
          cli
          rep insw
          sti
          out     0EDh,al
          add     dx,7
          in      al,dx
          test    al,1 ;Error is Set?
          je      short NoErrorInGetParam
          stc
NoErrorInGetParam:
          ret
ENDP AtaAtapiGetParam

PUBLIC WaitingBusyAndDRQClear,WaitingDRDYSet,WaitingBusy
PUBLIC WaitBusyAndDataRequest,WaitDRQClear

PROC WaitingBusyAndDRQClear
          sub     cx,cx
WaitingForClearBusyAndDRQ:
          out     0EDh,al
          in      al,dx
          test    al,88h    ; Test Bit 7 - Busy ;Bit 3 -DRQ
          je      short BusyAndDRQCleared
          loop    short WaitingForClearBusyAndDRQ
          stc
BusyAndDRQCleared:
          ret
ENDP WaitingBusyAndDRQClear

PROC WaitingDRDYSet
          sub     cx,cx
WaitingForSetDRDY:
          out     0EDh,al
          in      al,dx
          test    al,40h    ; Test Bit 6 - DRDY
          jne     short DRDYIsSet
          loop    short WaitingForSetDRDY
          stc
DRDYIsSet:
          ret
ENDP WaitingDRDYSet

PROC WaitingBusy
          sub     cx,cx
WaitingForClearBusy:
          out     0EDh,al
          in      al,dx
          test    al,80h    ; Test Bit 7 - Busy
          je      short BusyCleared
          loop    short WaitingForClearBusy
          stc
BusyCleared:
          ret
ENDP WaitingBusy

PROC WaitBusyAndDataRequest
          sub     cx,cx
WaitForDataRequest:
          out     0EDh,al
          in      al,dx
          test    al,80h  ; Test Bit 7 - Busy
          jne     short WaitBusyFailed
          test    al,8h   ;test bit 3 - Data Request
          je      short WaitBusyFailed
          test    al,1b   ;ERR is set?
          je      short WaitDataRequestOK
          jmp     short BusyClearingFailed
WaitBusyFailed:
          loop    short WaitForDataRequest
BusyClearingFailed:
          stc
WaitDataRequestOK:
          ret
ENDP WaitBusyAndDataRequest

PROC WaitDRQClear

          mov     bx,10h
NextWaitDRQLoop:
          call    GetATABlockSize
          shr     cx,1
          jcxz    short DRQStateError
          cli
          sub     dx,7
ReadNextByte:
          in      ax,dx
          loop    short ReadNextByte
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
ENDP WaitDRQClear

PUBLIC GetRPM,GetIDString

PROC GetRPM
          call    WaitingBusy
          jc      short ErrorInRPM

          call    WatingRPMstate
          jc      short ErrorInRPM

          call    StartNewTimer
          mov     bx,10
          ALIGN 2
NextGetRPM:
          call    WatingRPMstate
          jc      short ErrorInGetRPM
          dec     bx
          jnz     short NextGetRPM
          call    StopNewTimer
          sub     edx,edx
          mov     ebx,eax
          mov     eax,720712810
          div     ebx
          cmp     ax,3000
          jb      short ErrorInRPM
          cmp     ax,10500
          ja      short ErrorInRPM
          mov     [word ds:si+42+8],ax
ErrorInRPM:
          ret
ErrorInGetRPM:
          call    StopNewTimer
          ret
ENDP GetRPM

          ALIGN 2
PROC WatingRPMstate
          sub     cx,cx
NextWaitRPMstate:
          in      al,dx
          test    al,2
          jmp     $+2
          jz      short WaitRPMstateStep1OK
          loop    short NextWaitRPMstate
          jmp     short ErrorInWaitRPMstate
WaitRPMstateStep1OK:
          sub     cx,cx
NextWaitRPMstateJnz:
          in      al,dx
          test    al,2
          jmp     $+2
          jnz     short WaitRPMstateStep2OK
          loop    short NextWaitRPMstateJnz
ErrorInWaitRPMstate:
          stc
          ret
WaitRPMstateStep2OK:
          clc
          ret
ENDP WatingRPMstate

PROC GetIDString
NextIDWord:
          lodsw
          xchg    ah,al
          stosw
          loop    short NextIDWord
          ret
ENDP GetIDString

PUBLIC GetHDDSizeInGB

PROC GetHDDSizeInGB
          mov     ebx,10000
          mul     ebx
          mov     ebx,1024
          div     ebx
          xor     edx,edx
          mov     ebx,100
          div     ebx
          cmp     dl,50
          jb      short NotNidedIncForHDDSizeInGB
          inc     eax
NotNidedIncForHDDSizeInGB:
          ret
ENDP GetHDDSizeInGB

PUBLIC CalcResMem,WaitingAndGetCh

PROC CalcResMem
          mov     ebx,100
          mul     ebx
          shr     eax,10
          mov     cx,5
          ret
ENDP CalcResMem

          ALIGN 2
PROC WaitingAndGetCh
          xor     al,al
          call    KeyWaiting
          jz      short KeyNotPressed
          call    GetCh
KeyNotPressed:
          ret
ENDP WaitingAndGetCh

PUBLIC ISAPnPDelay,ISAPnPCheckSum,InBitMap,ISAPnPKey

PROC ISAPnPDelay
          push    ax
          in      al,61h
          and     al,0FCh
          out     61h,al
          cli
          mov     al,10110000b ; Таймеp: pежим счета 0, канал 2
          out     43h,al
          mov     al,24        ; 112. тактов~0.1 msec
          out     42h,al       ; Загpужаем мл. байт счетчика
          mov     al,1         ; 24+1*256=280~0.25 msec
          out     42h,al       ; Загpужаем ст. байт счетчика
          in      al,61h
          or      al,1h
          out     61h,al       ; Разpешаем счет
CheckChanel2ForOverflow:
          mov     al,10000000b ; Защелкнем значение счетчика 2
          out     43h,al
          in      al,42h
          in      al,42h
          or      al,al
          jns     short CheckChanel2ForOverflow
          pop     ax
          ret
ENDP ISAPnPDelay

PROC ISAPnPCheckSum
; Вход:  DS:SI=адpес массива CX=pазмеp массива  Выход: DL=CheckSum
          mov     dl,06Ah
          cld
NextByteISAPnPCheckSum:
          mov     dh,8
          lodsb
CalcISAPnPCheckSum:
          mov     ah,dl
          shr     ah,1
          xor     ah,dl
          xor     ah,al
          rcr     ah,1
          rcr     dl,1
          rcr     al,1
          dec     dh
          jnz     short CalcISAPnPCheckSum
          loop    short NextByteISAPnPCheckSum
          ret
ENDP ISAPnPCheckSum

PROC InBitMap
; заносим в битовую каpту DS:BX бит(AL=0?) n=CX
          push    dx
          push    cx
          push    bx
          push    ax
          mov     dx,cx
          shr     dx,3
          add     bx,dx
          and     cx,07h    ; Получаем: BX=адpес байта, CL=bit n
          or      al,al
          jz      short inbitmap01
          mov     dl,001h
          rol     dl,cl
          or      [byte ds:bx],dl
          jmp     short inbitmap02
inbitmap01:
          mov     dl,0FEh
          rol     dl,cl
          and     [byte ds:bx],dl
inbitmap02:
          pop     ax
          pop     bx
          pop     cx
          pop     dx
          ret
ENDP InBitMap

PROC ISAPnPKey
          push    dx
          mov     dx,0279h
          sub     al,al
          out     dx,al
          jmp     $+2
          out     dx,al
          jmp     $+2
          mov     al,6Ah
NextByteISAPnPKey:
          out     dx,al
          mov     ah,al
          shr     ah,1
          xor     ah,al
          rcl     ah,8
          rcr     al,1
          cmp     al,9Ch
          jnz     short NextByteISAPnPKey
          pop     dx
          ret
ENDP ISAPnPKey

PUBLIC DetectGA5AA

PROC DetectGA5AA
          push    si
          push    ds
          push    0F000h
          pop     ds
          mov     si,0f534h
          cmp     [dword ds:si],'AA5-'
          jnz     short NotGA5AA
          mov     cx,6
          sub     si,2
          pop     ax
          pop     ax
          ret
NotGA5AA:
          pop     ds
          pop     si
          ret
ENDP DetectGA5AA

PUBLIC GetTransmetaCPUName

PROC GetTransmetaCPUName
          mov     eax,80860003h
          P586
          cpuid
          P386
          mov     [dword ds:si],eax
          mov     [dword ds:si+4],ebx
          mov     [dword ds:si+8],ecx
          mov     [dword ds:si+12],edx
          mov     eax,80860004h
          P586
          cpuid
          P386
          mov     [dword ds:si+16],eax
          mov     [dword ds:si+4+16],ebx
          mov     [dword ds:si+8+16],ecx
          mov     [dword ds:si+12+16],edx
          mov     eax,80860005h
          P586
          cpuid
          P386
          mov     [dword ds:si+16+16],eax
          mov     [dword ds:si+4+16+16],ebx
          mov     [dword ds:si+8+16+16],ecx
          mov     [dword ds:si+12+16+16],edx
          mov     eax,80860006h
          P586
          cpuid
          P386
          mov     [dword ds:si+16+16+16],eax
          mov     [dword ds:si+4+16+16+16],ebx
          mov     [dword ds:si+8+16+16+16],ecx
          mov     [dword ds:si+12+16+16+16],edx
          ret
ENDP GetTransmetaCPUName


PUBLIC GetAMDCPUName

PROC GetAMDCPUName
          mov     eax,80000002h
          P586
          cpuid
          P386

          mov     [dword ds:si],eax
          mov     [dword ds:si+4],ebx
          mov     [dword ds:si+8],ecx
          mov     [dword ds:si+12],edx
          mov     eax,80000003h
          P586
          cpuid
          P386
          mov     [dword ds:si+16],eax
          mov     [dword ds:si+4+16],ebx
          mov     [dword ds:si+8+16],ecx
          mov     [dword ds:si+12+16],edx
          mov     eax,80000004h
          P586
          cpuid
          P386
          mov     [dword ds:si+16+16],eax
          mov     [dword ds:si+4+16+16],ebx
          mov     [dword ds:si+8+16+16],ecx
          mov     [dword ds:si+12+16+16],edx
          ret
ENDP GetAMDCPUName

ENDS Cseg
END