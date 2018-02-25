(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0008.PAS
  Description: ST-CASE2.PAS (Lowercase)
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:58
*)

Function DnCase(Ch: Char): Char;
Var
  n : Byte Absolute ch;
begin
  Case ch of
    'A'..'Z': n := n or 32;
  end;
  DnCase := chr(n);
end;

BEGIN
    Write( DnCase('A') );
END.
