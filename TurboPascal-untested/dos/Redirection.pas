(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0069.PAS
  Description: Redirection
  Author: JOHN HOWARD
  Date: 08-24-94  13:55
*)


{ I found an example of DOS redirection using TP.  I think it came from either
  Dr. Dobb's or PC Magazine in 1992.  I used this in my BinarY TExt (BYTE)
  file tool which performs file splits, merges, encryption/decryption, script
  execution, and complete backwards and forwards byte resolution manipulation.
}
UNIT Echo;

INTERFACE

USES DOS;

  FUNCTION InputRedirected : Boolean;
  FUNCTION OutputRedirected : Boolean;
  FUNCTION OutputNul : Boolean;
  FUNCTION EchoIsOn : Boolean;
  PROCEDURE EchoOn;
  PROCEDURE EchoOff;

IMPLEMENTATION

  FUNCTION InputRedirected : Boolean;
  VAR Regs : Registers; Handle : Word ABSOLUTE Input;
  BEGIN
    WITH Regs DO
      BEGIN
        Ax := $4400;
        Bx := Handle;
        MsDos(Regs);
        IF Dl AND $81 = $81 THEN InputRedirected := False
        ELSE InputRedirected := True;
      END;                        {With Regs}
  END;                            {Function InputRedirected}


  FUNCTION OutputRedirected : Boolean;
  VAR Regs : Registers; Handle : Word ABSOLUTE Output;
  BEGIN
    WITH Regs DO
      BEGIN
        Ax := $4400;
        Bx := Handle;
        MsDos(Regs);
        IF Dl AND $82 = $82 THEN OutputRedirected := False
        ELSE OutputRedirected := True;
      END;                        {With Regs}
  END;                            {Function OutputRedirected}


  FUNCTION OutputNul : Boolean;
  VAR Regs : Registers; Handle : Word ABSOLUTE Output;
  BEGIN
    WITH Regs DO
      BEGIN
        Ax := $4400;
        Bx := Handle;
        MsDos(Regs);
        IF Dl AND $84 <> $84 THEN OutputNul := False
        ELSE OutputNul := True;
      END;                        {With Regs}
  END;                            {Function OutputNul}


  FUNCTION Write40h(DataBuffer : Pointer; Count, Handle : Word) : Word;
  VAR Regs : Registers;
  TYPE DWord = RECORD O, S : Word; END;
  BEGIN
    WITH Regs DO
      BEGIN
        Ds := DWord(DataBuffer).S;
        Dx := DWord(DataBuffer).O;
        Bx := Handle;
        Cx := Count;
        Ah := $40;
        MsDos(Regs);
        IF Flags AND FCarry <> 0
        THEN Write40h := 103      {- "file not open" -}
        ELSE IF Ax < Cx
        THEN Write40h := 101      {- "disk write error" -}
        ELSE Write40h := 0;
      END;                        {With Regs do}
  END;                            {Function Write40h}


{$F+} FUNCTION EchoOutput(VAR F : TextRec) : Integer; {$F-}
{- Replacement for Output text file FlushFunc and InOutFunc -}
  BEGIN
    WITH F DO
      BEGIN
        EchoOutput := Write40h(BufPtr, BufPos, 2);
        EchoOutput := Write40h(BufPtr, BufPos, Handle);
        BufPos := 0;
      END;                        {With F do}
  END;                            {Function EchoOutput}


CONST EchoStatus : Boolean = False; {- PRIVATE to unit Echo -}

  PROCEDURE EchoOn;
  BEGIN
    IF OutputRedirected THEN
      BEGIN
        Flush(Output);
        TextRec(Output).InOutFunc := @EchoOutput;
        TextRec(Output).FlushFunc := @EchoOutput;
        EchoStatus := True;
      END;                        {If OutputRedirected}
  END;                            {Procedure EchoOn}

  PROCEDURE EchoOff;
  BEGIN
    IF OutputRedirected THEN
      BEGIN
        Rewrite(Output);
        EchoStatus := False;
      END;                        {If OutputRedirected THEN}
  END;                            {Procedure EchoOff}

  FUNCTION EchoIsOn : Boolean;
  BEGIN
    EchoIsOn := EchoStatus;
  END;                            {Function EchoIsOn}


BEGIN                             {- Unit initialization -}
  EchoOn;                         {- Echo all redirected output -}
END.

{-------------------------------------------------------------------}
PROGRAM EchoDemo;
USES Echo;
BEGIN
  IF InputRedirected THEN WriteLn('Input is being redirected');
  IF OutputNul THEN
    BEGIN
      WriteLn('Output is being sent to the Nul device');
      EchoOff;
    END;
  IF OutputRedirected THEN WriteLn('Output is being redirected');

  WriteLn('--------1--------');
  EchoOff;
  WriteLn('--------2--------');
  IF NOT OutputNul THEN EchoOn;
  WriteLn('--------3--------');
  EchoOff;
  WriteLn('--------4--------');
END.

