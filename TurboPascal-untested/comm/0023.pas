{
                     Version 1.2  26-August-1989

▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
█▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█
█▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█
█▒▒▒▒▒▒▒▒█████████████████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█
█▒▒▒▒▒▒▒ ███                         ▒▒▒▒▒▒▒▒▒▒▒▒▒███▒▒▒▒┌──────────────────┐▒█
█▒▒▒▒▒▒▒ ███▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ███▒▒▒▒│   Ronen Magid's  │▒█
█▒▒▒▒▒▒▒ ███▒▒▒▒▒████████▒▒███████▒▒███████▒▒███▒ ███▒▒▒▒│                  │▒█
█▒▒▒▒▒▒▒ ███▒▒▒▒ ███  ███▒ ███   ▒▒ ███   ▒▒ ███▒ ███▒▒▒▒│      Fossil      │▒█
█▒▒▒▒▒▒▒ ██████▒ ███▒ ███▒ ███▒▒▒▒▒ ███▒▒▒▒▒ ███▒ ███▒▒▒▒│      support     │▒█
█▒▒▒▒▒▒▒ ███  ▒▒ ███▒ ███▒ ███████▒ ███████▒ ███▒ ███▒▒▒▒│     Unit For     │▒█
█▒▒▒▒▒▒▒ ███▒▒▒▒ ███▒ ███▒     ███▒     ███▒ ███▒ ███▒▒▒▒│                  │▒█
█▒▒▒▒▒▒▒ ███▒▒▒▒ ███▒ ███▒▒▒▒  ███▒▒▒▒  ███▒ ███▒ ███▒▒▒▒│   TURBO PASCAL   │▒█
█▒▒▒▒▒▒▒ ███▒▒▒▒ ████████▒▒███████▒▒███████▒ ███▒ ███▒▒▒▒│     versions     │▒█
█▒▒▒▒▒▒▒   ▒▒▒▒▒        ▒▒       ▒▒       ▒▒   ▒▒   ▒▒▒▒▒│       4,5        │▒█
█▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒└──────────────────┘▒█
█▒▒▒████████████████████████████████████████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█
█▒▒                                                    ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█
█▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

          Copyright (c) 1989 by Ronen Magid. Tel (972)-52-917663 VOICE
                             972-52-27271 2400 24hrs


}

Unit FOSCOM;

Interface

Uses
  Dos, Crt;

Var
  Regs : Registers;                    {Registers used by Intr and Ms-Dos}



{             Available user Procedures and Functions                     }

Procedure Fos_Init       (Comport: Byte);
Procedure Fos_Close      (Comport: Byte);
Procedure Fos_Parms      (Comport: Byte; Baud: Integer; DataBits: Byte;
                          Parity: Char; StopBit: Byte);
Procedure Fos_Dtr        (Comport: Byte; State: Boolean);
Procedure Fos_Flow       (Comport: Byte; State: Boolean);
Function  Fos_CD         (Comport: Byte) : Boolean;
Procedure Fos_Kill_Out   (Comport: Byte);
Procedure Fos_Kill_In    (Comport: Byte);
Procedure Fos_Flush      (Comport: Byte);
Function  Fos_Avail      (Comport: Byte) : Boolean;
Function  Fos_OkToSend   (Comport: Byte) : Boolean;
Function  Fos_Empty      (Comport: Byte) : Boolean;
Procedure Fos_Write      (Comport: Byte; Character: Char);
Procedure Fos_String     (Comport: Byte; OutString: String);
Procedure Fos_StringCRLF (Comport: Byte; OutString: String);
Procedure Fos_Ansi       (Character: Char);
Procedure Fos_Bios       (Character: Char);
Procedure Fos_WatchDog   (Comport: Byte; State: Boolean);
Function  Fos_Receive    (Comport: Byte) : Char;
Function  Fos_Hangup     (Comport: Byte) : Boolean;
Procedure Fos_Reboot;
Function  Fos_CheckModem (Comport: Byte) : Boolean;
Function  Fos_AtCmd      (Comport: Byte; Command: String)  : Boolean;
Procedure Fos_Clear_Regs;


Implementation

Procedure Fos_Clear_Regs;
begin
  FillChar (Regs, SizeOf (Regs), 0);
end;

Procedure Fos_Init  (Comport: Byte);
begin
 Fos_Clear_Regs;
 With Regs Do
 begin
    AH := 4;
    DX := (ComPort-1);
    Intr ($14, Regs);
    if AX <> $1954 then
    begin
      Writeln;
      Writeln (' Fossil driver is not loaded.');
      halt (1);
    end;
  end;
end;

Procedure Fos_Close (Comport: Byte);
begin
  Fos_Clear_Regs;
  Fos_Dtr(Comport,False);

  With Regs Do
  begin
    AH := 5;
    DX := (ComPort-1);
    Intr ($14, Regs);
  end;
end;


Procedure Fos_Parms (ComPort: Byte; Baud: Integer; DataBits: Byte;
                                    Parity: Char; StopBit: Byte);
Var
 Code: Integer;
begin
  Code:=0;
  Fos_Clear_Regs;
  Case Baud of
      0 : Exit;
    100 : code:=code+000+00+00;
    150 : code:=code+000+00+32;
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
    Intr ($14, Regs);
  end;
end;

Procedure Fos_Dtr   (Comport: Byte; State: Boolean);
begin
  Fos_Clear_Regs;
  With Regs do
  begin
    AH := 6;
    DX := (ComPort-1);
    Case State of
    True : AL := 1;
    False: AL := 0;
    end;
    Intr ($14, Regs);
  end;
end;


Function  Fos_CD    (Comport: Byte) : Boolean;
begin
  Fos_Clear_Regs;
  With Regs do
  begin
    AH := 3;
    DX := (ComPort-1);
    Intr ($14, Regs);
    Fos_Cd := ((AL and 128) = 128);
  end;
end;


Procedure Fos_Flow  (Comport: Byte; State: Boolean);
begin
  Fos_Clear_Regs;
    With Regs do
    begin
    AH := 15;
    DX := ComPort-1;
    Case State of
      True:  AL := 255;
      False: AL := 0;
    end;
    Intr ($14, Regs);
  end;
end;

Procedure Fos_Kill_Out (Comport: Byte);
begin
  Fos_Clear_Regs;
    With Regs do
    begin
    AH := 9;
    DX := ComPort-1;
    Intr ($14, Regs);
  end;
end;


Procedure Fos_Kill_In  (Comport: Byte);
begin
  Fos_Clear_Regs;
  With Regs do
  begin
    AH := 10;
    DX := ComPort-1;
    Intr ($14, Regs);
  end;
end;

Procedure Fos_Flush    (Comport: Byte);
begin
  Fos_Clear_Regs;
  With Regs do
  begin
    AH := 8;
    DX := ComPort-1;
    Intr ($14, Regs);
  end;
end;

Function  Fos_Avail    (Comport: Byte) : Boolean;
begin
  Fos_Clear_Regs;
  With Regs do
  begin
    AH := 3;
    DX := ComPort-1;
    Intr ($14, Regs);
    Fos_Avail:= ((AH and 1) = 1);
  end;
end;

Function  Fos_OkToSend (Comport: Byte) : Boolean;
begin
  Fos_Clear_Regs;
  With Regs do
  begin
    AH := 3;
    DX := ComPort-1;
    Intr ($14, Regs);
    Fos_OkToSend := ((AH and 32) = 32);
  end;
end;


Function  Fos_Empty (Comport: Byte) : Boolean;
begin
  Fos_Clear_Regs;
  With Regs do
  begin
    AH := 3;
    DX := ComPort-1;
    Intr ($14, Regs);
    Fos_Empty := ((AH and 64) = 64);
  end;
end;

Procedure Fos_Write     (Comport: Byte; Character: Char);
begin
  Fos_Clear_Regs;
  With Regs do
  begin
    AH := 1;
    DX := ComPort-1;
    AL := ORD (Character);
    Intr ($14, Regs);
  end;
end;


Procedure Fos_String   (Comport: Byte; OutString: String);
Var
  Pos: Byte;
begin
  For Pos := 1 to Length(OutString) do
  begin
     Fos_Write(Comport,OutString[Pos]);
   end;
OutString:='';
end;


Procedure Fos_StringCRLF  (Comport: Byte; OutString: String);
Var
  Pos: Byte;
begin
  For Pos := 1 to Length(OutString) do
    Fos_Write(ComPort,OutString[Pos]);
  Fos_Write(ComPort,Char(13));
  Fos_Write(ComPort,Char(10));
  OutString:='';
end;

Procedure Fos_Bios     (Character: Char);
 begin
   Fos_Clear_Regs;
   With Regs do
   begin
     AH := 21;
     AL := ORD (Character);
     Intr ($14, Regs);
  end;
end;


Procedure Fos_Ansi     (Character: Char);
begin
  Fos_Clear_Regs;
  With Regs do
  begin
    AH := 2;
    DL := ORD (Character);
    Intr ($21, Regs);
  end;
end;


Procedure Fos_WatchDog (Comport: Byte; State: Boolean);
begin
  Fos_Clear_Regs;
  With Regs do
  begin
    AH := 20;
    DX := ComPort-1;
    Case State of
      True  : AL := 1;
      False : AL := 0;
    end;
    Intr ($14, Regs);
  end;
end;


Function Fos_Receive  (Comport: Byte) : Char;
begin
  Fos_Clear_Regs;
  With Regs do
  begin
    AH := 2;
    DX := ComPort-1;
    Intr ($14, Regs);
    Fos_Receive := Chr(AL);
  end;
end;


Function Fos_Hangup   (Comport: Byte) : Boolean;
Var
  Tcount : Integer;
begin
  Fos_Dtr(Comport,False);
  Delay (600);
  Fos_Dtr(Comport,True);
  if FOS_CD (ComPort)=True then
  begin
    Tcount:=1;
    Repeat
      Fos_String (Comport,'+++');
      Delay (3000);
      Fos_StringCRLF (Comport,'ATH0');
      Delay(3000);
      if Fos_CD (ComPort)=False then
        tcount:=3;
      Tcount:=Tcount+1;
    Until Tcount=4;
  end;

  if Fos_Cd (ComPort)=True then
    Fos_Hangup:=False
  else
    Fos_Hangup:=True;
end;


Procedure Fos_Reboot;
begin
  Fos_Clear_Regs;
  With Regs do
  begin
    AH := 23;
    AL := 1;
    Intr ($14, Regs);
  end;
end;

Function Fos_CheckModem (Comport: Byte) : Boolean;
Var
  Ch     :   Char;
  Result :   String[10];
  I,Z    :   Integer;

begin
  Fos_CheckModem:=False;
  Result:='';
  For Z:=1 to 3 do
  begin
    Delay(500);
    Fos_Write (Comport,Char(13));
    Delay(1000);
    Fos_StringCRLF (Comport,'AT');
    Delay(1000);
    Repeat
      if Fos_Avail (Comport) then
      begin
        Ch:=Fos_Receive(Comport);
        Result:=Result+Ch;
      end;
    Until Fos_Avail(1)=False;
    For I:=1 to Length(Result) do
    begin
      if Copy(Result,I,2)='OK' then
      begin
        Fos_CheckModem:=True;
        Exit;
      end;
    end;
  end;
end;


Function Fos_AtCmd (Comport: Byte; Command: String) : Boolean;
Var
  Ch     :   Char;
  Result :   String[10];
  I,Z    :   Integer;
begin
  Fos_AtCmd:=False;
  Result:='';
  For Z:=1 to 3 do
  begin
    Delay(500);
    Fos_Write (Comport,Char(13));
    Delay(1000);
    Fos_StringCRLF (Comport,Command);
    Delay(1000);
    Repeat
      if Fos_Avail (Comport) then
      begin
        Ch:=Fos_Receive(Comport);
        Result:=Result+Ch;
      end;
    Until Fos_Avail(1)=False;
    For I:=1 to Length(Result) do
    begin
      if Copy(Result,I,2)='OK' then
      begin
        Fos_AtCmd:=True;
       Exit;
      end;
    end;
  end;
end;

end.

