(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0035.PAS
  Description: Is Printer Online ??
  Author: MIKE COPELAND
  Date: 08-24-94  13:52
*)

{
>>    I'm using TP6 and plan to use to the PRINTER.TPU unit the
>>    write to the printer.  How do you detect whether the printer
>>    is on or not without ending up a dos error and the program
>>    halting.

   You need to check the status of the printer port.  Something like
this:
}

function TESTONLINE : Byte;           { Tests for Printer On Line }
var REGS : Registers;
begin
  with REGS do
    begin
      AH := 2; DX := 0;
      Intr($17, Dos.Registers(REGS));
      TESTONLINE := AH
    end
end;  { TESTONLINE }

  if TESTONLINE = 144 then okay_to_print
  else                     printer_not_ready


