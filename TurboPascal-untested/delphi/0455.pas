Unit MkFidoAddr32; {Delphi32 Only!}

Interface

///////////////////////////////////////////////////////////////////////////////
// MKFidoAddr32 Coded in Part by G.E. Ozz Nixon Jr. of www.warpgroup.com     //
// ========================================================================= //
// Original Source for DOS by Mythical Kindom's Mark May (mmay@dnaco.net)    //
// Re-written and distributed with permission!                               //
// See Original Copyright Notice before using any of this code!              //
///////////////////////////////////////////////////////////////////////////////

Type AddrType = Record                 {Used for Fido style addresses}
  Zone: Word;
  Net: Word;
  Node: Word;
  Point: Word;
  End;

Type SecType = Record
  Level: Word;                         {Security level}
  Flags: LongInt;                      {32 bitmapped flags}
  End;

Const
  BbsVersion : String='Your BBS Name Here - Version 0.01 Alpha';
  Copyright  : String='Your Copyright 1992-1997 by Mark May and Ozz Nixon';
  Contact    : String='Contact Name Here';

Const
  uoNotAvail = 0;
  uoBrowse =  1;
  uoXfer   =  2;
  uoMsg    =  3;
  uoDoor   =  4;
  uoChat   =  5;
  uoQuest  =  6;
  uoReady  =  7;
  uoMail   =  8;
  uoWait   =  9;
  uoLogIn  = 10;

Function  AddrStr(Addr: AddrType): String;
Function  PointlessAddrStr(Var Addr: AddrType): String;
Function  ParseAddr(AStr: String; CurrAddr: AddrType; Var DestAddr: AddrType): Boolean;
Function  ValidAddr(Addr: AddrType): Boolean;
Function  Access(USec: SecType; RSec: SecType): Boolean;
Function  EstimateXferTime(FS: LongInt; BaudRate: Word; Effic: Word): LongInt;
  {Result in seconds}
Function  NameCrcCode(Str: String): LongInt; {Get CRC code for name}
Function AddrEqual(Addr1: AddrType; Addr2: AddrType):Boolean;

Const
  UseEms: Boolean = True;
  LocalMode: Boolean = False;
  LogToPrinter: Boolean = False;
  ReLoad: Boolean = False;
  NodeNumber: Byte = 1;
  OverRidePort: Byte = 0;
  OverRideBaud: Word = 0;
  UserBaud: Word = 0;
  ExitErrorLevel: Byte = 0;
  TimeToEvent: LongInt = 0;
  ShellToMailer: Boolean = False;

Implementation

Uses Crc32, MKString32;


Function AddrStr(Addr: AddrType): String;
Begin
  If Addr.Point = 0 Then AddrStr:=PointLessAddrStr(Addr)
  Else AddrStr:=PointLessAddrStr(Addr)+Long2Str(Addr.Point);
End;

Function PointlessAddrStr(Var Addr: AddrType): String;
  Begin
  PointlessAddrStr := Long2Str(Addr.Zone) + ':' + Long2Str(Addr.Net) + '/' +
      Long2Str(Addr.Node);
  End;

Function Access(USec: SecType; RSec: SecType): Boolean;
  Begin
  If (USec.Level >=  RSec.Level) Then
    Access :=  ((RSec.Flags and Not(USec.Flags)) = 0)
  Else
    Access := False;
  End;

Function EstimateXferTime(FS: LongInt; BaudRate: Word; Effic: Word): LongInt;
  Begin
  If BaudRate > 0 Then
    EstimateXferTime := ((FS * 100) Div Effic) Div (BaudRate Div 10)
  Else
    EstimateXferTime := ((FS * 100) Div Effic) Div (960);
  End;

Function NameCrcCode(Str: String): LongInt;
  Var
    NCode: LongInt;
    i: WOrd;

  Begin
  NCode := UpdC32(Length(Str),$ffffffff);
  i := 1;
  While i < Length(Str) Do
    Begin
    NCode := Updc32(Ord(UpCase(Str[i])), NCode);
    Inc(i);
    End;
  NameCrcCode := NCode;
  End;


Function ParseAddr(AStr: String; CurrAddr: AddrType; Var DestAddr: AddrType): Boolean;
  Var
    SPos: Word;
    EPos: Word;
    TempStr: String;
    Code: Word;
    BadAddr: Boolean;

  Begin
  BadAddr := False;
  AStr := StripBoth(Upper(AStr), ' ');
  {thanks for the fix domain problem to Ryan Murray @ 1:153/942}
  Code := Pos('@', AStr);
  If Code > 0 then
    Delete(Astr, Code, Length(Astr) + 1 - Code);
  SPos := Pos(':',AStr) + 1;
  If SPos > 1 Then
    Begin
    TempStr := StripBoth(Copy(AStr,1,Spos - 2), ' ');
    DestAddr.Zone:=Str2Long(TempStr);
    If Code <> 0 Then
      BadAddr := True;
    AStr := Copy(AStr,Spos,Length(AStr));
    End
  Else
    DestAddr.Zone := CurrAddr.Zone;
  SPos := Pos('/',AStr) + 1;
  If SPos > 1 Then
    Begin
    TempStr := StripBoth(Copy(AStr,1,Spos - 2), ' ');
    DestAddr.Net:=Str2Long(TempStr);
    If Code <> 0 Then
      BadAddr := True;
    AStr := Copy(AStr,Spos,Length(AStr));
    End
  Else
    DestAddr.Net := CurrAddr.Net;
  EPos := Pos('.', AStr) + 1;
  If EPos > 1 Then
    Begin
    TempStr := StripBoth(Copy(AStr,EPos,Length(AStr)), ' ');
    DestAddr.Point:=Str2Long(TempStr);
    If Code <> 0 Then
      DestAddr.Point := 0;
    AStr := Copy(AStr,1,EPos -2);
    End
  Else
    DestAddr.Point := 0;
  TempStr := StripBoth(AStr,' ');
  If Length(TempStr) > 0 Then
    Begin
    DestAddr.Node:=Str2Long(TempStr);
    If Code <> 0 Then
      BadAddr := True;
    End
  Else
    DestAddr.Node := CurrAddr.Node;
  ParseAddr := Not BadAddr;
  End;


Function AddrEqual(Addr1: AddrType; Addr2: AddrType):Boolean;
Begin
  AddrEqual := ((Addr1.Zone = Addr2.Zone) and (Addr1.Net = Addr2.Net)
    and (Addr1.Node = Addr2.Node) and (Addr1.Point = Addr2.Point));
End;

Function  ValidAddr(Addr: AddrType): Boolean;
Begin
   ValidAddr := ((Addr.Zone<>0) And (Addr.Net<>0));
    { We have to skip administrative '/0' addresses}
End;

End.
