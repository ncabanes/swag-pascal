
var s: string;
begin
  FmtStr(s, '%.5d', [StrToInt(edit1.text)]);
  edit1.text := s;
end;
