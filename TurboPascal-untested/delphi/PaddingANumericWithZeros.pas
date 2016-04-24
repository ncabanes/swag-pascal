(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0161.PAS
  Description: Padding a numeric with zeros
  Author: SWAG SUPPORT TEAM
  Date: 08-30-96  09:35
*)


var s: string;
begin
  FmtStr(s, '%.5d', [StrToInt(edit1.text)]);
  edit1.text := s;
end;

