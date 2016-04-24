(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0048.PAS
  Description: Re: printer Ready
  Author: PETER PRIESKE
  Date: 11-22-95  13:30
*)


{ Untested On }

   FUNCTION PrinterNotReady : BOOLEAN;
   VAR Regs : REGISTERS;
   BEGIN
      PrinterNotReady := TRUE;
      FILLCHAR(Regs, SIZEOF(Regs), 00);
      WITH Regs DO BEGIN
         AX := $0200;
         DX := 0; { LPT1 = 0, LPT2 = 1 }
      END;
      Intr($17, Regs);
      IF Regs.AX AND $4000 = 0 THEN BEGIN
         IF Regs.AX AND $1000 <> 0 THEN PrinterNotReady := FALSE;
      END;
   END;


