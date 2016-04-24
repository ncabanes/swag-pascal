(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0050.PAS
  Description: Fossil Engine
  Author: KRISTO KIVISAAR
  Date: 08-24-94  13:40
*)


UNIT FossilP;  { see demo at end of code }

INTERFACE

Uses Dos, Crt; { Phone, PXEngine, PxMsg; Config;}

Type
  FossilInfo = Record
    MaxFunc    :Byte;   {Max func number supported}
    Revision   :Byte;  {Fossil revision supported}
    MajVer     :Byte;    {Major version}
    MinVer     :Byte;    {Minor version}
    Ident      :PChar;    {Null terminated ID string}
    IBufr      :Word;     {size of input buffer}
    IFree      :Word;     {number of bytes left in buffer}
    OBufr      :Word;     {size of output buffer}
    OFree      :Word;     {number of bytes left in buffer}
    SWidth     :Byte;    {width of screen}
    SHeight    :Byte;   {height of screen}
    Baud       :Byte;      {ACTUAL baud rate, computer to modem}
  End;

  FossilInfo2 = Record
    StrucSize   :Word; {Structure size in bytes}
    MajVer      :Byte;    {Major version}
    MinVer      :Byte;    {Minor version}
    Ident       :PChar;    {Null terminated ID string}
    IBufr       :Word;     {size of input buffer}
    IFree       :Word;     {number of bytes left in buffer}
    OBufr       :Word;     {size of output buffer}
    OFree       :Word;     {number of bytes left in buffer}
    SWidth      :Byte;    {width of screen}
    SHeight     :Byte;   {height of screen}
    Baud        :Byte;      {ACTUAL baud rate, computer to modem}
  End;

Procedure ModemSetting(Baud, DataBit: Integer; Party: Char; StopBit: Integer);
Function  FReadKey:Word;
Procedure FossilInt(var R:Registers);
Procedure GetFossilInfo(var FosRec:FossilInfo2; Port:Word);
Procedure InitFossil(var FosInf:FossilInfo; Port:Word);
Procedure DeInitFossil(Port:Word);
Function  FIsKeyPressed:Word;
Function  FossilReadChar(Port:Word):Byte;
Function  FossilIsCharReady(Port:Word):Word;
Function  FossilSendChar(Port:Word; Char:byte):Word;
Procedure Init;
Procedure FossilSendStr(S:String; Port:Word);
Procedure DialNo(Port:Word);
Procedure Run;
Procedure Done;

Procedure WriteAnsi;
Procedure HangUp;
Procedure DialRec(Port:Word);

IMPLEMENTATION

{ Fossil Functions }
Procedure FossilInt(var R:Registers);
begin
  Intr($14,R);
End;

Procedure ModemSetting(Baud, DataBit: Integer; Party: Char; StopBit: Integer);
Var Out : Integer;
    R   : Registers;
    Port: Word;
Begin
Out := 0;
Case Baud Of
    0 :Exit;
  100 :Out := Out + 000 + 00 + 00;
  150 :Out := Out + 000 + 00 + 32;
  300 :Out := Out + 000 + 64 + 00;
 1200 :Out := Out + 128 + 00 + 00;
 2400 :Out := Out + 128 + 00 + 32;
 4800 :Out := Out + 128 + 64 + 00;
 9600 :Out := Out + 128 + 64 + 32;
End;
Case DataBit Of
   5 :Out := Out + 0 + 0;
   6 :Out := Out + 0 + 1;
   7 :Out := Out + 2 + 0;
   8 :Out := Out + 2 + 1;
End;
Case Party Of
 'N'      :Out := Out + 00 + 0;
 'O', 'o' :Out := Out + 00 + 8;
 'n'      :Out := Out + 16 + 0;
 'E', 'e' :Out := Out + 16 + 8;
End;
Case StopBit Of
 1 :Out := Out + 0;
 2 :Out := Out + 4;
End;
R.AH:=0;
R.AL:=Out;
R.DX:=Port;
FossilInt(R);
End;

Procedure GetFossilInfo(var FosRec:FossilInfo2; Port:Word);
Var
  R: Registers;
Begin
  R.AH:=$1B;             {Function number 1bh}
  R.CX:=SizeOf(FosRec);  {size of user info}
  R.DX:=Port;            {port number}
  R.ES:=Seg(FosRec);     {segment of info buf}
  R.DI:=Ofs(FosRec);     {offset of info buf}
  FossilInt(R);
End;

Procedure InitFossil(var FosInf:FossilInfo; Port:Word);
Var
  R :Registers;
  Z :FossilInfo2;
Begin
  R.AH:=$04;
  R.DX:=Port;
  FossilInt(R);
  if R.AX=$1954 then begin {AX should countain 1954h if fossil is loaded}
    FosInf.MaxFunc :=R.BL;
    FosInf.Revision:=R.BH;
    GetFossilInfo(Z,Port);
    with FosInf do begin
      MajVer:= Z.MajVer;
      MinVer:= Z.MinVer;
      Ident := Z.Ident;
      IBufr := Z.IBufr;
      IFree := Z.IFree;
      OBufr := Z.OBufr;
      OFree := Z.OFree;
      SWidth:= Z.SWidth;
      SHeight:=Z.SHeight;
      Baud  := Z.Baud;
    End;
  End Else FosInf.MaxFunc:=0; {MaxFunc contains 0 if fossil is not found}
End;

Procedure DeInitFossil(Port:Word);
var
  R: Registers;
Begin
  R.AH:=$05;
  R.DX:=Port;
  FossilInt(R);
End;

Function FIsKeyPressed:Word;
var
  R:Registers;
Begin
  R.AH:=$0D;
  FossilInt(R);
  FIsKeyPressed := R.AX;
End;

Function FReadKey:Word;
var
  R:Registers;
Begin
  R.AH:=$0E;
  FossilInt(R);
  FReadKey := R.AX;
End;

Function FossilReadChar(Port:Word):Byte;
var
  R :Registers;
Begin
  R.AH:=$02;
  R.DX:=Port;
  FossilInt(R);
  FossilReadChar := R.AL
End;

Function FossilIsCharReady(Port:Word):Word;
var
  R :Registers;
Begin
  R.AH:=$0C;
  R.DX:=Port;
  FossilInt(R);
  FossilIsCharReady := R.AX;
End;

Function FossilSendChar(Port:Word; Char:byte):Word;
var
  R :Registers;
Begin
  R.AH:=$01;
  R.DX:=Port;
  R.AL:=Char;
  FossilInt(R);
  FossilSendChar := R.AX;
End;

Const
  CurPort :Word = 1;        {current COM port of modem}

  ExitKey=$2d00; {ALT-X}
  DialKey=$2000; {ALT-D}

  DialPref:String ='ATDT';
  DialSuf :String =#13;

Var
  Z :FossilInfo;

Procedure Init;
Begin
  Write('Modem Port(0=COM1):');
  ReadLn(CurPort);
  InitFossil(Z,CurPort);
  if Z.MaxFunc=0 then begin
    WriteLn('ERROR:No FOSSIL driver found!');
    Sound(400);
    Delay(500);
    NoSound;
    Halt(1);
  End;
  WriteLn('Fossil: Rev ',Z.Revision,'  ',Z.Ident);
End;


Procedure FossilSendStr(S:String; Port:Word);
Var
  I:Byte;
Begin
  for I:=1 to byte(S[0]) do FossilSendChar(Port,byte(S[I]));
End;

Procedure DialNo(Port:Word);
Const SufixDial = 'ATDT';
var
  TelNo:String;
Begin
  WriteLn;
  Write('Number to dial:');
  ReadLn(TelNo);
  if TelNo<>'' then begin
    TelNo := SufixDial+TelNo+DialSuf;
    FossilSendStr(TelNo,Port);
  end;
end;


Procedure DialRec(Port:Word);
var
  SufixDial : String;
  Num       : Integer;
  BBSName   : String;
  BBSNumber : String;
  Password  : String;
  Speed     : Integer;
  TelNo     : String;
Begin
Writeln('TelNo is ',TelNo);
TelNo := 'ATDT'+TelNo+DialSuf;
FossilSendStr(TelNo,Port);
End;

Procedure Run;
var
  Key :Word;
  Done:Boolean;
Begin
  Done := False;
  Repeat
    If FossilIsCharReady(1)<>$FFFF Then Begin
      Write(Chr(FossilReadChar(CurPort)));
    End;
    If FIsKeyPressed<>$FFFF Then Begin
      Key:=FReadKey;
      Case Key Of
        ExitKey:Done:=True;
        DialKey:DialNo(CurPort);
        Else FossilSendChar(CurPort,Lo(Key));
      End;

    End;
  Until Done;
End;

Procedure WriteAnsi;
Var R : registers;
Begin
 R.AH := $13;
 R.AL := ORD(FossilreadChar(CurPort));
 Intr($14, R);
End;

Procedure HangUp;
Begin
 FossilSendSTR('+++',CurPort);
 FossilSendSTR('ATH0'+#13, CurPort);
End;

Procedure Done;
Begin
  DeInitFossil(CurPort);
End;

End.

{ --------------------------------   DEMO PROGRAM --------------------- }

{$M 65520,65520,65520}
Program AnsiEmu;

Uses Dos, Crt, FossilP;
Const CurPort :Word=1;

      ExitKey     = $2d00; {ALT-X}
      DialKey     = $2000; {ALT-D}
      HangUpKey   = $2300; {ALT-H}
      DownLoadKey = $2004; {CTRL+D}
      UpLoadKey   = $1615; {CTRL+U}
      ChangeSetUp = $2100; {ALT+F}
      Menuu       = $2E00; {ALT+C}
      PgUp        = $4900; {PageUp}
      PgDown      = $5100; {PageDown}
      ReadPhon    = $1900; {ALT+P}


      DialPref :String='ATDT';
      DialSuf  :String=#13;


Var Key   : Word;
    Done  : Boolean;
    AnsiM : Char;

{ZMODEM'iga download}
Procedure DownLoadZ;
Begin
SwapVectors;
Exec(GetEnv('COMSPEC'), '/C' + 'c:\gsz.exe port 2 rz');
SwapVectors;
End;

Procedure UpLoadZ;
Var FileName : String;
Begin
Write('Millist faili tahad Uppida: ');
Readln(FileName);
SwapVectors;
Exec(GetEnv('COMSPEC'), '/C' + 'c:\gsz.exe port 2 sz '+FileName);
SwapVectors;
End;

Procedure FirstKey;
Var Vastus : Byte;
Begin
ClrScr;
TextColor(red);
Writeln('Millist Protocolli kasutad: ');
Writeln;
Writeln('1. Zmodem');
Writeln('2. Puma  ');
Writeln('3. SeaLink');
Writeln;
Write('Vastus: ');
Readln(Vastus);
 Case Vastus of
  1 : DownLoadZ;
 End; {End Case}
TextColor(White);
End;

Procedure DownLoad;
Begin
SwapVectors;
 Exec(GetEnv('COMSPEC'), '/C' + 'c:\gsz.exe port 2 rz');
SwapVectors;
End;

Procedure UpLoad;
Var FileName : String;
Begin
 Write('Enter Filename to UpLoad: ');
  Readln(FileName);
 SwapVectors;
   Exec(GetEnv('COMSPEC'), '/C' + 'c:\gsz.exe port 2 sz '+FileName);
 SwapVectors;
End;

Begin
ClrScr;
TextColor(White);
Init;
  Done:=False;
  Repeat
    If FossilIsCharReady(1)<>$FFFF then begin
      {Write(Chr(FossilReadChar(CurPort)));}
      WriteAnsi; {If ANSI loaded then color else BW}
    End;
    if FIsKeyPressed<>$FFFF then begin
      Key:=FReadKey;
      case Key of
        ExitKey    : Done:=True;
        DialKey    : DialNo(CurPort);
        HangUpKey  : HangUp;
        DownLoadKey: DownLoadZ;
        UpLoadKey  : UpLoadZ;
        PgDown     : FirstKey;                    {DownLoadSeaLink;}
        PgUp       : UpLoad;

        Else FossilSendChar(CurPort, Lo(Key));
      End;
    End;
  Until Done;

 Writeln('The End :-)');
{PXDone;}
TextColor(White);
End.


