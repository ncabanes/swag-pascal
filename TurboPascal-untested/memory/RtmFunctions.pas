(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0060.PAS
  Description: RTM Functions
  Author: PETER SAWATZKI
  Date: 08-24-94  13:55
*)

Unit RtmApi;
{ Import unit for all new functions in RTM 1.5
  written 06/20/94 by Peter Sawatzki }
Interface
Uses
  WinTypes;

procedure FatalExit(Code: Integer);
function GetVersion: LongInt;
function LocalInit(Segment, Start, EndPos: Word): Bool;
function LocalAlloc(Flags, Bytes: Word): THandle;
function LocalReAlloc(Mem: THandle; Bytes, Flags: Word): THandle;
function LocalFree(Mem: THandle): THandle;
function LocalLock(Mem: THandle): Pointer;
function LocalUnlock(Mem: THandle): Bool;
function LocalSize(Mem: THandle): Word;
function LocalHandle(Mem: Word): THandle;
function LocalFlags(Mem: THandle): Word;
function LocalCompact(MinFree: Word): Word;
function LocalDiscard(Mem: THandle): THandle;
{function LocalNotify(NotifyProc: TFarProc): TFarProc;}
function GlobalAlloc(Flags: Word; Bytes: LongInt): THandle;
function GlobalReAlloc(Mem: THandle; Bytes: LongInt; Flags: Word): THandle;
function GlobalFree(Mem: THandle): THandle;
function GlobalLock(Mem: THandle): Pointer;
function GlobalUnlock(Mem: THandle): Bool;
function UnlockResource(ResData: THandle): Bool;
function GlobalSize(Mem: THandle): LongInt;
function GlobalHandle(Mem: Word): LongInt;
function GlobalFlags(Mem: THandle): Word;
function LockSegment(Segment: Word): THandle;
function UnlockSegment(Segment: Word): THandle;
function GlobalCompact(MinFree: LongInt): LongInt;
function GetCurrentTask: THandle;
function GetModuleUsage(Module: THandle): Integer;
function GetModuleFileName(Module: THandle; Filename: PChar; Size: Integer): Integer;
function GetModuleHandle(ModuleName: PChar): THandle;
function GetProcAddress(Module: THandle; ProcName: PChar): TFarProc;
function Catch(var CatchBuf: TCatchBuf): Integer;
procedure Throw(var CatchBuf: TCatchBuf; ThrowBack: Integer);
function GetProfileInt(AppName, KeyName: PChar; Default: Integer): Word;
function GetProfileString(AppName, KeyName, Default, ReturnedString: PChar; Size: Integer): Integer;
function WriteProfileString(ApplicationName, KeyName, Str: PChar): Bool;
function FindResource(Instance: THandle; Name, ResType: PChar): THandle;
function LoadResource(Instance: THandle; ResInfo: THandle): THandle;
function LockResource(ResData: THandle): Pointer;
function FreeResource(ResData: THandle): Bool;
function AccessResource(Instance, ResInfo: THandle): Integer;
function SizeofResource(Instance, ResInfo: THandle): LongInt;
function OpenFile(FileName: PChar; var ReOpenBuff: TOfStruct; Style: Word): Integer;
function _lclose(FileHandle: Integer): Integer;
function _lread(FileHandle: Integer; Buffer: PChar; Bytes: Integer): Word;
function _lcreat(PathName: PChar; Atribute: Integer): Integer;
function _llseek(FileHandle: Integer; Offset: LongInt; Origin: Integer): LongInt;
function _lopen(PathName: PChar; ReadWrite: Integer): Integer;
function _lwrite(FileHandle: Integer; Buffer: PChar; Bytes: Integer): Word;
function LoadLibrary(LibFileName: PChar): THandle;
procedure FreeLibrary(LibModule: THandle);
procedure DOS3Call;
procedure OutputDebugString(OutputString: PChar);
function LocalShrink(Seg: THandle; Size: Word): Word;
function GetPrivateProfileInt(ApplicationName, KeyName: PChar;
                              Default: Integer; FileName: PChar): Word;
function GetPrivateProfileString(ApplicationName, KeyName: PChar;
                                 Default: PChar; ReturnedString: PChar;
                                 Size: Integer; FileName: PChar): Integer;
function WritePrivateProfileString(ApplicationName, KeyName, Str, FileName: PChar): Bool;
function GetDOSEnvironment: PChar;
function GetWinFlags: LongInt;
Function GetExePtr (aHandle: tHandle): tHandle;
function GetWindowsDirectory(Buffer: PChar; Size: Word): Word;
function GetSystemDirectory(Buffer: PChar; Size: Word): Word;
procedure GlobalNotify(NotifyProc: TFarProc);
function GlobalLRUOldest(Mem: THandle): THandle;
function GlobalLRUNewest(Mem: THandle): THandle;
function GetFreeSpace(Flag: Word): LongInt;
function AllocDStoCSAlias(Selector: Word): Word;
function AllocSelector(Selector: Word): Word;
function FreeSelector(Selector: Word): Word;
function ChangeSelector(DestSelector, SourceSelector: Word): Word;
function GlobalDosAlloc(Bytes: LongInt): LongInt;
function GlobalDosFree(Selector: Word): Word;
function GlobalPageLock(Selector: THandle): Word;
function GlobalPageUnlock(Selector: THandle): Word;
procedure GlobalFix(Mem: THandle);
function GlobalUnfix(Mem: THandle): Bool;
function AnsiUpper(Str: PChar): PChar;
function AnsiLower(Str: PChar): PChar;
function PrestoChangoSelector(SourceSel, DestSel: Word): Word;
function GetSelectorBase(Selector: Word): Longint;
function SetSelectorBase(Selector: Word; Base: Longint): Word;
function GetSelectorLimit(Selector: Word): Longint;
function SetSelectorLimit(Selector: Word; Base: Longint): Word;
function LockData(Dummy: Integer): THandle;
function UnlockData(Dummy: Integer): THandle;
function GlobalDiscard(Mem: THandle): THandle;

{USER}
function MessageBox(WndParent: HWnd; Txt, Caption: PChar; TextType: Word): Integer;
function GetTickCount: LongInt;
function GetCurrentTime: LongInt;
function LoadString(Instance: THandle; ID: Word; Buffer: PChar; BufferMax: Integer): Integer;
function _wsprintf(DestStr, Format: PChar; var ArgList): Integer; CDecl;

{KEYBOARD}
function AnsiToOem(AnsiStr, OemStr: PChar): Integer;
procedure AnsiToOemBuff(AnsiStr, OemStr: PChar; Length: Integer);
function OemToAnsi(OemStr, AnsiStr: PChar): Bool;
procedure OemToAnsiBuff(OemStr, AnsiStr: PChar; Length: Integer);

Implementation

function _LocalLock(Mem: THandle): Word; far; forward;

procedure FatalExit;                    external 'KERNEL'        Index 1;
function GetVersion;                    external 'KERNEL'        Index 3;
function LocalInit;                     external 'KERNEL'        Index 4;
function LocalAlloc;                    external 'KERNEL'        Index 5;
function LocalReAlloc;                  external 'KERNEL'        Index 6;
function LocalFree;                     external 'KERNEL'        Index 7;
function _LocalLock;                    external 'KERNEL'        Index 8;
function LocalUnlock;                   external 'KERNEL'        Index 9;
function LocalSize;                     external 'KERNEL'        Index 10;
function LocalHandle;                   external 'KERNEL'        Index 11;
function LocalFlags;                    external 'KERNEL'        Index 12;
function LocalCompact;                  external 'KERNEL'        Index 13;
{function LocalNotify;                   external 'KERNEL'       Index 14;}
function GlobalAlloc;                   external 'KERNEL'        Index 15;
function GlobalReAlloc;                 external 'KERNEL'        Index 16;
function GlobalFree;                    external 'KERNEL'        Index 17;
function GlobalLock;                    external 'KERNEL'        Index 18;
function GlobalUnlock;                  external 'KERNEL'        Index 19;
function UnlockResource;                external 'KERNEL'        Index 19;
function GlobalSize;                    external 'KERNEL'        Index 20;
function GlobalHandle;                  external 'KERNEL'        Index 21;
function GlobalFlags;                   external 'KERNEL'        Index 22;
function LockSegment;                   external 'KERNEL'        Index 23;
function UnlockSegment;                 external 'KERNEL'        Index 24;
function GlobalCompact;                 external 'KERNEL'        Index 25;
function GetCurrentTask;                external 'KERNEL'        Index 36;
function GetModuleHandle;               external 'KERNEL'        Index 47;
function GetModuleUsage;                external 'KERNEL'        Index 48;
function GetModuleFileName;             external 'KERNEL'        Index 49;
function GetProcAddress;                external 'KERNEL'        Index 50;
function Catch;                         external 'KERNEL'        Index 55;
procedure Throw;                        external 'KERNEL'        Index 56;
function GetProfileInt;                 external 'KERNEL'        Index 57;
function GetProfileString;              external 'KERNEL'        Index 58;
function WriteProfileString;            external 'KERNEL'        Index 59;
function FindResource;                  external 'KERNEL'        Index 60;
function LoadResource;                  external 'KERNEL'        Index 61;
function LockResource;                  external 'KERNEL'        Index 62;
function FreeResource;                  external 'KERNEL'        Index 63;
function AccessResource;                external 'KERNEL'        Index 64;
function SizeofResource;                external 'KERNEL'        Index 65;
function OpenFile;                      external 'KERNEL'        Index 74;
function _lclose;                       external 'KERNEL'        Index 81;
function _lread;                        external 'KERNEL'        Index 82;
function _lcreat;                       external 'KERNEL'        Index 83;
function _llseek;                       external 'KERNEL'        Index 84;
function _lopen;                        external 'KERNEL'        Index 85;
function _lwrite;                       external 'KERNEL'        Index 86;
function LoadLibrary;                   external 'KERNEL'        Index 95;
procedure FreeLibrary;                  external 'KERNEL'        Index 96;
procedure DOS3Call;                     external 'KERNEL'        Index 102;
procedure OutputDebugString;            external 'KERNEL'        Index 115;
function LocalShrink;                   external 'KERNEL'        Index 121;
function GetPrivateProfileInt;          external 'KERNEL'        Index 127;
function GetPrivateProfileString;       external 'KERNEL'        Index 128;
function WritePrivateProfileString;     external 'KERNEL'        Index 129;
function GetDOSEnvironment;             external 'KERNEL'        Index 131;
function GetWinFlags;                   external 'KERNEL'        Index 132;
function GetExePtr;                     external 'KERNEL'        Index 133;
function GetWindowsDirectory;           external 'KERNEL'        Index 134;
function GetSystemDirectory;            external 'KERNEL'        Index 135;
procedure GlobalNotify;                 external 'KERNEL'        Index 154;
function GlobalLRUOldest;               external 'KERNEL'        Index 163;
function GlobalLRUNewest;               external 'KERNEL'        Index 164;
function GetFreeSpace;                  external 'KERNEL'        Index 169;
function AllocDStoCSAlias;              external 'KERNEL'        Index 171;
function AllocSelector;                 external 'KERNEL'        Index 175;
function FreeSelector;                  external 'KERNEL'        Index 176;
function ChangeSelector;                external 'KERNEL'        Index 177;
function GlobalDosAlloc;                external 'KERNEL'        Index 184;
function GlobalDosFree;                 external 'KERNEL'        Index 185;
function GlobalPageLock;                external 'KERNEL'        Index 191;
function GlobalPageUnlock;              external 'KERNEL'        Index 192;
procedure GlobalFix;                    external 'KERNEL'        Index 197;
function GlobalUnfix;                   external 'KERNEL'        Index 198;
function AnsiUpper;                     external 'KERNEL'        Index 431;
function AnsiLower;                     external 'KERNEL'        Index 432;
function PrestoChangoSelector;          external 'KERNEL'        Index 177;
function GetSelectorBase;               external 'KERNEL'        Index 186;
function SetSelectorBase;               external 'KERNEL'        Index 187;
function GetSelectorLimit;              external 'KERNEL'        Index 188;
function SetSelectorLimit;              external 'KERNEL'        Index 189;

function MessageBox;                    external 'USER'          Index 1;
function GetTickCount;                  external 'USER'          Index 13;
function GetCurrentTime;                external 'USER'          Index 15;
function LoadString;                    external 'USER'          Index 176;
function _wsprintf;                     external 'USER'          Index 420;

function AnsiToOem;                     external 'KEYBOARD'      Index 5;
function OemToAnsi;                     external 'KEYBOARD'      Index 6;
procedure AnsiToOemBuff;                external 'KEYBOARD'      Index 134;
procedure OemToAnsiBuff;                external 'KEYBOARD'      Index 135;

{ Various wrapper routines }

function LockData(Dummy: Integer): THandle;
begin
  LockData := LockSegment($FFFF);
end;

function UnlockData(Dummy: Integer): THandle;
begin
  UnlockData := UnlockSegment($FFFF);
end;

function GlobalDiscard(Mem: THandle): THandle;
begin
  GlobalDiscard := GlobalReAlloc(Mem, 0, gmem_Moveable);
end;

function LocalDiscard(Mem: THandle): THandle;
begin
  LocalDiscard := LocalReAlloc(Mem, 0, lmem_Moveable);
end;

function LocalLock(Mem: THandle): Pointer; assembler;
asm
        PUSH    Mem
        CALL    _LocalLock
        MOV     DX,DS
end;

End.

