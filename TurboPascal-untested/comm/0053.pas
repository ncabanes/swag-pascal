 (* ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  *)
 (* ░░██████░░░░░░░░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  *)
 (* ░░█      ░░░░░░░░░░░░░░░░░░░░█      ░░░░░░░░░░·              ·░░░░░  *)
 (* ░░██████ █░░█░████░█▀▀█░█▄██░███░░████░█▀▀▀░░░ By Wayne Boyd  ▒░░░░  *)
 (* ░░░    █ █ ░█ █  █ █▀▀▀ █    █   ░█  █ ▀▀▀█░░░ Fido 1:153/763 ▒░░░░  *)
 (* ░░██████ ████ ████ ████ █ ░░░█ ░░░████ ████ ░░·              ·▒░░░░  *)
 (* ░░░      ░    █    ░    ░ ░░░░ ░░░░    ░    ░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░  *)
 (* ░░░░░░░░░░░░░░█ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  *)
 (* ░░░░░░░░░░░░░░░ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  *)
 (* ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  *)
 (* ░░░░░░░░░░░░░░░░░░░░░· A Turbo Pascal Unit for   ·░░░░░░░░░░░░░░░░░  *)
 (* ░░░░░░░░░░░░░░░░░░░░░  modem communications using ▒░░░░░░░░░░░░░░░░  *)
 (* ░░░░░░░░░░░░░░░░░░░░░· a FOSSIL driver.          ·▒░░░░░░░░░░░░░░░░  *)
 (* ░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░  *)
 (* ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  *)
 (* Welcome to my fossil driver world. After struggling for a long       *)
 (* time with various communications drivers I came to realize the       *)
 (* easiest way to go about writing doors and even BBS programs was to   *)
 (* use a FOSSIL driver. FOSSIL stands for Fido Opus Seadog Standard     *)
 (* Interface Layer. It's a TSR program that remains in your computer    *)
 (* memory and helps interface your software with the modem com port.    *)
 (* There's many BBS programs, Fidonet mailer's and On-line BBS games    *)
 (* that only operate with a FOSSIL driver loaded. The programs you      *)
 (* write with this unit will also depend on a FOSSIL driver.            *)
 (* Of course, there is no FOSSIL driver included with this package.     *)
 (* You have to pick one of those up on your own at most major           *)
 (* computer bulletin boards around country. I've tested this unit on    *)
 (* X00, BNU and OPUSCOMM and they work fine. The unit that is           *)
 (* included here is more a less a complete package. You could write a   *)
 (* BBS or a door with it easily. I've written many doors now, and       *)
 (* this is my standard unit. I don't want to claim credit for           *)
 (* everything here. In fact, the function calls used are from the       *)
 (* fossil revision 5 documentation and will work with any proper        *)
 (* FOSSIL driver.                                                       *)
 (*                                                                      *)
 (* = It is important to note that this unit was specifically written to *)
 (* = facilitate writing of BBS doors, but may be modified slightly to   *)
 (* = facilitate the writing of a BBS program itself. The difference is  *)
 (* = that generally when writing a door, if the caller drops carrier    *)
 (* = you would simply want the program to terminate and return to the   *)
 (* = BBS. In the case of a BBS, however, you want the BBS to recycle,   *)
 (* = not to terminate. Also, with some doors, rather than terminate     *)
 (* = immediately, you would want them to save information to file       *)
 (* = first. In such cases you have to modify all of the HALT statements *)
 (* = that are found within this unit to reflect your actual needs.      *)
 (*                                                                      *)
 (* I have provided this unit as a public service for the BBS community, *)
 (* but I do request that if you would like further support for programs *)
 (* that you write with this unit, that you register this unit with me   *)
 (* by sending me a modest donation of $25.00.                           *)
 (*                                                                      *)
 (* I may be contacted by writing:                                       *)
 (*                        ┌───────────────────────┐                     *)
 (*                        │ Wayne Boyd            │                     *)
 (*                        │ c/o Vipramukhya Swami │                     *)
 (*                        │ 5462 SE Marine Drive  │                     *)
 (*                        │ Burnaby, BC, V5J 3G8  │                     *)
 (*                        │ Canada                │                     *)
 (*                        └───────────────────────┘                     *)
 (* My BBS is called Sita and the Ring BBS, and it is Fidonet node       *)
 (* 1:153/763, Transnet node 132:732/4 and ISKCONet 108:410/8. File      *)
 (* requests and netmail is acceptable. You may also log on my board at  *)
 (* 2400 baud or less, and the phone number is (604)431-6260.            *)
 (*                                                                      *)

UNIT SuperFos;

INTERFACE

USES Dos,Crt,ansi;
             { this ANSI module is in ANSI.SWG.  }
CONST

  { These are defined global constants that can be passed to SetPort }

  Com0 = 0;  { local only mode }
  Com1 = 1;  { for COM1, etc.  }
  Com2 = 2;
  Com3 = 3;
  Com4 = 4;

PROCEDURE SetPort(Port : Integer);
 (*   Set's ComPortNum to correct value, used by all procedures. Must be *)
 (*   called first. Use the defined constants to make it easy. For       *)
 (*   example: SetPort(Com1) will assign COM1 as the input/output port.  *)
 (*   In reality, the numeric value of ComPortNum is (Port - 1).         *)
 (*   Calling SetPort with a 0 will cause all functions and              *)
 (*   procedure to function in local mode. You must make one call to     *)
 (*   SetPort at the beginning of your program before using any of the   *)
 (*   procedures or functions in this unit.                              *)
 (*                                                                      *)
 (*   If you use                                                         *)
 (*   SetPort(Com0), all functions and procedures will function in local *)
 (*   mode, since Com0 = 0. This will cause the value of ComPortNum to   *)
 (*   equal -1.                                                          *)

PROCEDURE SetBaudRate(A : LongInt);
 {  Set baud rate, 300/600/1200/2400/4800/9600/19200/38400 supported}

PROCEDURE TransmitChar(A : Char);
 {  Character is queued for transmission}

FUNCTION TxCharNoWait(A : Char) : BOOLEAN;
 {  Try to send char.  Returns true if sent, false if buffer full}

FUNCTION ReceiveChar : Char;
 {  Next char in input buffer returned, waits if none avail}

FUNCTION SerialStatus : Word;
{  AH bit 6, 1=output buffer empty
   AH bit 5, 1=output buffer not full
   AH bit 1, 1=input buffer overrun
   AH bit 0, 1=characters in input buffer
   AL bit 7, 1=carrier detect
   AL bit 3, 1=always}
FUNCTION KeyPressedPort : Boolean;
  { Similar to KEYPRESSED. Returns TRUE if there is a character waiting in
  the input port. Uses the SerialStatus function above. }

FUNCTION OutBufferFull : Boolean;
  { Returns TRUE if the Output Buffer is full. }

FUNCTION OutBufferEmpty : Boolean;
  { Returns TRUE if the Output Buffer is empty. }

FUNCTION OpenFossil : Boolean;
 {  Open & init fossil. Returns true if a fossil device is loaded }

PROCEDURE CloseFossil;
 {  Disengage fossil from com port. DTR not changed}

PROCEDURE SetDTR(A : Boolean);
 {  Raise or lower DTR}

PROCEDURE FlushOutput;
 {  Wait for all output to complete}

PROCEDURE PurgeOutput;
 {  Zero output buffer and return immediately. Chars in buffer lost}

PROCEDURE PurgeInput;
 {  Zero input buffer and return immediately.  Chars in buffer lost}

FUNCTION CarrierDetect : Boolean;
 {  Returns true if there is carrier detect }

FUNCTION SerialInput : Boolean;
 {  Returns true if there is a character ready to be input }

PROCEDURE WriteChar(c : Char);
 {  Write char to screen only with ANSI support}

PROCEDURE FlowControl(A : Byte);
 {  Enable/Disable com port flow control}

PROCEDURE WritePort(s : string);
 {  Write string S to the comport and echo it to the screen. Checks if the
   buffer is full, and if it is, waits until it is available. If Carrier is
   dropped, this procedure will halt the program.}

PROCEDURE WritelnPort(s : string);
 { Same as WritePort, but adds a linefeed + CarrierReturn to the end of S }

FUNCTION ReadKeyPort : char;
 { Like pascal's Readkey.
  Example:
  var
    ch : char;
  begin
    repeat
      ch := upcase(readkeyport);
    until ch in ['Y','N'];
  end.
}

PROCEDURE ReadPort(var C : char);
 { Similar to Pascal's Read(ch : char); This procedure will read the
  comport until a character is received. If no carrier is received it
  will wait and eventually time out. If carrier is dropped it will halt
  the program. The character is echoed to the local screen with ansi
  support.

  EXAMPLE
  var
    ch : char;
  begin
    ReadPort(Ch);
  end.
}

PROCEDURE ReadlnPort(var S : string);
 { Similar to Pascal's Readln(s : string); This procedure will read the
  comport until a carriage return is received, and assign the value to S.
  Carrier detect monitoring is enabled, and if the carrier is dropped the
  program will halt. Also there is a time out function. The characters
  are echoed to the local screen with ansi support.

  Example:
    var
      Rspns : string;
    begin
      ReadlnPort(Rspns);  (* read a string from comport and store in Rspns *)
    end.
}

PROCEDURE HangUp;
 {  Hangs up on the caller by lowering DTR until carrier is dropped, and then
   raising DTR again. }

VAR
  Reg : Registers;  { Saves on stack usage later }

 {-------------------------------------------------------------------------}

IMPLEMENTATION

Const
  TimeOut = 20000;

VAR
  Status : Word;
  bt : byte;
  ComPortNum : Integer;

PROCEDURE SetPort(Port : Integer);
BEGIN
  ComPortNum := Port - 1;
END;

FUNCTION BitOn(Position, TestByte : Byte) : Boolean;
 {
This function tests to see if a bit in TestByte is turned on (equal to one).
The bit to test is indicated by the parameter Position, which can range from 0
(right-most bit) to 7 (left-most bit). If the bit indicated by Position is
turned on, the BitOn function returns TRUE.
}
BEGIN
  bt := $01;
  bt := bt SHL Position;
  BitOn := (bt AND TestByte) > 0;
END;

PROCEDURE SetBaudRate(A : LongInt);
BEGIN
  IF ComPortNum < 0 then exit;
  WITH Reg DO BEGIN
    AH := 0;
    DX := ComPortNum;
    AL := $63;
    IF A=38400 THEN AL:=$23 ELSE
    CASE A OF
      300   : AL := $43;
      600   : AL := $63;
      1200  : AL := $83;
      2400  : AL := $A3;
      4800  : AL := $C3;
      9600  : AL := $E3;
      19200 : AL := $03;
    END;
    Intr($14, Reg);
  END;
END;

PROCEDURE TransmitChar(A : Char);
BEGIN
  IF ComPortNum < 0 then exit;
  Reg.AH := 1;
  Reg.DX := ComPortNum;
  Reg.AL := Ord(A);
  Intr($14, Reg);
END;

FUNCTION TxCharNoWait(A : Char) : BOOLEAN;
BEGIN
  IF ComPortNum < 0 then exit;
  Reg.AH := $0B;
  Reg.DX := ComPortNum;
  Intr($14,Reg);
  TxCharNoWait := (Reg.AX = 1);
END;

FUNCTION ReceiveChar : Char;
BEGIN
  IF ComPortNum < 0 then ReceiveChar := readkey else
  begin
    Reg.AH := 2;
    Reg.DX := ComPortNum;
    Intr($14,Reg);
    ReceiveChar := Chr(Reg.AL);
  end;
END;

FUNCTION SerialStatus : Word;
BEGIN
  Reg.AH := 3;
  Reg.DX := ComPortNum;
  Intr($14,Reg);
  SerialStatus := Reg.AX;
END;

FUNCTION KeyPressedPort : Boolean;
 {
Similar to KEYPRESSED. Returns TRUE if there is a character waiting in the
input port. Uses the SerialStatus function above.
}
VAR
  Status : Word;
  NextByte : byte;
begin
  IF ComPortNum < 0 then KeyPressedPort := Keypressed else
  begin
    Status := SerialStatus;
    NextByte := hi(Status);
    KeyPressedPort := BitOn(0,NextByte);
  end;
end;

FUNCTION OutBufferFull : Boolean;
 { Returns TRUE if the Output Buffer is full. }
begin
  IF ComPortNum < 0 then OutBufferFull := false else
  begin
    Status := SerialStatus;
    bt := hi(Status);
    OutBufferFull := (BitOn(5,bt) = FALSE);
  end;
end;

FUNCTION OutBufferEmpty : Boolean;
 { Returns TRUE if the Output Buffer is empty. }
begin
  IF ComPortNum < 0 then OutBufferEmpty := true else
  begin
    Status := SerialStatus;
    bt := hi(Status);
    OutBufferEmpty := BitOn(6,bt);
  end;
end;

FUNCTION OpenFossil : boolean;
BEGIN
  if ComPortNum < 0 then OpenFossil := true else
  begin
    Reg.AH := 4;
    Reg.DX := ComPortNum;
    Intr($14,Reg);
    OpenFossil := Reg.AX = $1954;
  end;
END;

PROCEDURE CloseFossil;
BEGIN
  IF ComPortNum < 0 then exit;
  Reg.AH := 5;
  Reg.DX := ComPortNum;
  Intr($14,Reg);
END;

PROCEDURE SetDTR;
BEGIN
  IF ComPortNum < 0 then exit;
  Reg.AH := 6;
  Reg.DX := ComPortNum;
  Reg.AL := Byte(A);
  Intr($14,Reg);
END;

PROCEDURE FlushOutput;
BEGIN
  IF ComPortNum < 0 then exit;
  Reg.AH := 8;
  Reg.DX := ComPortNum;
  Intr($14,Reg);
END;

PROCEDURE PurgeOutput;
BEGIN
  IF ComPortNum < 0 then exit;
  Reg.AH := 9;
  Reg.DX := ComPortNum;
  Intr($14,Reg);
END;

PROCEDURE PurgeInput;
BEGIN
  IF ComPortNum < 0 then exit;
  Reg.AH := $0A;
  Reg.DX := ComPortNum;
  Intr($14,Reg);
END;

FUNCTION CarrierDetect;
BEGIN
  IF ComPortNum < 0 then CarrierDetect := true else
  begin
    Reg.AH := 3;
    Reg.DX := ComPortNum;
    Intr($14,Reg);
    CarrierDetect := (Reg.AL AND $80) > 0;
  end;
END;

FUNCTION SerialInput;
BEGIN
  IF ComPortNum < 0 then SerialInput := true else
  begin
    Reg.AH := 3;
    Reg.DX := ComPortNum;
    Intr($14,Reg);
    SerialInput := (Reg.AH And 1) > 0;
  end;
END;

PROCEDURE WriteChar(c : char);
BEGIN
  if ComPortNum < 0 then Display_Ansi(c) else
  begin
    Reg.AH := $13;
    Reg.AL := ORD(c);
    Intr($14,Reg);
  end;
END;

PROCEDURE FlowControl;
BEGIN
  IF ComPortNum < 0 then exit;
  Reg.AH := $0F;
  Reg.DX := ComPortNum;
  Reg.AL := A;
  Intr($14, Reg);
END;

PROCEDURE WritePort(s : string);
VAR
  i : byte;
begin
  for i := 1 to length(s) do
  begin
    if (ComPortNum >= 0) then TransmitChar(s[i]);
    DISPLAY_Ansi(s[i]);
    if not CarrierDetect then halt(1);
  end;
end;

PROCEDURE WritelnPort(s : string);
BEGIN
  s := s + #10 + #13;
  WritePort(s);
end;

FUNCTION ReadKeyPort : char;
var
  ch : char;
  count : longint;
begin
  count := 0;
  repeat
    if not carrierdetect then exit;
    if ComPortNum < 0 then ch := readkey else
    if KeyPressedPort then ch := ReceiveChar else
     if keypressed then ch := readkey else
      ch := #0;
    if ch = #0 then inc(count);
  until (ch > #0) or (count > timeout);
  ReadKeyPort := ch;
end;

PROCEDURE ReadPort(var C : char);
type
  C_Type = char;
var
  CPtr : ^C_Type;
  ch : char;
  count : longint;
begin
  CPtr := @C;
  count := 0;
  repeat
    if not carrierdetect then halt(1);
    if ComPortNum < 0 then ch := readkey else
     if KeyPressedPort then ch := ReceiveChar else
      if keypressed then ch := readkey else
       ch := #0;
    if ch = #0 then inc(count) else
    begin
      if (ComPortNum >= 0) then TransmitChar(ch);
      DISPLAY_Ansi(ch);
    end;
  until (ch > #0) or (count > timeout);

  CPtr^ := ch;
end;

PROCEDURE ReadlnPort(var S : string);
type
  linestring = string;
var
  SPtr : ^linestring;
  st : string;
  ch : char;
begin
  SPtr := @S;
  st := '';

  repeat
    Ch := readkeyport;
    if ch in [#32..#255] then
    begin
      st := st + ch;
      writeport(ch);
    end else
    if (ch = #8) and (st > '') then
    begin
      delete(st,length(st),1);
      writeport(#8+#32+#8);
    end;
  until ch in [#13,#0];   { will equal NULL if ReadPort timed out }
  WritelnPort('');
  SPtr^ := st;
end;

PROCEDURE HangUp;
BEGIN
  if ComPortNum < 0 then exit;
  repeat
    SetDtr(TRUE);        { lower DTR to hangup }
  until Not CarrierDetect;
  SetDtr(FALSE);           { raise DTR again     }
END;

BEGIN
  Clrscr;
  Write('SuperFos - by Wayne Boyd 1:153/763');
  delay(1000);
END.
