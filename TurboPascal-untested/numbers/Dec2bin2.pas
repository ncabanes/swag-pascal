(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0011.PAS
  Description: DEC2BIN2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{ True so here is another version of the process that returns a String : }

Program Dec2BinRec;

Type
  Str32 = String[32];

Function Dec2BinStr(aNumber : LongInt) : Str32;

  Function Bit(aBit : Byte) : Char;
  (* return either Char '0' or Char '1' *)
  begin
    if aBit = 0 then
      Bit := '0'
    else
      Bit := '1'
  end;

begin
  If aNumber = 0 Then
    Dec2BinStr := ''   (* done With recursion ?*)
  else                                (* convert high bits + last bit *)
    Dec2BinStr := Dec2BinStr(ANumber Div 2) + Bit(aNumber Mod 2);
end;

Var
  L : LongInt;
begin
  Repeat
    Readln (L);
    If L <> 0 then
      Writeln(Dec2BinStr(L));
  Until (L = 0)
end.

