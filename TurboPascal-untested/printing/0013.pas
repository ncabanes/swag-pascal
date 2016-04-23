{Your're in luck, I just got a new Printer and started writing routines to
control it (TFDD etc..). These are probably the most important ones:



 note: This routines are not throughly tested on Various Printers.
       Thus it may of may not work on your Type of Printer.
       But, as a rule, experiment With it and have fun............}

Uses
  Dos;

Functio PrinterOutofPaper( Port : Byte): Boolean;
Var
  Regs : Registers;
begin
  Regs.AH := $02;
  Regs.DX := Port;          { 0=LPT1,  1=LPT2,  2=LPT3 }
  Intr($17, Regs);          { Print Service Please }
  PrinterOutofPaper := (Regs.AH and $20 = $20)
end;

Function PrinterReady( Port : Byte): Boolean;
Var
  Regs : Registers;
begin
  With Regs Do
    begin
      AH := $02;
      DX := Port;          { 0=LPT1,  1=LPT2,  2=LPT3 }
      Intr($17, Regs)
      PrinterReady := (AH and $80 = $80) and       { Printer Busy?   }
                      (AH and $10 = $10) and       { Printer Online? }
                      (AH and $08 = $00)           { Printer Error?  }
     end
end;

Procedure PrintChar(Port: Byte; Ch: Char);
Var
  Regs : Registers;
begin
  With Regs Do
    begin
      AL := ord(Ch);             { Char to print            }
      DX := Port;                { 0=LPT1,  1=LPT2,  2=LPT3 }
      AH := $00;                 { Print Char Service       }
      Intr($17, Regs);           { Call Bios                }
    end
end;

Procedure BootPrinter( Port: Byte);
 { Initializes IBM- or EPSON- Compatible Printer  }
 { Other Printers may not understand this command }
 { and may produce unwanted results               }
Var
  Regs : Registers;
begin
  Regs.DX := Port;                { 0=LPT1,  1=LPT2,  2=LPT3 }
  Regs.AH := $01;
  Intr($17, Regs)
end;
