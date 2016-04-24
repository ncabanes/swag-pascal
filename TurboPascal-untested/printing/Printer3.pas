(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0009.PAS
  Description: PRINTER3.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:55
*)

Unit Myprint;
{$D-,I-,S-}
Interface

Uses Dos;

Var
  Prt        : Array[1..2] of Text;
  Lst        : Text Absolute Prt;

Function PrinterStatus(p: Byte): Byte;
Function PrinterReady(Var b : Byte; p: Byte): Boolean;

Implementation

Procedure RawMode(Var L);       { make sure that device is in raw mode }
  Var
    regs : Registers;
  begin
    With regs do begin
      bx   := TextRec(L).Handle;         { place the File handle in bx }
      ax   := $4400;           { setup For Function $44 sub-Function 0 }
      MSDos(regs);                              { execute Dos Function }
      dl   := dl or $20;                            { bit 5 = raw mode }
      dh   := 0;                                      { set dh to zero }
      ax   := $4401;           { setup For Function $44 sub-Function 1 }
      MSDos(regs)                               { execute Dos Function }
    end; { With }
  end; { RawMode }

Function PrinterStatus(p: Byte): Byte;
   { Returns the Printer status. LPT1=p=1, LPT2=p=2 }
   Var regs   : Registers; { from the Dos Unit                         }
   begin
     With regs do begin
       dx := p - 1;        { The Printer number                        }
       ax := $0200;        { The Function code For service wanted      }
       intr($17,regs);     { $17= ROM bios int to return Printer status}
       PrinterStatus := ah;{ Bit 0 set = timed out                     }
     end;                  {     1     = unused                        }
   end;                    {     2     = unused                        }
                           {     3     = I/O error                     }
                           {     4     = Printer selected              }
                           {     5     = out of paper                  }
                           {     6     = acknowledge                   }
                           {     7     = Printer not busy              }

Function PrinterReady(Var b : Byte; p: Byte): Boolean;
  begin
    b := PrinterStatus(p);
    PrinterReady := (b = $90)         { This may Vary between Printers }
  end;

begin
  assign(Prt[1],'LPT1');
  reWrite(Prt[1]);
  RawMode(Prt[1]);
  assign(Prt[2],'LPT2');
  reWrite(Prt[2]);
  RawMode(Prt[2]);
end.


