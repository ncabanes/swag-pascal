(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0005.PAS
  Description: FIDONET *.MSG format
  Author: KELLY DROWN
  Date: 08-27-93  21:20
*)

{
> I am trying to write a program.  Does anyone have the structures for the
> FIDONET *.MSG format.  ANy help would be greatly appreciated.
}

Unit FidoNet; { Beta Copy - Rev 6/5/89 - Tested 6/20/89  Ver. 0.31 }

           { FIDONET UNIT by Kelly Drown, Copyright (C)1988,89-LCP  }
           {                                   All rights reserved  }
           { If you use this unit in your own programming, I ask    }
           { only that you give me credit in your documentation.    }
           { I ask this instead of money. All of the following code }
           { is covered under the copyright of Laser Computing Co.  }
           { and may be used in your own programming provided the   }
           { terms above have been satisfactorily met.              }

INTERFACE

Uses
  Dos,
  Crt,
  StrnTTT5,  { TechnoJocks Turbo Toolkit v5.0 }
  MiscTTT5;


Type
  NetMsg = Record        { NetMessage Record Structure }
    From,
    Too        : String[35];
    Subject    : String[71];
    Date       : String[19];
    TimesRead,
    DestNode,
    OrigNode,
    Cost,
    OrigNet,
    DestNet,
    ReplyTo,
    Attr,
    NextReply  : Word;
    AreaName   : String[20];
  End;

  PktHeader = Record        { Packet Header of Packet }
    OrigNode,
    DestNode,
    Year,
    Month,
    Day,
    Hour,
    Minute,
    Second,
    Baud,
    OrigNet,
    DestNet  : Word;
  End;

  PktMessage = Record        { Packet Header of each individual message }
    OrigNode,
    DestNode,
    OrigNet,
    DestNet,
    Attr,
    Cost     : Word;
    Date     : String[19];
    Too      : String[35];
    From     : String[35];
    Subject  : String[71];
    AreaName : String[20];
  End;

  ArchiveName = Record        { Internal Record Structure used for     }
    MyNet,                    { determining the name of of an echomail }
    MyNode,                   { archive. i.e. 00FA1FD3.MO1             }
    HisNet,
    HisNode : Word;
  End;

Const                        { Attribute Flags }
  _Private  = $0001;
  _Crash    = $0002;
  _Recvd    = $0004;
  _Sent     = $0008;
  _File     = $0010;
  _Forward  = $0020;     { Also know as In-Transit }
  _Orphan   = $0040;
  _KillSent = $0080;
  _Local    = $0100;
  _Hold     = $0200;
  _Freq     = $0800;

  Status    : Array[1..12] Of String[3] =
                ('Jan','Feb','Mar','Apr','May','Jun',
                 'Jul','Aug','Sep','Oct','Nov','Dec');

Var
  Net  : NetMsg;
  PH   : PktHeader;
  PM   : PktMessage;
  ArcN : ArchiveName;

Function  PacketName : String;
Function  PacketMessage : String;
Function  PacketHeader : String;
Function  NetMessage : String;
Function  GetPath(Var FName : String) : Boolean;
Function  GetNet(GN : String) : String;
Function  GetNode(GN : String) : String;
Function  MsgDateStamp : String;
Function  LastMsgNum(_NetPath : String) : Integer;
Function  Hex(n : word) : String;
Function  ArcName : String;
Procedure ExpandNodeNumbers(Var List : String; VAR TotalNumber : Integer);
Procedure Conv_NetNode(NetNode : String; VAR Net, Node : Word);

IMPLEMENTATION

{-------------------------------------------------------------------------}
Function PacketName : String;
{ Creates and returns a unique Packet name }
Var
  h, m, s,
  hs, yr,
  mo, da,
  dow     : Word;
  WrkStr  : String;
Begin
  WrkStr := '';
  GetTime(h, m, s, hs);
  GetDate(yr, mo, da, dow);

  WrkStr := PadRight(Int_To_Str(da), 2, '0')
           + PadRight(Int_To_Str(h), 2, '0')
           + PadRight(Int_To_Str(m), 2, '0')
           + PadRight(Int_To_Str(s), 2, '0');

  PacketName := WrkStr + '.PKT';
End;
{-------------------------------------------------------------------------}
Function PacketMessage : String;
{ Returns a Packet message header }
Var
  Hdr : String;
Begin
  Hdr := '';

  Hdr := #2#0 { Type #2 packets... Type #1 is obsolete }
         + Chr(Lo(PM.OrigNode)) + Chr(Hi(PM.OrigNode))
         + Chr(Lo(PM.DestNode)) + Chr(Hi(PM.DestNode))
         + Chr(Lo(PM.OrigNet)) + Chr(Hi(PM.OrigNet))
         + Chr(Lo(PM.DestNet)) + Chr(Hi(PM.DestNet))
         + Chr(Lo(PM.Attr)) + Chr(Hi(PM.Attr))
         + Chr(Lo(PM.Cost)) + Chr(Hi(PM.Cost))
         + PM.Date + #0 + PM.Too + #0 + PM.From + #0 + PM.Subject + #0
         + Upper(PM.AreaName);

  PacketMessage := Hdr;
End;
{-------------------------------------------------------------------------}
Function PacketHeader : String;
{ Returns a Packet Header String }
Var
  Hdr : String;
Begin
  Hdr := '';

  Hdr := Chr(Lo(PH.OrigNode)) + Chr(Hi(PH.OrigNode))
         + Chr(Lo(PH.DestNode)) + Chr(Hi(PH.DestNode))
         + Chr(Lo(PH.Year)) + Chr(Hi(PH.Year))
         + Chr(Lo(PH.Month)) + Chr(Hi(PH.Month))
         + Chr(Lo(PH.Day)) + Chr(Hi(PH.Day))
         + Chr(Lo(PH.Hour)) + Chr(Hi(PH.Hour))
         + Chr(Lo(PH.Minute)) + Chr(Hi(PH.Minute))
         + Chr(Lo(PH.Second)) + Chr(Hi(PH.Second))
         + Chr(Lo(PH.Baud)) + Chr(Hi(PH.Baud))
         + #2#0 + Chr(Lo(PH.OrigNet)) + Chr(Hi(PH.OrigNet))
         + Chr(Lo(PH.DestNet)) + Chr(Hi(PH.DestNet))
         + #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0   { Null Field Fill Space }
         + #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;

  PacketHeader := Hdr;
End;
{-------------------------------------------------------------------------}
Function NetMessage : String;
{ Returns a NetMessage header string }
Var
  Hdr : String;
Begin
  Hdr := '';

  Hdr := PadLeft(Net.From, 36, #0);
  Hdr := Hdr + PadLeft(Net.Too, 36, #0)
             + PadLeft(Net.Subject, 72, #0)
             + PadRight(Net.Date, 19, ' ') + #0
             + Chr(Lo(Net.TimesRead)) + Chr(Hi(Net.TimesRead))
             + Chr(Lo(Net.DestNode)) + Chr(Hi(Net.DestNode))
             + Chr(Lo(Net.OrigNode)) + Chr(Hi(Net.OrigNode))
             + Chr(Lo(Net.Cost)) + Chr(Hi(Net.Cost))
             + Chr(Lo(Net.OrigNet)) + Chr(Hi(Net.OrigNet))
             + Chr(Lo(Net.DestNet)) + Chr(Hi(Net.DestNet))
             + #0#0#0#0#0#0#0#0
             + Chr(Lo(Net.ReplyTo)) + Chr(Hi(Net.ReplyTo))
             + Chr(Lo(Net.Attr)) + Chr(Hi(Net.Attr))
             + Chr(Lo(Net.NextReply)) + Chr(Hi(Net.NextReply))
             + Upper(Net.AreaName);

  NetMessage := Hdr;
End;
{-------------------------------------------------------------------------}
Function GetPath(Var FName : String) : Boolean;
{ Returns the FULL Path and filename for a filename if the file  }
{ is found in the path. }
Var
  Str1,
  Str2    : String;
  NR      : Byte;
  HomeDir : String;
Begin
  HomeDir := FExpand(FName);
  If Exist(HomeDir) Then
  Begin
    FName   := HomeDir;
    GetPath := True;
    Exit;
  End;

  Str1 := GetEnv('PATH');
  For NR := 1 to Length(Str1) DO
    IF Str1[NR] = ';' Then
      Str1[NR] := ' ';

  For NR := 1 to WordCnt(Str1) DO
  Begin
    Str2 := ExtractWords(NR, 1, Str1) + '\' + FName;
    IF Exist(Str2) Then
    Begin
      FName   := Str2;
      GetPath := True;
      Exit;
    End;
  End;
  GetPath := False;
End;

{-------------------------------------------------------------------------}
Function MsgDateStamp : String;  { Creates Fido standard- 01 Jan 89 21:05:18 }
Var                              { Standard message header time/date stamp   }
  h, m, s,
  hs, y, mo,
  d, dow    : Word;
  Tmp, o1,
  o2, o3    : String;

Begin
  o1  := '';
  o2  := '';
  o3  := '';
  tmp := '';
  GetDate(y, mo, d, dow);
  GetTime(h, m, s, hs);
  o1  := PadRight(Int_To_Str(d), 2, '0');
  o2  := Status[mo];
  o3  := Last(2,Int_To_Str(y));
  Tmp := Concat(o1, ' ', o2, ' ', o3,'  ');
  o1  := PadRight(Int_To_Str(h), 2, '0');
  o2  := PadRight(Int_To_Str(m), 2, '0');
  o3  := PadRight(Int_To_Str(s), 2, '0');
  Tmp := Tmp + Concat(o1, ':', o2, ':', o3);
  MsgDateStamp := Tmp;
End;

{-------------------------------------------------------------------------}
Function MsgToNum(Fnm : String) : Integer; { Used Internally by LastMsgNum }
Var
  p : Byte;
Begin
  p        := Pos('.', Fnm);
  Fnm      := First(p - 1, Fnm);
  MsgToNum := Str_To_Int(Fnm);
End;
{-------------------------------------------------------------------------}

Function LastMsgNum(_NetPath : String) : Integer;
{ Returns the highest numbered xxx.MSG in NetPath directory }
Var
  _Path,
  Temp1,
  Temp2   : String;
  Len     : Byte;
  DxirInf : SearchRec;
  Num,
  Num1    : Integer;

Begin
  Num   := 0;
  Num1  := 0;
  Temp1 := '';
  Temp2 := '';
  _Path := '';
  _Path := _NetPath + '\*.MSG';

  FindFirst(_Path, Archive, DxirInf);
  While DosError = 0 DO
  Begin
    Temp1 := DxirInf.Name;
    Num1 := MsgToNum(Temp1);
    IF Num1 > Num Then
      Num := Num1;
    FindNext(DxirInf);
  End;

  IF Num = 0 Then
    Num := 1;
  LastMsgNum := Num;
End;

{-------------------------------------------------------------------------}
Function Hex(N : Word) : String;
{ Converts an integer or word to it's Hex equivelent }
Var
  L   : string[16];
  BHi,
  BLo : byte;

Begin
  L   := '0123456789ABCDEF';
  BHi := Hi(n);
  BLo := Lo(n);
  Hex := copy(L,succ(BHi shr 4),  1) +
         copy(L,succ(BHi and 15), 1) +
         copy(L,succ(BLo shr 4),  1) +
         copy(L,succ(BLo and 15), 1);
End;

{-------------------------------------------------------------------------}
Function ArcName : String;
{ Returns the proper name of an echomail archive }
Var
  C1, C2 : LongInt;
Begin
  C1 := 0;
  C2 := 0;
  C1 := ArcN.MyNet - ArcN.HisNet;
  C2 := ArcN.MyNode - ArcN.HisNode;
  If C1 < 0 Then
    C1 := 65535 + C1;
  If C2 < 0 Then
    C2 := 65535 + C2;
  ArcName := Hex(C1) + Hex(C2);
End;

{-------------------------------------------------------------------------}
Function GetNet(GN : String) : String;
{ Returns the NET portion of a Net/Node string }
Var
  P : Byte;
Begin
  P := Pos('/', GN);
  GetNet := First(P - 1, GN);
End;

{-------------------------------------------------------------------------}
Function GetNode(GN : String) : String;
{ Returns the NODE portion of a Net/Node string }
Var
  P : Byte;
Begin
  P := Pos('/', GN);
  GetNode := Last(Length(GN) - P, GN);
End;
{-------------------------------------------------------------------------}
Procedure ExpandNodeNumbers(Var List : String; VAR TotalNumber : Integer );
{ Expands a list of short form node numbers to thier proper       }
{ Net/Node representations. Example:                              }
{ The string: 170/100 101 102 5 114/12 15 17 166/225 226          }
{ Would return: 170/100 170/101 170/102 170/5 114/12 114/15 etc.. }
Var
  Net,
  NetNode  : String[10];
  HoldStr,
  WS1      : String;
  N1       : Integer;

Begin
  Net := '';
  NetNode := '';
  HoldStr := '';
  WS1 := '';
  N1  := 0;
  TotalNumber := 0;
  TotalNumber := WordCnt(List);

  For N1 := 1 to TotalNumber DO
  Begin
    WS1 := ExtractWords(N1, 1, List);
    IF Pos('/', WS1) <> 0 Then
    Begin
      Net := GetNet(WS1) + '/';
      NetNode := WS1;
    End
    ELSE
      NetNode := Net + WS1;
    HoldStr := HoldStr + ' ' + Strip('A', ' ', NetNode);
  End;
End;

{-------------------------------------------------------------------------}
Procedure Conv_NetNode(NetNode : String; VAR Net, Node : Word);
{ Returns NET and NODE as words from a Net/Node string }
Var
  WStr : String[6];
Begin
  Wstr := GetNet(NetNode);
  Net  := Str_To_Int(Wstr);
  Wstr := GetNode(NetNode);
  Node := Str_To_Int(Wstr);
End;
{-------------------------------------------------------------------------}

Begin
  { Initialize the data structures }

  FillChar(Net, SizeOf(Net), #0);
  FillChar(PM, SizeOf(PM), #0);
  FillChar(PH, SizeOf(PH), #0);
  FillChar(ArcN, SizeOf(ArcN), #0);

End. {Unit}

