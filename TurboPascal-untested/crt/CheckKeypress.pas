(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0007.PAS
  Description: Check KEYPRESS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:36
*)

{
To the person that posted the message about using KeyPressed or anyone
else interested. Below is a Function that I have used to read keyboard input
that is similiar to KeyPressed.  It does a KeyPressed and ReadKey all in one
statement.  If you are familiar With BASIC this InKey Function is similiar
to the one in BASIC in that is doesn't sit and wait For input.  The KeyEnh
Function just returns True/False depending on whether or not it detected
an Enhanced keyboard. SHIFT, CTRL, and ALT are global Boolean Variables
which value reflect the state of these keys involved in the the keypress.
}

Uses
  Dos;

Function KeyEnh:  Boolean;
Var
  Enh:  Byte Absolute $0040:$0096;

begin
  KeyEnh := False;
  if (Enh and $10) = $10 then
    KeyEnh := True;
end;

Function InKey(Var SCAN, ASCII:  Byte): Boolean;
Var
  i     :  Integer;
  Shift,
  Ctrl,
  Alt   : Boolean;
  Temp,
  Flag1 : Byte;
  HEXCH,
  HEXRD,
  HEXFL : Byte;
  reg   : Registers;

begin
  if KeyEnh then
  begin
    HEXCH := $11;
    HEXRD := $10;
    HEXFL := $12;
  end
  else
  begin
    HEXCH := $01;
    HEXRD := $00;
    HEXFL := $02;
  end;

  reg.ah := HEXCH;
  Intr($16, reg);
  i := reg.flags and FZero;

  reg.ah := HEXFL;
  Intr($16, reg);
  Flag1 := Reg.al;
  Temp  := Flag1 and $03;

  if Temp = 0 then
    SHIFT := False
  ELSE
    SHIFT := True;

  Temp  := Flag1 and $04;
  if Temp = 0 then
    CTRL := False
  ELSE
    CTRL := True;

  Temp  := Flag1 and $08;
  if Temp = 0 Then
    ALT  := False
  ELSE
    ALT  := True;

  if i = 0 then
  begin
    reg.ah := HEXRD;
    Intr($16, reg);
    scan  := reg.ah;
    ascii := reg.al;
    InKey := True;
  end
  else
    InKey := False;
end;


Var
  Hi, Hi2 : Byte;

begin
  Repeat Until InKey(Hi,Hi2);
  Writeln(Hi);
  Writeln(Hi2);
end.
