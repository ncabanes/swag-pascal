{
TERRY GRANT

Here is a Unit I posted some time ago For use With EMSI Sessions. Hope it
helps some of you out. You will require a fossil or Async Interface for
this to compile!
}

Program Emsi;

Uses
  Dos , Crt, Fossil;

Type
  HexString = String[4];

Const
  FingerPrint          = '{EMSI}';
  System_Address       = '1:210/20.0';      { Your address }
  PassWord             = 'PASSWord';        { Session passWord }
  Link_Codes           = '{8N1}';           { Modem setup }
  Compatibility_Codes  = '{JAN}';           { Janis }
  Mailer_Product_Code  = '{00}';
  Mailer_Name          = 'MagicMail';
  Mailer_Version       = '1.00';
  Mailer_Serial_Number = '{Alpha}';
  EMSI_INQ : String = '**EMSI_INQC816';
  EMSI_REQ : String = '**EMSI_REQA77E';
  EMSI_ACK : String = '**EMSI_ACKA490';
  EMSI_NAK : String = '**EMSI_NAKEEC3';
  EMSI_CLI : String = '**EMSI_CLIFA8C';
  EMSI_ICI : String = '**EMSI_ICI2D73';
  EMSI_HBT : String = '**EMSI_HBTEAEE';
  EMSI_IRQ : String = '**EMSI_IRQ8E08';

Var
  EMSI_DAT : String;            { NOTE : EMSI_DAT has no maximum length }
  Length_EMSI_DAT : HexString;  { Expressed in Hexidecimal }
  Packet : String;
  Rec_EMSI_DAT : String;        { EMSI_DAT sent by the answering system }
  Len_Rec_EMSI_DAT : Word;

  Len,
  CRC : HexString;

  R : Registers;
  C : Char;
  Loop,ComPort,TimeOut,Tries : Byte;
  Temp : String;

Function Up_Case(St : String) : String;
begin
  For Loop := 1 to Length(St) do
    St[Loop] := Upcase(St[Loop]);

  Up_Case := St;
end;

Function Hex(i : Word) : HexString;
Const
  hc : Array[0..15] of Char = '0123456789ABCDEF';
Var
  l, h : Byte;
begin
  l := Lo(i);
  h := Hi(i);
  Hex[0] := #4;          { Length of String = 4 }
  Hex[1] := hc[h shr 4];
  Hex[2] := hc[h and $F];
  Hex[3] := hc[l shr 4];
  Hex[4] := hc[l and $F];
end {Hex} ;

Function Power(Base,E : Byte) : LongInt;
begin
  Power := Round(Exp(E * Ln(Base) ));
end;

Function Hex2Dec(HexStr : String) : LongInt;

Var
  I,HexBit : Byte;
  Temp : LongInt;
  Code : Integer;

begin
  Temp := 0;
  For I := Length(HexStr) downto 1 do
  begin
    If HexStr[I] in ['A','a','B','b','C','c','D','d','E','e','F','f'] then
      Val('$' + HexStr[I],HexBit,Code)
    else
      Val(HexStr[I],HexBit,Code);
    Temp := Temp + HexBit * Power(16,Length(HexStr) - I);
  end;
  Hex2Dec := Temp;
end;

Function Bin2Dec(BinStr : String) : LongInt;

{ Maximum is 16 bits, though a requirement For more would be   }
{ easy to accomodate.  Leading zeroes are not required. There  }
{ is no error handling - any non-'1's are taken as being zero. }

Var
  I : Byte;
  Temp : LongInt;
  BinArray : Array[0..15] of Char;

begin
  For I := 0 to 15 do
    BinArray[I] := '0';
  For I := 0 to Pred(Length(BinStr)) do
    BinArray[I] := BinStr[Length(BinStr) - I];
  Temp := 0;
  For I := 0 to 15 do
  If BinArray[I] = '1' then
    inc(Temp,Round(Exp(I * Ln(2))));
  Bin2Dec := Temp;
end;

Function CRC16(s:String):Word;  { By Kevin Cooney }
Var
  crc : LongInt;
  t,r : Byte;
begin
  crc:=0;
  For t:=1 to length(s) do
  begin
    crc:=(crc xor (ord(s[t]) shl 8));
    For r:=1 to 8 do
    if (crc and $8000)>0 then
      crc:=((crc shl 1) xor $1021)
    else
      crc:=(crc shl 1);
  end;
  CRC16:=(crc and $FFFF);
end;

{**** FOSSIL Routines ****}
{**** Removed from Code ***}

Procedure Hangup;
begin
  Write2Port('+++'+#13);
end;

{**** EMSI Handshake Routines ****}

Procedure Create_EMSI_DAT;
begin
  FillChar(EMSI_DAT,255,' ');

  EMSI_DAT := FingerPrint + '{' + System_Address + '}{'+ PassWord + '}' +
              Link_Codes + Compatibility_Codes + Mailer_Product_Code +
              '{' + Mailer_Name + '}{' + Mailer_Version + '}' +
              Mailer_Serial_Number;

  Length_EMSI_DAT := Hex(Length(EMSI_DAT));
end;

Function Carrier_Detected : Boolean;
begin
  TimeOut := 20;   { Wait approximately 20 seconds }
  Repeat
    Delay(1000);
    Dec(TimeOut);
  Until (TimeOut = 0) or (Lo(StatusReq) and $80 = $80);

  If Timeout = 0 then
    Carrier_Detected := False
  else
    Carrier_Detected := True;
end;

Function Get_EMSI_REQ : Boolean;
begin
  Temp := '';
  Purge_Input;

  Repeat
    C := ReadKeyfromPort;
    If (C <> #10) and (C <> #13) then
      Temp := Temp + C;
  Until Length(Temp) = Length(EMSI_REQ);

  If Up_Case(Temp) = EMSI_REQ then
    get_EMSI_REQ := True
  else
    get_EMSI_REQ := False;
end;

Procedure Send_EMSI_DAT;
begin
  CRC := Hex(CRC16('EMSI_DAT' + Length_EMSI_DAT + EMSI_DAT));
  Write2Port('**EMSI_DAT' + Length_EMSI_DAT + EMSI_DAT + CRC);
end;

Function Get_EMSI_ACK : Boolean;
begin
  Temp := '';

  Repeat
    C := ReadKeyfromPort;
    If (C <> #10) and (C <> #13) then
      Temp := Temp + C;
  Until Length(Temp) = Length(EMSI_ACK);

  If Up_Case(Temp) = EMSI_ACK then
    get_EMSI_ACK := True
  else
    get_EMSI_ACK := False;
end;

Procedure Get_EMSI_DAT;
begin
  Temp := '';
  For Loop := 1 to 10 do                  { Read in '**EMSI_DAT' }
    Temp := Temp + ReadKeyfromPort;

  Delete(Temp,1,2);                       { Remove the '**'      }

  Len := '';
  For Loop := 1 to 4 do                   { Read in the length   }
    Len := Len + ReadKeyFromPort;

  Temp := Temp + Len;

  Len_Rec_EMSI_DAT := Hex2Dec(Len);

  Packet := '';
  For Loop := 1 to Len_Rec_EMSI_DAT do    { Read in the packet   }
    Packet := Packet + ReadKeyfromPort;

  Temp := Temp + Packet;

  CRC := '';
  For Loop := 1 to 4 do                   { Read in the CRC      }
    CRC := CRC + ReadKeyFromPort;

  Rec_EMSI_DAT := Packet;

  Writeln('Rec_EMSI_DAT = ',Rec_EMSI_DAT);

  If Hex(CRC16(Temp)) <> CRC then
    Writeln('The recieved EMSI_DAT is corrupt!!!!');
end;

begin
  { Assumes connection has been made at this point }

  Tries := 0;
  Repeat
    Write2Port(EMSI_INQ);
    Delay(1000);
    Inc(Tries);
  Until (Get_EMSI_REQ = True) or (Tries = 5);

  If Tries = 5 then
  begin
    Writeln('Host system failed to acknowledge the inquiry sequence.');
    Hangup;
    Halt;
  end;

  { Used For debugging }
  Writeln('Boss has acknowledged receipt of EMSI_INQ');

  Send_EMSI_DAT;

  Tries := 0;
  Repeat
    Inc(Tries);
  Until (Get_EMSI_ACK = True) or (Tries = 5);

  If Tries = 5 then
  begin
    Writeln('Host system failed to acknowledge the EMSI_DAT packet.');
    Hangup;
    halt;
  end;

  Writeln('Boss has acknowledged receipt of EMSI_DAT');

  Get_EMSI_DAT;
  Write2Port(EMSI_ACK);

  { Normally the File transfers would start at this point }
  Hangup;
end.

{
 This DOES not include all the possibilities in an EMSI Session.
}