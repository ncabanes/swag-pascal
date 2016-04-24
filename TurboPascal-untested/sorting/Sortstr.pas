(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0029.PAS
  Description: SORT-STR.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
It gets better and better.  The Procedure below is incredibly fast in the
sorting of the Strings in the Arrays!  1.2 sec For 1485 Strings.
}

Procedure Sort(item : PFilearr; Last : Integer);
Var
  i, j : Integer;
  span : Integer;
begin
  item^[0] := newstr('                       ');
  span := Last shr 1;  {Span=Last/2}
  While span > 0 do
  begin
  For i := Span to Last - 1 do
  begin
    For j := (i - Span + 1) downto 1 do
    if item^[j]^ <= item^[j + Span]^ then
      j:=1   {to make it quit the j-loop}
    else
    begin {swap Array(j) With Array(j+Span)}
      item^[0] := item^[j];
      item^[j] := item^[j + Span];
      item^[j + Span] := item^[0];
    end;
  end;
  Span := Span shr 1; {Span=Span/2}
  end;
end;

