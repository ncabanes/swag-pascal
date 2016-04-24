(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0014.PAS
  Description: Write to CON and PRN
  Author: SWAG SUPPORT TEAM
  Date: 06-22-93  09:11
*)

UNIT ConPrnIO;
{ UNIT TO WRITE TO SCREEN AND PRINTER AT THE SAME TIME }

INTERFACE

  USES DOS;
  VAR
    ConPrn : Text;

  PROCEDURE SetLptNbr(PrinterPort: Byte);

IMPLEMENTATION

  VAR
    IOBuffer : ARRAY[0..255] OF Char;
    OldExitProc : Pointer;

{$F+}
  PROCEDURE ExitConPrn;
  BEGIN
    ExitProc := OldExitProc;
    Close(ConPrn)
  END;

{------------------------------}

  PROCEDURE SetLptNbr;

      FUNCTION NbrLpts: Integer;
      VAR
        Regs : Registers;
      BEGIN
        Intr($11,Regs);
        NbrLpts := Regs.AH SHR 6
      END;


  BEGIN
    IF NbrLpts = 0 THEN
      BEGIN
        WriteLn('No printer port installed');
        Halt(1)
      END;

    WITH TextRec(ConPrn) DO
      BEGIN
        IF PrinterPort <= NbrLpts THEN
          UserData[1] := PrinterPort - 1
        ELSE
          UserData[1] := 0  {Default to LPT1}
      END
  END;

{------------------------------}

  FUNCTION OutPrn(VAR F: TextRec; ch : Char):
                                         Integer;
    FUNCTION GetPrnStatus(PrnPort: Byte): Boolean;

      VAR
        Regs : Registers;
        NbrPasses : Byte;
      CONST
        Retries : Byte = 100;

      BEGIN

        NbrPasses := 0;
        GetPrnStatus := TRUE;

        WITH Regs DO
          BEGIN
            REPEAT
               AH := $02;
               DX := F.UserData[1];
               Intr($17,Regs);
               AH := AH AND $90;
               IF (AH <> $90) AND
                  (NbrPasses < Retries) THEN
                 Inc(NbrPasses)
            UNTIL (NbrPasses > Retries) OR
                  (AH = $90);
            IF AH <> $90 THEN
               GetPrnStatus := FALSE;
          END
      END;


    VAR
      Regs : Registers;
      ChByte : Byte;

    BEGIN
      ChByte := Ord(ch);
      WITH Regs DO
        BEGIN
          IF GetPrnStatus(F.UserData[1]) THEN
            BEGIN
              AH := $00;
              AL := ChByte;
              DX := F.UserData[1];
              Intr($17,Regs);
              OutPrn := 0;
            END
          ELSE
            OutPrn := 160
        END
      END;

{------------------------------}

  FUNCTION InOutConPrn(VAR F: TextRec): Integer;


    PROCEDURE OutCon(ch : Char; DspPage : Byte);
    VAR
      Regs : Registers;
    BEGIN
      Regs.AH := $0E;        {Write TTY character}
      Regs.AL := Byte(ch);
      Regs.BH := DspPage;
      Intr($10,Regs)
    END;


  VAR
    OutputPos, DspPage : Byte;
    Regs               : Registers;
    Status               : Integer;

  BEGIN
    WITH F DO
      BEGIN
        Regs.AH := $0F; {Get Current Display Page}
        Intr($10,Regs);
        DspPage := Regs.BH;
        OutputPos := 0;
        Status := 0;
        InOutConPrn := 0;
        WHILE (OutputPos < BufPos) AND
              (Status = 0) DO
          BEGIN
            OutCon(BufPtr^[OutputPos],DspPage);
            Status := OutPrn(F,BufPtr^[OutputPos]);
            Inc(OutputPos);
            IF Status <> 0 THEN
              InOutConPrn := 160;
          END;
        BufPos := 0;
      END
  END;

{------------------------------}

  FUNCTION FlushConPrn(VAR F: TextRec): Integer;
  BEGIN
    WITH F DO
      BEGIN
        IF BufPos <> 0 THEN
          FlushConPrn := InOutConPrn(F)
        ELSE
          FlushConPrn := 0
      END
  END;

{------------------------------}

  FUNCTION CloseConPrn(VAR F: TextRec): Integer;
  {print a ff on printer when closing device}
  BEGIN
    IF F.UserData[1] < 3 THEN
       CloseConPrn := OutPrn(F,Chr(12))
  END;

{------------------------------}

  FUNCTION OpenConPrn(VAR F: TextRec): Integer;
  BEGIN
    WITH F DO
      BEGIN
        IF Mode = fmOutput THEN
          BEGIN
            InOutFunc        := @InOutConPrn;
            FlushFunc        := @FlushConPrn;
            CloseFunc        := @CloseConPrn;
            FillChar(IOBuffer,SizeOf(IOBuffer),#0);
            OpenConPrn        := 0
          END
        ELSE
          OpenConPrn := 104 {file not open
                             for input or Append}
      END
  END;

{$F-}

{------------------------------}


  PROCEDURE AssignConPrn(VAR F : Text);

  BEGIN
     WITH TextRec(F) DO
       BEGIN
         Mode             := fmClosed;
         BufSize     := SizeOf(IOBuffer);
         BufPtr             := @IOBuffer;
         OpenFunc    := @OpenConPrn;
         Name[0]     := #0
       END
  END;

{-------- UNIT INITIALIZATION SECTION ---------}


BEGIN
  AssignConPrn(ConPrn);
  Rewrite(ConPrn);

  OldExitProc := ExitProc;
  ExitProc := @ExitConPrn;

  SetLptNbr(1);               {default to LPT1}
END.

{ ------------------    TEST PROGRAM ------------------------}

PROGRAM TestConPrn;


USES DOS,CRT,Printer,ConPrnIO;


BEGIN
  ClrScr;
  WriteLn('Written to screen');
  WriteLn(ConPrn,'Written to both');
  WriteLn('Written to screen');
  WriteLn(Lst,'Written to printer only')
END.


