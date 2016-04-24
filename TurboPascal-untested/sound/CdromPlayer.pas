(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0043.PAS
  Description: CDROM Player
  Author: MICHAEL W. ARMSTRONG
  Date: 05-26-94  06:37
*)

{ Copyright 1993 by Michael W. Armstrong.
                    2800 Skipwith Rd
                    Richmond, VA 23294

  Compuserve ID 72740, 1145
  This program is entered as Shareware.  If you find it useful, a small
  donation would be appreciated.  Feel free to incorporate the code into
  your own programs.
}

{  NOTE : The CD_Vars and CDUNIT_P are at the end of this code }


{$X+}
program CDPlay;

{$IfDef Windows}
{$C PRELOAD}
uses CD_Vars, CDUnit_P, WinCRT, WinProcs;
{$Else}
uses CD_Vars, CDUnit_P, CRT, Drivers;
{$EndIf}

Type
  TotPlayRec = Record
     Frames,
     Seconds,
     Minutes,
     Nada     : Byte;
  End;

Var
  GoodDisk : Boolean;
  SaveExit   : Pointer;
  OldMode    : Word;
  CurrentTrack,
  StartTrack,
  EndTrack   : Integer;
  TotPlay    : TotPlayRec;
  TrackInfo  : Array[1..99] of PAudioTrackInfo;

function LeadingZero(w: Word): String;
var s: String;
begin
  Str(w:0, s);
  LeadingZero := Copy('00', 1, 2 - Length(s)) + s;
end;


procedure DrawScreen;
Const TStr = '%03d:%02d';
      VStr = '%1d.%2d';
Var   FStr : PChar;
      NStr : String;
      Param: Array[1..2] of LongInt;
      Code : Integer;
begin
  WriteLn('CD ROM Audio Disk Player');
  WriteLn('Copyright 1992 by M. W. ARMSTRONG');
  Param[1] := MSCDEX_Version.Major;
  Param[2] := MSCDEX_Version.Minor;

{$IfDef Windows}
  wvsPrintf(FStr, VStr, Param);
{$Else}
  FormatStr(NStr, VStr, Param);
{$EndIf}

  WriteLn('MSCDEX Version ', NStr);
  Str(NumberOfCD, NStr);
  WriteLn('Number of CD ROM Drives is: '+Nstr);
  WriteLn('First CD Drive Letter is  : '+Chr(FirstCD+65));
  WriteLn('There are ' + LeadingZero(EndTrack - StartTrack + 1) + ' Tracks on this disk');
  Code := 1;
end;
{***********************************************************************}

{***********************************************************************}


procedure Setup;
Var
  LeadOut,
  StartP,
  TotalPlayTime    : LongInt;
  I     : Integer;
  A,B,C : LongInt;
  Track : Byte;
  EA    : Array[1..4] of Byte;
  SP,EP : LongInt;

Begin
  FillChar(AudioDiskInfo, SizeOf(AudioDiskInfo), #0);
  DeviceStatus;
  If Audio THEN
  Begin
    Audio_Disk_Info;
    TotalPlayTime := 0;
    LeadOut := AudioDiskInfo.LeadOutTrack;

    StartTrack := AudioDiskInfo.LowestTrack;
    EndTrack := AudioDiskInfo.HighestTrack;
    CurrentTrack := StartTrack;
    I := StartTrack-1;

    Repeat               { Checks if Audio Track or Data Track }
        Inc(I);
        Track := I;
        Audio_Track_Info(StartP, Track);
    Until (Track AND 64 = 0) OR (I = EndTrack);

    StartTrack := I;

    For I := StartTrack to EndTrack DO
      Begin
        Track := I;
        Audio_Track_Info(StartP, Track);
        New(TrackInfo[I]);
        FillChar(TrackInfo[I]^, SizeOf(TrackInfo[I]^), #0);
        TrackInfo[I]^.Track := I;
        TrackInfo[I]^.StartPoint := StartP;
        TrackInfo[I]^.TrackControl := Track;
      End;

    For I := StartTrack to EndTrack - 1 DO
        TrackInfo[I]^.EndPoint := TrackInfo[I+1]^.StartPoint;
    TrackInfo[EndTrack]^.EndPoint := LeadOut;

    For I := StartTrack to EndTrack DO
        Move(TrackInfo[I]^.EndPoint, TrackInfo[I]^.Frames, 4);

    TrackInfo[StartTrack]^.PlayMin := TrackInfo[StartTrack]^.Minutes;
    TrackInfo[StartTrack]^.PlaySec := TrackInfo[StartTrack]^.Seconds - 2;

    For I := StartTrack + 1 to EndTrack DO
      Begin
        EP := (TrackInfo[I]^.Minutes * 60) + TrackInfo[I]^.Seconds;
        SP := (TrackInfo[I-1]^.Minutes * 60) + TrackInfo[I-1]^.Seconds;
        EP := EP - SP;
        TrackInfo[I]^.PlayMin := EP DIV 60;
        TrackInfo[I]^.PlaySec := EP Mod 60;
      End;

    TotalPlayTime := AudioDiskInfo.LeadOutTrack - TrackInfo[StartTrack]^.StartPoint;
    Move(TotalPlayTime, TotPlay, 4);
  End;
end;

{***********************************************************************}


Begin
  Setup;
  If Audio THEN
  If Playing THEN
     StopAudio
  ELSE
     Begin
       StopAudio;
       Play_Audio(TrackInfo[StartTrack]^.StartPoint,
             TrackInfo[EndTrack]^.EndPoint);
       Audio_Status_Info;
       DrawScreen;
     End
  ELSE
      WriteLn('This is not an Audio CD');
  WriteLn('UPC Code is: ', UPC_Code);
end.

{ -----------------------------------   CUT HERE --------------------   }

Unit CD_Vars;

Interface

Type
  ListBuf    = Record
    UnitCode : Byte;
    UnitSeg,
    UnitOfs  : Word;
  end;
  VTOCArray  = Array[1..2048] of Byte;
  DriveByteArray = Array[1..128] of Byte;

  Req_Hdr    = Record
     Len     : Byte;
     SubUnit : Byte;
     Command : Byte;
     Status  : Word;
     Reserved: Array[1..8] of Byte;
  End;

Const
  Init       = 0;
  IoCtlInput = 3;
  InputFlush = 7;
  IOCtlOutput= 12;
  DevOpen    = 13;
  DevClose   = 14;
  ReadLong   = 128;
  ReadLongP  = 130;
  SeekCmd    = 131;
  PlayCD     = 132;
  StopPlay   = 133;
  ResumePlay = 136;

Type

  Audio_Play = Record
    APReq    : Req_Hdr;
    AddrMode : Byte;
    Start    : LongInt;
    NumSecs  : LongInt;
  end;

  IOControlBlock = Record
    IOReq_Hdr : Req_Hdr;
    MediaDesc : Byte;
    TransAddr : Pointer;
    NumBytes  : Word;
    StartSec  : Word;
    ReqVol    : Pointer;
    TransBlock: Array[1..130] OF Byte;
  End;

  ReadControl = Record
    IOReq_Hdr : Req_Hdr;
    AddrMode  : Byte;
    TransAddr : Pointer;
    NumSecs   : Word;
    StartSec  : LongInt;
    ReadMode  : Byte;
    IL_Size,
    IL_Skip   : Byte;
  End;

  AudioDiskInfoRec = Record
    LowestTrack    : Byte;
    HighestTrack   : Byte;
    LeadOutTrack   : LongInt;
  End;

  PAudioTrackInfo   = ^AudioTrackInfoRec;
  AudioTrackInfoRec = Record
    Track           : Integer;
    StartPoint      : LongInt;
    EndPoint        : LongInt;
    Frames,
    Seconds,
    Minutes,
    PlayMin,
    PlaySec,
    TrackControl    : Byte;
  end;

  MSCDEX_Ver_Rec = Record
    Major,
    Minor       : Integer;
  End;

  DirBufRec    = Record
     XAR_Len   : Byte;
     FileStart : LongInt;
     BlockSize : Integer;
     FileLen   : LongInt;
     DT        : Byte;
     Flags     : Byte;
     InterSize : Byte;
     InterSkip : Byte;
     VSSN      : Integer;
     NameLen   : Byte;
     NameArray : Array[1..38] of Char;
     FileVer   : Integer;
     SysUseLen : Byte;
     SysUseData: Array[1..220] of Byte;
     FileName  : String[38];
  end;

  Q_Channel_Rec = Record
    Control     : Byte;
    Track       : Byte;
    Index       : Byte;
    Minutes     : Byte;
    Seconds     : Byte;
    Frame       : Byte;
    Zero        : Byte;
    AMinutes    : Byte;
    ASeconds    : Byte;
    AFrame      : Byte;
  End;

Var
  AudioChannel   : Array[1..9] of Byte;
  RedBook,
  Audio,
  DoorOpen,
  DoorLocked,
  AudioManip,
  DiscInDrive    : Boolean;
  AudioDiskInfo  : AudioDiskInfoRec;
  DriverList     : Array[1..26] of ListBuf;
  NumberOfCD     : Integer;
  FirstCD        : Integer;
  UnitList       : Array[1..26] of Byte;
  MSCDEX_Version : MSCDEX_Ver_Rec;
  QChannelInfo   : Q_Channel_Rec;
  Busy,
  Playing,
  Paused         : Boolean;
  Last_Start,
  Last_End       : LongInt;
  DirBuf         : DirBufRec;

Implementation

Begin
  FillChar(DriverList, SizeOf(DriverList), #0);
  FillChar(UnitList, SizeOf(UnitList), #0);
  NumberOfCD  := 0;
  FirstCD  := 0;
  MSCDEX_Version.Major := 0;
  MSCDEX_Version.Minor := 0;
end.

{ -----------------------------------   CUT HERE --------------------   }

{$X+}

Unit CDUnit_P;

Interface

{Include the appropriate units.}

{$IfDef Windows}
{$C PRELOAD}
Uses Strings, WinCRT, WinDOS, WinProcs, SimRMI, CD_Vars;
{$EndIf}
{$IfDef DPMI}
Uses Strings, CRT, DOS, WinAPI, SimRMI, CD_Vars;
{$EndIf}
{$IfDef MSDOS}
Uses Strings, CRT, DOS, CD_Vars;
{$EndIf}

Var
  Drive   : Integer;  { Must set drive before all operations }
  SubUnit : Integer;

function File_Name(var Code : Integer) : String;

function Read_VTOC(var VTOC : VTOCArray;
                   var Index : Integer) : Boolean;

procedure CD_Check(var Code : Integer);

procedure Vol_Desc(Var Code : Integer;
                   var ErrCode : Integer);

procedure Get_Dir_Entry(PathName : String;
                        var Format, ErrCode : Integer);

procedure DeviceStatus;

procedure Audio_Channel_Info;

procedure Audio_Disk_Info;

procedure Audio_Track_Info(Var StartPoint : LongInt;
                           Var TrackControl : Byte);

procedure Audio_Status_Info;

procedure Q_Channel_Info;

procedure Lock(LockDrive : Boolean);

procedure Reset;

procedure Eject;

procedure CloseTray;

procedure Resume_Play;

procedure Pause_Audio;

procedure Play_Audio(StartSec, EndSec : LongInt);

function StopAudio : Boolean;

function Sector_Size(ReadMode : Byte) : Word;

function Volume_Size : LongInt;

function Media_Changed : Boolean;

function Head_Location(AddrMode : Byte) : LongInt;

procedure Read_Drive_Bytes(Var ReadBytes : DriveByteArray);

function UPC_Code : String;

Implementation

Const
  CarryFlag  = $0001;

Var
{$IfDef MSDOS}
  Regs       : Registers;
{$Else}
  Regs       :TRealModeRecord; { from SimRMI Unit }
{$EndIf}
  DOSOffset,
  DOSSegment,
  DOSSelector:Word;
  AllocateLong:Longint;
  IOBlock    : Pointer;


{$IfDef MSDOS}
{ standard DOS routines for segments and pointers }
function GetIOBlock(var Block : Pointer; Size : Word) : Boolean;
begin
  GetMem(Block, Size);
  DOSSegment := Seg(Block^);
  DOSOffset := Ofs(Block^);
  GetIOBlock := TRUE;
end;

function FreeIOBlock(var Block: Pointer) : Boolean;
begin
  FreeMem(Block, SizeOf(Block^));
  DOSSegment := 0;
  DOSSelector := 0;
  DOSOffset := 0;
  FreeIOBlock := TRUE;
end;

{$ELSE}

{ Get a block in DOS and set pointer values.  DOSSelector is used
  to access the block under protected mode.  DOSSegment accesses the
  block in real mode }

function GetIOBlock(var Block : Pointer; Size : Word) : Boolean;
begin
  AllocateLong:=GlobalDOSAlloc(Size); { enough extra room for string }
  If AllocateLong<>0 Then  {If allocation was successful...}
  Begin
     DOSSegment:=AllocateLong SHR 16;     {Get the real mode segment of the memory}
     DOSSelector:=AllocateLong AND $FFFF; {Get the protected mode selector of the memory}
     DOSOffset := 0;
     Block := Ptr(DOSSelector, 0);
     GetIOBlock := TRUE;
  End
  ELSE
     GetIOBlock := FALSE;
end;

{ Free the DOS block and dereference the pointer }

function FreeIOBlock(var Block: Pointer) : Boolean;
begin
  DOSSelector := GlobalDOSFree(DOSSelector);
  DOSSegment := 0;
  Block := NIL;
  FreeIOBlock := (DOSSelector = 0);
end;

{$EndIf}

procedure Clear_Regs;
begin
  FillChar(Regs, SizeOf(Regs), #0);
end;

procedure CD_Intr;
begin
  Regs.AH := $15;

{$IfDef MSDOS}
  Intr($2F, Regs);  { Call DOS normally }
{$Else}
  If NOT SimRealModeInt($2F,@Regs) Then    {Call DOS through the DPMI}
     Halt(100);
{$EndIf}
end;

procedure MSCDEX_Ver;
begin
  Clear_Regs;
  Regs.AL := $0C;
  Regs.BX := $0000;
  CD_Intr;
  MSCDEX_Version.Minor := 0;
  If Regs.BX = 0 Then
     MSCDEX_Version.Major := 1
  ELSE
     Begin
       MSCDEX_Version.Major := Regs.BH;
       MSCDEX_Version.Minor := Regs.BL;
     End;
end;

procedure Initialize;
begin
  NumberOfCD := 0;
  Clear_Regs;
  Regs.AL := $00;
  Regs.BX := $0000;
  CD_Intr;
  If Regs.BX <> 0 THEN
     Begin
       NumberOfCD := Regs.BX;
       FirstCD := Regs.CX;
       Clear_Regs;
       FillChar(DriverList, SizeOf(DriverList), #0);
       FillChar(UnitList, SizeOf(UnitList), #0);
       Regs.AL := $01;               { Get List of Driver Header Addresses }
       Regs.ES := Seg(DriverList);
       Regs.BX := Ofs(DriverList);
       CD_Intr;
       Clear_Regs;
       Regs.AL := $0D;               { Get List of CD-ROM Units }
       Regs.ES := Seg(UnitList);
       Regs.BX := Ofs(UnitList);
       CD_Intr;
       MSCDEX_Ver;
     End;
end;


function File_Name(var Code : Integer) : String;
Var
  FN : Pointer;
begin
  Clear_Regs;
  If NOT GetIOBlock(FN, 64) THEN
     Exit;
  FillChar(FN, SizeOf(FN), #0);
  Regs.AL := Code + 1;
{
       Copyright Filename     =  1
       Abstract Filename      =  2
       Bibliographic Filename =  3
}
  Regs.CX := Drive;
  Regs.ES := DOSSegment;
  Regs.BX := DOSOffset;
  CD_Intr;
  Code := Regs.AX;
  If (Regs.Flags AND CarryFlag) = 0 THEN
     File_Name := StrPas(FN)
  ELSE
     File_Name := '';
  FreeIOBlock(FN);
end;


function Read_VTOC(var VTOC : VTOCArray;
                   var Index : Integer) : Boolean;
{ On entry -
     Index = Vol Desc Number to read from 0 to ?
  On return
     Case Index of
            1    : Standard Volume Descriptor
            $FF  : Volume Descriptor Terminator
            0    : All others
}
var
  PVTOC : Pointer;

begin
  Clear_Regs;
  If NOT GetIOBlock(PVTOC, SizeOf(VTOCArray)) THEN
     Exit;
  FillChar(PVTOC^, SizeOf(PVTOC^), #0);
  Regs.AL := $05;
  Regs.CX := Drive;
  Regs.DX := Index;
  Regs.ES := DOSSegment;
  Regs.BX := DOSOffset;
  CD_Intr;
  Index := Regs.AX;
  Move(PVTOC^,VTOC, SizeOf(VTOC));
  If (Regs.Flags AND CarryFlag) = 0 THEN
     Read_VTOC := TRUE
  ELSE
     Read_VTOC := FALSE;
  FreeIOBlock(PVTOC);
end;

procedure CD_Check(var Code : Integer);
begin
  Clear_Regs;
  Regs.AL := $0B;
  Regs.BX := $0000;
  Regs.CX := Drive;
  CD_Intr;
  If Regs.BX <> $ADAD THEN
     Code := 2
  ELSE
     Begin
       If Regs.AX <> 0 THEN
          Code := 0
       ELSE
          Code := 1;
     End;
end;


procedure Vol_Desc(Var Code : Integer;
                   var ErrCode : Integer);

  function Get_Vol_Desc : Byte;
    begin
      Clear_Regs;
      Regs.CX := Drive;
      Regs.AL := $0E;
      Regs.BX := $0000;
      CD_Intr;
      Code := Regs.AX;
      If (Regs.Flags AND CarryFlag) <> 0 THEN
         ErrCode := $FF;
      Get_Vol_Desc := Regs.DH;
    end;

begin
  Clear_Regs;
  ErrCode := 0;
  If Code <> 0 THEN
     Begin
       Regs.DH := Code;
       Regs.DL := 0;
       Regs.BX := $0001;
       Regs.AL := $0E;
       Regs.CX := Drive;
       CD_Intr;
       Code := Regs.AX;
       If (Regs.Flags AND CarryFlag) <> 0 THEN
          ErrCode := $FF;
     End;
  If ErrCode = 0 THEN
     Code := Get_Vol_Desc;
end;

procedure Get_Dir_Entry(PathName : String;
                        var Format, ErrCode : Integer);
var
  PN : PChar;
  DB : Pointer;
begin
  FillChar(DirBuf, SizeOf(DirBuf), #0);
  PathName := PathName + #0;
  If NOT GetIOBlock(DB, SizeOf(DirBufRec) + 256) THEN
     Exit;
  PN := Ptr(DOSSelector, SizeOf(DirBufRec) + 1);
  Clear_Regs;
  Regs.AL := $0F;
  Regs.CL := Drive;
  Regs.CH := 1;
  Regs.ES := DOSSegment;
  Regs.BX := SizeOf(DirBufRec) + 1;
  Regs.SI := DOSSegment;
  Regs.DI := DOSOffset;
  CD_Intr;
  ErrCode := Regs.AX;
  If (Regs.Flags AND CarryFlag) = 0 THEN
  Begin
    Move(DB^, DirBuf, SizeOf(DirBuf));
    Move(DirBuf.NameArray[1], DirBuf.FileName[1], 38);
    DirBuf.FileName[0] := #12; { File names are only 8.3 }
    Format := Regs.AX
  End
  ELSE
    Format := $FF;
  FreeIOBlock(DB);
end;

function IO_Control(Command, NumberOfBytes, TransferBytes,
                     ReturnBytes, StartPoint : Byte;
                     var Bytes, TransferBlock): Byte;
var
  I : Word;
begin
  If NOT GetIOBlock(IOBlock, SizeOf(IOControlBlock)) THEN
     Exit;
  With IOControlBlock(IOBlock^) DO
  Begin
    I := Ofs(TransBlock[1]) - Ofs(IOReq_Hdr);
    NumBytes := NumberOfBytes;
    IOReq_Hdr.Len := 26;
    IOReq_Hdr.SubUnit := SubUnit;
    IOReq_Hdr.Status := 0;
    TransAddr := Ptr(DOSSegment, I); { 23 bytes into the IOBlock^ }
    IOReq_Hdr.Command := Command;
    Move(Bytes, TransBlock[1], TransferBytes);
    Clear_Regs;
    Regs.AL := $10;
    Regs.CX := Drive;
    Regs.ES := DOSSegment;
    Regs.BX := DOSOffset;
    CD_Intr;
    Busy := (IOReq_Hdr.Status AND 512) <> 0;
    If ((IOReq_Hdr.Status AND 32768) <> 0) THEN
       I := IOReq_Hdr.Status AND $FF
    ELSE
        I := 0;
    If ReturnBytes <> 0 THEN
       Move(TransBlock[StartPoint], TransferBlock, ReturnBytes);
  End;
  IO_Control := I;
  FreeIOBlock(IOBlock);
end;

procedure Audio_Channel_Info;
var
  Bytes : Byte;
begin
  Bytes := 4;
  IO_Control(IOCtlInput, 9, 1, 9, 1, Bytes, AudioChannel);
End;

procedure DeviceStatus;
var
  Bytes : Array[1..2] OF Byte;
  Status: Word;
begin
  Bytes[1] := 6;

  IO_Control(IOCtlInput, 5, 1, 2, 2, Bytes, Bytes);
  Move(Bytes, Status, 2);

  DoorOpen     := Status AND 1 <> 0;
  DoorLocked   := Status AND 2 = 0;
  Audio        := Status AND 16 <> 0;
  AudioManip   := Status AND 256 <> 0;
  DiscInDrive  := Status AND 2048 = 0;
  RedBook      := Status AND 1024 <> 0;
End;

procedure Audio_Disk_Info;
var Bytes : Byte;
begin
  Bytes := 10;
  IO_Control(IOCtlInput, 7, 1, 6, 2, Bytes, AudioDiskInfo);
  Playing := Busy;
end;

procedure Audio_Track_Info(Var StartPoint : LongInt;
                           Var TrackControl : Byte);
var
  Bytes : Array[1..5] Of BYTE;
begin
  Bytes[1] := 11;
  Bytes[2] := TrackControl;   { Track number }

  IO_Control(IOCtlInput, 7, 2, 5, 3, Bytes, Bytes);
  Move(Bytes[1], StartPoint, 4);
  TrackControl := Bytes[5];

  Playing := Busy;
end;

procedure Q_Channel_Info;
var
  Bytes : Byte;
begin
  Bytes := 12;
  IO_Control(IOCtlInput, 11, 1, 11, 2, Bytes, QChannelInfo);
end;

procedure Audio_Status_Info;
var
  Bytes : Array[1..11] Of Byte;
begin
  Bytes[1] := 15;
  IO_Control(IOCtlInput, 11, 1, 8, 2, Bytes, Bytes);
  Paused := (Word(Bytes[2]) AND 1) <> 0;
  Move(Bytes[4], Last_Start, 4);
  Move(Bytes[8], Last_End, 4);
  Playing := Busy;
end;

procedure Eject;
var
  Bytes : Byte;
begin
  Bytes := 0;
  IO_Control(IOCtlOutput, 1, 1, 0, 0, Bytes, Bytes);
end;

procedure Reset;
var Bytes : Byte;
begin
  Bytes := 2;
  IO_Control(IOCtlOutput, 1, 1, 0, 0, Bytes, Bytes);
  Busy := TRUE;
end;

procedure Lock(LockDrive : Boolean);
var
  Bytes : Array[1..2] Of Byte;
begin
  Bytes[1] := 1;
  If LockDrive THEN
     Bytes[2] := 1
  ELSE
     Bytes[2] := 0;
  IO_Control(IOCtlOutput, 2, 2, 0, 0, Bytes, Bytes);
end;

procedure CloseTray;
var Bytes : Byte;
begin
  Bytes := 5;
  IO_Control(IOCtlOutput, 1, 1, 0, 0, Bytes, Bytes);
end;

Var
  AudioPlay : Pointer;


function Play(StartLoc, NumSec : LongInt) : Boolean;
begin

  If NOT GetIOBlock(AudioPlay, SizeOf(Audio_Play)) THEN
     Exit;
  With Audio_Play(AudioPlay^) DO
  Begin
    APReq.Command := PlayCD;
    APReq.Len := 22;
    APReq.SubUnit := SubUnit;
    Start := StartLoc;
    NumSecs := NumSec;
    AddrMode := 1;
    Regs.AL := $10;
    Regs.CX := Drive;
    Regs.ES := DOSSegment;
    Regs.BX := DOSOffset;
    CD_Intr;
    Play := ((APReq.Status AND 32768) = 0);
  End;
  FreeIOBlock(AudioPlay);
end;

procedure Play_Audio(StartSec, EndSec : LongInt);
Var
  SP,
  EP     : LongInt;
  SArray : Array[1..4] Of Byte;
  EArray : Array[1..4] Of Byte;
begin
  Move(StartSec, SArray[1], 4);
  Move(EndSec, EArray[1], 4);
  SP := SArray[3];           { Must use longint or get negative result }
  SP := (SP*75*60) + (SArray[2]*75) + SArray[1];
  EP := EArray[3];
  EP := (EP*75*60) + (EArray[2]*75) + EArray[1];
  EP := EP-SP;

  Playing := Play(StartSec, EP);
  Audio_Status_Info;
end;

procedure Pause_Audio;
begin

  If Playing THEN
     Begin
       If NOT GetIOBlock(AudioPlay, SizeOf(Audio_Play)) THEN
          Exit;
       With Audio_Play(AudioPlay^) DO
       Begin
         APReq.Command := StopPlay;
         APReq.Len := 13;
         APReq.SubUnit := SubUnit;
       End;
       Regs.AL := $10;
       Regs.CX := Drive;
       Regs.ES := DOSSegment;
       Regs.BX := DOSOffset;
       CD_Intr;
       FreeIOBlock(AudioPlay);
     end;
  Audio_Status_Info;
  Playing := FALSE;
end;

procedure Resume_Play;
begin
  If NOT GetIOBlock(AudioPlay, SizeOf(Audio_Play)) THEN
     Exit;
  With Audio_Play(AudioPlay^) DO
  Begin
    APReq.Command := ResumePlay;
    APReq.Len := 13;
    APReq.SubUnit := SubUnit;
  End;
  Regs.AL := $10;
  Regs.CX := Drive;
  Regs.ES := DOSSegment;
  Regs.BX := DOSOffset;
  CD_Intr;
  Audio_Status_Info;
  FreeIOBlock(AudioPlay); { free DOS block anbd dereference pointer }
end;

function StopAudio : Boolean;
begin

  If NOT GetIOBlock(AudioPlay, SizeOf(Audio_Play)) THEN
     Exit;
  With Audio_Play(AudioPlay^) DO
  Begin
    APReq.Command := StopPlay;
    APReq.Len := 13;
    APReq.SubUnit := SubUnit;
    Regs.AL := $10;
    Regs.CX := Drive;
    Regs.ES := DOSSegment;
    Regs.BX := DOSOffset;
    CD_Intr;
    StopAudio := ((APReq.Status AND 32768) = 0);
  End;
  FreeIOBlock(AudioPlay);
end;

function Sector_Size(ReadMode : Byte) : Word;
Var
  SecSize : Word;
  Bytes   : Array[1..2] Of Byte;
begin
  Bytes[1] := 7;
  Bytes[2] := ReadMode;
  IO_Control(IOCtlInput, 4, 2, 2, 3, Bytes, SecSize);
  Sector_Size := SecSize;
End;

function Volume_Size : LongInt;
Var
  VolSize : LongInt;
  Bytes   : Byte;
begin
  Bytes := 8;
  IO_Control(IOCtlInput, 5, 1, 4, 2, Bytes, VolSize);
  Volume_Size := VolSize;
End;

function Media_Changed : Boolean;

{  1  :  Media not changed
   0  :  Don't Know
  -1  :  Media changed
}
var
  MedChng : Byte;
  Bytes : Byte;
begin
  Bytes := 9;
  IO_Control(IOCtlInput, 2, 1, 4, 2, Bytes, MedChng);
  Inc(MedChng);
  If MedChng IN [1,0] THEN
     Media_Changed := True
  ELSE
     Media_Changed := False;
End;

function Head_Location(AddrMode : Byte) : LongInt;
Var
  HeadLoc : Longint;
  Bytes : Array[1..2] Of Byte;
begin
  Bytes[1] := 1;
  Bytes[2] := AddrMode;
  IO_Control(IOCtlInput, 6, 2, 4, 3, Bytes, HeadLoc);
  Head_Location := HeadLoc;
End;

procedure Read_Drive_Bytes(Var ReadBytes : DriveByteArray);
var
  Bytes : Byte;
Begin
  Bytes := 5;
  IO_Control(IOCtlInput, 130, 1, 128, 3, Bytes, ReadBytes);
End;

function UPC_Code : String;
Var
  I, J, K : Integer;
  TempStr : String;
  Bytes : Array[1..11] Of Byte;
Begin
  TempStr := '';
  FillChar(Bytes, SizeOf(Bytes), #0);
  Bytes[1] := 14;
  If (IO_Control(IOCtlInput, 11, 1, 11, 1, Bytes, Bytes) <> 0) THEN
     TempStr := 'No UPC Code'
  ELSE
  Begin
    For I := 3 to 9 DO
      Begin
        J := (Bytes[I] AND $F0) SHR 4;
        K := Bytes[I] AND $0F;
        TempStr := TempStr + Chr(J + 48);
        TempStr := TempStr + Chr(K + 48);
      End;
    If Length(TempStr) > 13 THEN
        TempStr := Copy(TempSTr, 1, 13);
  End;
  UPC_Code := TempStr;
End;

{************************************************************}
{$IfDef MSDOS}
{$ELSE}
{$F+}
var
  ExitRoutine : Pointer;
procedure MyExit;
begin
  ExitProc := ExitRoutine;
  If DOSSelector <> 0 THEN
  Begin
     GlobalDOSFree(DOSSelector);
     WriteLn('DOS Selector not free');
  End
  ELSE
     WriteLn('DOS Selector free');
end;
{$EndIf}

Begin
  NumberOfCD := 0;
  FirstCD := 0;
  FillChar(MSCDEX_Version, SizeOf(MSCDEX_Version), #0);
  Initialize;
  Drive := FirstCD;
  SubUnit := 0;
{$IfDef MSDOS}
{$ELSE}
  ExitRoutine := ExitProc;
  ExitProc := @MyExit;
{$EndIf}
End.

