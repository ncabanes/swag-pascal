(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0008.PAS
  Description: Get Keyboard CLICK
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{$M $800,0,0 }   { 2K stack, no heap }
{ This Program caUses a click each time
 a key is pressed.}
Uses Crt, Dos;
Var
  KbdIntVec : Procedure;
{$F+}
Procedure Keyclick; interrupt;
begin
  if Port[$60] < $80 then
    { Only click when key is pressed }
    begin
    Sound(5000);
    Delay(1);
    NoSound;
    end;
  Inline ($9C); { PUSHF -- Push flags }
  { Call old ISR using saved vector }
  KbdIntVec;
end;
{$F-}
begin
  { Insert ISR into keyboard chain }
  GetIntVec($9,@KbdIntVec);
  SetIntVec($9,Addr(Keyclick));
  Keep(0); { Terminate, stay resident }
  readln;
end.

{
Actually this works as long as you change the GETinTVEC line, where it says
@@KbdIntVec, it should be only one @, odd that borland would have an example
that didn't Compile. (It's a fine example, surprised myself too)
}
