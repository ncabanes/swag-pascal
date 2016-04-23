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