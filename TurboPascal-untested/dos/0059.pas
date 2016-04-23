{
I'm very glad to be useful and to post the enhanced DOS unit for Turbo Pascal
7.0. It includes lots of nice routines written on inline asm, combined with
short comments and explanations. All you have in standard DOS unit you may
find in EnhDOS as well except of Exec and SwapVectors. Sure, the full source
code!

What is good?
-----------------

1. Fast! (because of the asm)
2. Flexible! (less procedures, more functions, lots of parameters)
3. Good error-handling routines. (don't need to care to check errors at all)
4. _Strong_ file service. (lots of file functions)
5. Lots of additional DOS service functions that can't be found in any standard
   or non-standard Pascal, C,... library.
6. Windows (tm) compatible (means you may use these routines when developing
   Windows (tm) applications.
7. Own memory allocate/release routines. (used DOS memory allocation)
8. Free. Released to a Public Domain.

What is bad?
-----------------

1. Requires Borland Turbo Pascal version 7.0 or later (7.01)
2. Requires DOS 3.1 or later. Sorry guys, wanna cool service - need later DOS.
3. Won't run on XT personal computers. (uses 286 instructions)
4. No more strings. (all string-type names are of PChar type)
5. Exec and SwapVectors not implemented. If you'd like this code, I will
   continue modifying this unit and will eventually add the above functions
   too.

Well, routines were checked on IBM PS/2 386SX, seems like work fine!

Greetingz to
-----------------

 Bas van Gaalen (cool asm programmer and my PASCAL area friend ;)
 Dj Murdoch (best explainer ;)
 Gayle Davis (SWAG live forever) Feel free to place it into a next SWAG bundle.
 Ralph Brown (brilliant idea to make the interrupt list)
 Alex Grischenko (whose asm help was very appreciated)
 ...and all of you, guys!

Material used
-----------------

Borland Pascal 7.0 Runtime Library source code
Ralph Brown's Interrupt List
Tech Help 4.0


You may use this source-code-software in ANY purpose. Code may be changed.
If some of the routines won't work, please send me a message.
If you don't mind, please leave my copyright strings as they are.}

Unit EnhDOS;
(*
  Turbo Pascal 7.0 - ENHDOS.PAS

  Enhanced DOS interface unit for DOS 3.1+ ***  Version 1.1  April, 1994.
  Copyright (c) 1994  by Andrew Eigus           Fidonet 2:5100/33

  Runtime Library Portions Copyright (c) 1991,92 Borland International }

  THIS UNIT SOURCE IS FREE
*)

interface

{$X+} { Enable extended syntax }
{$G+} { Enable 286+ instructions }

const

  { My copyright information }

  Copyright : PChar = 'Portions Copyright (c) 1994 by Andrew Eigus';

  { GetDriveType return values }

  dtError     = $00; { Bad drive }
  dtFixed     = $01; { Fixed drive }
  dtRemovable = $02; { Removable drive }
  dtRemote    = $03; { Remote (network) drive }

  { Handle file open modes (om) constants }

  omRead           = $00; { Open file for input only }
  omWrite          = $01; { Open file for output only }
  omReadWrite      = $02; { Open file for input or/and output (both modes) }
  omShareCompat    = $00; { Modes used when SHARE.EXE loaded }
  omShareExclusive = $10;
  omShareDenyWrite = $20;
  omShareDenyRead  = $30;
  omShareDenyNone  = $40;

  { Maximum file name component string lengths }

  fsPathName       = 79;
  fsDirectory      = 67;
  fsFileSpec       = 12;
  fsFileName       = 8;
  fsExtension      = 4;

  { FileSplit return flags }

  fcExtension      = $0001;
  fcFileName       = $0002;
  fcDirectory      = $0004;
  fcWildcards      = $0008;

  { File attributes (fa) constants }

  faNormal         = $00;
  faReadOnly       = $01;
  faHidden         = $02;
  faSysFile        = $04;
  faVolumeID       = $08;
  faDirectory      = $10;
  faArchive        = $20;
  faAnyFile        = $3F;

  { Seek start offset (sk) constants }

  skStart = 0; { Seek position relative to the beginning of a file }
  skPos   = 1; { Seek position relative to a current file position }
  skEnd   = 2; { Seek position relative to the end of a file }

  { Error handler function (fr) result codes }

  frOk    = 0; { Continue program }
  frRetry = 1; { Retry function once again }

  { Function codes (only passed to error handler routine) (fn) constants }

  fnGetDPB         = $3200;
  fnGetDiskSize    = $3600;
  fnGetDiskFree    = $3601;
  fnGetCountryInfo = $3800;
  fnSetDate        = $2B00;
  fnSetTime        = $2D00;
  fnIsFixedDisk    = $4408;
  fnIsNetworkDrive = $4409;
  fnCreateDir      = $3900;
  fnRemoveDir      = $3A00;
  fnGetCurDir      = $4700;
  fnSetCurDir      = $3B00;
  fnDeleteFile     = $4100;
  fnRenameFile     = $5600;
  fnGetFileAttr    = $4300;
  fnSetFileAttr    = $4301;
  fnFindFirst      = $4E00;
  fnFindNext       = $4F00;
  fnCreateFile     = $5B00;
  fnCreateTempFile = $5A00;
  fnOpenFile       = $3D00;
  fnRead           = $3F00;
  fnWrite          = $4000;
  fnSeek           = $4200;
  fnGetFDateTime   = $5700;
  fnSetFDateTime   = $5701;
  fnCloseFile      = $3E00;
  fnMemAlloc       = $4800;
  fnMemFree        = $4900;

  { DOS 3.x+ errors/return codes }

  dosrOk                = 0;   { Success }
  dosrInvalidFuncNumber = 1;   { Invalid DOS function number }
  dosrFileNotFound      = 2;   { File not found }
  dosrPathNotFound      = 3;   { Path not found }
  dosrTooManyOpenFiles  = 4;   { Too many open files }
  dosrFileAccessDenied  = 5;   { File access denied }
  dosrInvalidFileHandle = 6;   { Invalid file handle }
  dosrNotEnoughMemory   = 8;   { Not enough memory }
  dosrInvalidEnvment    = 10;  { Invalid environment }
  dosrInvalidFormat     = 11;  { Invalid format }
  dosrInvalidAccessCode = 12;  { Invalid file access code }
  dosrInvalidDrive      = 15;  { Invalid drive number }
  dosrCantRemoveDir     = 16;  { Cannot remove current directory }
  dosrCantRenameDrives  = 17;  { Cannot rename across drives }
  dosrNoMoreFiles       = 18;  { No more files }

type

  TPathStr = array[0..fsPathName] of Char;
  TDirStr  = array[0..fsDirectory] of Char;
  TNameStr = array[0..fsFileName] of Char;
  TExtStr  = array[0..fsExtension] of Char;
  TFileStr = array[0..fsFileSpec] of Char;

  { Disk information block structure }

  PDiskParamBlock = ^TDiskParamBlock;
  TDiskParamBlock = record
    Drive : byte;             { Disk drive number (0=A, 1=B, 2=C...) }
    SubunitNum : byte;        { Sub-unit number from driver device header }
    SectSize : word;          { Number of bytes per sector }
    SectPerClust : byte;      { Number of sectors per cluster -1
                                (max sector in cluster) }
    ClustToSectShft : byte;   { Cluster-to-sector shift }
    BootSize : word;          { Reserved sectors (boot secs; start of root dir}
    FATCount : byte;          { Number of FATs }
    MaxDir : word;            { Number of directory entries allowed in root }
    DataSect : word;          { Sector number of first data cluster }
    Clusters : word;          { Total number of allocation units (clusters)
                                +2 (number of highest cluster) }
    FATSectors : byte;        { Sectors needed by first FAT }
    RootSect : word;          { Sector number of start of root directory }
    DeviceHeader : pointer;   { Address of device header }
    Media : byte;             { Media descriptor byte }
    AccessFlag : byte;        { 0 if drive has been accessed }
    NextPDB : pointer         { Address of next DPB (0FFFFh if last) }
  end;

  { Disk allocation data structure }

  PDiskAllocInfo = ^TDiskAllocInfo;
  TDiskAllocInfo = record
    FATId : byte;             { FAT Id }
    Clusters : word;          { Number of allocation units (clusters) }
    SectPerClust : byte;      { Number of sectors per cluster }
    SectSize : word           { Number of bytes per sector }
  end;

  { Country information structure }

  PCountryInfo = ^TCountryInfo;
  TCountryInfo = record
    DateFormat : word; { Date format value may be one of the following:
                         0 - Month, Day, Year     (USA)
                         1 - Day, Month, Year     (Europe)
                         2 - Year, Month, Day     (Japan) }

    CurrencySymbol : array[0..4] of Char; { Currency symbol string }
    ThousandsChar : byte; { Thousands separator character }
    reserved1 : byte;
    DecimalChar : byte;   { Decimal separator character }
    reserved2 : byte;
    DateChar : byte;      { Date separator character }
    reserved3 : byte;
    TimeChar : byte;      { Time separator character }
    reserved4 : byte;
    CurrencyFormat : byte; { Currency format:
                             $XXX.XX
                             XXX.XX$
                             $ XXX.XX
                             XXX.XX $
                             XXX$XX }

    Digits : byte;          { Number of digits after decimal in currency }
    TimeFormat : byte;      { Time format may be one of the following:
                              bit 0 = 0 if 12 hour clock
                                  1 if 24 hour clock }

    MapRoutine : pointer;   { Address of case map routine FAR CALL,
                              AL - character to map to upper case [>=80h] }

    DataListChar : byte;    { Data-list separator character }
    reserved5 : byte;
    reserved6 : array[1..10] of Char
  end;

  THandle = Word; { Handle type (file handle and memory handle functions) }

  { Error handler function }

  TErrorFunc = function(ErrCode : integer; FuncCode : word) : byte;

  { Search record used by FindFirst and FindNext }

  TSearchRec = record
    Fill : array[1..21] of Byte;
    Attr : byte;
    Time : longint;
    Size : longint;
    Name : TFileStr
  end;

  { Date and time record used by PackTime and UnpackTime }

  TDateTime = record
    Year,
    Month,
    Day,
    Hour,
    Min,
    Sec : word
  end;


var
  DOSResult : integer; { Error status variable }
  TempStr : array[0..High(String)] of Char;

function SetErrorHandler(Handler : TErrorFunc) : pointer;
function Pas2PChar(S : string) : PChar;

function GetInDOSFlag : boolean;
function GetDOSVersion : word;
function GetSwitchChar : char;
function SetSwitchChar(Switch : char) : byte;
function GetCountryInfo(var Info : TCountryInfo) : integer;
procedure GetDate(var Year : word; var Month, Day, DayOfWeek : byte);
function SetDate(Year : word; Month, Day : byte) : boolean;
procedure GetTime(var Hour, Minute, Second, Sec100 : byte);
function SetTime(Hour, Minute, Second, Sec100 : byte) : boolean;
function GetCBreak : boolean;
function SetCBreak(Break : boolean) : boolean;
function GetVerify : boolean;
function SetVerify(Verify : boolean) : boolean;
function GetArgCount : integer;
function GetArgStr(Dest : PChar; Index : integer; MaxLen : word) : PChar;
function GetEnvVar(VarName : PChar) : PChar;
function GetIntVec(IntNo : byte; var Vector : pointer) : pointer;
function SetIntVec(IntNo : byte; Vector : pointer) : pointer;

function GetDTA : pointer;
function GetCurDisk : byte;
function SetCurDisk(Drive : byte) : byte;
procedure GetDriveAllocInfo(Drive : byte; var Info : TDiskAllocInfo);
function GetDPB(Drive : byte; var DPB : TDiskParamBlock) : integer;
function DiskSize(Drive : byte) : longint;
function DiskFree(Drive : byte) : longint;
function IsFixedDisk(Drive : byte) : boolean;
function IsNetworkDrive(Drive : byte) : boolean;
function GetDriveType(Drive : byte) : byte;

function CreateDir(Dir : PChar) : integer;
function RemoveDir(Dir : PChar) : integer;
function GetCurDir(Drive : byte; Dir : PChar) : integer;
function SetCurDir(Dir : PChar) : integer;

function DeleteFile(Path : PChar) : integer;
function RenameFile(OldPath, NewPath : PChar) : integer;
function ExistsFile(Path : PChar) : boolean;
function GetFileAttr(Path : PChar) : integer;
function SetFileAttr(Path : PChar; Attr : word) : integer;
function FindFirst(Path : PChar; Attr: word; var F : TSearchRec) : integer;
function FindNext(var F : TSearchRec) : integer;
procedure UnpackTime(P : longint; var T : TDateTime);
function PackTime(var T : TDateTime) : longint;

function h_CreateFile(Path : PChar) : THandle;
function h_CreateTempFile(Path : PChar) : THandle;
function h_OpenFile(Path : PChar; Mode : byte) : THandle;
function h_Read(Handle : THandle; var Buffer; Count : word) : word;
function h_Write(Handle : THandle; var Buffer; Count : word) : word;
function h_Seek(Handle : THandle; SeekPos : longint; Start : byte) : longint;
function h_FilePos(Handle : THandle) : longint;
function h_FileSize(Handle : THandle) : longint;
function h_Eof(Handle : THandle) : boolean;
function h_GetFTime(Handle : THandle) : longint;
function h_SetFTime(Handle : THandle; DateTime : longint) : longint;
function h_CloseFile(Handle : THandle) : integer;

function MemAlloc(Size : longint) : pointer;
function MemFree(P : pointer) : integer;

function FileSearch(Dest, Name, List : PChar) : PChar;
function FileExpand(Dest, Name : PChar) : PChar;
function FileSplit(Path, Dir, Name, Ext : PChar) : word;

implementation

{$IFDEF Windows}
{$DEFINE ProtectedMode}
{$ENDIF}

{$IFDEF DPMI}
{$DEFINE ProtectedMode}
{$ENDIF}

{$IFDEF Windows}

uses WinTypes, WinProcs, Strings;

{$ELSE}

uses Strings;

{$ENDIF}

const DOS = $21; { DOS interrupt number }

var
  ErrorHandler : TErrorFunc;

Function SetErrorHandler;
{ Sets the new error handler to hook all errors returned by EnhDOS functions,
  and returns the pointer to an old interrupt handler routine }
Begin
  SetErrorHandler := @ErrorHandler;
  ErrorHandler := Handler
End; { SetErrorHandler }

Function Pas2PChar(S : string) : PChar;
{ Returns PChar type equivalent of the S variable. Use this function
  to convert strings to PChars }
Begin
  Pas2PChar := StrPCopy(TempStr, S)
End; { Pas2PChar }

{$IFDEF Windows}

procedure AnsiDosFunc; assembler;
asm
  PUSH DS
  PUSH CX
  PUSH AX
  MOV SI,DI
  PUSH ES
  POP DS
  LEA DI,TempStr
  PUSH SS
  POP ES
  MOV CX,fsPathName
  CLD
@@1:
  LODSB
  OR  AL,AL
  JE  @@2
  STOSB
  LOOP @@1
@@2:
  XOR AL,AL
  STOSB
  LEA DI,TempStr
  PUSH SS
  PUSH DI
  PUSH SS
  PUSH DI
  CALL AnsiToOem
  POP AX
  POP CX
  LEA DX,TempStr
  PUSH SS
  POP DS
  INT DOS
  POP DS
end; { AnsiDosFunc /Windows }

{$ELSE}

procedure AnsiDosFunc; assembler;
asm
  PUSH DS
  MOV DX,DI
  PUSH ES
  POP DS
  INT DOS
  POP DS
end; { AnsiDosFunc }

{$ENDIF}

Function GetInDOSFlag; assembler;
{ GETINDOSFLAG - DOS service function
  Description: Returns the current state of InDOS flag; fn=34h
  Returns: True if a DOS operation is being performed, False if there is
           no DOS command that currently is running }
Asm
  MOV AH,34h
  INT DOS
  MOV AL,BYTE PTR [ES:BX]
End; { GetInDOSFlag }

Function GetDOSVersion; assembler;
{ GETDOSVERSION - DOS service function
  Description: Retrieves DOS version number; fn=30h
  Returns: Major DOS version number in low-order byte,
           minor version number in high-order byte of word }
Asm
  MOV AH,30h
  INT DOS
End; { GetDOSVersion }

Function GetSwitchChar; assembler;
{ GETSWITCHCHAR - DOS service function
  Description: Retrieves DOS command line default switch character; fn=37h
  Returns: Switch character ('/', '-', ...) or FFh if unsupported subfunction }
Asm
  MOV AH,37h
  XOR AL,AL
  INT DOS
  CMP AL,0FFh
  JE  @@1
  MOV AL,DL
@@1:
End; { GetSwitchChar }

Function SetSwitchChar; assembler;
{ SETSWITCHCHAR - DOS service function
  Description: Sets new DOS command line switch character; fn=37h
  Returns: FFh if unsupported subfunction, any other value success }
Asm
  MOV AX,3701h
  MOV DL,Switch
  INT DOS
End; { SetSwitchChar }

Function GetCountryInfo; assembler;
{ GETCOUNTRYINFO - DOS service function
  Description: Retrieves country information; fn=38h
  Returns: Country code if successful, negative DOS error code otherwise }
Asm
@@1:
  PUSH DS
  MOV AH,38h
  XOR AL,AL
  LDS DX,Info
  INT DOS
  POP DS
  JC  @@2
  MOV AX,BX
  MOV DOSResult,dosrOk
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnGetCountryInfo { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
  NEG AX
@@3:
End; { GetCountryInfo }

Procedure GetDate; assembler;
{ GETDATE - DOS service function
  Description: Retrieves the current date set in the operating system.
               Ranges of the values returned are: Year 1980-2099,
               Month 1-12, Day 1-31 and DayOfWeek 0-6 (0 corresponds to
               Sunday) }
Asm
  MOV AH,2AH
  INT DOS
  XOR AH,AH
  LES DI,DayOfWeek
  STOSB
  MOV AL,DL
  LES DI,Day
  STOSB
  MOV AL,DH
  LES DI,Month
  STOSB
  XCHG AX,CX
  LES DI,Year
  STOSW
End; { GetDate }

Function SetDate; assembler;
{ SETDATE - DOS service function
  Description: Sets the current date in the operating system. Valid
               parameter ranges are: Year 1980-2099, Month 1-12 and
               Day 1-31
  Returns: True if the date was set, False if the date is not valid }
Asm
  MOV CX,Year
  MOV DH,Month
  MOV DL,Day
  MOV AH,2BH
  INT DOS
  CMP AL,0
  JE  @@1
  MOV DOSResult,AX
  PUSH AX
  PUSH fnSetDate
  CALL ErrorHandler
  MOV AL,True
@@1:
  NOT AL
End; { SetDate }

Procedure GetTime; assembler;
{ GETTIME - DOS service function
  Description: Returns the current time set in the operating system.
               Ranges of the values returned are: Hour 0-23, Minute 0-59,
               Second 0-59 and Sec100 (hundredths of seconds) 0-99 }
Asm
  MOV AH,2CH
  INT DOS
  XOR AH,AH
  MOV AL,DL
  LES DI,Sec100
  STOSB
  MOV AL,DH
  LES DI,Second
  STOSB
  MOV AL,CL
  LES DI,Minute
  STOSB
  MOV AL,CH
  LES DI,Hour
  STOSB
End; { GetTime }

Function SetTime; assembler;
{ SETTIME - DOS service function
  Description: Sets the time in the operating system. Valid
               parameter ranges are: Hour 0-23, Minute 0-59, Second 0-59 and
               Sec100 (hundredths of seconds) 0-99
  Returns: True if the time was set, False if the time is not valid }
Asm
  MOV CH,Hour
  MOV CL,Minute
  MOV DH,Second
  MOV DL,Sec100
  MOV AH,2DH
  INT DOS
  CMP AL,0
  JE  @@1
  MOV DOSResult,AX
  PUSH AX
  PUSH fnSetTime
  CALL ErrorHandler
  MOV AL,True
@@1:
  NOT AL
End; { SetTime }

Function GetCBreak; assembler;
{ GETCBREAK - DOS service function
  Description: Retrieves Control-Break state; fn=3300h
  Returns: Current Ctrl-Break state }
Asm
  MOV AX,3300h
  INT DOS
  MOV AL,DL
End; { GetCBreak }

Function SetCBreak; assembler;
{ SETCBREAK - DOS service function
  Description: Sets new Control-Break state; fn=3300h
  Returns: Old Ctrl-Break state }
Asm
  CALL GetCBreak
  PUSH AX
  MOV AX,3301h
  MOV DL,Break
  INT DOS
  POP AX
End; { SetCBreak }

Function GetVerify; assembler;
{ GETVERIFY - DOS service function
  Description: Returns the state of the verify flag in DOS.
               When off (False), disk writes are not verified.
               When on (True), all disk writes are verified to insure proper
               writing; fn=54h
  Returns: State of the verify flag }
Asm
  MOV AH,54H
  INT DOS
End; { GetVerify }

Function SetVerify; assembler;
{ SETVERIFY - DOS service function
  Description: Sets the state of the verify flag in DOS; fn=2Eh
  Returns: Previous state of the verify flag }
Asm
  CALL GetVerify
  PUSH AX
  MOV AL,Verify
  MOV AH,2EH
  INT DOS
  POP AX
End; { SetVerify }

{$IFDEF Windows}

Procedure ArgStrCount; assembler;
Asm
  LDS SI,CmdLine
  CLD
@@1:
  LODSB
  OR  AL,AL
  JE  @@2
  CMP AL,' '
  JBE @@1
@@2:
  DEC SI
  MOV BX,SI
@@3:
  LODSB
  CMP AL,' '
  JA  @@3
  DEC SI
  MOV AX,SI
  SUB AX,BX
  JE  @@4
  LOOP @@1
@@4:
End; { ArgStrCount /Windows }

Function GetArgCount; assembler;
{ GETARGCOUNT - DOS service function
  Description: Returns the number of parameters passed to the
               program on the command line
  Returns: Actual number of command line parameters }

Asm
  PUSH DS
  XOR  CX,CX
  CALL ArgStrCount
  XCHG AX,CX
  NEG AX
  POP DS
End; { GetArgCount /Windows }

Function GetArgStr; assembler;
{ GETARGSTR - DOS service function
  Description: Returns the specified parameter from the command line
  Returns: ASCIIZ parameter, or an empty string if Index is less than zero
           or greater than GetArgCount. If Index is zero, GetArgStr returns
           the filename of the current module. The maximum length of the
           string returned in Dest is given by the MaxLen parameter. The
           returned value is Dest }

Asm
  MOV CX,Index
  JCXZ @@2
  PUSH DS
  CALL ArgStrCount
  MOV SI,BX
  LES DI,Dest
  MOV CX,MaxLen
  CMP CX,AX
  JB  @@1
  XCHG AX,CX
@@1:
  REP MOVSB
  XCHG AX,CX
  STOSB
  POP DS
  JMP @@3
@@2:
  PUSH HInstance
  PUSH WORD PTR [Dest+2]
  PUSH WORD PTR [Dest]
  MOV AX,MaxLen
  INC AX
  PUSH AX
  CALL GetModuleFileName
@@3:
  MOV AX,WORD PTR [Dest]
  MOV DX,WORD PTR [Dest+2]
End; { GetArgStr /Windows }

{$ELSE}

Procedure ArgStrCount; assembler;
Asm
  MOV DS,PrefixSeg
  MOV SI,80H
  CLD
  LODSB
  MOV DL,AL
  XOR DH,DH
  ADD DX,SI
@@1:
  CMP SI,DX
  JE  @@2
  LODSB
  CMP AL,' '
  JBE @@1
  DEC SI
@@2:
  MOV BX,SI
@@3:
  CMP SI,DX
  JE  @@4
  LODSB
  CMP AL,' '
  JA  @@3
  DEC SI
@@4:
  MOV AX,SI
  SUB AX,BX
  JE  @@5
  LOOP @@1
@@5:
End; { ArgStrCount }

Function GetArgCount; assembler;
{ GETARGCOUNT - DOS service function
  Description: Returns the number of parameters passed to the
               program on the command line
  Returns: Actual number of command line parameters }
Asm
  PUSH DS
  XOR CX,CX
  CALL ArgStrCount
  XCHG AX,CX
  NEG AX
  POP DS
End; { GetArgCount }

Function GetArgStr; assembler;
{ GETARGSTR - DOS service function
  Description: Returns the specified parameter from the command line
  Returns: ASCIIZ parameter, or an empty string if Index is less than zero
           or greater than GetArgCount. If Index is zero, GetArgStr returns
           the filename of the current module. The maximum length of the
           string returned in Dest is given by the MaxLen parameter. The
           returned value is Dest }
Asm
  PUSH DS
  MOV CX,Index
  JCXZ @@1
  CALL ArgStrCount
  MOV SI,BX
  JMP @@4
@@1:
  MOV AH,30H
  INT DOS
  CMP AL,3
  MOV AX,0
  JB  @@4
  MOV DS,PrefixSeg
  MOV ES,DS:WORD PTR 2CH
  XOR DI,DI
  CLD
@@2:
  CMP AL,ES:[DI]
  JE  @@3
  MOV CX,-1
  REPNE SCASB
  JMP @@2
@@3:
  ADD DI,3
  MOV SI,DI
  PUSH ES
  POP DS
  MOV CX,256
  REPNE SCASB
  XCHG AX,CX
  NOT AL
@@4:
  LES DI,Dest
  MOV CX,MaxLen
  CMP CX,AX
  JB  @@5
  XCHG AX,CX
@@5:
  REP MOVSB
  XCHG AX,CX
  STOSB
  MOV AX,WORD PTR [Dest]
  MOV DX,WORD PTR [Dest+2]
  POP DS
End; { GetArgStr }

{$ENDIF}

Function GetEnvVar;
{ GETENVVAR - DOS service function
  Description: Retrieves a specified DOS environment variable
  Returns: A pointer to the value of a specified variable,
           i.e. a pointer to the first character after the equals
           sign (=) in the environment entry given by VarName.
           VarName is case insensitive. GetEnvVar returns NIL if
           the specified environment variable does not exist }
var
  L : word;
  P : PChar;
Begin
  L := StrLen(VarName);
{$IFDEF Windows}
  P := GetDosEnvironment;
{$ELSE}
  P := Ptr(Word(Ptr(PrefixSeg, $2C)^), 0);
{$ENDIF}
  while P^ <> #0 do
  begin
    if (StrLIComp(P, VarName, L) = 0) and (P[L] = '=') then
    begin
      GetEnvVar := P + L + 1;
      Exit;
    end;
    Inc(P, StrLen(P) + 1)
  end;
  GetEnvVar := nil
End; { GetEnvVar }

Function GetIntVec; assembler;
{ GETINTVEC - DOS service function
  Description: Retrieves the address stored in the specified interrupt vector
  Returns: A pointer to this address }
Asm
  MOV AL,IntNo
  MOV AH,35H
  INT DOS
  MOV AX,ES
  LES DI,Vector
  CLD
  MOV DX,BX
  XCHG AX,BX
  STOSW
  XCHG AX,BX
  STOSW
  XCHG AX,DX
End; { GetIntVec }

Function SetIntVec; assembler;
{ SETINTVEC - DOS Service function
  Description: Sets the address in the interrupt vector table for the
               specified interrupt
  Returns: The old address of the specified interrupt vector }
Asm
  LES DI,Vector
  PUSH WORD PTR IntNo
  PUSH ES
  PUSH DI
  PUSH CS
  CALL GetIntVec
  PUSH DX
  PUSH AX
  PUSH DS
  LDS DX,Vector
  MOV AL,IntNo
  MOV AH,25H
  INT DOS
  POP DS
  POP AX
  POP DX
End; { SetIntVec }

Function GetDTA; assembler;
{ GETDTA - DOS service function
  Description: Retrieves a pointer address to a DOS data exchange buffer (DTA).
               By default, DTA address has the offset PSP+80h and the size of
               128 bytes. DTA is used to access files with the FCB method;
               fn=2Fh
  Returns: A pointer address to DTA }
Asm
  MOV AH,2Fh
  INT DOS
  MOV DX,BX { store offset }
  MOV AX,ES { store segment }
End; { GetDTA }

Function GetCurDisk; assembler;
{ GETCURDISK - DOS disk service function
  Description: Retrieves number of disk currently being active; fn=19h
  Returns: Default (current, active) disk number }
Asm
  MOV AH,19h
  INT DOS
End; { GetCurDisk }

Function SetCurDisk; assembler;
{ SETCURDISK - DOS disk service function
  Description: Sets current (default/active) drive; fn=0Eh
  Returns: Number of disks in the system }
Asm
  MOV AH,0Eh
  MOV DL,Drive
  INT DOS
End; { SetCurDisk }

Procedure GetDriveAllocInfo; assembler;
{ GETDRIVEALLOCINFO - DOS disk service function
  Description: Retrieves disk allocation information; fn=1Ch
  Retrieves Info structure }
Asm
  PUSH DS
  MOV AH,1Ch
  MOV DL,Drive
  INT DOS
  MOV AH,BYTE PTR [DS:BX]
  LES DI,Info
  MOV BYTE PTR ES:[DI],AH      { Info.FATId }
  MOV WORD PTR ES:[DI+1],DX    { Info.Clusters }
  MOV BYTE PTR ES:[DI+3],AL    { Info.SectorsPerCluster }
  MOV WORD PTR ES:[DI+4],CX    { Info.BytesPerSector }
  POP DS
End; { GetDriveAllocInfo }

Function GetDPB; assembler;
{ GETDPB - DOS disk service function (undocumented)
  Description: Returns a block of information that is useful for applications
               which perform sector-level access of disk drives supported by
               device drivers; fn=32h
  Returns: 0 if successful, negative dosrInvalidDrive error code otherwise
  Remarks: Use 0 for default drive }
Asm
  MOV DOSResult,dosrOk
  PUSH DS
  MOV AH,32h
  MOV DL,Drive
  INT DOS
  MOV WORD PTR [DPB],DS
  MOV WORD PTR [DPB+2],BX
  POP DS
  XOR AH,AH
  CMP AL,0FFh
  JNE @@1
  MOV DOSResult,dosrInvalidDrive
  PUSH DOSResult
  PUSH fnGetDPB
  CALL ErrorHandler
  MOV AX,DOSResult
  NEG AX
@@1:
End; { GetDPB }

Function DiskSize; assembler;
{ DISKSIZE - DOS disk service function
  Description: Retrieves total disk size; fn=36h
  Returns: Total disk size in bytes if successful, negative dosrInvalidDrive
           error code otherwise
  Remarks: Use 0 for default drive }
Asm
@@1:
  MOV AH,36h
  MOV DL,Drive
  INT DOS
  CMP AX,0FFFFh
  JE  @@2
  MOV BX,DX
  IMUL CX
  IMUL BX
  JMP @@3
@@2:
  MOV DOSResult,dosrInvalidDrive
  PUSH DOSResult
  PUSH fnGetDiskSize
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  MOV AX,DOSResult
  NEG AX
  XOR DX,DX
@@3:
End; { DiskSize }

Function DiskFree; assembler;
{ DISKFREE - DOS disk service function
  Description: Retrieves amount of free disk space; fn=36h
  Returns: Amount of free disk space in bytes if successful,
           negative dosrInvalidDrive error code otherwise
  Remarks: Use 0 for default drive }
Asm
@@1:
  MOV AH,36h
  MOV DL,Drive
  INT DOS
  CMP AX,0FFFFh
  JE  @@2
  IMUL CX
  IMUL BX
  JMP @@3
@@2:
  MOV DOSResult,dosrInvalidDrive
  PUSH DOSResult
  PUSH fnGetDiskFree
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  MOV AX,DOSResult
  NEG AX
  XOR DX,DX
@@3:
End; { DiskFree }

Function IsFixedDisk; assembler;
{ ISFIXEDDISK - DOS disk service function
  Description: Ensures whether the specified disk is fixed or removable;
               fn=4408h
  Returns: True, if the disk is fixed, False - otherwise
  Remarks: Use 0 for default (current) drive }
Asm
  MOV AX,4408h
  MOV BL,Drive
  INT DOS
  JNC @@1
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnIsFixedDisk  { store function code }
  CALL ErrorHandler
@@1:
End; { IsFixedDisk }

Function IsNetworkDrive; assembler;
{ ISNETWORKDRIVE - DOS disk service function
  Description: Ensures whether the specified disk drive is a network drive;
               fn=4409h
  Returns: True if drive is a network drive, False if it's a local drive
  Remarks: Use 0 for detecting the default (current) drive }
Asm
  MOV AX,4409h
  MOV BL,Drive
  INT DOS
  JNC @@1
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnIsNetworkDrive  { store function code }
  CALL ErrorHandler
@@1:
End; { IsNetworkDrive }

Function GetDriveType(Drive : byte) : byte; assembler;
{ GETDRIVETYPE - Disk service function
  Description: Detects the type of the specified drive. Uses IsFixedDisk and
               IsNetworkDrive functions to produce a result value
  Returns: One of (dt) constants (see const section)
  Remarks: Use 0 for detecting the default (current) drive }
Asm
  PUSH WORD PTR Drive
  CALL IsNetworkDrive
  XOR BL,BL
  CMP DOSResult,dosrOk
  JNE @@3
  CMP AL,True
  JNE @@1
  MOV BL,dtRemote
  JMP @@3
@@1:
  PUSH WORD PTR Drive
  CALL IsFixedDisk
  XOR BL,BL
  CMP DOSResult,dosrOk
  JNE @@3
  CMP AL,True
  JNE @@2
  MOV BL,dtFixed
  JMP @@3
@@2:
  MOV BL,dtRemovable
@@3:
  MOV AL,BL
End; { GetDriveType }

Function CreateDir; assembler;
{ CREATEDIR - DOS directory function
  Description: Creates a directory; fn=39h
  Returns: 0 if successful, negative DOS error code otherwise }
Asm
@@1:
  PUSH DS
  LDS DX,Dir
  MOV AH,39h
  INT DOS
  POP DS
  JC  @@2
  XOR AX,AX
  MOV DOSResult,dosrOk
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnCreateDir  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
  NEG AX
@@3:
End; { CreateDir }

Function RemoveDir; assembler;
{ REMOVEDIR - DOS directory function
  Description: Removes (deletes) a directory; fn=3Ah
  Returns: 0 if successful, negative DOS error code otherwise }
Asm
@@1:
  PUSH DS
  LDS DX,Dir
  MOV AH,3Ah
  INT DOS
  POP DS
  JC  @@2
  XOR AX,AX
  MOV DOSResult,dosrOk
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnRemoveDir  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
  NEG AX
@@3:
End; { RemoveDir }

Function GetCurDir; assembler;
{ GETCURDIR - DOS directory function
  Description: Retrieves current (active) directory name; fn=47h
  Returns: 0 if successful, negative DOS error code otherwise }
Asm
@@1:
  PUSH DS
  LDS SI,Dir
  MOV DL,Drive
  MOV AH,47h
  INT DOS
  POP DS
  JC  @@2
  XOR AX,AX
  MOV DOSResult,dosrOk
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnGetCurDir  { store function number }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
  NEG AX
@@3:
End; { GetCurDir }

Function SetCurDir; assembler;
{ SETCURDIR - DOS directory function
  Description: Sets current (active) directory; fn=3Bh
  Returns: 0 if successful, negative DOS error code otherwise }
Asm
@@1:
  PUSH DS
  LDS DX,Dir
  MOV AH,3Bh
  INT DOS
  POP DS
  JC  @@2
  XOR AX,AX
  MOV DOSResult,AX
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnSetCurDir  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
  NEG AX
@@3:
End; { SetCurDir }

Function DeleteFile; assembler;
{ DELETEFILE - DOS file function
  Description: Deletes a file; fn=41h
  Returns: 0 if successful, negative DOS error code otherwise }
Asm
@@1:
  PUSH DS
  LDS DX,Path
  MOV AH,41h
  INT DOS
  POP DS
  JC  @@2
  XOR AX,AX
  MOV DOSResult,dosrOk
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnDeleteFile  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
  NEG AX
@@3:
End; { DeleteFile }

Function RenameFile; assembler;
{ RENAMEFILE - DOS file function
  Description: Renames/moves a file; fn=56h
  Returns: 0 if successful, negative error code otherwise }
Asm
@@1:
  PUSH DS
  LDS DX,OldPath
  LES DI,NewPath
  MOV AH,56h
  INT DOS
  POP DS
  JC  @@2
  XOR AX,AX
  MOV DOSResult,dosrOk
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnRenameFile  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
  NEG AX
@@3:
End; { RenameFile }

Function ExistsFile; assembler;
{ EXISTSFILE - DOS file function
  Description: Determines whether the file exists; fn=4Eh
  Returns: TRUE if the file exists, FALSE - otherwise }
Asm
  PUSH DS
  LDS DX,Path
  MOV AH,4Eh
  INT DOS
  POP DS
  JNC @@1
  XOR AL,AL
  JMP @@2
@@1:
  MOV AL,True
@@2:
End; { ExistsFile }

Function GetFileAttr; assembler;
{ GETFILEATTR - DOS file function
  Description: Gets file attributes; fn=43h,AL=0
  Returns: File attributes if no error, negative DOS error code otherwise }
Asm
@@1:
  PUSH DS
  LDS DX,Path
  MOV AX,4300h
  INT DOS
  POP DS
  JC  @@2
  MOV AX,CX
  MOV DOSResult,dosrOk
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnGetFileAttr  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
  NEG AX
@@3:
End; { GetFileAttr }

Function SetFileAttr; assembler;
{ SETFILEATTR - DOS file function
  Description: Sets file attributes; fn=43h,AL=1
  Returns: 0 if no error, negative DOS error code otherwise }
Asm
@@1:
  PUSH DS
  LDS DX,Path
  MOV CX,Attr
  MOV AX,4301h
  INT DOS
  POP DS
  JC  @@2
  XOR AX,AX
  MOV DOSResult,dosrOk
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnSetFileAttr  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
  NEG AX
@@3:
End; { GetFileAttr }

Function FindFirst; assembler;
{ FINDFIRST - DOS file service function
  Description: Searches the specified (or current) directory for
               the first entry that matches the specified filename and
               attributes; fn=4E00h
  Returns: 0 if successful, negative DOS error code otherwise }
Asm
@@1:
  PUSH DS
  LDS DX,F
  MOV AH,1AH
  INT DOS
  POP DS
  LES DI,Path
  MOV CX,Attr
  MOV AH,4EH
  CALL AnsiDosFunc
  MOV DOSResult,dosrOk
  JC  @@2
{$IFDEF Windows}
  LES DI,F
  ADD DI,OFFSET TSearchRec.Name
  PUSH ES
  PUSH DI
  PUSH ES
  PUSH DI
  CALL OemToAnsi
{$ENDIF}
  XOR AX,AX
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnFindFirst  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
@@3:
  NEG AX
End; { FindFirst }

Function FindNext; assembler;
{ FINDNEXT - DOS file service function
  Description: Returs the next entry that matches the name and
               attributes specified in a previous call to FindFirst.
               The search record must be one passed to FindFirst
  Returns: 0 if successful, negative DOS error code otherwise }
Asm
@@1:
  PUSH DS
  LDS DX,F
  MOV AH,1AH
  INT DOS
  POP DS
  MOV AH,4FH
  MOV DOSResult,dosrOk
  INT DOS
  JC  @@2
{$IFDEF Windows}
  LES DI,F
  ADD DI,OFFSET TSearchRec.Name
  PUSH ES
  PUSH DI
  PUSH ES
  PUSH DI
  CALL OemToAnsi
{$ENDIF}
  XOR AX,AX
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnFindNext  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
@@3:
  NEG AX
End; { FindNext }

Procedure UnpackTime; assembler;
{ UNPACKTIME - Service function
  Description: Converts a 4-byte packed date/time returned by
               FindFirst, FindNext or GetFTime into a TDateTime record }
Asm
  LES DI,T
  CLD
  MOV AX,WORD PTR [P+2]
  MOV CL,9
  SHR AX,CL
  ADD AX,1980
  STOSW
  MOV AX,WORD PTR [P+2]
  MOV CL,5
  SHR AX,CL
  AND AX,15
  STOSW
  MOV AX,WORD PTR [P+2]
  AND AX,31
  STOSW
  MOV AX,P.Word[0]
  MOV CL,11
  SHR AX,CL
  STOSW
  MOV AX,WORD PTR [P+2]
  MOV CL,5
  SHR AX,CL
  AND AX,63
  STOSW
  MOV AX,WORD PTR [P]
  AND AX,31
  SHL AX,1
  STOSW
End; { UnpackTime }

Function PackTime; assembler;
{ PACKTIME - Service function
  Decription: Converts a TDateTime record into a 4-byte packed
              date/time used by SetFTime
  Returns: 4-byte long integer corresponding to packed date/time }
Asm
  PUSH DS
  LDS SI,T
  CLD
  LODSW
  SUB AX,1980
  MOV CL,9
  SHL AX,CL
  XCHG AX,DX
  LODSW
  MOV CL,5
  SHL AX,CL
  ADD DX,AX
  LODSW
  ADD DX,AX
  LODSW
  MOV CL,11
  SHL AX,CL
  XCHG AX,BX
  LODSW
  MOV CL,5
  SHL AX,CL
  ADD BX,AX
  LODSW
  SHR AX,1
  ADD AX,BX
  POP DS
End; { PackTime }

Function h_CreateFile; assembler;
{ H_CREATEFILE - DOS Handle file function
  Description: Creates a file; fn=3Ch
  Returns: File handle if successful, 0 if unsuccessful }
Asm
@@1:
  PUSH DS
  LDS DX,Path
  MOV CX,0
  MOV AH,5Bh
  INT DOS
  POP DS
  JC  @@2
  MOV DOSResult,dosrOk
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnCreateFile  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  XOR AX,AX
@@3:
End; { h_CreateFile }

Function h_CreateTempFile; assembler;
{ H_CREATETEMPFILE - DOS Handle file function
  Description: Creates a temporary file; fn=5Ah
  Returns: File handle if successful, 0 if unsuccessful }
Asm
@@1:
  PUSH DS
  LDS DX,Path
  MOV CX,0 { file attribute here, 0 used for normal }
  MOV AH,5Ah
  INT DOS
  POP DS
  JC  @@2
  MOV DOSResult,dosrOk
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnCreateTempFile  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  XOR AX,AX
@@3:
End; { h_CreateTempFile }

Function h_OpenFile; assembler;
{ H_OPENFILE - DOS Handle file function
  Description: Opens a file for input, output or input/output; fn=3Dh
  Returns: File handle if successful, 0 if unsuccessful }
Asm
@@1:
  PUSH DS
  LDS DX,Path
  MOV AH,3Dh
  MOV AL,Mode
  INT DOS
  POP DS
  JC  @@2
  MOV DOSResult,dosrOk
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnOpenFile  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  XOR AX,AX
@@3:
End; { h_OpenFile }

Function h_Read; assembler;
{ H_READ - DOS Handle file function
  Description: Reads a memory block from file; fn=3Fh
  Returns: Actual number of bytes read }
Asm
@@1:
  PUSH DS
  LDS DX,Buffer
  MOV CX,Count
  MOV BX,Handle
  MOV AH,3Fh
  INT DOS
  POP DS
  MOV DOSResult,dosrOk
  JNC @@2
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnRead  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
@@2:
End; { h_Read }

Function h_Write; assembler;
{ H_WRITE - DOS Handle file function
  Description: Writes a memory block to file; fn=40h
  Returns: Actual number of bytes written }
Asm
@@1:
  PUSH DS
  LDS DX,Buffer
  MOV CX,Count
  MOV BX,Handle
  MOV AH,40h
  INT DOS
  POP DS
  MOV DOSResult,dosrOk
  JNC @@2
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnWrite  { store function code }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
@@2:
End; { h_Write }

Function h_Seek; assembler;
{ H_SEEK - DOS Handle file function
  Description: Seeks to a specified file position; fn=42h
               Start is one of the (sk) constants and points to a relative
               seek offset position
  Returns: Current file position if successful, 0 - otherwise }
Asm
@@1:
  MOV CX,WORD PTR [SeekPos+2]
  MOV DX,WORD PTR [SeekPos]
  MOV BX,Handle
  MOV AL,Start
  MOV AH,42h
  MOV DOSResult,dosrOk
  INT DOS
  JNC @@2
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnSeek  { store function number }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
@@2:
End; { h_Seek }

Function h_FilePos;
{ H_GETPOS - DOS Handle file function
  Description: Calls h_Seek to determine file active position
  Returns: Current file (seek) position number in long integer }
Begin
  h_FilePos := h_Seek(Handle, 0, skPos)
End; { h_FilePos }

Function h_FileSize;
{ H_FILESIZE - DOS Handle file function
  Description: Determines file size
  Returns: File size in bytes }
var SavePos, Size : longint;
Begin
  SavePos := h_FilePos(Handle);
  h_FileSize := h_Seek(Handle, 0, skEnd);
  h_Seek(Handle, SavePos, skStart)
End; { h_FileSize }

Function h_Eof; assembler;
{ H_EOF - DOS Handle file function
  Description: Checks if the current file position is equal to file size
               and then returns True
  Returns: True if end of file detected, False - otherwise }
var Size : longint;
Asm
  PUSH Handle
  CALL h_FileSize               { Get file size in AX:DX }
  MOV WORD PTR [Size],AX        { Store high word }
  MOV WORD PTR [Size+2],DX      { Store low word }
  PUSH Handle
  CALL h_FilePos                 { Get current file position }
  XOR CL,CL
  CMP AX,WORD PTR [Size]
  JNE @@1
  CMP DX,WORD PTR [Size+2]
  JNE @@1
  MOV CL,True
@@1:
  MOV AL,CL
End; { h_GetPos }

Function h_GetFTime; assembler;
{ H_GETFTIME - DOS Handle file function
  Description: Returns file update date and time values; fn=5700h
  Returns: Date and time values in long integer
           or negative DOS error code if an error occured }
Asm
@@1:
  MOV BX,Handle
  MOV AX,5700h { read date and time }
  MOV DOSResult,dosrOk
  INT DOS
  JNC @@2
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnGetFDateTime  { store function number }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
  NEG AX
@@2:
End; { h_GetFTime }

Function h_SetFTime; assembler;
{ H_SETFTIME - DOS Handle file function
  Description: Sets file date and time; fn=5701h
  Returns: New date and time values in long integer
           or negative DOS error code if an error occured }
Asm
@@1:
  MOV CX,WORD PTR [DateTime]
  MOV DX,WORD PTR [DateTime+2]
  MOV BX,Handle
  MOV AX,5701h { read date and time }
  MOV DOSResult,dosrOk
  INT DOS
  JNC @@2
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnSetFDateTime  { store function number }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
  NEG AX
@@2:
End; { h_SetFTime }

Function h_CloseFile; assembler;
{ H_CLOSEFILE - DOS Handle file function
  Description: Closes open file; fn=3Eh
  Returns: 0 if successful, negative DOS error code otherwise }
Asm
@@1:
  MOV BX,Handle
  MOV AH,3Eh
  INT DOS
  JC  @@2
  XOR AX,AX
  MOV DOSResult,dosrOk
  JMP @@3
@@2:
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnCloseFile  { store function number }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  POP AX
  NEG AX
@@3:
End; { h_CloseFile }

Function MemAlloc; assembler;
Asm
@@1:
  MOV DOSResult,dosrOk
  MOV AX,WORD PTR [Size]
  MOV DX,WORD PTR [Size+2]
  MOV CX,16
  DIV CX
  INC AX
  MOV BX,AX
  MOV AH,48h
  INT DOS
  JNC @@2
  MOV DOSResult,AX { save error code in global variable }
  PUSH AX     { store error code }
  PUSH fnMemAlloc  { store function number }
  CALL ErrorHandler
  CMP AL,frRetry
  JE  @@1
  XOR AX,AX
@@2:
  MOV DX,AX
  XOR AX,AX
End; { MemAlloc }

Function MemFree; assembler;
Asm
  MOV DOSResult,dosrOk
  MOV ES,WORD PTR [P+2]
  MOV AH,49h
  INT DOS
  JNC @@1
  MOV DOSResult,AX
  PUSH AX
  PUSH fnMemFree
  CALL ErrorHandler
@@1:
  MOV AX,DOSResult
  NEG AX
End; { MemFree }

Function FileSearch; assembler;
{ FileSearch searches for the file given by Name in the list of }
{ directories given by List. The directory paths in List must   }
{ be separated by semicolons. The search always starts with the }
{ current directory of the current drive. If the file is found, }
{ FileSearch stores a concatenation of the directory path and   }
{ the file name in Dest. Otherwise FileSearch stores an empty   }
{ string in Dest. The maximum length of the result is defined   }
{ by the fsPathName constant. The returned value is Dest.       }
Asm
  PUSH DS
  CLD
  LDS SI,List
  LES DI,Dest
  MOV CX,fsPathName
@@1:
  PUSH DS
  PUSH SI
  JCXZ @@3
  LDS SI,Name
@@2:
  LODSB
  OR  AL,AL
  JE  @@3
  STOSB
  LOOP @@2
@@3:
  XOR AL,AL
  STOSB
  LES DI,Dest
  MOV AX,4300H
  CALL AnsiDosFunc
  POP SI
  POP DS
  JC  @@4
  TEST CX,18H
  JE  @@9
@@4:
  LES DI,Dest
  MOV CX,fsPathName
  XOR AH,AH
  LODSB
  OR  AL,AL
  JE  @@8
@@5:
  CMP AL,';'
  JE  @@7
  JCXZ @@6
  MOV AH,AL
  STOSB
  DEC CX
@@6:
  LODSB
  OR  AL,AL
  JNE @@5
  DEC SI
@@7:
  JCXZ @@1
  CMP AH,':'
  JE  @@1
  MOV AL,'\'
  CMP AL,AH
  JE  @@1
  STOSB
  DEC CX
  JMP @@1
@@8:
  STOSB
@@9:
  MOV AX,WORD PTR [Dest]
  MOV DX,WORD PTR [Dest+2]
  POP DS
End; { FileSearch }

Function FileExpand; assembler;
{ FileExpand fully expands the file name in Name, and stores    }
{ the result in Dest. The maximum length of the result is       }
{ defined by the fsPathName constant. The result is an all }
{ upper case string consisting of a drive letter, a colon, a }
{ root relative directory path, and a file name. Embedded '.' }
{ and '..' directory references are removed, and all name and }
{ extension components are truncated to 8 and 3 characters. The }
{ returned value is Dest.                }

Asm
  PUSH DS
  CLD
  LDS SI,Name
  LEA DI,TempStr
  PUSH SS
  POP ES
  LODSW
  OR  AL,AL
  JE  @@1
  CMP AH,':'
  JNE @@1
  CMP AL,'a'
  JB  @@2
  CMP AL,'z'
  JA  @@2
  SUB AL,20H
  JMP @@2
@@1:
  DEC SI
  DEC SI
  MOV AH,19H
  INT DOS
  ADD AL,'A'
  MOV AH,':'
@@2:
  STOSW
  CMP [SI].Byte,'\'
  JE  @@3
  SUB AL,'A'-1
  MOV DL,AL
  MOV AL,'\'
  STOSB
  PUSH DS
  PUSH SI
  MOV AH,47H
  MOV SI,DI
  PUSH ES
  POP DS
  INT DOS
  POP SI
  POP DS
  JC  @@3
  XOR AL,AL
  CMP AL,ES:[DI]
  JE  @@3
{$IFDEF Windows}
  PUSH ES
  PUSH ES
  PUSH DI
  PUSH ES
  PUSH DI
  CALL OemToAnsi
  POP ES
{$ENDIF}
  MOV CX,0FFFFH
  XOR AL,AL
  CLD
  REPNE SCASB
  DEC DI
  MOV AL,'\'
  STOSB
@@3:
  MOV CX,8
@@4:
  LODSB
  OR  AL,AL
  JE  @@7
  CMP AL,'\'
  JE  @@7
  CMP AL,'.'
  JE  @@6
  JCXZ @@4
  DEC CX
{$IFNDEF Windows}
  CMP AL,'a'
  JB  @@5
  CMP AL,'z'
  JA  @@5
  SUB AL,20H
{$ENDIF}
@@5:
  STOSB
  JMP @@4
@@6:
  MOV CL,3
  JMP @@5
@@7:
  CMP ES:[DI-2].Word,'.\'
  JNE @@8
  DEC DI
  DEC DI
  JMP @@10
@@8:
  CMP ES:[DI-2].Word,'..'
  JNE @@10
  CMP ES:[DI-3].Byte,'\'
  JNE @@10
  SUB DI,3
  CMP ES:[DI-1].Byte,':'
  JE  @@10
@@9:
  DEC DI
  CMP ES:[DI].Byte,'\'
  JNE @@9
@@10:
  MOV CL,8
  OR  AL,AL
  JNE @@5
  CMP ES:[DI-1].Byte,':'
  JNE @@11
  MOV AL,'\'
  STOSB
@@11:
  LEA SI,TempStr
  PUSH SS
  POP DS
  MOV CX,DI
  SUB CX,SI
  CMP CX,79
  JBE @@12
  MOV CX,79
@@12:
  LES DI,Dest
  PUSH ES
  PUSH DI
{$IFDEF Windows}
  PUSH ES
  PUSH DI
{$ENDIF}
  REP MOVSB
  XOR AL,AL
  STOSB
{$IFDEF Windows}
  CALL AnsiUpper
{$ENDIF}
  POP AX
  POP DX
  POP DS
End; { FileExpand }

{$W+}
Function FileSplit;
{ FileSplit splits the file name specified by Path into its     }
{ three components. Dir is set to the drive and directory path  }
{ with any leading and trailing backslashes, Name is set to the }
{ file name, and Ext is set to the extension with a preceding   }
{ period. If a component string parameter is NIL, the           }
{ corresponding part of the path is not stored. If the path     }
{ does not contain a given component, the returned component    }
{ string is empty. The maximum lengths of the strings returned  }
{ in Dir, Name, and Ext are defined by the fsDirectory,         }
{ fsFileName, and fsExtension constants. The returned value is  }
{ a combination of the fcDirectory, fcFileName, and fcExtension }
{ bit masks, indicating which components were present in the    }
{ path. If the name or extension contains any wildcard          }
{ characters (* or ?), the fcWildcards flag is set in the       }
{ returned value.                                               }
var
  DirLen, NameLen, Flags : word;
  NamePtr, ExtPtr : PChar;
begin
  NamePtr := StrRScan(Path, '\');
  if NamePtr = nil then NamePtr := StrRScan(Path, ':');
  if NamePtr = nil then NamePtr := Path else Inc(NamePtr);
  ExtPtr := StrScan(NamePtr, '.');
  if ExtPtr = nil then ExtPtr := StrEnd(NamePtr);
  DirLen := NamePtr - Path;
  if DirLen > fsDirectory then DirLen := fsDirectory;
  NameLen := ExtPtr - NamePtr;
  if NameLen > fsFilename then NameLen := fsFilename;
  Flags := 0;
  if (StrScan(NamePtr, '?') <> nil) or (StrScan(NamePtr, '*') <> nil) then
    Flags := fcWildcards;
  if DirLen <> 0 then Flags := Flags or fcDirectory;
  if NameLen <> 0 then Flags := Flags or fcFilename;
  if ExtPtr[0] <> #0 then Flags := Flags or fcExtension;
  if Dir <> nil then StrLCopy(Dir, Path, DirLen);
  if Name <> nil then StrLCopy(Name, NamePtr, NameLen);
  if Ext <> nil then StrLCopy(Ext, ExtPtr, fsExtension);
  FileSplit := Flags;
End; { FileSplit }
{$W-}

Function StdErrorProc(ErrCode : integer; FuncCode : word) : byte; far;
assembler;
{ Default error handler procedure called from EnhDOS functions }
Asm
  MOV AL,frOk   { Return zero }
End; { StdErrorProc }


const WrongDOSVersion : PChar = 'DOS 3.1 or greater required.'#13#10'$';

Begin
  asm
    MOV AH,30h { Get DOS version }
    INT DOS
    CMP AL,3
    JGE @@continue { if greater than or equal to 3 then continue else exit }
    PUSH DS
    LDS DX,WrongDOSVersion
    MOV AH,09h
    INT DOS
    MOV AH,4Ch
    INT DOS
  @@continue:
    LES DI,Copyright
  end;
  DOSResult := dosrOk;
  SetErrorHandler(StdErrorProc)
End. { EnhDOS+ }

{ -------------------------------------   DEMO ------------------   }
{ ***** ENHDDEMO.PAS ***** }

Program DemoEnhDOS;
{ Copyright (c) 1994 by Andrew Eigus   Fido Net 2:5100/33 }
{ EnhDOS+ (Int21) demo program }

{$M 8192,0,0}
{ no heap size, couz using own memeory allocation }

(* Simple copy file program *)

uses EnhDOS, Strings;

const BufSize = 65535; { may be larger; you may allocate more }

var
  Buffer : pointer;
  InputFile, OutputFile : array[0..63] of Char;
  Handle1, Handle2 : THandle;
  BytesRead : word;

Function Int21ErrorHandler(ErrCode : integer; FuncCode : word) : byte; far;
var fn : array[0..20] of Char;
Begin
  case FuncCode of
    fnOpenFile: StrCopy(fn, 'h_OpenFile');
    fnCreateFile: StrCopy(fn, 'h_CreateFile');
    fnRead: StrCopy(fn, 'h_Read');
    fnWrite: StrCopy(fn, 'h_Write');
    fnSeek: StrCopy(fn, 'h_Seek');
    fnCloseFile: StrCopy(fn, 'h_CloseFile');
    fnMemAlloc: StrCopy(fn, 'MemAlloc');
    fnDeleteFile: Exit;
    else fn[0] := #0
  end;
  WriteLn('DOS Error ', ErrCode, ' in function ', FuncCode, ' (', fn, ')');
  { actually for function return code see fr consts in the EnhDOS const
    section }
End; { Int21ErrorHandler }

Begin
  SetErrorHandler(Int21ErrorHandler);

  WriteLn('EnhDOS+ demo program: copies one file to another');
  repeat
    if ParamCount > 0 then
      StrPCopy(InputFile, ParamStr(1))
    else
    begin
      Write('Enter file name to read from: ');
      ReadLn(InputFile)
    end;
    if ParamCount > 1 then
      StrPCopy(OutputFile, ParamStr(2))
    else
    begin
      Write('Enter file name to write to:  ');
      ReadLn(OutputFile)
    end;
    WriteLn
  until (StrLen(InputFile) > 0) and (StrLen(OutputFile) > 0);

  if not ExistsFile(InputFile) then
  begin
    WriteLn('File not found: ', InputFile);
    Halt(1)
  end;

  Buffer := MemAlloc(BufSize);

  Write('Copying... ');

  Handle1 := h_OpenFile(InputFile, omRead);
  if Handle1 <> 0 then
  begin
    DeleteFile(OutputFile);
    Handle2 := h_CreateFile(OutputFile);
    if Handle2 <> 0 then
    begin
      BytesRead := 1;

      while (BytesRead > 0) and (DOSResult = dosrOk) do
      begin
        BytesRead := h_Read(Handle1, Buffer^, BufSize);

        if DOSResult <> dosrOk then
          { read error then }
          WriteLn('Error reading from input file');

        if h_Write(Handle2, Buffer^, BytesRead) <> BytesRead then
          { write error then }
        begin
          WriteLn('Error writing to output file');
          DOSResult := $FF
        end
      end;
      if DOSResult = dosrOk then WriteLn('File copied OK');
      h_CloseFile(Handle2)
    end;
    h_CloseFile(Handle1)
  end;

  MemFree(Buffer)
End. { DemoEnhDOS }

