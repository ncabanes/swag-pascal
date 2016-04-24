(*
  Category: SWAG Title: JOYSTICK ROUTINES
  Original name: 0007.PAS
  Description: Joystick Manipulation
  Author: RICHARD GODBEE
  Date: 01-27-94  12:10
*)

{
> I'd like to use a joystick in a program but I'm not familiar
> with any algorithm to do that, suggestions?

Here's one I found lying around (public domain...<G>) on a local BBS... I
changed it around a little so it would fit in one message...  It compiled into
a .TPU okay, so it *probably* works.  Let me know if it doesn't... :)

--Ricky Godbee, Jr.
}

unit Joystick;
interface
uses Dos, Crt;
procedure JPos(Joystick_Number: byte; var Joystick_X, Joystick_Y: word);
procedure JBut(Joystick_Number: byte; var Button_1, Button_2: boolean);
implementation
var Register: Registers;
procedure InitRegisters;
begin
 FillChar(Register, Sizeof(Register), 0);
end;
procedure JPos(Joystick_Number: byte; var Joystick_X, Joystick_Y: word);
begin
 InitRegisters;
 Register.AH := $84;
 Register.DX := $01;
 Intr($15, Register);
 if Joystick_Number = 1 then
  begin
   Joystick_X := Register.AX;
   Joystick_Y := Register.BX;
  end
 else if Joystick_Number = 2 then
  begin
   Joystick_X := Register.CX;
   Joystick_Y := Register.DX;
  end;
end;
procedure JBut(Joystick_Number: byte; var Button_1, Button_2: boolean);
begin
 InitRegisters;
 Register.AH := $84;
 Register.DX := $00;
 Intr($15, Register);
 case Joystick_Number of
  1: begin
      Button_1 := (Register.AL and $20) <> $20;
      Button_2 := (Register.AL and $10) <> $10;
     end;
  2: begin
      Button_1 := (Register.AL and $40) <> $40;
      Button_2 := (Register.AL and $80) <> $80;
     end;
 end;
end;
end.

