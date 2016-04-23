
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