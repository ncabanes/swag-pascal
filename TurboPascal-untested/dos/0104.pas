{
 BP> Is there some way I can use interrupts or whatever to detect whether
 BP> the "file name" contained in the S string variable is a device name
 BP> (such as "CON", "LPT1", "AUX", etc) or not?

Yes: use the ubiquitious INT $21. }

FUNCTION IsDevice(CONST Fname: PathStr): boolean;
{ -- Returns TRUE if named file is actually a device.
  -- Example: IsDevice('CON') = TRUE, IsDevice(paramstr(0)) = FALSE.
  -- N.B.: returns FALSE if FName is a non-existent file. }
VAR Regs: Registers;
    F   : FILE;
    FH  : word ABSOLUTE F;
BEGIN IsDevice := FALSE;
      assign(F, Fname);
      reset(F, 1);
      IF IOresult <> 0 THEN exit;
      WITH Regs
      DO BEGIN { -- Get information about file: }
               AX := $4400;
               BX := FH;
               MsDos(Regs);
               IF NOT odd(Flags) AND (DL AND $80 <> 0)
               THEN IsDevice := TRUE
         END;
      close(F);
      IF IOresult <> 0 THEN ;
END;

