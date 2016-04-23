
This function will add commas to a longint.

function FormatNumber(l: longint): string;
var
  len, count: integer;
  s: string;
begin
  str(l, s);
  len := length(s);
  for count := ((len - 1) div 3) downto 1 do
    begin
      insert(',', s, len - (count * 3) + 1);
      len := len + 1;
    end;
  FormatNumber := s;
end;

And if you are using Delphi, there is, of course, the easy way:

function FormatNumber(l: longint): string;
begin
  FormatNumber := FormatFloat('#,##0', StrToFloat(IntToStr(l)));
end;

