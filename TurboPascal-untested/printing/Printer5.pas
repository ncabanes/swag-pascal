(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0011.PAS
  Description: PRINTER5.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:55
*)

{
 EPSON Printer. I'm using TP7.0. Everythings works fine except one
 situation that occured when a Character 26 (Ctrl-Z which is Eof) is in

This may be the easy way out, but why not just use BIOS interrupt $17?
It's probably slower, but it'll work.
}

Type PGraphics : ^Graphics;
     Graphics : Array [1..65535] of Byte;

Function InitPort (PortNum : Byte) : Byte; {returns status}
Var Regs : Registers;
begin
  Regs.DX := PortNum;
  Intr ($17, Regs);
  InitPort := Regs.AL;
  end;

Procedure OutStreamofStuff (PortNum : Byte; Where : PGraphics; Len : Word);
Var Count : Word; Regs : Registers;
begin
  Regs.DX := NumPort;
  For Count := 1 to Len do
      begin
        Regs.AL := ^Where[Count];
        end;
  end;

InitPort returns
   144 Printer OK
    24 Printer not OK
   184 Printer is off

