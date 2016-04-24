(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0031.PAS
  Description: Using 101 Keys - F11/F12
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:41
*)

{  Return Extended keys for 101 Keyboard including F11/F12.
   If key is extended, the BOOLEAN = TRUE.  This is needed as Home key will
   return the same character value as 'G' }

USES DOS;

VAR Ch : Char;
    Ext : BOOLEAN;

function ExReadKey(VAR Extended : BOOLEAN) : char;
var Regs : registers;
begin
  Regs.AX := $1000;
  Intr($16,Regs);
  Extended := (Regs.AL = 0) OR (Regs.AL > 127);
  IF Extended THEN ExReadKey  := Chr(Regs.AH)
  ELSE ExReadKey := Chr(Regs.AL);
end;

function ReadKey : char;
{ This function adds 128 to char if it is extended }
var Regs : registers;
begin
  Regs.AX := $1000;
  Intr($16,Regs);
  IF (Regs.AL = 0) OR (Regs.AL > 127) THEN
  ReadKey  := Chr(Regs.AH + 128) ELSE ReadKey := Chr(Regs.AL);
end;

Begin
Repeat
ch := ReadKey;
WriteLn(ch,' ',Ext,' ',ORD(Ch));
Until Ch = #27;
END.
