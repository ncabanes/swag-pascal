(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0002.PAS
  Description: Another Center Text
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:08
*)

{ Center Text }

Uses Crt;
Var
  s : String;
  i : Integer;
begin
  Write('String? ');
  readln(s);
  i := (succ(lo(windmax)) - length(s)) shr 1;
  gotoXY(i,10);
  Write(s);
end.

