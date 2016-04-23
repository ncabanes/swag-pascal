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