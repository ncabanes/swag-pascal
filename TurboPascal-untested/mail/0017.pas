{
  The following source uses the FIDONET unit which will follow in the next
message.. It is a modified version of the origionsl FIDOPAS archive: }

Unit FidoNet;

INTERFACE

Uses Dos,
     Crt,
     StrnTTT5,
     MiscTTT5;

Type
  NetMsg = record
    From,                            { Name of sender              }
    Too           : String[35];      { Name of receiver            }
    Subject       : String[71];      { Msg subject                 }
    DateTime      : String[19];      { Msg date/time, see below    }
    Times ,                          { Times message has been read }
    DestNode,                        { Destination node number     }
    OrgNode,                         { Originating node number     }
    Cost,                            { Cost - 0 if not supported   }
    OrgNet,                          { Originating net number      }
    DestNet       : word;            { Destination net number      }
    DateWritten,                     { Date/time written           }
    SentReceived  : longint;         { Date/time sent/rcvd         }
    ReplyTO,                         { # of next message in replys }
    Attr,                            { Message status bits         }
    NextReply     : word;            { Number of previous message  }
    AreaName   : String[20];         {AreaName (Only if Echomail)  }
  end;

Const
        _private    = $0001;
        _crash      = $0002;
        _received   = $0004;
        _sent       = $0008;
        _fileattach = $0010;
        _transit    = $0020;
        _orphan     = $0040;
        _killsent   = $0080;
        _local      = $0100;   { required on all locally entered messages! }
        _hold       = $0200;
        _direct     = $0400;
        _filereq    = $0800;
        _updatereq  = $8000;

      Status    : Array[1..12] Of String[3] = ('Jan','Feb','Mar','Apr',
                                               'May','Jun','Jul','Aug',
                                               'Sep','Oct','Nov','Dec');
Var Net    : NetMsg;

Function  NetMessage     : String;
Function  GetPath(Var FName : String) : Boolean;
Function  GetNet(GN : String) : String;
Function  GetNode(GN : String) : String;
Function  MsgDateStamp   : String;
Function  LastMsgNum( _NetPath : String ) : Integer;
Function  Hex (n : word) : String;
Procedure ExpandNodeNumbers(Var List : String; VAR TotalNumber : Integer );
Procedure Conv_NetNode(NetNode : String; VAR Net, Node : Word);

IMPLEMENTATION

Function NetMessage : String;  { Returns a NetMessage header string }
Var Hdr : String;
Begin
  Hdr := '';

  Hdr := PadLeft(Net.From,36,#0);
  Hdr := Hdr + PadLeft(Net.Too,36,#0)
             + PadLeft(Net.Subject,72,#0)
             + PadRight(Net.DateTime,19,' ')+#0
             + Chr(Lo(Net.Times))+Chr(Hi(Net.Times))
             + Chr(Lo(Net.DestNode))+Chr(Hi(Net.DestNode))
             + Chr(Lo(Net.OrgNode))+Chr(Hi(Net.OrgNode))
             + Chr(Lo(Net.Cost))+Chr(Hi(Net.Cost))
             + Chr(Lo(Net.OrgNet))+Chr(Hi(Net.OrgNet))
             + Chr(Lo(Net.DestNet))+Chr(Hi(Net.DestNet))
             + #0#0#0#0#0#0#0#0
             + Chr(Lo(Net.ReplyTo))+Chr(Hi(Net.ReplyTo))
             + Chr(Lo(Net.Attr))+Chr(Hi(Net.Attr))
             + Chr(Lo(Net.NextReply))+Chr(Hi(Net.NextReply))
             + Upper(Net.AreaName);
  NetMessage := Hdr;
End;

Function GetPath(Var FName : String) : Boolean;
{ Returns the FULL Path and filename for a file if it is found in the path. }
Var Str1,Str2 : String;
    NR        : Byte;
    HomeDir   : String;

Begin
  HomeDir := FExpand(FName);
  If Exist(HomeDir) Then Begin
                  FName := HomeDir;
                  GetPath := True;
                  Exit;
                End;

  Str1 := GetEnv('PATH');
  For NR := 1 to Length(Str1) DO IF Str1[NR] = ';' Then Str1[NR] := ' ';
  For NR := 1 to WordCnt(Str1) DO
   Begin
    Str2 := ExtractWords(NR,1,Str1)+'\'+FName;
    IF Exist(Str2) Then Begin
      FName := Str2;
      GetPath := True;
      Exit;
    End;
   End;
   GetPath := False;
End;

Function MsgDateStamp : String; { Creates Fido standard- 01 Jan 89 21:05:18 }
Var h,m,s,hs          : Word;   { header time/date stamp   }
    y,mo,d,dow        : Word;
    Tmp,
    o1,o2,o3          : String;

Begin
  o1 := '';
  o2 := '';
  o3 := '';
  tmp := '';
  GetDate(y,mo,d,dow);
  GetTime(h,m,s,hs);
  o1 := PadRight(Int_To_Str(d),2,'0');
  o2 := Status[mo];
  o3 := Last(2,Int_To_Str(y));
  Tmp := Concat( o1,' ',o2,' ',o3,'  ');
  o1 := PadRight(Int_To_Str(h),2,'0');
  o2 := PadRight(Int_To_Str(m),2,'0');
  o3 := PadRight(Int_To_Str(s),2,'0');
  Tmp := Tmp + Concat(o1,':',o2,':',o3);
  MsgDateStamp := Tmp;
End;

Function MsgToNum(Fnm : String ):Integer; { Used Internally by LastMsgNum }
Var p : Byte;
Begin
  p        := Pos('.',Fnm);
  Fnm      := First(p-1,Fnm);
  MsgToNum := Str_To_Int(Fnm);
End;

Function LastMsgNum( _NetPath : String ) : Integer;
{ Returns the highest numbered xxx.MSG in NetPath directory }
Var
    _Path   : String;
    Temp1,
    Temp2   : String;
    Len     : Byte;
    DxirInf  : SearchRec;
    Num,
    Num1    : Integer;

Begin
  Num   := 0;
  Num1  := 0;
  Temp1 := '';
  Temp2 := '';
  _Path := '';
  _Path := _NetPath + '\*.MSG';

  FindFirst( _Path, Archive, DxirInf );
  While DosError = 0 DO
  Begin
    Temp1 := DxirInf.Name;
    Num1 := MsgToNum(Temp1);
    IF Num1 > Num Then Num := Num1;
    FindNext(DxirInf);
  End;

  IF Num = 0 Then Num := 1;
  LastMsgNum := Num;
End;

Function Hex(N : Word) : String;
{ Converts an integer or word to it's Hex equivelent }
Var
  L : string[16];
  BHi,
  BLo : byte;

Begin
  L := '0123456789abcdef';
  BHi := Hi(n);
  BLo := Lo(n);
  Hex := copy(L,succ(BHi shr 4),1) +
         copy(L,succ(BHi and 15),1) +
         copy(L,succ(BLo shr 4),1) +
         copy(L,succ(BLo and 15),1);
End;

Function GetNet( GN : String ) : String;
{ Returns the NET portion of a Net/Node string }
Var P : Byte;
Begin
  P := Pos('/',GN);
  GetNet := First(P-1,GN);
End;

Function GetNode( GN : String ) : String;
{ Returns the NODE portion of a Net/Node string }
Var P : Byte;
Begin
  P := Pos('/',GN);
  GetNode := Last(Length(GN)-P,GN);
End;

Procedure ExpandNodeNumbers(Var List : String; VAR TotalNumber : Integer );
        { Expands a list of short form node numbers to thier proper       }
        { Net/Node representations. Example:                              }
        { The string: 170/100 101 102 5 114/12 15 17 166/225 226          }
        { Would return: 170/100 170/101 170/102 170/5 114/12 114/15 etc.. }
Var Net,NetNode  : String[10];
    HoldStr,
    WS1          : String;
    N1           : Integer;
Begin
  Net := '';
  NetNode := '';
  HoldStr := '';
  WS1 := '';
  N1 := 0;
  TotalNumber := 0;
  TotalNumber := WordCnt(List);

  For N1 := 1 to TotalNumber DO Begin
    WS1 := ExtractWords(N1,1,List);
    IF Pos('/',WS1) <> 0 Then Begin Net := GetNet(WS1)+'/'; NetNode := WS1;
    End ELSE NetNode := Net+WS1;
    HoldStr := HoldStr + ' ' + Strip('A',' ',NetNode);
  End;
End;

Procedure Conv_NetNode(NetNode : String; VAR Net, Node : Word);
         { Returns NET and NODE as words from a Net/Node string }
Var WStr : String[6];
Begin
  Wstr := GetNet(NetNode);
  Net  := Str_To_Int(Wstr);
  Wstr := GetNode(NetNode);
  Node := Str_To_Int(Wstr);
End;

Begin
  { Initialize the data structures }
  FillChar(Net,SizeOf(Net),#0);
End.

{ --------------------- DEMO PROGRAM -------------------------- }
Program Test;

Uses
  Crt,
  FidoNet,
  StrnTTT5;      {TechnoJocks Turbo Toolkit StrnTTT5 unit}

var
  NetPath   : String;

Procedure Create_NetMessage(FileName : String );
Var LastOne,i : Integer;
    Msg_Name  : String;
    Attrib    : Word;
    MsgFil,
    Inputfile : Text;
    Header,
    S         : String;

Begin
  Header   := '';
  S        := '';
  LastOne  := 0;
  Msg_Name := '';
  Attrib   := _Local + _Private;
  With Net DO Begin
    From      := 'Lucas Nealan';
    Too       := 'Anyone';
    Subject   := 'Testing the FidoNet Unit...';
    DateTime  := MsgDateStamp;
    Times     := 0;
    DestNode  := 0;
    OrgNode   := 100;
    Cost      := 0;
    OrgNet    := 31;
    DestNet   := 22;
    ReplyTo   := 0;
    Attr      := Attrib;
    NextReply := 0;
  End;
  Header := NetMessage;
  LastOne := LastMsgNum(NetPath);
  Inc(LastOne);
  Msg_Name := NetPath+'\'+Int_To_Str(LastOne)+'.MSG';
  Assign(MsgFil, Msg_Name );
  Rewrite(MsgFil);
  WriteLn(MsgFil,Header);
  Assign(InputFile, FileName);
  Reset(InputFile);
  WriteLn(MsgFil,#1'INTL 20:22/0 20:31/100');
  WriteLn(MsgFil,#1'PID Lucas'' *.MSG Util');
  WriteLn(MsgFil,^A'FLAGS DIR');
  While not Eof(InputFile) do begin
    ReadLn(InputFile,S);
    WriteLn(MsgFil,S);
  end;
  Flush(MsgFil);
  Close(MsgFil);
  Close(InputFile);
end;

begin
  ClrScr;
  WriteLn;
  WriteLn('Posting file: '+ParamStr(1));
  WriteLn;
  NetPath := 'D:\FD\NETMAIL';
  Create_NetMessage(ParamStr(1));
end.

  The INTL Kludge line is used to send messages through non standard network
zones (20 in this example).  For fido standard zone 1 you may specify just the
origin net and node as well as destination net and zone and it will default to
zone 1.  Also with the direct flag you may either use the _Direct in the status
or add your own FLAGS DIR kludge.

   Good luck!

                                        Lucas Nealan
                                      Real World Programming

