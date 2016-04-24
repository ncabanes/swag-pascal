(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0354.PAS
  Description: Replacing substrings
  Author: MICHAEL BIALAS
  Date: 01-02-98  07:33
*)


From: michael@quinto.ruhr.de (Michael Bialas)

Does anyone know a fast algorithm that replaces all occurences of any
substring sub1 to any string sub2 in any string str.
This should do the job: 


--------------------------------------------------------------------------------

  function ReplaceSub(str, sub1, sub2: String): String;
  var
    aPos: Integer;
    rslt: String;
  begin
    aPos := Pos(sub1, str);
    rslt := '';
    while (aPos <> 0) do begin
      rslt := rslt + Copy(str, 1, aPos - 1) + sub2;
      Delete(str, 1, aPos + Length(sub1));
      aPos := Pos(sub1, str);
    end;
    Result := rslt + str;
  end;

