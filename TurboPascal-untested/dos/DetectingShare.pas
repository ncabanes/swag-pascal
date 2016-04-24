(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0025.PAS
  Description: Detecting SHARE
  Author: LARS HELLSTEN
  Date: 08-27-93  21:57
*)

{
LARS HELLSTEN

> I would like to open a few Files in READ, DENY Write mode.  I can get the r
> part (just a reset), but not the DENY Write.  How can I accomplish this in
> Turbo Pascal Without locking specific Records or parts of Files, or the who
> File... or is that what is required?

You can accomplish that by changing the FileMODE Variable.  I
don't know if that's what you're looking for, or already know this,
but, here's a table of FileMODE values:
                                      Sharing Method
Access Method  Compatibility  Deny Write  Deny Read  Deny None
--------------------------------------------------------------
Read Only           0             32          48         64
Write Only          1             33          49         65
Read/Write          2             34          50         66
--------------------------------------------------------------

   So, as you can see, all you need to do is set the FileMODE to 32.  Just
put the satement "FileMode := 32;" in before you reset the File.  This will
only work With Dos' SHARE installed, or a compatible network BIOS.  if you
need a routine to detect SHARE, here's one:
}

Uses
  Dos;

Function ShareInstalled : Boolean;
Var
  Regs : Registers;
begin
  Regs.AH := $16;
  Regs.AL := $00;
  Intr($21, Regs);
  ShareInstalled := (Regs.AL = $FF);
end;

begin
  Writeln('Share: ', ShareInstalled);
end.
