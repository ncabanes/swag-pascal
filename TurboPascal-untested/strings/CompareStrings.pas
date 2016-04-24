(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0027.PAS
  Description: Compare Strings
  Author: SWAG SUPPORT TEAM
  Date: 08-27-93  20:27
*)

Function CompareStr(Str1, Str1 : String) : Boolean;
begin
  if (Length(Str1) = Length(Str2)) and (Pos(Str1, Str2) <> 0)) then
    CompareStr := True
  else
    CompareStr := False;
end;

Function CompareStrContext(Str1, Str2 : String) : Boolean;
begin
  CompareStrContext := CompareStr(StUpCase(Str1), StUpCase(Str2));
end;

