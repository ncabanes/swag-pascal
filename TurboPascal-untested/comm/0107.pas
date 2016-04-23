
Unit Modem;
{$O+,F+}

InterFace

uses dos;

const crlf:string[2] = #13+#10;

type
  pDriverInfo = ^DriverInfo;
  DriverInfo = record
      Size  : Word;
      Spec  : byte;
      Rev   : Byte;
      ID    : String;
      Ibuf  : Word;
      Iavl  : Word;
      OBuf  : Word;
      Oavl  : Word;
      Width : Byte;
      Height: Byte;
      Baud  : Byte;
    end;

Type
 pModemObj = ^ModemObj;
 ModemObj = object
 Function  Init(c:byte):boolean;
 Procedure Close;

 Function  Spec:byte;
 Function  Rev :byte;
 Function  ID  :String;
 Function  InputBuf : word;
 Function  OutputBuf: word;
 Function  DTEBaud: word;
 Function  OutBufUsed: word;
 Function  InBufUsed: word;

 Procedure SetParams(baud_:word; DataBits:byte; Parity:char; StopBit:byte);
 Procedure SetDtr(state:boolean);
 Procedure SetFlow(state:boolean);
 Function  CD:boolean;
 Procedure KillOut;
 Procedure KillIn;
 Procedure Flush;
 Function  Available:boolean;
 Function  OkToSend:boolean;
 Function  Empty:boolean;
 Procedure WriteChar(c:char);
 Procedure Write(s:string);
 Procedure Writeln(s:string);
 Function  Readkey:char;
 Function  HangUp:boolean;
 Function  ATCommand(command:string):boolean;
 Function  PeekAhead:char;
 Procedure Snarf(n:word);
 Procedure ReadBlock(var s:string;reqnum,maxnum:byte);

 Private
   ComPortVal: byte;
   DriverInfo: pDriverInfo;
   Procedure SetComPort(c:byte);
   Function ComPort:byte;
   Procedure  GetInfo;
 end;

IMPLEMENTATION

uses Crt; { needed for Delay() }

Procedure ModemObj.GetInfo;
  type
   DvrInfo = Record
      Size  : Word;
      Spec  : byte;
      Rev   : Byte;
      ID    : Pointer;
      Ibuf  : Word;
      Iavl  : Word;
      OBuf  : Word;
      Oavl  : Word;
      Width : Byte;
      Height: Byte;
      Baud  : Byte;
    End;

  var regs:registers;
      di: dvrinfo;
      ts: string;
  Begin
  fillchar(regs,sizeof(regs),0);

    Regs.Cx := Sizeof(di);
    Regs.Es := Seg(di);
    Regs.Di := Ofs(di);
    Regs.Dx := comport-1;
    Regs.ah := $1B;
    Intr($14,Regs);

  DriverInfo^.Size := di.size;
  DriverInfo^.spec := di.spec;
  DriverInfo^.rev  := di.rev;

  DriverInfo^.ibuf := di.ibuf;
  DriverInfo^.iavl := di.iavl;
  DriverInfo^.obuf := di.obuf;
  DriverInfo^.oavl := di.oavl;
  DriverInfo^.width := di.width;
  DriverInfo^.height := di.height;
  DriverInfo^.baud := di.baud;

  move ( di.id^, mem[seg(ts):ofs(ts)+1], sizeof(ts)-1);

  ts[0]:=#255;

  ts[0]:=char(pos(#0,ts)-1);

  DriverInfo^.id:=ts;

  End;

Function  ModemObj.Spec:byte;
 begin
 Spec := DriverInfo^.Spec;
 end;

Function  ModemObj.Rev :byte;
 begin
 Rev:=DriverInfo^.Rev;
 end;

Function  ModemObj.ID  :String;
 begin
 ID:=DriverInfo^.id;
 end;

Function  ModemObj.InputBuf : word;
 begin
 InputBuf := DriverInfo^.IBuf;
 end;

Function  ModemObj.OutputBuf: word;
 begin
 OutputBuf := DriverInfo^.OBuf;
 end;

{

                010 =   300 baud
                011 =   600  ''
                100 =  1200  ''
                101 =  2400  ''
                110 =  4800  ''
                111 =  9600  ''
                000 = 19200  '' (Replaces old 110 baud mask)
                001 = 38400  '' (Replaces old 150 baud mask)
}

Function  ModemObj.DTEBaud: word;
 begin
 case driverinfo^.baud of
   0: dtebaud := 19200;
   1: dtebaud := 38400;
   2: dtebaud := 300;
   3: dtebaud := 600;
   4: dtebaud := 1200;
   5: dtebaud := 2400;
   6: dtebaud := 4800;
   7: dtebaud := 9600;
   else dtebaud := 0;
   end;
 end;

Function  ModemObj.OutBufUsed:word;
 begin
 GetInfo;
 OutBufUsed := DriverInfo^.OAvl;
 end;

Function  ModemObj.InBufUsed:word;
 begin
 GetInfo;
 InBufUsed := DriverInfo^.IAvl;
 end;

function ModemObj.PeekAhead:char;
 var regs:registers;
 begin
 fillchar(regs,sizeof(regs),0);
 with regs do
   begin
   ah:=$0C;
   dx:=comport-1;
   end;
 Intr($14, regs);

 if regs.ax=$ffff then PeekAhead:=#0 else
   PeekAhead:=char(regs.al);

 end;


Procedure ModemObj.SetComPort(c:byte);
 begin
 ComPortVal:=c;
 end;

Function ModemObj.ComPort:byte;
 begin;
 ComPort:=ComPortVal;
 end;

Function ModemObj.Init(c: Byte):boolean;
var regs:registers;
Begin
 ModemObj.SetComPort(c);

 FillChar(regs,sizeof(regs),0);
 With Regs Do
 Begin
    AH := 4;
    DX := (ComPort-1);
 end;
 Intr($14, Regs);
 if (regs.AX=$1954) then
  begin
  Init:=True;
  New(DriverInfo);
  GetInfo;
  end
 else Init:=False;
end;

Procedure ModemObj.Close;
var regs:registers;
Begin
  FillChar(regs,sizeof(regs),0);

  {a setdtr(false) used to be here}

  With Regs Do
  Begin
    AH := 5;
    DX := (ComPort-1);
    Intr($14, Regs);
  end;
  dispose(Driverinfo);
end;

{
|   AH = 18h    Read block (transfer from FOSSIL to user buffer)

|           Parameters:
|               Entry:  CX = Maximum number of characters to transfer
|                       DX = Port number
|                       ES = Segment of user buffer
|                       DI = Offset into ES of user buffer
|               Exit:   AX = Number of characters actually transferred

|   A "no-wait"  block read of 0 to FFFFh characters from the FOSSIL inbound
|   ring buffer to the calling routine's buffer. ES:DI are left unchanged by
|   the call; the count of bytes actually transferred will be returned in AX.
}

Procedure ModemObj.ReadBlock(var s:string;reqnum,maxnum:byte);
 var regs:registers;
     t:string;
 begin
 with regs do
   begin
   if maxnum<=255 then cx := maxnum else cx := 255;
   dx := comport-1;
   es := seg(s);
   di := ofs(s) +1;
   end;
 Intr($14, regs);

 s[0] := chr(regs.ax);

 if regs.ax<reqnum then
   begin
   t:='';
   ReadBlock(t,reqnum-regs.ax,maxnum-regs.ax);
   s:= concat (s,t);
   end;

 end;

Procedure ModemObj.SetParams (Baud_: Word; DataBits: Byte; Parity: Char;
                     StopBit: Byte);
Var
 Code: Integer;
 regs:registers;

Begin
  Code:=0;
  FillChar(regs,sizeof(regs),0);
    Case Baud_ of
      0 : Exit;
  19200 : code:=code+000+00+00;
  38400 : code:=code+000+00+32;
    300 : code:=code+000+64+00;
    600 : code:=code+000+64+32;
    1200: code:=code+128+00+00;
    2400: code:=code+128+00+32;
    4800: code:=code+128+64+00;
    9600: code:=code+128+64+32;
  end;

  Case DataBits of
    5: code:=code+0+0;
    6: code:=code+0+1;
    7: code:=code+2+0;
    8: code:=code+2+1;
  end;

  Case Parity of
    'N','n': code:=code+00+0;
    'O','o': code:=code+00+8;
    'E','e': code:=code+16+8;
  end;

  Case StopBit of
    1: code := code + 0;
    2: code := code + 4;
  end;

  With Regs do
  begin
    AH := 0;
    AL := Code;
    DX := (ComPort-1);
    Intr($14, Regs);
  end;
end;

Procedure ModemObj.SetDtr   (State: Boolean);
var regs:registers;
Begin
  FillChar(regs,sizeof(regs),0);
  With Regs do
  begin
    AH := 6;
    DX := (ComPort-1);
    Case State of
    True : AL := 1;
    False: AL := 0;
    end;
    Intr($14, Regs);
  end;
end;


Function  ModemObj.CD     : Boolean;
var regs:registers;
Begin
  FillChar(regs,sizeof(regs),0);
  With Regs do
  Begin
    AH := 3;
    DX := (ComPort-1);
    Intr($14, Regs);
    CD := ((AL AND 128) = 128);
  end;
end;


Procedure ModemObj.SetFlow  (State: Boolean);
var regs:registers;
Begin
  FillChar(regs,sizeof(regs),0);
    With Regs do
    Begin
    AH := 15;
    DX := ComPort-1;
    Case State of
      TRUE:  AL := 255;
      FALSE: AL := 0;
    end;
    Intr($14, Regs);
  end;
end;

Procedure ModemObj.KillOut;
var regs:registers;
Begin
  FillChar(regs,sizeof(regs),0);
    With Regs do
    begin
    AH := 9;
    DX := ComPort-1;
    Intr($14, Regs);
  end;
end;

Procedure ModemObj.Snarf(n:word);
 var c:char;
     i:word;
 begin
 for i:=1 to n do c:=readkey;
 end;


Procedure ModemObj.KillIn  ;
var regs:registers;
Begin
  FillChar(regs,sizeof(regs),0);
  With Regs do
  begin
    AH := 10;
    DX := ComPort-1;
    Intr($14, Regs);
  end;
end;

Procedure ModemObj.Flush ;
var regs:registers;
Begin
  FillChar(regs,sizeof(regs),0);
  With Regs do
  Begin
    AH := 8;
    DX := ComPort-1;
    Intr($14, Regs);
  end;
end;

Function  ModemObj.Available: Boolean;
var regs:registers;
Begin
  FillChar(regs,sizeof(regs),0);
  With Regs do
  Begin
    AH := 3;
    DX := ComPort-1;
    Intr($14, Regs);
    Available:= ((AH AND 1) = 1);
  end;
end;

Function  ModemObj.OkToSend : Boolean;
var regs:registers;
Begin
  FillChar(regs,sizeof(regs),0);
  With Regs do
  Begin
    AH := 3;
    DX := ComPort-1;
    Intr($14, Regs);
    OkToSend := ((AH AND 32) = 32);
  end;
end;


Function  ModemObj.Empty : Boolean;
var regs:registers;
Begin
  FillChar(regs,sizeof(regs),0);
  With Regs do
  Begin
    AH := 3;
    DX := ComPort-1;
    Intr($14, Regs);
    Empty := ((AH AND 64) = 64);
  end;
end;

Procedure ModemObj.WriteChar (C: Char);
var regs:registers;
Begin
  FillChar(regs,sizeof(regs),0);
  With Regs do
  Begin
    AH := 1;
    DX := ComPort-1;
    AL := ORD (C);
    Intr($14, Regs);
  end;
end;

{
|   AH = 19h    Write block (transfer from user buffer to FOSSIL)

|           Parameters:
|               Entry:  CX = Maximum number of characters to transfer
|                       DX = Port number
|                       ES = Segment of user buffer
|                       DI = Offset into ES of user buffer
|               Exit:   AX = Number of characters actually transferred


|   A  "no-wait"  block  move of 0  to FFFFh  characters  from  the  calling
|   program's  buffer into  the  FOSSIL outbound ring buffer. ES:DI are left
|   unchanged by the call;  the count of bytes actually transferred  will be
|   returned in AX.
}


Procedure ModemObj.Write ( s: String);
Var
  regs:registers;
begin
 FillChar(regs,sizeof(regs),0);

 with regs do
  begin
  ah := $19;
  cx := ord(s[0]);
  dx := comport-1;
  es := seg(s);
  di := ofs(s)+1;
  Intr($14, regs);
  end;

 if not(regs.ax=ord(s[0])) then
   begin
   Flush;
   Write(copy(s,regs.ax+1,ord(s[0])));
   end;
end;


Procedure ModemObj.Writeln (s: String);
Var
 regs:registers;
begin
   Write(s+crlf);
end;

Function ModemObj.Readkey : Char;
var regs:registers;
Begin
  FillChar(regs,sizeof(regs),0);
  With Regs do
  Begin
    AH := 2;
    DX := ComPort-1;
    Intr($14, Regs);
    Readkey := Chr(AL);
  end;
end;


Function ModemObj.Hangup  : Boolean;
var
  Tcount : Integer;
  var regs:registers;
begin
  ModemObj.SetDtr(FALSE);
  delay (600);
  ModemObj.SetDtr(TRUE);
  if ModemObj.CD=true then begin
    Tcount:=1;
      repeat
        ModemObj.Write ('+++');
        delay (3000);
        ModemObj.Writeln ('ATH0');
        delay(3000);
        if ModemObj.CD=false then tcount:=3;
        Tcount:=Tcount+1;
      until Tcount=4;
  end;

 hangup:=not(ModemObj.cd=true)
end;

Function ModemObj.AtCommand (Command: String) : Boolean;
Var
  Ch     :   Char;
  Result :   String[50];
  I,Z    :   Integer;
Begin
  AtCommand:=FALSE;
  Result:='';
  For Z:=1 to 3 do begin
    Write (Char(13));
    Writeln (Command);
    Delay(500);
    Repeat
      If Available then Begin
        Ch:=Readkey;
        Result:=Result+Ch;
      end;
    Until Available=FALSE;
    For I:=1 to Length(Result)-2 do Begin
      If copy(result,i,2)='OK' then Begin
        AtCommand:=TRUE;
       Exit;
      end;
    end;
  end;
End;


END.

