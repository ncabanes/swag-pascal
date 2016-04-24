(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0050.PAS
  Description: Printer Troubles
  Author: JAN FEIJES
  Date: 11-22-95  15:50
*)

{
 SM> #1.)  The printer's not on...
 SM> #2.)  The printer's outta paper
 SM> #3.)  The printer's fried, etc.


 Write data to the printer normally like : }

 Assign (uitvf,'LPT1');
 Rewrite (Uitvf);
 Repeat
{$I-}
       Write (Uitvf,PrinterData);
       If IOResult <> 0 then
       begin
            WriteLn ('Somthing''s wrong with the printer');
            WriteLn ('PrinterError = ',CheckPrinterStatus (1));
       end;
{$I+}
 until AllWritten;


 The funtion to determine the status of the printer :

 Function CheckPrinterStatus (Port : Word) : Byte;Assembler;

{
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~ Status :    0 - time out            Returns the printer status
             1 - unused              ==========================
             2 - unused
             3 - I/O error
             4 - On line selected
             5 - Out of paper
             6 - Acknowledge
             7 - Not Busy

 2     : Printer not found
 3+4   : Printer not on line / selected
 3     : Printer not on line / selected
 4+5   : Cable not hooked up
 4+5+7 : Cable not hooked up
 3+6+7 : Printer off or unplugged

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~}

ASM
                MOV     DX,Port
                DEC     DX            {DX := Lpt -1                   }
                MOV     AX,$0200      {AH := $02 : Read printer status}
                INT     $17
                MOV     AL,AH         {Zet status in AL}
end;

{-----------------------------------------------------------------------------
}

