(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0059.PAS
  Description: Example Intr($14
  Author: GREG VIGNEAULT
  Date: 08-25-94  09:09
*)

{
>Hi Greg;  I tried this out a few minutes ago but it insists on
>accessing COM1.

 Sorry about that. I should have used a single global CONSTant for
 the COM port number. I made the change, so now you just need to
 have "COMx = 2" for COM2.

 This code is a quick'n-dirty example, so I'm certain that there
 are errors/bugs in the COM i/o error checking. I'll take another
 look at it later...
}

PROGRAM UseInt14;
USES  Dos, Crt;

CONST COMx = 1;               { <<-- 1 for COM1, 2 for COM2, etc.   }

VAR   reg   : Registers;      { CPU registers                       }
      Okay  : BOOLEAN;
      ch    : CHAR;           { i/o character                       }

PROCEDURE InitCOM (PortNo,Baud,WordLen,Parity,Stops:WORD);
  VAR IniParm:BYTE; BEGIN
    IniParm := 0;
    CASE Baud OF
      300   : IniParm := 64;
      1200  : IniParm := 128;
      2400  : IniParm := 160;
      4800  : IniParm := 192;
      9600  : IniParm := 224;
    END{CASE};
    CASE Parity OF
      1   : {odd}   IniParm := IniParm OR 8;
      2   : {none}  ;
      3   : {even}  IniParm := IniParm OR 24;
    END{CASE};
    CASE Stops OF
      2   : IniParm := IniParm OR 4;
    ELSE  ;
    END{CASE};
    CASE WordLen OF
      7 : IniParm := IniParm OR 2;
      8 : IniParm := IniParm OR 3;
    END{CASE};
    reg.DX := PortNo - 1;; reg.AL := IniParm;;
    reg.AH := 0;; Intr($14,reg);
  END {InitCOM};

PROCEDURE PutComChar (PortNo:WORD; Data:CHAR); BEGIN
    reg.DX := PortNo - 1;; reg.AL := ORD(Data);;
    reg.AH := 1;; Intr($14,reg);
    Okay := ((reg.AL AND 14) = 0) OR NOT BOOLEAN(reg.AH SHR 7);
  END {PutComChar};

PROCEDURE GetComChar (PortNo:WORD; VAR Data:CHAR); BEGIN
    reg.DX := PortNo - 1;; reg.AH := 2;; Intr($14,reg);;
    Data := CHR(reg.AL);
    Okay := ((reg.AL AND 14) = 0) OR NOT BOOLEAN(reg.AH SHR 7);
  END {GetComChar};

FUNCTION ComReady (PortNo:WORD):BOOLEAN; BEGIN
    reg.AH := 3;; reg.DX := PortNo - 1;; Intr($14,reg);
    Okay := ((reg.AL AND 14) = 0) OR NOT BOOLEAN(reg.AH SHR 7);
    ComReady := (reg.AH AND 96) <> 0;
  END {ComReady};

FUNCTION ComDataAvailable (PortNo:WORD):BOOLEAN; BEGIN
    reg.AH := 3;; reg.DX := PortNo - 1;; Intr($14,reg);
    Okay := ((reg.AL AND 14) = 0) OR NOT BOOLEAN(reg.AH SHR 7);
    ComDataAvailable := (reg.AH AND 1) <> 0;
  END {ComDataAvailable};

BEGIN {UseInt14}
  InitCOM (COMx,9600,8,2,1);    { initialize COMx: 9600 bps, 8n1  }
  REPEAT
    IF ComDataAvailable(COMx) THEN GetComChar(COMx,ch) ELSE ch := #0;
    IF (ch <> #0) THEN Write (ch);
    IF NOT Okay THEN WriteLn(#13,#10,'****COM I/O ERROR****',#7);
    IF KeyPressed THEN ch := ReadKey ELSE ch := #0;
    IF (ch <> #0) THEN BEGIN
      REPEAT {wait} UNTIL ComReady(COMx);
      PutComChar(COMx,ch);
    END{IF};
    IF NOT Okay THEN WriteLn(#13,#10,'****COM I/O ERROR****',#7);
  UNTIL ch = #27;   { exit when ESC key pressed }

END {UseInt14}.

